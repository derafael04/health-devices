// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/temporary/constants.dart';
import 'package:health_devices/src/temporary/util.dart';
import 'package:rxdart/rxdart.dart';

class DeviceController {
  DeviceController(this.device) : super() {
    init();
  }

  // UDS control point codes
  final int UDS_CP_REGISTER_NEW_USER = 0x01;
  final int UDS_CP_CONSENT = 0x02;
  final int UDS_CP_DELETE_USER_DATA = 0x03;
  final int UDS_CP_LIST_ALL_USERS = 0x04;
  final int UDS_CP_DELETE_USERS = 0x05;
  final int UDS_CP_RESPONSE = 0x20;

  // UDS response codes
  final int UDS_CP_RESP_VALUE_SUCCESS = 0x01;
  final int UDS_CP_RESP_OP_CODE_NOT_SUPPORTED = 0x02;
  final int UDS_CP_RESP_INVALID_PARAMETER = 0x03;
  final int UDS_CP_RESP_OPERATION_FAILED = 0x04;
  final int UDS_CP_RESP_USER_NOT_AUTHORIZED = 0x05;

  // Manufacturer Specific Services
  final Guid BF1000_CUSTOM_SERVICE = Guid('FFFF');

  // Manufacturer Specific Characteristics
  final Guid CHARACTERISTIC_SCALE_SETTINGS = Guid('0000');
  final Guid CHARACTERISTIC_USER_LIST = Guid('0001');
  final Guid CHARACTERISTIC_INITIALS = Guid('0002');
  final Guid CHARACTERISTIC_TARGET_WEIGHT = Guid('0003');
  final Guid CHARACTERISTIC_ACTIVITY_LEVEL = Guid('0004');
  final Guid CHARACTERISTIC_REFER_WEIGHT_BF = Guid('000B');
  final Guid CHARACTERISTIC_BT_MODULE = Guid('0005');
  final Guid CHARACTERISTIC_TAKE_MEASUREMENT = Guid('0006');
  final Guid CHARACTERISTIC_TAKE_GUEST_MEASUREMENT = Guid('0007');
  final Guid CHARACTERISTIC_BEURER_I = Guid('0008');
  final Guid CHARACTERISTIC_UPPER_LOWER_BODY = Guid('0008');
  final Guid CHARACTERISTIC_BEURER_II = Guid('0009');
  final Guid CHARACTERISTIC_BEURER_III = Guid('000A');
  final Guid CHARACTERISTIC_ADVEANCED_USER_SETTINGS = Guid('000C');
  final Guid CHARACTERISTIC_IMG_IDENTIFY = Guid('ffc1');
  final Guid CHARACTERISTIC_IMG_BLOCK = Guid('ffc2');

  final BluetoothDevice device;

  final ValueNotifier<bool> _isConnected = ValueNotifier(false);

  ValueNotifier<bool> get isConnected => _isConnected;

  StreamSubscription<BluetoothConnectionState>? _connectionState;

  // Streams
  StreamSubscription? weightSubscription;

  StreamSubscription? biaSubscription;

  StreamSubscription? bfSubscription;

  StreamSubscription? massSubscription;

  StreamSubscription? confirmationSubscription;

  StreamSubscription? _onServicesResetSubscription;

  final List<int> weight = [];

  final List<int> bia = [];

  final List<int> bf = [];

  final List<int> mass = [];

  ValueNotifier<WeightData> weightData = ValueNotifier(WeightData());

  ValueNotifier<BiaData> biaData = ValueNotifier(BiaData());

  ValueNotifier<BfData> bfData = ValueNotifier(BfData());

  ValueNotifier<MassData> massData = ValueNotifier(MassData());

  // ########################## CONNECT AND DISCONNECT METHODS ##########################
  List<BluetoothService?>? _discoveredServices;

  void connect() async {
    await device.connect();
    _discoveredServices = await device.discoverServices();
  }

  void disconnected() {
    device.disconnect();
  }

  // ########################## User Methods ##########################

  Future<List<UserData>?> listUsers() async {
    List<UserData> users = [];

    var userListCharacteristic = await getCharacteristic(
      serviceUuid: BF1000_CUSTOM_SERVICE,
      characteristicUuid: CHARACTERISTIC_USER_LIST,
    );

    await userListCharacteristic.setNotifyValue(true);

    userListCharacteristic.write([0x00]);

    await userListCharacteristic.onValueReceived
        .timeout(
      const Duration(seconds: 30),
      onTimeout: (sink) => [-0x01],
    )
        .doOnData((event) {
      if (event.length > 1) {
        users.add(UserData.fromBytes(event));
      }
    }).firstWhere(
      (event) => event.length == 1,
    );

    return users;
  }

  Future<void> selectUser(int index, int consentCode) async {
    assert(index >= 1 && index <= 10, 'Index must be between 1 and 10');
    assert(consentCode >= 0 && consentCode <= 9999, 'Consent code must be between 0 and 9999');

    final consentCodeBytes = ByteData(2)..setUint16(0, consentCode, Endian.little);
    var data = Uint8List.fromList([0x02, index, ...consentCodeBytes.buffer.asUint8List()]);

    await writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: data,
    );
  }

  Future<void> createUser({required int consentCode, required UserData userData}) async {
    assert(consentCode >= 0 && consentCode <= 9999, 'Consent code must be between 0 and 9999');
    assert(userData.birthYear != null, 'Birth year must not be null');
    assert(userData.birthMonth != null, 'Birth month must not be null');
    assert(userData.birthDay != null, 'Birth day must not be null');
    assert(userData.gender != null, 'Gender must not be null');
    assert(userData.heightInCm != null, 'Height must not be null');
    assert(userData.nickname != null, 'Nickname must not be null');
    assert(userData.activityLevel != null, 'Activity level must not be null');

    // Write birth date
    final birthDateBytes = ByteData(4)
      ..setUint16(0, userData.birthYear!, Endian.little)
      ..setUint8(2, userData.birthMonth!)
      ..setUint8(3, userData.birthDay!);

    await writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_DATE_OF_BIRTH,
      data: birthDateBytes.buffer.asUint8List(),
    );

    // Write Gender
    final int genderByte = userData.gender! == Gender.M ? 0x00 : 0x01;
    await writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_GENDER,
      data: [genderByte],
    );

    // Write Height
    final heightBytes = ByteData(2)..setUint16(0, userData.heightInCm!, Endian.little);
    await writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_HEIGHT,
      data: heightBytes.buffer.asUint8List(),
    );

    // Write Target Weight
    final weightBytes = ByteData(2)..setUint16(0, 63, Endian.little);
    await writeToCharacteristic(
      serviceUuid: BF1000_CUSTOM_SERVICE,
      characteristicUuid: CHARACTERISTIC_TARGET_WEIGHT,
      data: weightBytes.buffer.asUint8List(),
    );

    // Write activity level
    final activityLevelByte = userData.activityLevel!.index + 1;
    await writeToCharacteristic(
      serviceUuid: BF1000_CUSTOM_SERVICE,
      characteristicUuid: CHARACTERISTIC_ACTIVITY_LEVEL,
      data: [activityLevelByte],
    );

    // Write nickname
    final initials = userData.nickname!.padRight(3, 'F').toUpperCase().substring(0, 3).codeUnits;
    await writeToCharacteristic(
      serviceUuid: BF1000_CUSTOM_SERVICE,
      characteristicUuid: CHARACTERISTIC_INITIALS,
      data: initials.toList(),
    );

    // Increment Database
    await writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_CHANGE_INCREMENT,
      data: [0x01, 0x00, 0x00, 0x00, 0x00],
    );

    final consentCodeBytes = ByteData(2)..setUint16(0, consentCode, Endian.little);
    List<int> data = Uint8List.fromList([0x01, ...consentCodeBytes.buffer.asUint8List()]);
    await writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: data,
    );
  }

  Future<void> deleteUser(int index, int consentCode) async {
    assert(index >= 1 && index <= 10, 'Index must be between 1 and 10');
    assert(consentCode >= 0 && consentCode <= 9999, 'Consent code must be between 0 and 9999');

    await selectUser(index, consentCode);
    await writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: [0x03],
    );
  }

  void init() {
    _connectionState?.cancel();
    _connectionState = device.connectionState.listen((event) {
      if (event == BluetoothConnectionState.disconnected) {
        _isConnected.value = false;
      } else {
        _isConnected.value = true;
      }
    });

    _onServicesResetSubscription?.cancel();
    _onServicesResetSubscription = device.onServicesReset.listen((event) async {
      if (device.isConnected) {
        _discoveredServices = await device.discoverServices();
      }
    });
  }

  void dispose() {
    _connectionState?.cancel();
  }

  // ########################## Characteristic Methods ##########################

  Future<StreamSubscription<List<int>>> startListeningToCharacteristic({required Guid serviceUuid, required Guid characteristicUuid, void Function(List<int> data)? onData}) async {
    BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == serviceUuid);
    if (service == null) throw Exception('Service $serviceUuid not found');
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == characteristicUuid);
    if (characteristic == null) throw Exception('Characteristic $characteristicUuid not found');

    StreamSubscription<List<int>> subscription = characteristic.onValueReceived.listen(onData);

    device.cancelWhenDisconnected(subscription);

    await characteristic.setNotifyValue(true);

    return subscription;
  }

  Future<void> writeToCharacteristic({required serviceUuid, required characteristicUuid, required List<int> data}) async {
    BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == serviceUuid);
    if (service == null) throw Exception('Service $serviceUuid not found');
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == characteristicUuid);
    if (characteristic == null) throw Exception('Characteristic $characteristicUuid not found');

    return await characteristic.write(data);
  }

  Future<BluetoothCharacteristic> getCharacteristic({required serviceUuid, required characteristicUuid}) async {
    BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == serviceUuid);
    if (service == null) throw Exception('Service $serviceUuid not found');
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == characteristicUuid);
    if (characteristic == null) throw Exception('Characteristic $characteristicUuid not found');

    return characteristic;
  }

  Future<void> startBia() async {
    StreamSubscription<List<int>>? weightScaleCharacteristicSubscription;
    StreamSubscription<List<int>>? bodyCompositionCharacteristicSubscription;
    StreamSubscription<List<int>>? bfCharacteristicSubscription;
    StreamSubscription<List<int>>? massCharacteristicSubscription;
    List<int>? biaReturnValue;

    try {
      BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == Guid("FFFF"));
      if (service == null) throw Exception('Service FFFF not found');
      BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == Guid("0006"));
      if (characteristic == null) throw Exception('Characteristic 0006 not found');

      // Start listening to weight scale data
      weightScaleCharacteristicSubscription = await startListeningToCharacteristic(
        serviceUuid: Guid("181D"),
        characteristicUuid: Guid("2A9D"),
        onData: (event) {
          weight.addAll(event);
        },
      );

      // Start listening to body composition data
      bodyCompositionCharacteristicSubscription = await startListeningToCharacteristic(
        serviceUuid: Guid("181B"),
        characteristicUuid: Guid("2A9C"),
        onData: (event) {
          bia.addAll(event);
        },
      );

      // Start listening to bf data
      bfCharacteristicSubscription = await startListeningToCharacteristic(
        serviceUuid: Guid("FFFF"),
        characteristicUuid: Guid("0009"),
        onData: (event) {
          bf.addAll(event);
        },
      );

      // Start listening to mass data
      massCharacteristicSubscription = await startListeningToCharacteristic(
        serviceUuid: Guid("FFFF"),
        characteristicUuid: Guid("000a"),
        onData: (event) {
          mass.addAll(event);
        },
      );

      await characteristic.setNotifyValue(true);

      characteristic.write([0x00]);

      bool onValueReceivedFuture = await characteristic.onValueReceived
          .timeout(
            const Duration(seconds: 30),
            onTimeout: (sink) => [-0x01],
          )
          .take(1)
          .doOnData((event) {
        biaReturnValue = event;
      }).every((element) => element.length == 1 && element.first == 0x01);

      if (onValueReceivedFuture == true) {
        print('Event: $biaReturnValue');
        print('A Weight: $weight');
        print('A Bia: $bia');
        print('A BF: $bf');
        print('A Mass: $mass');
        weightData.value = parseWeightData(Uint8List.fromList(weight));
        biaData.value = parseBiaData(Uint8List.fromList(bia));
        bfData.value = parseBfData(Uint8List.fromList(bf));
        massData.value = parseMassData(Uint8List.fromList(mass));
      }
    } catch (e) {
      rethrow;
    } finally {
      weightScaleCharacteristicSubscription?.cancel();
      bodyCompositionCharacteristicSubscription?.cancel();
      bfCharacteristicSubscription?.cancel();
      massCharacteristicSubscription?.cancel();
    }
  }

  void fetchData() {
    weightData.value = parseWeightData(Uint8List.fromList(weight));
    biaData.value = parseBiaData(Uint8List.fromList(bia));
    bfData.value = parseBfData(Uint8List.fromList(bf));
    massData.value = parseMassData(Uint8List.fromList(mass));
  }
}

class UserData {
  UserData({
    this.index,
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.nickname,
    this.gender,
    this.heightInCm,
    this.activityLevel,
  });

  final int? index;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
  final String? nickname;
  final Gender? gender;
  final int? heightInCm;
  final ActivityLevel? activityLevel;

  @override
  String toString() {
    return 'UserData{birthYear: $birthYear, birthMonth: $birthMonth, birthDay: $birthDay, nickname: $nickname, gender: $gender, activityLevel: ${activityLevel?.index}}';
  }

  static fromBytes(List<int> bytes) {
    Uint8List intArray = Uint8List.fromList(bytes);
    ByteData byteData = intArray.buffer.asByteData();

    //index, nickname, year, month, day, height, gender, activity level
    int index = byteData.getUint8(1);
    String nickname = String.fromCharCodes([byteData.getUint8(2), byteData.getUint8(3), byteData.getUint8(4)]);
    int year = byteData.getUint16(5, Endian.little);
    int month = byteData.getUint8(7);
    int day = byteData.getUint8(8);
    int height = byteData.getUint8(9);
    int genderNumber = byteData.getUint8(10);
    Gender gender = genderNumber == 0 ? Gender.M : Gender.F;
    int activityLevelNumber = byteData.getUint8(11);
    ActivityLevel activityLevel = ActivityLevel.values[activityLevelNumber - 1];

    return UserData(
      birthYear: year,
      birthMonth: month,
      birthDay: day,
      nickname: nickname,
      activityLevel: activityLevel,
      gender: gender,
      heightInCm: height,
    );
  }
}

class WeightData {
  WeightData({
    this.weight,
    this.ano,
    this.mes,
    this.dia,
    this.hora,
    this.minuto,
    this.segundo,
    this.userIndex,
    this.imc,
    this.altura,
  });

  final double? weight;
  final int? ano;
  final int? mes;
  final int? dia;
  final int? hora;
  final int? minuto;
  final int? segundo;
  final int? userIndex;
  final double? imc;
  final double? altura;
}

// Bia data [flags] [ BF? ] [bmr? ] [%massa?] [soft lean mass] [Agua %] [impedancia]

class BiaData {
  BiaData({
    this.flags,
    this.bf,
    this.bmr,
    this.percentMass,
    this.softLeanMass,
    this.waterPercent,
    this.impedance,
  });

  final int? flags;
  final double? bf;
  final double? bmr;
  final double? percentMass;
  final double? softLeanMass;
  final double? waterPercent;
  final double? impedance;
}

class BfData {
  BfData({
    this.gordVisceral,
    this.bfBracoDireito,
    this.bfBracoEsquerdo,
    this.bfTronco,
    this.bfPernaDireita,
    this.bfPernaEsquerda,
  });

  final double? gordVisceral;
  final double? bfBracoDireito;
  final double? bfBracoEsquerdo;
  final double? bfTronco;
  final double? bfPernaDireita;
  final double? bfPernaEsquerda;
}

class MassData {
  MassData({
    this.massBracoDireito,
    this.massBracoEsquerdo,
    this.massTronco,
    this.massPernaDireita,
    this.massPernaEsquerda,
  });

  final double? massBracoDireito;
  final double? massBracoEsquerdo;
  final double? massTronco;
  final double? massPernaDireita;
  final double? massPernaEsquerda;
}

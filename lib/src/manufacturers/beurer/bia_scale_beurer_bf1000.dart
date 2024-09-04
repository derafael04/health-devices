// ignore_for_file: non_constant_identifier_names
part of '../../i_health_devices.dart';

class BIAScaleBeurerBf1000 extends IHealthDevice {
  BIAScaleBeurerBf1000({
    required String macAddress,
  })  : _macAddress = macAddress,
        _bleDriver = BLEDriver(macAddress: macAddress) {
    _userDataService = BleUserDataService(driver: _bleDriver);
  }

  static bool isDevice(ScanResult sr) {
    return sr.device.advName == 'BF1000' && sr.advertisementData.serviceUuids.contains(SERVICE_WEIGHT_SCALE);
  }

  @override
  Model get model => Model.BF_1000;

  @override
  String get id => macAddress;

  @override
  Brand get brand => Brand.BEURER;

  final String _macAddress;
  @override
  String? get name => _bleDriver.bluetoothDevice.advName;

  String get macAddress => _macAddress;

  static final Guid BF1000_CUSTOM_SERVICE = Guid('FFFF');
  static final Guid CHARACTERISTIC_SCALE_SETTINGS = Guid('0000');
  static final Guid CHARACTERISTIC_USER_LIST = Guid('0001');
  static final Guid CHARACTERISTIC_INITIALS = Guid('0002');
  static final Guid CHARACTERISTIC_TARGET_WEIGHT = Guid('0003');
  static final Guid CHARACTERISTIC_ACTIVITY_LEVEL = Guid('0004');
  static final Guid CHARACTERISTIC_REFER_WEIGHT_BF = Guid('000B');
  static final Guid CHARACTERISTIC_BT_MODULE = Guid('0005');
  static final Guid CHARACTERISTIC_TAKE_MEASUREMENT = Guid('0006');
  static final Guid CHARACTERISTIC_TAKE_GUEST_MEASUREMENT = Guid('0007');
  static final Guid CHARACTERISTIC_BEURER_I = Guid('0008');
  static final Guid CHARACTERISTIC_UPPER_LOWER_BODY = Guid('0008');
  static final Guid CHARACTERISTIC_BEURER_II = Guid('0009');
  static final Guid CHARACTERISTIC_BEURER_III = Guid('000A');
  static final Guid CHARACTERISTIC_ADVANCED_USER_SETTINGS = Guid('000C');
  static final Guid CHARACTERISTIC_IMG_IDENTIFY = Guid('ffc1');
  static final Guid CHARACTERISTIC_IMG_BLOCK = Guid('ffc2');

  final BLEDriver _bleDriver;
  late final BleUserDataService _userDataService;

  /// Starts the BIA (Bioelectrical Impedance Analysis) measurement on the Beurer BF1000 BIA scale.
  ///
  /// This method initiates the BIA measurement on the scale for the specified user index and consent code.
  /// It returns a [Future] that resolves to a [BeurerBiaData] object containing the measurement results.
  ///
  /// Parameters:
  /// - `userIndex`: The index of the user for whom the measurement is being started.
  /// - `consentCode`: The consent code required to start the measurement.
  ///
  /// Returns:
  /// A [Future] that resolves to a [BeurerBiaData] object containing the measurement results.
  Future<BeurerBiaData> startBia(int userIndex, int consentCode) async {
    StreamSubscription<List<int>>? weightScaleCharacteristicSubscription;
    StreamSubscription<List<int>>? bodyCompositionCharacteristicSubscription;
    StreamSubscription<List<int>>? bfCharacteristicSubscription;
    StreamSubscription<List<int>>? massCharacteristicSubscription;
    try {
      await selectUser(userIndex, consentCode);

      var biaControlPointCharacteristic = await _bleDriver.getCharacteristic(
        serviceUuid: BF1000_CUSTOM_SERVICE,
        characteristicUuid: CHARACTERISTIC_TAKE_MEASUREMENT,
      );

      // TODO: Find a way to name make that strategy simpler, so that we can only get the data as a future from the driver (maybe a finish callback to end the future)
      final List<int> weight = [];
      final List<int> bia = [];
      final List<int> bf = [];
      final List<int> mass = [];

      // Start listening to weight scale data
      weightScaleCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: Guid("181D"),
        characteristicUuid: Guid("2A9D"),
        onData: (event) {
          weight.addAll(event);
        },
      );

      // Start listening to body composition data
      bodyCompositionCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: Guid("181B"),
        characteristicUuid: Guid("2A9C"),
        onData: (event) {
          bia.addAll(event);
        },
      );

      // Start listening to bf data
      bfCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: Guid("FFFF"),
        characteristicUuid: Guid("0009"),
        onData: (event) {
          bf.addAll(event);
        },
      );

      // Start listening to mass data
      massCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: Guid("FFFF"),
        characteristicUuid: Guid("000a"),
        onData: (event) {
          mass.addAll(event);
        },
      );

      await biaControlPointCharacteristic.setNotifyValue(true);

      biaControlPointCharacteristic.write([0x00]);

      List<int> firstEvent = await biaControlPointCharacteristic.onValueReceived
          .timeout(
            const Duration(seconds: 30),
            onTimeout: (sink) => [-0x01],
          )
          .first;
      bool wasBiaSuccessful = firstEvent.length == 1 && firstEvent.first == 0x01;

      if (wasBiaSuccessful == true) {
        var weightScaleData = WeightScaleMeasurement.fromBytes(Uint8List.fromList(weight));
        var bodyCompositionData = BodyCompositionServiceData.fromBytes(Uint8List.fromList(bia));
        var bodyFatData = BeurerBodyFatData.fromBytes(Uint8List.fromList(bf));
        var skeletalMuscleMassData = BeurerSkeletalMuscleMassData.fromBytes(Uint8List.fromList(mass));
        return BeurerBiaData(
          bodyFatData: bodyFatData,
          skeletalMuscleMassData: skeletalMuscleMassData,
          bodyCompositionData: bodyCompositionData,
          weightScaleData: weightScaleData,
        );
      } else {
        throw Exception('BIA measurement failed');
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

  /// Starts a BIA measurement as a guest user.
  ///
  /// This method is not implemented and will throw an [UnimplementedError].
  Future<Stream<bool>> startBIAAsGuest(BeurerUserData userData) => throw UnimplementedError();

  /// Stops any ongoing BIA measurement
  ///
  /// This method is not implemented and will throw an [UnimplementedError].
  Future<void> stopBIA() => throw UnimplementedError();

  Future<void> connect() => _bleDriver.connect();
  Future<void> disconnect() => _bleDriver.disconnect();
  Future<void> selectUser(int userIndex, int consentCode) => _userDataService.selectUser(userIndex, consentCode);
  Future<void> deleteUser(int userIndex, int consentCode) => _userDataService.deleteUser(userIndex, consentCode);
  Future<void> createUser(int consentCode, BeurerUserData userData) async {
    var futures = [
      _writeBF1000ActivityLevel(userData.activityLevel!),
      _writeBF1000Nickname(userData.nickname!),
      _writeBF1000TargetWeight(userData.targetWeight!),
      _userDataService.writeHeight(userData.heightInCm!),
      _userDataService.writeUserBirthDate(userData.birthDate!),
      _userDataService.writeUserGender(userData.gender == BeurerGender.M ? Gender.MALE : Gender.FEMALE),
    ];
    await Future.wait(futures);
    return _userDataService.saveCurrentDataAsNewUser(consentCode);
  }

  Future<List<BeurerUserData>?> listUsers() async {
    List<BeurerUserData> users = [];

    var userListCharacteristic = await _bleDriver.getCharacteristic(
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
        users.add(BeurerUserData.fromBytes(event));
      }
    }).firstWhere(
      (event) => event.length == 1,
    );

    return users;
  }

  Future<void> _writeBF1000TargetWeight(int targetWeight) async {
    var weightBytes = ByteDataUtils.fromInt(targetWeight).reverse.suffix(2);
    await _bleDriver.writeToCharacteristic(
      serviceUuid: BF1000_CUSTOM_SERVICE,
      characteristicUuid: CHARACTERISTIC_TARGET_WEIGHT,
      data: weightBytes,
    );
  }

  Future<void> _writeBF1000ActivityLevel(BeurerActivityLevel activityLevel) async {
    final activityLevelByte = activityLevel.code;
    await _bleDriver.writeToCharacteristic(
      serviceUuid: BF1000_CUSTOM_SERVICE,
      characteristicUuid: CHARACTERISTIC_ACTIVITY_LEVEL,
      data: [activityLevelByte],
    );
  }

  Future<void> _writeBF1000Nickname(String nickname) async {
    final initials = nickname.padRight(3, 'F').toUpperCase().substring(0, 3).codeUnits;
    await _bleDriver.writeToCharacteristic(
      serviceUuid: BF1000_CUSTOM_SERVICE,
      characteristicUuid: CHARACTERISTIC_INITIALS,
      data: initials,
    );
  }
}
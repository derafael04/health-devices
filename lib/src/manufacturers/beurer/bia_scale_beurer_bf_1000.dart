// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/manufacturers/beurer/beurer_b_f1000_user_data.dart';
import 'package:health_devices/src/services/bluetooth/ble_driver.dart';
import 'package:health_devices/src/services/bluetooth/ble_user_data_services.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_characteristics.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_services.dart';
import 'package:rxdart/rxdart.dart';

import '../../all_enums.dart';
import '../../i_health_device.dart';

class BIAScaleBeurerBf1000 extends IHealthDevice {
  BIAScaleBeurerBf1000({
    required this.macAddress,
  }) : _bleDriver = BLEDriver(macAddress: macAddress) {
    _userDataServices = BleUserDataServices(driver: _bleDriver);
  }

  @override
  Model get model => Model.BF_1000;

  @override
  String get id => macAddress;

  @override
  Brand get brand => Brand.BEURER;

  String macAddress;

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
  late final BleUserDataServices _userDataServices;

  /// Starts the BIA measurement for the user with the given index
  Future<void> startBia() async {
    StreamSubscription<List<int>>? weightScaleCharacteristicSubscription;
    StreamSubscription<List<int>>? bodyCompositionCharacteristicSubscription;
    StreamSubscription<List<int>>? bfCharacteristicSubscription;
    StreamSubscription<List<int>>? massCharacteristicSubscription;
    List<int>? biaReturnValue;
    List<int> weight = [];
    List<int> bia = [];
    List<int> bf = [];
    List<int> mass = [];

    try {
      var characteristic = await _bleDriver.getCharacteristic(serviceUuid: BF1000_CUSTOM_SERVICE, characteristicUuid: CHARACTERISTIC_TAKE_MEASUREMENT);

      // Start listening to weight scale data
      weightScaleCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: SERVICE_WEIGHT_SCALE,
        characteristicUuid: CHARACTERISTIC_WEIGHT_MEASUREMENT,
        onData: (event) {
          weight.addAll(event);
        },
      );

      // Start listening to body composition data
      bodyCompositionCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: SERVICE_BODY_COMPOSITION,
        characteristicUuid: CHARACTERISTIC_BODY_COMPOSITION_MEASUREMENT,
        onData: (event) {
          bia.addAll(event);
        },
      );

      // Start listening to bf data
      bfCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: BF1000_CUSTOM_SERVICE,
        characteristicUuid: CHARACTERISTIC_BEURER_II,
        onData: (event) {
          bf.addAll(event);
        },
      );

      // Start listening to mass data
      massCharacteristicSubscription = await _bleDriver.startListeningToCharacteristic(
        serviceUuid: BF1000_CUSTOM_SERVICE,
        characteristicUuid: CHARACTERISTIC_BEURER_III,
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
        // weightData.value = parseWeightData(Uint8List.fromList(weight));
        // biaData.value = parseBiaData(Uint8List.fromList(bia));
        // bfData.value = parseBfData(Uint8List.fromList(bf));
        // massData.value = parseMassData(Uint8List.fromList(mass));
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

  Future<Stream<bool>> startBIAAsGuest(BeurerBF1000UserData userData) => throw UnimplementedError();

  /// Stops any ongoing BIA measurement
  Future<void> stopBIA() => throw UnimplementedError();

  /// Connects to the device and do any necessary procedures to start the BIA measurement
  /// - Update the scale clock
  Future<void> connect() => _bleDriver.connect();
  Future<void> disconnect() => _bleDriver.disconnect();
  Future<void> selectUser(int userIndex, int consentCode) => _userDataServices.selectUser(userIndex, consentCode);
  Future<void> deleteUser(int userIndex, int consentCode) => _userDataServices.deleteUser(userIndex, consentCode);
  Future<void> updateUser(int userIndex, int consentCode, BeurerBF1000UserData userData) => _userDataServices.updateUser(userIndex, consentCode, userData.toBytes());
  Future<Stream<BeurerBF1000UserData>> getUser(int userIndex) => throw UnimplementedError();

  Future<List<BeurerBF1000UserData>?> listUsers() async {
    List<BeurerBF1000UserData> users = [];

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
        users.add(BeurerBF1000UserData.fromBytes(event));
      }
    }).firstWhere(
      (event) => event.length == 1,
    );

    return users;
  }
}

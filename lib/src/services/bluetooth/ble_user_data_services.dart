import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/services/bluetooth/ble_driver.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_characteristics.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_services.dart';

class BleUserDataServices {
  static final Guid serviceGUID = SERVICE_USER_DATA;
  BLEDriver _driver;

  BleUserDataServices({
    required BLEDriver driver,
  }) : _driver = driver;

  Future<void> selectUser(int userIndex, int consentCode) async {
    final consentCodeBytes = ByteData(2)..setUint16(0, consentCode, Endian.little);
    var data = Uint8List.fromList([0x02, userIndex, ...consentCodeBytes.buffer.asUint8List()]);

    await _driver.writeToCharacteristic(
      serviceUuid: serviceGUID,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: data,
    );
  }

  Future<void> deleteUser(int userIndex, int consentCode) async {
    await selectUser(userIndex, consentCode);
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: [0x03],
    );
  }

  Future<void> updateUser(int userIndex, int consentCode, List<int> userData) async {
    await selectUser(userIndex, consentCode);
    var data = Uint8List.fromList([0x01, ...userData]);
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: data,
    );
  }

}

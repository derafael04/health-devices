// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_driver.dart';

class BleDeviceInformationService {
  final BLEDriver _driver;

  BleDeviceInformationService({
    required BLEDriver driver,
  }) : _driver = driver;

  static final Guid DEVICE_INFORMATION_SERVICE = Guid('180A');
  static final Guid MANUFACTURER_NAME_STRING = Guid('2A29');
  static final Guid MODEL_NUMBER_STRING = Guid('2A24');
  static final Guid SERIAL_NUMBER_STRING = Guid('2A25');
  static final Guid HARDWARE_REVISION_STRING = Guid('2A27');
  static final Guid FIRMWARE_REVISION_STRING = Guid('2A26');
  static final Guid SOFTWARE_REVISION_STRING = Guid('2A28');
  static final Guid SYSTEM_ID = Guid('2A23');
  static final Guid IEEE_11073_20601_REGULATORY_CERTIFICATION_DATA_LIST = Guid('2A2A');
  static final Guid PNP_ID = Guid('2A50');

  Future<String> getManufacturerName() => _driver
      .readCharacteristic(
        characteristicUuid: MANUFACTURER_NAME_STRING,
        serviceUuid: DEVICE_INFORMATION_SERVICE,
      )
      .then((data) => String.fromCharCodes(data));

  Future<String> getModelNumber() => _driver
      .readCharacteristic(
        characteristicUuid: MODEL_NUMBER_STRING,
        serviceUuid: DEVICE_INFORMATION_SERVICE,
      )
      .then((data) => String.fromCharCodes(data));

  Future<String> getSerialNumber() => _driver
      .readCharacteristic(
        characteristicUuid: SERIAL_NUMBER_STRING,
        serviceUuid: DEVICE_INFORMATION_SERVICE,
      )
      .then((data) => String.fromCharCodes(data));

  Future<String> getHardwareRevision() => _driver
      .readCharacteristic(
        characteristicUuid: HARDWARE_REVISION_STRING,
        serviceUuid: DEVICE_INFORMATION_SERVICE,
      )
      .then((data) => String.fromCharCodes(data));

  Future<String> getFirmwareRevision() => _driver
      .readCharacteristic(
        characteristicUuid: FIRMWARE_REVISION_STRING,
        serviceUuid: DEVICE_INFORMATION_SERVICE,
      )
      .then((data) => String.fromCharCodes(data));

  Future<String> getSoftwareRevision() => _driver
      .readCharacteristic(
        characteristicUuid: SOFTWARE_REVISION_STRING,
        serviceUuid: DEVICE_INFORMATION_SERVICE,
      )
      .then((data) => String.fromCharCodes(data));

  // Future<SystemID> getSystemID() => _driver
  //     .readCharacteristic(
  //       characteristicUuid: SYSTEM_ID,
  //       serviceUuid: DEVICE_INFORMATION_SERVICE,
  //     )
  //     .then((data) => SystemID.fromBytes(data));
}

enum VendorIDSourceField {
  BLUETOOTH_SIG(1),
  USB_FORUM(2);

  const VendorIDSourceField(this.code);
  static VendorIDSourceField fromCode(int code) {
    switch (code) {
      case 0:
        return VendorIDSourceField.BLUETOOTH_SIG;
      case 1:
        return VendorIDSourceField.USB_FORUM;
      default:
        return VendorIDSourceField.BLUETOOTH_SIG;
    }
  }

  final int code;
}

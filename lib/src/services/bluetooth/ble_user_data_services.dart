import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../common_enums.dart';
import '../../byte_data_extension.dart';
import '../../utils/utils.dart';
import 'ble_driver.dart';
import 'bluetooth_characteristics.dart';
import 'bluetooth_services.dart';

class BleUserDataService {
  static final Guid serviceGUID = SERVICE_USER_DATA;
  BLEDriver _driver;

  BleUserDataService({
    required BLEDriver driver,
  }) : _driver = driver;

  _validateUserIndex(int index) {
    if (index < 1 || index > 10) throw Exception('User index must be between 1 and 10');
  }

  _validateConsentCode(int consentCode) {
    if (consentCode < 0 || consentCode > 9999) throw Exception('Consent code must be between 0 and 9999');
  }

  Future<void> selectUser(int userIndex, int consentCode) async {
    _validateConsentCode(consentCode);
    _validateUserIndex(userIndex);

    final consentCodeBytes = ByteData(2)..setUint16(0, consentCode, Endian.little);
    var data = Uint8List.fromList([0x02, userIndex, ...consentCodeBytes.buffer.asUint8List()]);

    await _driver.writeToCharacteristic(
      serviceUuid: serviceGUID,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: data,
    );
  }

  Future<void> deleteUser(int userIndex, int consentCode) async {
    _validateConsentCode(consentCode);
    _validateUserIndex(userIndex);

    await selectUser(userIndex, consentCode);
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: [0x03],
    );
  }

  Future<void> saveCurrentDataAsNewUser(int consentCode) async {
    _validateConsentCode(consentCode);

    final consentCodeBytes = ByteDataUtils.fromInt(consentCode).prefix(2);
    List<int> data = Uint8List.fromList([0x01, ...consentCodeBytes]);
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_CONTROL_POINT,
      data: data,
    );
  }

  Future<void> writeHeight(int heightInCm) async {
    var heightBytes = ByteDataUtils.fromInt(heightInCm).reverse.suffix(2);
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_HEIGHT,
      data: heightBytes,
    );
  }

  Future<void> writeUserGender(Gender gender) async {
    final int genderByte = gender == Gender.MALE ? 0x00 : 0x01;
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_GENDER,
      data: [genderByte],
    );
  }

  Future<void> incrementUserChangeCount() async {
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_CHANGE_INCREMENT,
      data: [0x01, 0x00, 0x00, 0x00, 0x00],
    );
  }

  Future<void> writeUserBirthDate(DateTime birthDate) async {
    final birthDateBytes = getBirthDateBytes(birthDate);
    await _driver.writeToCharacteristic(
      serviceUuid: SERVICE_USER_DATA,
      characteristicUuid: CHARACTERISTIC_USER_DATE_OF_BIRTH,
      data: birthDateBytes.buffer.asUint8List(),
    );
  }
}
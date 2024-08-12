// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// https://www.bluetooth.com/specifications/gatt/services
final Guid SERVICE_BODY_COMPOSITION = Guid("181b");
final Guid SERVICE_DEVICE_INFORMATION = Guid("180a");
final Guid SERVICE_GENERIC_ACCESS = Guid("1800");
final Guid SERVICE_GENERIC_ATTRIBUTE = Guid("1801");
final Guid SERVICE_WEIGHT_SCALE = Guid("181d");
final Guid SERVICE_CURRENT_TIME = Guid("1805");
final Guid SERVICE_USER_DATA = Guid("181C");
final Guid SERVICE_BATTERY_LEVEL = Guid("180F");

// https://www.bluetooth.com/specifications/gatt/characteristics
final Guid CHARACTERISTIC_APPEARANCE = Guid("2a01");
final Guid CHARACTERISTIC_BODY_COMPOSITION_MEASUREMENT = Guid("2a9c");
final Guid CHARACTERISTIC_CURRENT_TIME = Guid("2a2b");
final Guid CHARACTERISTIC_DEVICE_NAME = Guid("2a00");
final Guid CHARACTERISTIC_FIRMWARE_REVISION_STRING = Guid("2a26");
final Guid CHARACTERISTIC_HARDWARE_REVISION_STRING = Guid("2a27");
final Guid CHARACTERISTIC_IEEE_11073_20601_REGULATORY_CERTIFICATION_DATA_LIST = Guid("2a2a");
final Guid CHARACTERISTIC_MANUFACTURER_NAME_STRING = Guid("2a29");
final Guid CHARACTERISTIC_MODEL_NUMBER_STRING = Guid("2a24");
final Guid CHARACTERISTIC_PERIPHERAL_PREFERRED_CONNECTION_PARAMETERS = Guid("2a04");
final Guid CHARACTERISTIC_PERIPHERAL_PRIVACY_FLAG = Guid("2a02");
final Guid CHARACTERISTIC_PNP_ID = Guid("2a50");
final Guid CHARACTERISTIC_RECONNECTION_ADDRESS = Guid("2a03");
final Guid CHARACTERISTIC_SERIAL_NUMBER_STRING = Guid("2a25");
final Guid CHARACTERISTIC_SERVICE_CHANGED = Guid("2a05");
final Guid CHARACTERISTIC_SOFTWARE_REVISION_STRING = Guid("2a28");
final Guid CHARACTERISTIC_SYSTEM_ID = Guid("2a23");
final Guid CHARACTERISTIC_WEIGHT_MEASUREMENT = Guid("2a9d");
final Guid CHARACTERISTIC_BATTERY_LEVEL = Guid("2A19");
final Guid CHARACTERISTIC_CHANGE_INCREMENT = Guid("2a99");
final Guid CHARACTERISTIC_USER_CONTROL_POINT = Guid("2A9F");
final Guid CHARACTERISTIC_USER_AGE = Guid("2A80");
final Guid CHARACTERISTIC_USER_DATE_OF_BIRTH = Guid("2A85");
final Guid CHARACTERISTIC_USER_GENDER = Guid("2A8C");
final Guid CHARACTERISTIC_USER_HEIGHT = Guid("2A8E");

enum ActivityLevel {
  SEDENTARY,
  LIGHTLY_ACTIVE,
  MODERATELY_ACTIVE,
  VERY_ACTIVE,
  SUPER_ACTIVE
}

enum Gender {
  M,
  F
}
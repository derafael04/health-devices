library health_devices;

import 'package:health_devices/health_devices.dart';
import 'package:health_devices/src/brand_enum.dart';
import 'package:health_devices/src/model_enum.dart';

import 'common_enums.dart';
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/byte_data_extension.dart';
import 'package:health_devices/src/manufacturers/beurer/beurer_body_fat_data.dart';
import 'package:health_devices/src/manufacturers/beurer/beurer_body_mass_data.dart';
import 'package:health_devices/src/manufacturers/beurer/beurer_user_data.dart';
import 'package:health_devices/src/services/bluetooth/ble_driver.dart';
import 'package:health_devices/src/services/bluetooth/ble_user_data_services.dart';
import 'package:rxdart/rxdart.dart';

import 'manufacturers/beurer/beurer_bia_data.dart';
import 'services/bluetooth/ble_body_composition_service.dart';
import 'services/bluetooth/ble_weight_scale_service.dart';
import 'services/bluetooth/bluetooth_services.dart';

part 'manufacturers/beurer/bia_scale_beurer_bf1000.dart';
part 'manufacturers/coospo/heart_rate_monitor_coospo_hw_807.dart';

sealed class IHealthDevice {
  String get id;
  Brand? get brand;
  Model? get model;
  String? get name;

  HealthDeviceIdentifier getIdentifier(ConnectionType c) => (
        id: id,
        brand: brand,
        model: model,
        connectionType: c,
      );
}

class UnknownHealthDevice extends IHealthDevice {
  UnknownHealthDevice({
    required this.id,
    this.brand,
    this.model,
    this.connectionType,
    this.name,
  });

  ConnectionType? connectionType;
  @override
  final String id;
  @override
  final Brand? brand;
  @override
  final Model? model;
  @override
  String? name;

  HealthDeviceIdentifier? get identifier => connectionType == null ? null : getIdentifier(connectionType!);
}

typedef HealthDeviceIdentifier = ({
  String id,
  Brand? brand,
  Model? model,
  ConnectionType connectionType,
});

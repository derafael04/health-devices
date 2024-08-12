import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/services/bluetooth/ble_driver.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_services.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_struct_interface.dart';

import 'bluetooth_characteristics.dart';

class BleBodyCompositionService {
  BleBodyCompositionService({
    required BLEDriver driver,
  }) : _driver = driver;

  BLEDriver _driver;

  static final Guid serviceGUID = SERVICE_BODY_COMPOSITION;
  static final Guid measurementCharacteristic = CHARACTERISTIC_BODY_COMPOSITION_MEASUREMENT;

  Future<BodyCompositionServiceData> getMeasurement() => _driver
      .readCharacteristic(
        characteristicUuid: measurementCharacteristic,
        serviceUuid: serviceGUID,
      )
      .then((data) => BodyCompositionServiceData.fromBytes(data));
}

class BodyCompositionServiceData extends BluetoothStructInterface<BodyCompositionServiceData> {
  BodyCompositionServiceData({
    this.flags,
    this.bodyFat,
    this.basalMetabolicRate,
    this.percentMass,
    this.softLeanMass,
    this.waterPercent,
    this.impedance,
  });

  final int? flags;
  final double? bodyFat;
  final double? basalMetabolicRate;
  final double? percentMass;
  final double? softLeanMass;
  final double? waterPercent;
  final double? impedance;

  factory BodyCompositionServiceData.fromBytes(List<int> bytes) {
    final byteData = Uint8List.fromList(bytes).buffer.asByteData();

    if (byteData.lengthInBytes < 14) {
      return BodyCompositionServiceData();
    }

    final flags = byteData.getUint16(0, Endian.little);
    final bodyFat = byteData.getUint16(2, Endian.little) / 10.0;
    final basalMetabolicRate = byteData.getUint16(4, Endian.little) / 4.184;
    final percentMass = byteData.getUint16(6, Endian.little) / 10.0;
    final softLeanMass = byteData.getUint16(8, Endian.little) / 10.0;
    final waterPercent = byteData.getUint16(10, Endian.little) / 10.0;
    final impedance = byteData.getUint16(12, Endian.little) / 10.0;

    return BodyCompositionServiceData(
      flags: flags,
      bodyFat: bodyFat,
      basalMetabolicRate: basalMetabolicRate,
      percentMass: percentMass,
      softLeanMass: softLeanMass,
      waterPercent: waterPercent,
      impedance: impedance,
    );
  }

  @override
  fromBytes(List<int> bytes) => BodyCompositionServiceData.fromBytes(bytes);

  @override
  List<int> toBytes() {
    final byteData = ByteData(14);
    byteData.setUint16(0, flags ?? 0, Endian.little);
    byteData.setUint16(2, ((bodyFat ?? 0) * 10).toInt(), Endian.little);
    byteData.setUint16(4, ((basalMetabolicRate ?? 0) * 4.184).toInt(), Endian.little);
    byteData.setUint16(6, ((percentMass ?? 0) * 10).toInt(), Endian.little);
    byteData.setUint16(8, ((softLeanMass ?? 0) * 10).toInt(), Endian.little);
    byteData.setUint16(10, ((waterPercent ?? 0) * 10).toInt(), Endian.little);
    byteData.setUint16(12, ((impedance ?? 0) * 10).toInt(), Endian.little);

    return byteData.buffer.asUint8List();
  }
}

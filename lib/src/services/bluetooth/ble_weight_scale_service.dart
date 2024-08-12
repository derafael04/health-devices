import 'dart:typed_data';

import 'package:health_devices/src/services/bluetooth/ble_driver.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_struct_interface.dart';

import 'bluetooth_characteristics.dart';
import 'bluetooth_services.dart';

class BleWeightScaleService {
  BleWeightScaleService({
    required BLEDriver driver,
  }) : _driver = driver;

  BLEDriver _driver;

  static final serviceGUID = SERVICE_WEIGHT_SCALE;
  static final measurementCharacteristic = CHARACTERISTIC_WEIGHT_MEASUREMENT;

  Future<WeightScaleMeasurement> getMeasurement() => _driver
      .readCharacteristic(
        characteristicUuid: measurementCharacteristic,
        serviceUuid: serviceGUID,
      )
      .then((data) => WeightScaleMeasurement.fromBytes(data));
}
class WeightScaleMeasurement implements BluetoothStructInterface<WeightScaleMeasurement> {
  final double? weight;
  final DateTime? time;
  final int? userIndex;
  final double? imc;
  final double? height;

  WeightScaleMeasurement({
    this.weight,
    this.time,
    this.userIndex,
    this.imc,
    this.height,
  });

  factory WeightScaleMeasurement.fromBytes(List<int> bytes) {
    final byteData = Uint8List.fromList(bytes).buffer.asByteData();

    if (byteData.lengthInBytes < 15) {
      return WeightScaleMeasurement();
    }

    //TODO: Deal with different precisions
    final weight = byteData.getUint16(1, Endian.little) / 200.0;
    final year = byteData.getUint16(3, Endian.little);
    final month = byteData.getUint8(5);
    final day = byteData.getUint8(6);
    final hour = byteData.getUint8(7);
    final minute = byteData.getUint8(8);
    final second = byteData.getUint8(9);
    final userIndex = byteData.getUint8(10);
    final imc = byteData.getUint16(11, Endian.little) / 10.0;
    final height = byteData.getUint16(13, Endian.little) / 10.0;

    return WeightScaleMeasurement(
      weight: weight,
      time: DateTime(year, month, day, hour, minute, second),
      userIndex: userIndex,
      imc: imc,
      height: height,
    );
  }

  @override
  List<int> toBytes() {
    final byteData = ByteData(15);

    //TODO: Define a way to better represent this structure (like what we learn in Assembly)
    byteData.setUint8(0, 0x1d);
    byteData.setUint16(1, (weight! * 200).round(), Endian.little);
    byteData.setUint16(3, time!.year, Endian.little);
    byteData.setUint8(5, time!.month);
    byteData.setUint8(6, time!.day);
    byteData.setUint8(7, time!.hour);
    byteData.setUint8(8, time!.minute);
    byteData.setUint8(9, time!.second);
    byteData.setUint8(10, userIndex!);
    byteData.setUint16(11, (imc! * 10).round(), Endian.little);
    byteData.setUint16(13, (height! * 10).round(), Endian.little);
    return byteData.buffer.asUint8List();
  }

  @override
  WeightScaleMeasurement fromBytes(List<int> bytes) => WeightScaleMeasurement.fromBytes(bytes);
}

import 'dart:typed_data';

import 'package:health_devices/src/services/bluetooth/bluetooth_struct_interface.dart';

class BeurerBodyFatData implements BluetoothStructInterface<BeurerBodyFatData> {
  const BeurerBodyFatData({
    this.visceralFatPercentage,
    this.rightArmFatPercentage,
    this.leftArmFatPercentage,
    this.trunkFatPercentage,
    this.rightLegFatPercentage,
    this.leftLegFatPercentage,
  });
  final double? visceralFatPercentage;
  final double? rightArmFatPercentage;
  final double? leftArmFatPercentage;
  final double? trunkFatPercentage;
  final double? rightLegFatPercentage;
  final double? leftLegFatPercentage;

  factory BeurerBodyFatData.fromBytes(List<int> bytes) {
    final byteData = Uint8List.fromList(bytes).buffer.asByteData();

    if (byteData.lengthInBytes < 12) {
      return const BeurerBodyFatData();
    }

    final visceralFat = byteData.getUint16(0, Endian.little) / 1.0;
    final rightArmFat = byteData.getUint16(2, Endian.little) / 10.0;
    final leftArmFat = byteData.getUint16(4, Endian.little) / 10.0;
    final trunkFat = byteData.getUint16(6, Endian.little) / 10.0;
    final rightLegFat = byteData.getUint16(8, Endian.little) / 10.0;
    final leftLegFat = byteData.getUint16(10, Endian.little) / 10.0;

    return BeurerBodyFatData(
      visceralFatPercentage: visceralFat,
      rightArmFatPercentage: rightArmFat,
      leftArmFatPercentage: leftArmFat,
      trunkFatPercentage: trunkFat,
      rightLegFatPercentage: rightLegFat,
      leftLegFatPercentage: leftLegFat,
    );
  }

  @override
  fromBytes(List<int> bytes) => BeurerBodyFatData.fromBytes(bytes);

  @override
  List<int> toBytes() {
    var byteData = ByteData(12);
    byteData.setUint16(0, (visceralFatPercentage ?? 0).toInt() * 1, Endian.little);
    byteData.setUint16(2, (rightArmFatPercentage ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(4, (leftArmFatPercentage ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(6, (trunkFatPercentage ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(8, (rightLegFatPercentage ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(10, (leftLegFatPercentage ?? 0).toInt() * 10, Endian.little);
    return byteData.buffer.asUint8List();
  }
}

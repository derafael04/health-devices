import 'dart:typed_data';

import 'package:health_devices/src/services/bluetooth/bluetooth_struct_interface.dart';

class BeurerSkeletalMuscleMassData implements BluetoothStructInterface<BeurerSkeletalMuscleMassData> {
  const BeurerSkeletalMuscleMassData({
    this.rightArmSkeletalMuscleMass,
    this.leftArmSkeletalMuscleMass,
    this.trunkSkeletalMuscleMass,
    this.rightLegSkeletalMuscleMass,
    this.leftLegSkeletalMuscleMass,
  });

  final double? rightArmSkeletalMuscleMass;
  final double? leftArmSkeletalMuscleMass;
  final double? trunkSkeletalMuscleMass;
  final double? rightLegSkeletalMuscleMass;
  final double? leftLegSkeletalMuscleMass;

  factory BeurerSkeletalMuscleMassData.fromBytes(List<int> bytes) {
    final byteData = Uint8List.fromList(bytes).buffer.asByteData();

    if (byteData.lengthInBytes < 11) {
      return const BeurerSkeletalMuscleMassData();
    }

    final rightArmMass = byteData.getUint16(1, Endian.little) / 10.0;
    final leftArmMass = byteData.getUint16(3, Endian.little) / 10.0;
    final trunkMass = byteData.getUint16(5, Endian.little) / 10.0;
    final rightLegMass = byteData.getUint16(7, Endian.little) / 10.0;
    final leftLegMass = byteData.getUint16(9, Endian.little) / 10.0;

    return BeurerSkeletalMuscleMassData(
      rightArmSkeletalMuscleMass: rightArmMass,
      leftArmSkeletalMuscleMass: leftArmMass,
      trunkSkeletalMuscleMass: trunkMass,
      rightLegSkeletalMuscleMass: rightLegMass,
      leftLegSkeletalMuscleMass: leftLegMass,
    );
  }

  @override
  BeurerSkeletalMuscleMassData fromBytes(List<int> bytes) => BeurerSkeletalMuscleMassData.fromBytes(bytes);

  @override
  List<int> toBytes() {
    var byteData = ByteData(11);
    byteData.setUint16(0, 0, Endian.little);
    byteData.setUint16(1, (rightArmSkeletalMuscleMass ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(3, (leftArmSkeletalMuscleMass ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(5, (trunkSkeletalMuscleMass ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(7, (rightLegSkeletalMuscleMass ?? 0).toInt() * 10, Endian.little);
    byteData.setUint16(9, (leftLegSkeletalMuscleMass ?? 0).toInt() * 10, Endian.little);
    return byteData.buffer.asUint8List();
  }
}

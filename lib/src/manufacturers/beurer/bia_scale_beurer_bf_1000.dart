import '../../all_enums.dart';
import '../../i_health_device.dart';

class BIAScaleBeurerBf1000 extends IHealthDevice {
  BIAScaleBeurerBf1000({
    required this.id,
    required this.macAddress,
  });

  @override
  Model get model => Model.BF_1000;

  @override
  String id;

  @override
  Brand get brand => Brand.BEURER;

  String macAddress;

  Future<Stream<BeurerBf1000BiaData>> startBIA() => throw UnimplementedError();
  Future<void> stopBIA() => throw UnimplementedError();
  Future<void> connect() => throw UnimplementedError();
  Future<void> disconnect() => throw UnimplementedError();
  Future<void> selectUser(int userIndex) => throw UnimplementedError();
  Future<void> updateUser(int userIndex, String userName) => throw UnimplementedError();
  Future<Stream<BeurerBf1000UserData>> getUser(int userIndex) => throw UnimplementedError();
}

typedef BeurerBf1000BiaData = ({
  DateTime? timestamp,
  int? userIndex,
  double? basalMetabolism,
  double? musclePercentage,
  double? muscleMass,
  double? fatFreeMass,
  double? softLeanMass,
  double? bodyWaterMass,
  double? impedance,
  double? weight,
  double? height,
});

typedef BeurerBf1000UserData = ({
  int? userIndex,
  String? userName,
});

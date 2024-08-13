part of '../../i_health_devices.dart';

class HeartRateMonitorCoospoHw807 extends IHealthDevice {
  HeartRateMonitorCoospoHw807({
    required this.id,
    required this.macAddress,
  });
  @override
  Brand get brand => Brand.COOSPO;

  @override
  String id;

  @override
  Model get model => Model.HW807;

  String macAddress;

  @override
  //TODO: implement name
  String get name => '';

  static bool isDevice(ScanResult sr) {
    // todo: find a way to guess this device, because name ain't enough
    return false;
  }

  HeartRateMonitorCoospoHw807Data getDataFromBroadcast(List<int> broadcast) => throw UnimplementedError();

  Future<void> connect() => throw UnimplementedError();
  Future<void> disconnect() => throw UnimplementedError();
  Future<void> updateMaximalHeartRate(int maximalHeartRate) => throw UnimplementedError();
  Future<void> enableMaximalHeartRateVibrationFeedback() => throw UnimplementedError();
  Future<void> disableMaximalHeartRateVibrationFeedback() => throw UnimplementedError();
}

typedef HeartRateMonitorCoospoHw807Data = ({
  DateTime? timestamp,
  int? heartRate,
  double? batteryLevel,
  int? rssi,
  // int? heartRateVariability,
});

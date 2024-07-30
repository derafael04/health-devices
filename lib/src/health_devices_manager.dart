import 'package:health_devices/src/services/bluetooth/ble_driver.dart';

import 'i_health_device.dart';

class HealthDevicesManager {
  HealthDevicesManager._internal();
  static final HealthDevicesManager _instance = HealthDevicesManager._internal();
  static HealthDevicesManager get instance => _instance;
  static HealthDevicesManager getInstance() => _instance;
  factory HealthDevicesManager() {
    return _instance;
  }

  Stream<IHealthDevice> getBLEDevicesCloseBy() => BLEDriver.closeByDevices;
  Stream<IHealthDevice> getBluetoothDevicesCloseBy() => throw UnimplementedError();
  Stream<IHealthDevice> getANTPlusDevicesCloseBy() => throw UnimplementedError();
}

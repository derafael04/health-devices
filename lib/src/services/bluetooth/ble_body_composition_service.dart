import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/services/bluetooth/ble_driver.dart';
import 'package:health_devices/src/services/bluetooth/bluetooth_services.dart';

class BleBodyCompositionService {
  BleBodyCompositionService({
    required BLEDriver driver,
  }): _driver = driver;

  BLEDriver _driver;

  static final Guid serviceGUID = SERVICE_BODY_COMPOSITION;
}

import 'dart:collection';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/brand_enum.dart';
import 'package:health_devices/src/model_enum.dart';

import 'common_enums.dart';
import 'i_health_devices.dart';
import 'services/bluetooth/ble_driver.dart';

class HealthDevicesManager {
  factory HealthDevicesManager() {
    return _instance;
  }

  HealthDevicesManager._internal();

  static final HealthDevicesManager _instance = HealthDevicesManager._internal();

  static HealthDevicesManager get instance => _instance;

  static HealthDevicesManager getInstance() => _instance;

  final Map<String, HealthDeviceIdentifier> _deviceIdentifiers = {};
  late final UnmodifiableMapView<String, HealthDeviceIdentifier> _unmodifiableDeviceIdentifiers = UnmodifiableMapView(_deviceIdentifiers);

  /// This is an unmodifiable map, trying to add, remove or set a device will throw an error
  Map<String, HealthDeviceIdentifier> get deviceIdentifiers => _unmodifiableDeviceIdentifiers;

  /// If the identifier already exists, it will be replaced
  void addDeviceIdentifier(HealthDeviceIdentifier device) {
    _deviceIdentifiers[device.id] = device;
    identify(device); //TODO: When you add an identifier, you should instantiate the device, not identify it
  }

  /// If the identifier already exists, it will be replaced
  void addDeviceIdentifiers({required List<HealthDeviceIdentifier> devices}) {
    _deviceIdentifiers.addEntries(devices.map((device) => MapEntry(device.id, device)));
    devices.forEach(identify); //TODO: When you add an identifier, you should instantiate the device, not identify it
  }

  void removeDeviceIdentifier({required String deviceID}) => _deviceIdentifiers.remove(deviceID); // TODO: Will this prevent the device from being listed or identified? Does it makes sense to remove an identifier?

  void clearDeviceIdentifiers() => _deviceIdentifiers.clear(); // TODO: Remove?

  Future<IHealthDevice?> identify(HealthDeviceIdentifier device) async {
    var id = device.id;
    if (_knownDevices.containsKey(id)) {
      return _knownDevices[id];
    }
    var c = device.connectionType;
    IHealthDevice? d;
    switch (c) {
      case ConnectionType.BLE:
        d = await _identifyBLEDevice(device);
      case ConnectionType.BLUETOOTH_CLASSIC:
        d = null;
      case ConnectionType.ANT_PLUS:
        d = null;
      default:
        d = null;
    }
    if (d != null) {
      _knownDevices[d.id] = d;
    }
    return d;
  }

  Future<IHealthDevice?> _identifyBLEDevice(HealthDeviceIdentifier device) async {
    var b = device.brand;
    var m = device.model;
    if (b == null || m == null) {
      var driver = BLEDriver(macAddress: device.id);
      var identifier = await driver.identify();
      b = identifier.brand;
      m = identifier.model;
    }
    switch (b) {
      case Brand.BEURER:
        switch (m) {
          case Model.BF_1000:
            return BIAScaleBeurerBf1000(macAddress: device.id);
          default:
            return null;
        }
      case Brand.COOSPO:
        switch (m) {
          case Model.HW807:
            return HeartRateMonitorCoospoHw807(macAddress: device.id, id: device.id);
          default:
            return null;
        }
      default:
        return null;
    }
  }

  /// The IDs whose device type are known by the manager
  final Map<String, IHealthDevice> _knownDevices = {};

  /// The IDs whose device type are unknown by the manager
  final Map<String, UnknownHealthDevice> _unknownDevices = {};

  Stream<Iterable<IHealthDevice>> getBLEDevicesCloseBy() {
    BLEDriver.startScan(); //TODO: await this future
    return BLEDriver.closeByDevices.map(
      (event) {
        return event.map((scanResult) {
          var id = scanResult.device.remoteId.str;
          final device = _knownDevices[id];
          if (device != null) {
            return device;
          }
          return _guessBLEDeviceByScanResult(scanResult);
        });
      },
    );
  }

  /// Checks if the scan result is a known device, if not, tries to guess the device
  /// If the device is not known, it will return an UnknownHealthDevice
  IHealthDevice _guessBLEDeviceByScanResult(ScanResult sr) {
    var id = sr.device.remoteId.str;
    final device = _knownDevices[id];

    if (device != null) {
      return device;
    }

    var d = _checkAllBLEDevices(sr);

    if (d != null) {
      _knownDevices[id] = d;
      return d;
    }

    var u = _unknownDevices[id];
    u ??= UnknownHealthDevice(
      id: id,
      connectionType: ConnectionType.BLE,
    );

    _unknownDevices.putIfAbsent(id, () => u!);

    return u;
  }

  /// Throws an [UnimplementedError] because it is not implemented yet
  Stream<IHealthDevice> getBluetoothDevicesCloseBy() => throw UnimplementedError();

  /// Throws an [UnimplementedError] because it is not implemented yet
  Stream<IHealthDevice> getANTPlusDevicesCloseBy() => throw UnimplementedError();
}

IHealthDevice? _checkAllBLEDevices(ScanResult sr) {
  if (BIAScaleBeurerBf1000.isDevice(sr)) {
    return BIAScaleBeurerBf1000(macAddress: sr.device.remoteId.str);
  }

  if (HeartRateMonitorCoospoHw807.isDevice(sr)) {
    return HeartRateMonitorCoospoHw807(macAddress: sr.device.remoteId.str, id: sr.device.remoteId.str);
  }

  return null;
}
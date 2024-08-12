import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/src/brand_enum.dart';
import 'package:health_devices/src/i_health_devices.dart';
import 'package:health_devices/src/services/bluetooth/ble_device_information_service.dart';
import 'package:health_devices/src/utils/execution_controller.dart';

import '../../common_enums.dart';
import '../../model_enum.dart';

class BLEDriver {
  BLEDriver({
    required this.macAddress,
  }) {
    // TODO: cancel this subscription
    bluetoothDevice.onServicesReset.listen((event) async {
      if (bluetoothDevice.isConnected) {
        _discoveredServices = await bluetoothDevice.discoverServices();
      }
    });
  }

  // ################################# STATIC #################################
  static final ExecutionController _scanController = ExecutionController(
    onPlay: () {
      FlutterBluePlus.startScan();
    },
    onPause: () {
      FlutterBluePlus.stopScan();
    },
    onFinish: () {
      FlutterBluePlus.stopScan();
    },
  );

  static void startScan() {
    _scanController.play();
  }

  static void pauseScan() {
    _scanController.pause();
  }

  /// This is the pool of devices that were identified by the BLE driver
  /// The key is the device's MAC address
  /// The value is the pair of the HealthDevice and the BluetoothDevice
  static final Map<String, BluetoothDevice> _devices = {};

  static Stream<List<ScanResult>> get closeByDevices => FlutterBluePlus.scanResults;

  // ################################# INSTANCE #################################
  String macAddress;
  BluetoothDevice get bluetoothDevice => _devices[macAddress]!; //TODO: throw exception if device not found
  List<BluetoothService?>? _discoveredServices;

  Future<void> connect() async {
    await bluetoothDevice.connect();
    _discoveredServices = await bluetoothDevice.discoverServices();
  }

  Future<void> disconnect() async {
    await bluetoothDevice.disconnect();
  }

  Future<HealthDeviceIdentifier> identify() async {
    var isConnected = this.isConnected;
    if (!isConnected) {
      await connect();
    }
    try {
      var deviceInformationService = BleDeviceInformationService(driver: this);
      var brandName = await deviceInformationService.getManufacturerName();
      var modelName = await deviceInformationService.getModelNumber();
      var brand = Brand.fromManufacturerName(brandName);
      var model = Model.fromName(modelName);
      return (
        id: macAddress,
        connectionType: ConnectionType.BLE,
        brand: brand,
        model: model,
      );
    } catch (e) {
      return (
        id: macAddress,
        connectionType: ConnectionType.BLE,
        brand: Brand.UNKNOWN,
        model: Model.UNKNOWN,
      );
    } finally {
      await disconnect();
    }
  }

  bool get isConnected => bluetoothDevice.isConnected;
  Stream<bool>? _isConnectedStream;
  Stream<bool> get isConnectedStream => _isConnectedStream ??= bluetoothDevice.connectionState.map(
        (event) => event == BluetoothConnectionState.connected,
      );

  Future<void> writeToCharacteristic({required serviceUuid, required characteristicUuid, required List<int> data}) async {
    BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == serviceUuid);
    if (service == null) throw Exception('Service $serviceUuid not found');
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == characteristicUuid);
    if (characteristic == null) throw Exception('Characteristic $characteristicUuid not found');

    return await characteristic.write(data);
  }

  Future<BluetoothCharacteristic> getCharacteristic({required Guid serviceUuid, required Guid characteristicUuid}) async {
    BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == serviceUuid);
    if (service == null) throw Exception('Service $serviceUuid not found');
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == characteristicUuid);
    if (characteristic == null) throw Exception('Characteristic $characteristicUuid not found');

    return characteristic;
  }

  Future<List<int>> readCharacteristic({required Guid serviceUuid, required Guid characteristicUuid}) async {
    BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == serviceUuid);
    if (service == null) throw Exception('Service $serviceUuid not found');
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == characteristicUuid);
    if (characteristic == null) throw Exception('Characteristic $characteristicUuid not found');

    return await characteristic.read();
  }

  Future<StreamSubscription<List<int>>> startListeningToCharacteristic({required Guid serviceUuid, required Guid characteristicUuid, void Function(List<int> data)? onData}) async {
    BluetoothService? service = _discoveredServices?.firstWhere((element) => element?.uuid == serviceUuid);
    if (service == null) throw Exception('Service $serviceUuid not found');
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhereOrNull((element) => element.uuid == characteristicUuid);
    if (characteristic == null) throw Exception('Characteristic $characteristicUuid not found');

    StreamSubscription<List<int>> subscription = characteristic.onValueReceived.listen(onData);

    bluetoothDevice.cancelWhenDisconnected(subscription);

    await characteristic.setNotifyValue(true);

    return subscription;
  }
}

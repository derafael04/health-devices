import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:health_devices/bia_scales.dart';
import 'package:health_devices/src/utils/execution_controller.dart';

class BLEDriver {
  BLEDriver({
    required this.macAddress,
  });

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
  static final Map<String, FlutterBluePlusDevicePair> _devices = {};

  static Stream<IHealthDevice> get closeByDevices => FlutterBluePlus.scanResults.map((scanResult) {
        // TODO: transform each device into the correct HealthDevice identifying the brand and model
        // TODO: each mapped device must not be instantiated again if it is already in the devices pool, this helps us keep the state of the devices
        throw UnimplementedError();
      });

  // ################################# INSTANCE #################################
  String macAddress;
  BluetoothDevice get bluetoothDevice => _devices[macAddress]!.bluetoothDevice; //TODO: throw exception if device not found
  IHealthDevice get healthDevice => _devices[macAddress]!.healthDevice; //TODO: throw exception if device not found
  List<BluetoothService?>? _discoveredServices;

  Future<void> connect() async {
    await bluetoothDevice.connect();
  }

  Future<void> disconnect() async {
    await bluetoothDevice.disconnect();
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

typedef FlutterBluePlusDevicePair = ({
  IHealthDevice healthDevice,
  BluetoothDevice bluetoothDevice,
});

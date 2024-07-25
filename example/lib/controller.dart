import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rxdart/subjects.dart';

class Controller {
  Controller._();

  static Controller? _instance;

  static Controller get instance {
    _instance ??= Controller._();
    return _instance!;
  }

  

  final BehaviorSubject<List<BluetoothDevice>> _devices = BehaviorSubject<List<BluetoothDevice>>();

  BehaviorSubject<List<BluetoothDevice>> get devices => _devices;

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  

  void discoverDevices() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((event) {
      devices.add(event.map((e) => e.device).where((element) => element.platformName.isNotEmpty).toList());
    });
    FlutterBluePlus.startScan();
  }

  void stopDiscovering() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
  }
}

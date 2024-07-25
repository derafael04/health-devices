import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:test/util.dart';

class DeviceController {
  DeviceController(this.device) : super() {
    init();
  }

  final BluetoothDevice device;

  final ValueNotifier<bool> _isConnected = ValueNotifier(false);

  ValueNotifier<bool> get isConnected => _isConnected;

  StreamSubscription<BluetoothConnectionState>? _connectionState;

  List<BluetoothService?>? _services;

  // Streams
  StreamSubscription? weightSubscription;

  StreamSubscription? biaSubscription;

  StreamSubscription? bfSubscription;

  StreamSubscription? massSubscription;

  StreamSubscription? confirmationSubscription;

  StreamSubscription? _onServicesResetSubscription;

  final List<int> weight = [];

  final List<int> bia = [];

  final List<int> bf = [];

  final List<int> mass = [];

  ValueNotifier<WeightData> weightData = ValueNotifier(WeightData());

  ValueNotifier<BiaData> biaData = ValueNotifier(BiaData());

  ValueNotifier<BfData> bfData = ValueNotifier(BfData());

  ValueNotifier<MassData> massData = ValueNotifier(MassData());

  void connect() async {
    await device.connect();
    _services = await device.discoverServices();
    print(_services);
  }

  void disconnected() {
    device.disconnect();
  }

  void init() {
    _connectionState?.cancel();
    _connectionState = device.connectionState.listen((event) {
      if (event == BluetoothConnectionState.disconnected) {
        _isConnected.value = false;
      } else {
        _isConnected.value = true;
      }
    });

    _onServicesResetSubscription?.cancel();
    _onServicesResetSubscription = device.onServicesReset.listen((event) async {
      if (device.isConnected) {
        _services = await device.discoverServices();
      }
    });
  }

  void dispose() {
    _connectionState?.cancel();
  }

  Future<void> readWeight() async {
    BluetoothService? service = _services?.firstWhere((element) => element?.uuid == Guid("181D"));
    if (service == null) return;
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhere((element) => element.uuid == Guid("2A9D"));
    if (characteristic == null) return;

    if (weightSubscription != null) weightSubscription?.cancel();
    weightSubscription = characteristic.onValueReceived.listen((event) {
      print('Event Weight Subscription: $event');
      weight.addAll(event);
      print('Weight: $weight');
    });

    device.cancelWhenDisconnected(weightSubscription!);

    await characteristic.setNotifyValue(true);
  }

  Future<void> readBia() async {
    BluetoothService? service = _services?.firstWhere((element) => element?.uuid == Guid("181B"));
    if (service == null) return;
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhere((element) => element.uuid == Guid("2A9C"));
    if (characteristic == null) return;

    if (biaSubscription != null) biaSubscription?.cancel();
    biaSubscription = characteristic.onValueReceived.listen((event) {
      print('Event Bia Subscription: $event');
      bia.addAll(event);
      print('Bia: $bia');
    });

    device.cancelWhenDisconnected(biaSubscription!);

    await characteristic.setNotifyValue(true);
  }

  Future<void> readBf() async {
    BluetoothService? service = _services?.firstWhere((element) => element?.uuid == Guid("FFFF"));
    if (service == null) return;
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhere((element) => element.uuid == Guid("0009"));
    if (characteristic == null) return;

    if (bfSubscription != null) bfSubscription?.cancel();
    bfSubscription = characteristic.onValueReceived.listen((event) {
      print('Event Bf Subscription: $event');
      bf.addAll(event);
      print('BF: $bf');

    });

    device.cancelWhenDisconnected(bfSubscription!);

    await characteristic.setNotifyValue(true);
  }

  Future<void> readMass() async {
    BluetoothService? service = _services?.firstWhere((element) => element?.uuid == Guid("FFFF"));
    if (service == null) return;
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhere((element) => element.uuid == Guid("000a"));
    if (characteristic == null) return;

    if (massSubscription != null) massSubscription?.cancel();
    massSubscription = characteristic.onValueReceived.listen((event) {
      print('Event Mass Subscription: $event');
      mass.addAll(event);
      print('Mass: $mass');
    });

    device.cancelWhenDisconnected(massSubscription!);

    await characteristic.setNotifyValue(true);
  }

  Future<void> startBia() async {
    BluetoothService? service = _services?.firstWhere((element) => element?.uuid == Guid("FFFF"));
    if (service == null) return;
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhere((element) => element.uuid == Guid("0006"));
    if (characteristic == null) return;

    if (confirmationSubscription != null) confirmationSubscription?.cancel();
    confirmationSubscription = characteristic.onValueReceived.listen((event) {
      if (event.first == 0x01) {
        print('Event: $event');
        print('A Weight: $weight');
        print('A Bia: $bia');
        print('A BF: $bf');
        print('A Mass: $mass');
        weightData.value = parseWeightData(Uint8List.fromList(weight));
        biaData.value = parseBiaData(Uint8List.fromList(bia));
        bfData.value = parseBfData(Uint8List.fromList(bf));
        massData.value = parseMassData(Uint8List.fromList(mass));
      }
    });

    await characteristic.setNotifyValue(true);
    device.cancelWhenDisconnected(confirmationSubscription!);

    await characteristic.write([0x00]);
  }

  Future<void> selectUser(int index, int consentCode) async {
    BluetoothService? service = _services?.firstWhere((element) => element?.uuid == Guid("181C"));
    if (service == null) return;
    BluetoothCharacteristic? characteristic = service.characteristics.firstWhere((element) => element.uuid == Guid("2A9F"));
    if (characteristic == null) return;

    await characteristic.write([0x02, index, 0xD2, 0x04]);
  }

  void fetchData() {
    weightData.value = parseWeightData(Uint8List.fromList(weight));
    biaData.value = parseBiaData(Uint8List.fromList(bia));
    bfData.value = parseBfData(Uint8List.fromList(bf));
    massData.value = parseMassData(Uint8List.fromList(mass));
  }
}

class WeightData {
  WeightData({
    this.weight,
    this.ano,
    this.mes,
    this.dia,
    this.hora,
    this.minuto,
    this.segundo,
    this.userIndex,
    this.imc,
    this.altura,
  });

  final double? weight;
  final int? ano;
  final int? mes;
  final int? dia;
  final int? hora;
  final int? minuto;
  final int? segundo;
  final int? userIndex;
  final double? imc;
  final double? altura;
}

// Bia data [flags] [ BF? ] [bmr? ] [%massa?] [soft lean mass] [Agua %] [impedancia]

class BiaData {
  BiaData({
    this.flags,
    this.bf,
    this.bmr,
    this.percentMass,
    this.softLeanMass,
    this.waterPercent,
    this.impedance,
  });

  final int? flags;
  final double? bf;
  final double? bmr;
  final double? percentMass;
  final double? softLeanMass;
  final double? waterPercent;
  final double? impedance;
}

class BfData {
  BfData({
    this.gordVisceral,
    this.bfBracoDireito,
    this.bfBracoEsquerdo,
    this.bfTronco,
    this.bfPernaDireita,
    this.bfPernaEsquerda,
  });

  final double? gordVisceral;
  final double? bfBracoDireito;
  final double? bfBracoEsquerdo;
  final double? bfTronco;
  final double? bfPernaDireita;
  final double? bfPernaEsquerda;
}

class MassData {
  MassData({
    this.massBracoDireito,
    this.massBracoEsquerdo,
    this.massTronco,
    this.massPernaDireita,
    this.massPernaEsquerda,
  });

  final double? massBracoDireito;
  final double? massBracoEsquerdo;
  final double? massTronco;
  final double? massPernaDireita;
  final double? massPernaEsquerda;
}

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test/controller.dart';
import 'package:test/device_controller.dart';
import 'package:test/device_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (Platform.isAndroid) {
    [Permission.location, Permission.storage, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request().then((status) {
      runApp(const MyApp());
    });
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  MyHomePage({super.key});
  final controller = Controller.instance;

  @override
  Widget build(BuildContext context) {
    var devices = useStream(controller.devices);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  children: [
                    Card(
                      child: InkWell(
                        onTap: () {
                          controller.discoverDevices();
                        },
                        child: const Center(
                          child: Text('Discover devices'),
                        ),
                      ),
                    ),
                    Card(
                      child: InkWell(
                        onTap: () {
                          controller.stopDiscovering();
                        },
                        child: const Center(
                          child: Text('Stop discovering'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  children: [
                    ...devices.data
                            ?.map(
                              (e) => GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return DeviceScreen(controller: DeviceController(e));
                                      },
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Center(
                                    child: Text(e.platformName),
                                  ),
                                ),
                              ),
                            )
                            .toList() ??
                        const [],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

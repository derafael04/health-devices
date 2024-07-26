import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:test/constants.dart';
import 'package:test/device_controller.dart';

class DeviceScreen extends HookWidget {
  const DeviceScreen({
    required this.controller,
    super.key,
  });

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    var deviceController = useMemoized(() => controller);
    var x = useListenable(deviceController.isConnected);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                color: x.value ? Colors.green : Colors.red,
                child: Text(x.value ? 'Connected' : 'Not connected'),
              ),
              GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                children: [
                  Card(
                    child: InkWell(
                      onTap: () {
                        deviceController.connect();
                      },
                      child: const Center(
                        child: Text('Connect'),
                      ),
                    ),
                  ),
                  Card(
                    child: InkWell(
                      onTap: () {
                        deviceController.disconnected();
                      },
                      child: const Center(
                        child: Text('Disconnect'),
                      ),
                    ),
                  ),
                  Card(
                    child: InkWell(
                      onTap: () async {
                        // await deviceController.deleteUser(10, 1234);
                        await deviceController.createUser(
                          consentCode: 1000,
                          userData: UserData(
                            activityLevel: ActivityLevel.VERY_ACTIVE,
                            birthDay: 19,
                            birthMonth: 1,
                            birthYear: 1999,
                            gender: Gender.M,
                            heightInCm: 190,
                            index: 2,
                            nickname: 'Luan Cesar',
                          ),
                        );
                        // var x = await deviceController.listUsers();
                        // for(final a in x ?? []) {
                        //   print(a.toString());
                        // }
                        // await deviceController.selectUser(1, 1234);

                        // deviceController.startBia();
                      },
                      child: const Center(
                        child: Text('Button'),
                      ),
                    ),
                  ),
                  Card(
                    child: InkWell(
                      onTap: () {
                        deviceController.fetchData();
                      },
                      child: const Center(
                        child: Text('fetch'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text('Weight: ${deviceController.weight}'),
              Text('Bia: ${deviceController.bia}'),
              Text('Bf: ${deviceController.bf}'),
              Text('Mass: ${deviceController.mass}'),
              Divider(),
              Text('Weight: ${deviceController.weightData.value.weight}'),
              Text('Ano: ${deviceController.weightData.value.ano}'),
              Text('Mes: ${deviceController.weightData.value.mes}'),
              Text('Dia: ${deviceController.weightData.value.dia}'),
              Text('Hora: ${deviceController.weightData.value.hora}'),
              Text('Minuto: ${deviceController.weightData.value.minuto}'),
              Text('Segundo: ${deviceController.weightData.value.segundo}'),
              Text('User index: ${deviceController.weightData.value.userIndex}'),
              Text('IMC: ${deviceController.weightData.value.imc}'),
              Text('Altura: ${deviceController.weightData.value.altura}'),
              Divider(),
              Text('BF Braço Direito: ${deviceController.bfData.value.bfBracoDireito}'),
              Text('BF Braço Esquerdo: ${deviceController.bfData.value.bfBracoEsquerdo}'),
              Text('BF Tronco: ${deviceController.bfData.value.bfTronco}'),
              Text('BF Perna Direita: ${deviceController.bfData.value.bfPernaDireita}'),
              Text('BF Perna Esquerda: ${deviceController.bfData.value.bfPernaEsquerda}'),
              Text('Gordura Visceral: ${deviceController.bfData.value.gordVisceral}'),
              Divider(),
              Text('BF: ${deviceController.biaData.value.bf}'),
              Text('BMR: ${deviceController.biaData.value.bmr}'),
              Text('Percent Mass: ${deviceController.biaData.value.percentMass}'),
              Text('Soft Lean Mass: ${deviceController.biaData.value.softLeanMass}'),
              Text('Water Percent: ${deviceController.biaData.value.waterPercent}'),
              Text('Impedance: ${deviceController.biaData.value.impedance}'),
              Divider(),
              Text('Massa Braco Direito: ${deviceController.massData.value.massBracoDireito}'),
              Text('Massa Braco Esquerdo: ${deviceController.massData.value.massBracoEsquerdo}'),
              Text('Massa Tronco: ${deviceController.massData.value.massTronco}'),
              Text('Massa Perna Direita: ${deviceController.massData.value.massPernaDireita}'),
              Text('Massa Perna Esquerda: ${deviceController.massData.value.massPernaEsquerda}'),
            ],
          ),
        ),
      ),
    );
  }
}

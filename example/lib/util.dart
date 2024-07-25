import 'dart:typed_data';

import 'package:test/device_controller.dart';

WeightData parseWeightData(Uint8List data) {
  final byteData = data.buffer.asByteData();

  if(byteData.lengthInBytes < 15) {
    return WeightData();
  }

  final weight = byteData.getUint16(1, Endian.little) / 200.0;
  final ano = byteData.getUint16(3, Endian.little);
  final mes = byteData.getUint8(5);
  final dia = byteData.getUint8(6);
  final hora = byteData.getUint8(7);
  final minuto = byteData.getUint8(8);
  final segundo = byteData.getUint8(9);
  final userIndex = byteData.getUint8(10);
  final imc = byteData.getUint16(11, Endian.little) / 10.0;
  final altura = byteData.getUint16(13, Endian.little) / 10.0;
  
  return WeightData(
    weight: weight,
    ano: ano,
    mes: mes,
    dia: dia,
    hora: hora,
    minuto: minuto,
    segundo: segundo,
    userIndex: userIndex,
    imc: imc,
    altura: altura,
  );
}

BiaData parseBiaData(Uint8List data) {
  final byteData = data.buffer.asByteData();

  if(byteData.lengthInBytes < 14) {
    return BiaData();
  }

  final flags = byteData.getUint16(0, Endian.little);
  final bf = byteData.getUint16(2, Endian.little) / 10.0;
  final bmr = byteData.getUint16(4, Endian.little) / 4.184;
  final percentMass = byteData.getUint16(6, Endian.little) / 10.0;
  final softLeanMass = byteData.getUint16(8, Endian.little) / 10.0;
  final waterPercent = byteData.getUint16(10, Endian.little) / 10.0;
  final impedance = byteData.getUint16(12, Endian.little) / 10.0;

  return BiaData(
    flags: flags,
    bf: bf,
    bmr: bmr,
    percentMass: percentMass,
    softLeanMass: softLeanMass,
    waterPercent: waterPercent,
    impedance: impedance,
  );
  
}

BfData parseBfData(Uint8List data) {
  final byteData = data.buffer.asByteData();

  if(byteData.lengthInBytes < 12) {
    return BfData();
  }

  final gordVisceral = byteData.getUint16(0, Endian.little) / 1.0;
  final bfBracoDireito = byteData.getUint16(2, Endian.little) / 10.0;
  final bfBracoEsquerdo = byteData.getUint16(4, Endian.little) / 10.0;
  final bfTronco = byteData.getUint16(6, Endian.little) / 10.0;
  final bfPernaDireita = byteData.getUint16(8, Endian.little) / 10.0;
  final bfPernaEsquerda = byteData.getUint16(10, Endian.little) / 10.0;

  return BfData(
    gordVisceral: gordVisceral,
    bfBracoDireito: bfBracoDireito,
    bfBracoEsquerdo: bfBracoEsquerdo,
    bfTronco: bfTronco,
    bfPernaDireita: bfPernaDireita,
    bfPernaEsquerda: bfPernaEsquerda,
  );
}

MassData parseMassData(Uint8List data) {
  final byteData = data.buffer.asByteData();

  if(byteData.lengthInBytes < 11) {
    return MassData();
  }

  final massBracoDireito = byteData.getUint16(1, Endian.little) / 10.0;
  final massBracoEsquerdo = byteData.getUint16(3, Endian.little) / 10.0;
  final massTronco = byteData.getUint16(5, Endian.little) / 10.0;
  final massPernaDireita = byteData.getUint16(7, Endian.little) / 10.0;
  final massPernaEsquerda = byteData.getUint16(9, Endian.little) / 10.0;

  return MassData(
    massBracoDireito: massBracoDireito,
    massBracoEsquerdo: massBracoEsquerdo,
    massTronco: massTronco,
    massPernaDireita: massPernaDireita,
    massPernaEsquerda: massPernaEsquerda,
  );
}
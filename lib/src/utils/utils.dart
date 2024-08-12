import 'dart:typed_data';

Uint8List getBirthDateBytes(DateTime birthDate) {
  final birthDateBytes = ByteData(4)
    ..setUint16(0, birthDate.year, Endian.little)
    ..setUint8(2, birthDate.month)
    ..setUint8(3, birthDate.day);
  return birthDateBytes.buffer.asUint8List();
}

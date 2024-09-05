import 'dart:typed_data';

extension ByteDataUtils on ByteData {
  /// Returns a list of bytes from the byte data
  Uint8List get bytes => buffer.asUint8List();
  static ByteData fromInt(int value) {
    final byteData = ByteData(8);
    byteData.setInt64(0, value, Endian.little);
    return byteData;
  }

  Uint8List prefix(int length) {
    return buffer.asUint8List().sublist(0, length);
  }

  Uint8List suffix(int length) {
    var list = buffer.asUint8List();
    var listLength = list.length;
    return list.sublist(listLength - length);
  }

  ByteData get reverse {
    final reversed = ByteData(8);
    for (int i = 0; i < 8; i++) {
      reversed.setUint8(i, getUint8(7 - i));
    }
    return reversed;
  }
}
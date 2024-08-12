

extension IntExtension on int {
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
  bool isDivisibleBy(int number) => this % number == 0;
  int get factorial {
    if (this < 0) throw Exception('Factorial of negative number is not defined');
    return this == 0 ? 1 : this * (this - 1).factorial;
  }
  int get next => this + 1;
  int get previous => this - 1;
  int get abs => this < 0 ? -this : this;
  int get square => this * this;
  int get cube => this * this * this;
  double get float => toDouble();
  String get toBinary => toRadixString(2);
  String get toOctal => toRadixString(8);
  String get toHex => toRadixString(16);
  /// In Dart not compiled to JS, integers are 64-bit.
  /// 
  /// The 8 bytes in the integer are enumerated from 0 to 7, where 0 is the least significant byte and 7 is the most significant byte.
  int getByteAt(int position) => (this >> (position * 8)) /* & 0xFF */;

  int get reverseBytes {
    int reversed = 0;
    for (int i = 0; i < 8; i++) {
      reversed |= getByteAt(i) << ((7 - i) * 8);
    }
    return reversed;
  }

  List<int> bytesAsUInt8List() {
    List<int> bytes = [];
    for (int i = 0; i < 8; i++) {
      bytes.add(getByteAt(i));
    }
    return bytes;
  }
}
abstract class BluetoothStructInterface<T> {
  List<int> toBytes();
  T fromBytes(List<int> bytes);
}

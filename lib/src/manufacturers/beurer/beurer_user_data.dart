// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';

import 'package:health_devices/src/services/bluetooth/bluetooth_struct_interface.dart';

class BeurerUserData implements BluetoothStructInterface<BeurerUserData> {
  const BeurerUserData({
    this.index,
    this.nickname,
    this.gender,
    this.heightInCm,
    this.activityLevel,
    this.targetWeight,
    this.birthDate,
  });

  final int? index;
  final DateTime? birthDate;
  final String? nickname;
  final BeurerGender? gender;
  final int? heightInCm;
  final BeurerActivityLevel? activityLevel;
  final int? targetWeight;

  @override
  List<int> toBytes() {
    List<int> bytes = [];
    bytes.add(0x00);
    bytes.add(index!);
    bytes.addAll(nickname!.codeUnits);
    bytes.add(birthDate!.year & 0xFF);
    bytes.add((birthDate!.year >> 8) & 0xFF);
    bytes.add(birthDate!.month);
    bytes.add(birthDate!.day);
    bytes.add(heightInCm!);
    bytes.add(gender == BeurerGender.M ? 0 : 1);
    return bytes;
  }

  factory BeurerUserData.fromBytes(List<int> bytes) {
    Uint8List intArray = Uint8List.fromList(bytes);
    ByteData byteData = intArray.buffer.asByteData();

    //index, nickname, year, month, day, height, gender, activity level
    // int index = byteData.getUint8(1);
    String nickname = String.fromCharCodes([byteData.getUint8(2), byteData.getUint8(3), byteData.getUint8(4)]);
    int year = byteData.getUint16(5, Endian.little);
    int month = byteData.getUint8(7);
    int day = byteData.getUint8(8);
    int height = byteData.getUint8(9);
    int genderNumber = byteData.getUint8(10);
    BeurerGender gender = BeurerGender.fromCode(genderNumber);
    int activityLevelNumber = byteData.getUint8(11);
    BeurerActivityLevel activityLevel = BeurerActivityLevel.fromCode(activityLevelNumber);

    return BeurerUserData(
      birthDate: DateTime(year, month, day),
      nickname: nickname,
      activityLevel: activityLevel,
      gender: gender,
      heightInCm: height,
    );
  }

  @override
  fromBytes(List<int> bytes) => BeurerUserData.fromBytes(bytes);
}

enum BeurerActivityLevel {
  SEDENTARY(1),
  LIGHTLY_ACTIVE(2),
  MODERATELY_ACTIVE(3),
  VERY_ACTIVE(4),
  SUPER_ACTIVE(5);

  const BeurerActivityLevel(this.code);
  static BeurerActivityLevel fromCode(int code) {
    switch (code) {
      case 1:
        return BeurerActivityLevel.SEDENTARY;
      case 2:
        return BeurerActivityLevel.LIGHTLY_ACTIVE;
      case 3:
        return BeurerActivityLevel.MODERATELY_ACTIVE;
      case 4:
        return BeurerActivityLevel.VERY_ACTIVE;
      case 5:
        return BeurerActivityLevel.SUPER_ACTIVE;
      default:
        return BeurerActivityLevel.SEDENTARY;
    }
  }
  final int code;
}

enum BeurerGender {
  M(0),
  F(1);

  const BeurerGender(this.code);
  static BeurerGender fromCode(int code) {
    switch (code) {
      case 0:
        return BeurerGender.M;
      case 1:
        return BeurerGender.F;
      default:
        return BeurerGender.M;
    }
  }
  final int code;
}

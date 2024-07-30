// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

class BeurerBF1000UserData {
  BeurerBF1000UserData({
    this.index,
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.nickname,
    this.gender,
    this.heightInCm,
    this.activityLevel,
  });

  final int? index;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
  final String? nickname;
  final BeurerSex? gender;
  final int? heightInCm;
  final BeurerActivityLevel? activityLevel;

  @override
  String toString() {
    return 'UserData{birthYear: $birthYear, birthMonth: $birthMonth, birthDay: $birthDay, nickname: $nickname, gender: $gender, activityLevel: ${activityLevel?.index}}';
  }

  List<int> toBytes() {
    List<int> bytes = [];
    bytes.add(0x00);
    bytes.add(index!);
    bytes.addAll(nickname!.codeUnits);
    bytes.add(birthYear! & 0xFF);
    bytes.add((birthYear! >> 8) & 0xFF);
    bytes.add(birthMonth!);
    bytes.add(birthDay!);
    bytes.add(heightInCm!);
    bytes.add((gender?.name ?? BeurerSex.M.name).codeUnitAt(0));
    return bytes;
  }

  static fromBytes(List<int> bytes) {
    Uint8List intArray = Uint8List.fromList(bytes);
    ByteData byteData = intArray.buffer.asByteData();

    //index, nickname, year, month, day, height, gender, activity level
    int index = byteData.getUint8(1);
    String nickname = String.fromCharCodes([byteData.getUint8(2), byteData.getUint8(3), byteData.getUint8(4)]);
    int year = byteData.getUint16(5, Endian.little);
    int month = byteData.getUint8(7);
    int day = byteData.getUint8(8);
    int height = byteData.getUint8(9);
    int genderNumber = byteData.getUint8(10);
    BeurerSex gender = genderNumber == 0 ? BeurerSex.M : BeurerSex.F;
    int activityLevelNumber = byteData.getUint8(11);
    BeurerActivityLevel activityLevel = BeurerActivityLevel.values[activityLevelNumber - 1];

    return BeurerBF1000UserData(
      birthYear: year,
      birthMonth: month,
      birthDay: day,
      nickname: nickname,
      activityLevel: activityLevel,
      gender: gender,
      heightInCm: height,
    );
  }
}

// ignore: constant_identifier_names
enum BeurerActivityLevel { SEDENTARY, LIGHTLY_ACTIVE, MODERATELY_ACTIVE, VERY_ACTIVE, SUPER_ACTIVE }

enum BeurerSex {
  M,
  F,
}

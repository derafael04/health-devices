// ignore_for_file: constant_identifier_names

enum Brand {
  APPLE(manufacturerName: 'APPLE'),
  SAMSUNG(manufacturerName: 'SAMSUNG'),
  GOOGLE(manufacturerName: 'GOOGLE'),
  MICROSOFT(manufacturerName: 'MICROSOFT'),
  UNKNOWN(manufacturerName: 'UNKNOWN'),
  BEURER(manufacturerName: 'BEURER'),
  COOSPO(manufacturerName: 'COOSPO'),
  POLAR(manufacturerName: 'POLAR'),
  MY_BEAT(manufacturerName: 'MY_BEAT'),
  GARMIN(manufacturerName: 'GARMIN'),
  FITBIT(manufacturerName: 'FITBIT'),
  HUAWEI(manufacturerName: 'HUAWEI'),
  XIAOMI(manufacturerName: 'XIAOMI'),
  SONY(manufacturerName: 'SONY');

  const Brand({required this.manufacturerName});
  static Brand fromManufacturerName(String manufacturerName) {
    switch (manufacturerName) {
      case 'APPLE':
        return Brand.APPLE;
      case 'SAMSUNG':
        return Brand.SAMSUNG;
      case 'GOOGLE':
        return Brand.GOOGLE;
      case 'MICROSOFT':
        return Brand.MICROSOFT;
      case 'UNKNOWN':
        return Brand.UNKNOWN;
      case 'BEURER':
        return Brand.BEURER;
      case 'COOSPO':
        return Brand.COOSPO;
      case 'POLAR':
        return Brand.POLAR;
      case 'MY_BEAT':
        return Brand.MY_BEAT;
      case 'GARMIN':
        return Brand.GARMIN;
      case 'FITBIT':
        return Brand.FITBIT;
      case 'HUAWEI':
        return Brand.HUAWEI;
      case 'XIAOMI':
        return Brand.XIAOMI;
      case 'SONY':
        return Brand.SONY;
      default:
        return Brand.UNKNOWN;
    }
  }
  final String manufacturerName;
}

// ignore_for_file: constant_identifier_names

enum Model {
  UNKNOWN(name: 'UNKNOWN'),
  BF_1000(name: 'BF1000'),
  HW807(name: 'HW807'),
  HW706(name: 'HW706'),
  VERITY_SENSE(name: 'VERITY_SENSE'),;

  const Model({required this.name});
  static Model fromName(String name) {
    switch (name) {
      case 'BF1000':
        return Model.BF_1000;
      case 'HW807':
        return Model.HW807;
      case 'HW706':
        return Model.HW706;
      case 'VERITY_SENSE':
        return Model.VERITY_SENSE;
      default:
        return Model.UNKNOWN;
    }
  }
  final String name;
}

import '../../services/bluetooth/ble_body_composition_service.dart';
import '../../services/bluetooth/ble_weight_scale_service.dart';
import 'beurer_body_fat_data.dart';
import 'beurer_body_mass_data.dart';

class BeurerBiaData {
  BeurerBiaData({
    required this.bodyFatData,
    required this.skeletalMuscleMassData,
    required this.bodyCompositionData,
    required this.weightScaleData,
  });

  BeurerBodyFatData bodyFatData;
  BeurerSkeletalMuscleMassData skeletalMuscleMassData;
  BodyCompositionServiceData bodyCompositionData;
  WeightScaleMeasurement weightScaleData;
}

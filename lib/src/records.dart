/// This document holds the records definitions of commons data returned by the devices.
library;

/// The data available at the characteristic Body Composition Measurement (0x2A9C).
typedef BIAScaleBodyCompositionData = ({
  DateTime? timestamp,
  int? userIndex,
  double? basalMetabolism,
  double? musclePercentage,
  double? muscleMass,
  double? fatFreeMass,
  double? softLeanMass,
  double? bodyWaterMass,
  double? impedance,
  double? weight,
  double? height,
});

/// The data available at the characteristic Weight Scale Measurement (0x2A9D).
typedef BIAScaleWeightScaleData = ({
  DateTime? timestamp,
  double? weight,
  double? height,
  double? bodyMassIndex,
  int? userIndex,
});

/// The data available at the characteristic User Index (0x2A9A).
typedef BIAScaleUserIndexData = ({
  int? userIndex,
  String? userName,
});
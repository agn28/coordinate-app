import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';

class Helpers {

  /// Calculate age.
  /// [year], [month], ['date] are required as parameter
  calculateAge(year, month, date) {
    final birthDay = DateTime(int.parse(year), int.parse(month), int.parse(date));
    final now = DateTime.now();
    final ageInDays = now.difference(birthDay).inDays;
    final age = (ageInDays/365).floor();

    return age;
  }

  /// Convert [type] to lowercase and replace ' ' with '_'
  getType(type) {
    return type.toLowerCase().replaceAll(' ', '_');
  }

  /// Find if any blood pressure is added
  getBpStatus() {
    return BloodPressure().bpItems.length > 0 ? 'Complete' : 'Incomplete';
  }

  /// Find if any body measurement is added
  getBmStatus() {
    return BodyMeasurement().bmItems.length >= 3 ? 'Complete' : 'Incomplete';
  }

  /// Find if any blood test is added
  getBtStatus() {
    return BloodTest().btItems.length >= 7 ? 'Complete' : 'Incomplete';
  }

  /// Clear all added observations items from local variable.
  clearObservationItems() {
    BloodPressure().clearItems();
    BloodTest().clearItems();
    BodyMeasurement().clearItems();
  }
}

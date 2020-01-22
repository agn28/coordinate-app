import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';

class Helpers {
  calculateAge(year, month, date) {
    final birthDay = DateTime(int.parse(year), int.parse(month), int.parse(date));
    final now = DateTime.now();
    final ageInDays = now.difference(birthDay).inDays;
    final age = (ageInDays/365).floor();

    return age;
  }


  getType(type) {
    return type.toLowerCase().replaceAll(' ', '_');
  }

  getBpStatus() {
    return BloodPressure().bpItems.length > 0 ? 'Complete' : 'Incomplete';
  }

  getBmStatus() {
    return BodyMeasurement().bmItems.length >= 3 ? 'Complete' : 'Incomplete';
  }

  getBtStatus() {
    return BloodTest().btItems.length >= 7 ? 'Complete' : 'Incomplete';
  }
}

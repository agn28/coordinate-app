import 'package:basic_utils/basic_utils.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/questionnaire.dart';

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
    var data = BloodPressure().bpItems;
    if (data.length > 0) {
      if (data[0]['body']['data']['skip'] != null && data[0]['body']['data']['skip'] == true) {
        return 'Skipped';
      }
      return 'Complete';
    }
    return 'Incomplete';
  }

  /// Find if any body measurement is added
  getBmStatus() {
    var data = BodyMeasurement().bmItems;

    if (data.length >= 3) {
      return 'Complete';
    } else if (data.length > 0) {
      if (data[0]['body']['data']['skip'] != null && data[0]['body']['data']['skip'] == true) {
        return 'Skipped';
      }
    }
    return 'Incomplete';
  }

  /// Find if any blood test is added
  getBtStatus() {
    var data = BloodTest().btItems;

    if (data.length >= 7) {
      return 'Complete';
    } else if (data.length > 0) {
      if (data[0]['body']['data']['skip'] != null && data[0]['body']['data']['skip'] == true) {
        return 'Skipped';
      }
    }
    return 'Incomplete';
  }

  /// Clear all added observations items from local variable.
  clearObservationItems() {
    BloodPressure().clearItems();
    BloodTest().clearItems();
    BodyMeasurement().clearItems();
    Questionnaire().clearItems();
  }

  /// Clear all added assessment items from local variable.
  clearAssessment() {
    Assessment().clearItem();
  }

  convertDate(date) {
    return date != null ? DateFormat("MMMM d, y").format(DateTime.parse(date)) : '';
  }

  getPatientName(patient) {
    return '${patient['data']['first_name']} ${patient['data']['last_name']}';
  }

  getPatientAgeAndGender(patient) {
    return '${patient["data"]["age"]}Y ${StringUtils.capitalize(patient["data"]["gender"])}';
  }
}

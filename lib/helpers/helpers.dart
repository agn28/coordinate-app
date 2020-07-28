import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/auth_screen.dart';

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

  getQnStatus() {
    var data = Questionnaire().qnItems;

    if (data.length >= 6) {
      return 'Complete';
    } else if (data.length > 0) {
      if (data[0]['body']['data']['skip'] != null && data[0]['body']['data']['skip'] == true) {
        return 'Skipped';
      }
    }
    return 'Incomplete';
  }

  isInternetAvailable() async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    
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
  convertDateFromSeconds(date) {
    if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);

      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  getPatientName(patient) {
    return '${patient['data']['first_name']} ${patient['data']['last_name']}';
  }

  getPatientAgeAndGender(patient) {
    return '${patient["data"]["age"]}Y ${StringUtils.capitalize(patient["data"]["gender"])}';
  }

  logout(context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('sessionExpired'), style: TextStyle(fontWeight: FontWeight.w500),),
          content: Text(AppLocalizations.of(context).translate('sessionExpiredDetails')),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(context).translate('logout'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: kPrimaryColor),),
              onPressed:  () async {
                await Auth().logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
              },
            ),
          ],
        );
      },
    );
    
  }
}

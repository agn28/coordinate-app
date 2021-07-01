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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

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

  calculateDobFromAge(int age) {
    var date = DateTime.now();
    var newDate = DateTime(date.year - age, date.month, date.day);
    var birthDay = DateFormat("y-MM-dd").format(newDate);

    return birthDay;
  }

  calculateAgeFromDate(date) {
    final birthDay = DateFormat("dd/MM/yyyy").parse(date);
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
  getBmStatus(count) {
    var data = BodyMeasurement().bmItems;

    if (data.length >= count) {
      return 'Complete';
    } else if (data.length > 0) {
      if (data[0]['body']['data']['skip'] != null && data[0]['body']['data']['skip'] == true) {
        return 'Skipped';
      }
    }
    return 'Incomplete';
  }

  /// Find if any blood test is added
  getBtStatus(count) {
    var data = BloodTest().btItems;

    if (data.length >= count) {
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

  getPatientPid(patient) {
    print('patient topbar');
    if (patient["data"]["pid"] != null && patient["data"]["pid"] != '') {
      print(patient["data"]["pid"]);
      return 'PID:  ${patient["data"]["pid"]}';
    }
    return '';
  }

  logout(context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.wifi && connectivityResult != ConnectivityResult.mobile) {
      Get.dialog(
        AlertDialog(
          title: Text('You can not logout in offline mode.', style: TextStyle(fontWeight: FontWeight.w500),),
          // content: Text(AppLocalizations.of(context).translate('sessionExpiredDetails')),
          actions: [
            FlatButton(
              child: Text('Ok', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: kPrimaryColor),),
              onPressed:  () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      );

      return;
    }

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
              
                Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => AuthScreen()), (Route<dynamic> route) => false);
                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
              },
            ),
          ],
        );
      },
    );
    
  }

  bool isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

getQuestionText(context, question) {
  var locale = Localizations.localeOf(context);

  if (locale == Locale('bn', 'BN')) {
    print('true');
    return question['question_bn'];
  }
  return question['question'];
}

getOptionText(context, question, option) {
  var locale = Localizations.localeOf(context);

  if (locale == Locale('bn', 'BN')) {
    if (question['options_bn'] != null) {
      return question['options_bn'][question['options'].indexOf(option)];
    }
    return option;
    
  }
  return StringUtils.capitalize(option);
}

}

import 'package:intl/intl.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/auth_repository.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nhealth/repositories/patient_repository.dart';

class AuthController {

  /// Get all the patients
  login(email, password) async {
    var response = await AuthRepository().login(email, password);

    if (response['errors'] == null) {
      if (response['message'] != null) {
        return 'error';
      }

      Auth().setAuth(response);

    } else {
      print(response['errors']);
      return '';
    }

    return 'success';
  }

}

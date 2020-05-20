import 'package:intl/intl.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/followup_repository.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'dart:convert';

import 'package:nhealth/repositories/patient_repository.dart';

class FollowupController {

  /// Get all the patients
  create(data) async {
    var response = await FollowupRepository().create(data);

    return response;
  }

}

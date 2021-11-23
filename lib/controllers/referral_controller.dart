import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'package:nhealth/repositories/local/referral_repository_local.dart';
import 'package:nhealth/repositories/referral_repository.dart';
import 'package:nhealth/repositories/sync_repository.dart';
import 'package:uuid/uuid.dart';

class ReferralController {
  var referralRepo = ReferralRepository();
  var referralRepoLocal = ReferralRepositoryLocal();

  /// Get all the patients
  create(data, isSynced, {localStatus: ''}) async {
    var referralId = Uuid().v4();
    await referralRepoLocal.create(referralId, data, isSynced, localStatus: localStatus);
  }

  update(data) async {
    var response = await ReferralRepository().update(data);

    return response;
  }

  getReferralById(id) async {
    var response = await ReferralRepository().getReferralById(id);

    return response;
  }

  getReferralByAssessment(assessmentId) async {
    var patientId = Patient().getPatient()['id'];
    var referrals = await ReferralRepositoryLocal().getReferralsByPatient(patientId);
    var data = {};
    var parsedData;

    await referrals.forEach((item) {
      parsedData = jsonDecode(item['data']);
      if (parsedData['meta']['assessment_id'] == assessmentId) {
        data = {
          'id': item['id'],
          'body': parsedData['body'],
          'meta': parsedData['meta']
        };
      }
    });
    return data;
  }

  getFollowupsByPatient(patientID) async {
    var response = await ReferralRepository().getFollowupsByPatient(patientID);

    return response;
  }
}

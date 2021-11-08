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
  create(context, data) async {
    var referralId = Uuid().v4();

    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.

      var apiData = data;
      // apiData['id'] = referralId;

      var apiResponse = await ReferralRepository().create(apiData);

      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      } else if (apiResponse['exception'] != null) {
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }

        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));

        response = await referralRepoLocal.create(referralId, data, false);
        // Identifying this patient with not synced data
        await PatientReposioryLocal().updateLocalStatus(data['meta']['patient_id'], false);
        return response;
      } else if (apiResponse['error'] != null && apiResponse['error']) {
        // Scaffold.of(context).showSnackBar(SnackBar(
        //   content: Text("Error: ${apiResponse['message']}"),
        //   backgroundColor: kPrimaryRedColor,
        // ));
        return;
      } else if (apiResponse['error'] != null && !apiResponse['error']) {
        response = await referralRepoLocal.create(referralId, data, true);

        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          var updateSync = await SyncRepository()
              .updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
        }
        return response;
      }
      return response;
    } else {
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      response = await referralRepoLocal.create(referralId, data, false);
      // Identifying this patient with not synced data
      await PatientReposioryLocal().updateLocalStatus(data['meta']['patient_id'], false);
      return response;
    }
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

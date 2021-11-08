import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/care_plan_repository.dart';
import 'package:nhealth/repositories/health_report_repository.dart';
import 'package:nhealth/repositories/local/care_plan_repository_local.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'package:nhealth/repositories/sync_repository.dart';
import 'package:nhealth/constants/constants.dart';
import '../app_localizations.dart';
import 'package:uuid/uuid.dart';

class CarePlanController {

  /// Get all the patients
  // getCarePlan() async {
  //   var carePlan = await CarePlanRepository().getCarePlan();
  //   return carePlan;
  // }

  getCarePlan({checkAssignedTo: ''}) async {
    var apiResponse = await CarePlanRepository().getCarePlan(checkAssignedTo: checkAssignedTo);
    
    if (apiResponse['error'] != null && !apiResponse['error']) {
      return apiResponse;
    }

    var data = [];

    if (isNull(apiResponse) || isNotNull(apiResponse['exception'])) {

      var patientId = Patient().getPatient()['id'];
      var careplans = await CarePlanRepositoryLocal().getCareplanByPatient(patientId);

      var data = [];
      var parsedData;

      await careplans.forEach((careplan) {
        parsedData = jsonDecode(careplan['data']);
        if(checkAssignedTo == 'false') {
          if (parsedData['body']['patient_id'] == Patient().getPatient()['id']
          && parsedData['meta']['status'] == 'pending') {
            data.add({
              'id': careplan['id'],
              'body': parsedData['body'],
              'meta': parsedData['meta']
            });
          }
        } else {
          if (parsedData['body']['patient_id'] == Patient().getPatient()['id']
          && parsedData['meta']['status'] == 'pending'
          && parsedData['meta']['assigned_to'].contains(Auth().getAuth()['uid'])) {
            data.add({
              'id': careplan['id'],
              'body': parsedData['body'],
              'meta': parsedData['meta']
            });
          }
        }
        
      });


      var response = {
        'data': data,
        'error': false
      };
      return response;
      // return data;
    }
  }

  getLocalCarePlan() async {
    var patientId = Patient().getPatient()['id'];
    var carePlan = await CarePlanRepositoryLocal().getCareplanByPatient(patientId);
    return carePlan;
  }

  update(context, data, comment) async {

    // var response = await CarePlanRepository().update(data, comment);

    // if (response['error'] == false) {
    //   return 'success';
    // }

    // return 'error';
    
    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.

      var apiResponse = await CarePlanRepository().update(data, comment);

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return 'error';
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return 'error';
        }
        // exception type known (e.g: slow/no net)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));
        // creating local careplan with not synced status
        response = await CarePlanRepositoryLocal().completeLocalCarePlan(data['id'], data, comment, false);
        // Identifying this patient with not synced data
        await PatientReposioryLocal().updateLocalStatus(data['body']['patient_id'], false);
        return 'success';
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return 'error';
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        // creating local careplan with synced status
        response = await CarePlanRepositoryLocal().completeLocalCarePlan(data['id'], data, comment, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          var updateSync = await SyncRepository()
              .updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
        }
        return 'success';
      }
      return 'error';
    } else {
      // return;
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      // creating local careplan with not synced status
      response = await CarePlanRepositoryLocal().completeLocalCarePlan(data['id'], data, comment, false);
      // Identifying this patient with not synced data
      await PatientReposioryLocal().updateLocalStatus(data['body']['patient_id'], false);
      return 'success';
    }
  }

  getReports() async {
    var reports = await HealthReportRepository().getReports();
    return reports;
  }

  confirmAssessment(reports, comments) async {
    var data = _prepareConfirmData(reports, comments);
    var response = await HealthReportRepository().create(data);

    if (response == null) {
      return 'Server error';
    } else if (response['errors'] != null && response['errors'].isNotEmpty) {
      return 'Error! Data not Saved';
    } else {
      return 'success';
    }
    
  }

  sendForReview(reports, comments) async {
    var data = _prepareReviewData(reports, comments);
    var response = await HealthReportRepository().create(data);

    if (response == null) {
      return 'Server error';
    } else if (response['errors'] != null && response['errors'].isNotEmpty) {
      return 'Error! Data not Saved';
    } else {
      return 'success';
    }
    
  }

  _prepareReviewData(reports, comments) {
    var id = Uuid().v4();
    var patietnId = Patient().getPatient()['id'];
    patietnId = 'cef20c27-8082-4776-8d39-c18e0cbfab55';

    var data = {
      "id": id,
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now()),
        "review_required": true
      },
      "body": {
        "patient_id": patietnId,
        "comment": comments,
        "results": reports
      }
    };

    return data;
  }

  _prepareConfirmData(reports, comments) {
    var id = Uuid().v4();
    var patietnId = Patient().getPatient()['id'];
    patietnId = 'cef20c27-8082-4776-8d39-c18e0cbfab55';

    var data = {
      "id": id,
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "patient_id": patietnId,
        "comment": comments,
        "results": reports
      }
    };

    return data;
  }



}

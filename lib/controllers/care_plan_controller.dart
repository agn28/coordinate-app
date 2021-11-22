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
    // var apiResponse = await CarePlanRepository().getCarePlan(checkAssignedTo: checkAssignedTo);
    // if (apiResponse['error'] != null && !apiResponse['error']) {
    //   return apiResponse;
    // }

    // var data = [];

    // if (isNull(apiResponse) || isNotNull(apiResponse['exception'])) {
      var patientId = Patient().getPatient()['id'];
      var careplans = await CarePlanRepositoryLocal().getCareplanByPatient(patientId);
      // print('careplans: $careplans');
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


      // var response = {
      //   'data': data,
      //   'error': false
      // };
      // return response;
      // print('data $data');
      return data;
    // }
  }

  getLocalCarePlan() async {
    var patientId = Patient().getPatient()['id'];
    var carePlan = await CarePlanRepositoryLocal().getCareplanByPatient(patientId);
    return carePlan;
  }

  update(context, data, comment) async {
    try { 
      await CarePlanRepositoryLocal().completeLocalCarePlan(data['id'], data, comment, false);
      return 'success';
    } catch (error) {
      return error;
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

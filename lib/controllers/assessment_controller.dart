import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/repositories/assessment_repository.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:nhealth/repositories/observation_repository.dart';
import 'package:nhealth/repositories/sync_repository.dart';
import 'package:uuid/uuid.dart';

import '../app_localizations.dart';

var bloodPressures = [];

class AssessmentController {

  var assesmentRepoLocal = AssessmentRepositoryLocal();

  /// Get all the assessments.
  getAllAssessmentsByPatient() async {
    var assessments = await AssessmentRepositoryLocal().getAllAssessments();
    var data = [];
    var parsedData;

    await assessments.forEach((assessment) {
      parsedData = jsonDecode(assessment['data']);
      if (parsedData['body']['patient_id'] == Patient().getPatient()['id']) {
        data.add({
          'id': assessment['id'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      }
    });
    return data;
  }

  getAssessmentsByPatients(patientIds) async {
    var assessments = await AssessmentRepositoryLocal().getAllAssessments();
    var data = [];
    var parsedData;

    await assessments.forEach((assessment) {
      parsedData = jsonDecode(assessment['data']);
      if (parsedData['body']['patient_id'] == Patient().getPatient()['id']) {
        data.add({
          'id': assessment['id'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      }
    });
    return data;
  }

  getLiveAllAssessmentsByPatient() async {
    var response = await AssessmentRepository().getAllAssessments();

    print('encounter respose ' + response.toString());
    var data = [];
    // if (response == null) {
    //   return data;
    // }

    if (isNull(response) || isNotNull(response['exception'])) {
      print('into exception');
      var patientId = Patient().getPatient()['id'];
      var localResponse = await AssessmentRepositoryLocal().getAssessmentsByPatients(patientId);
      print('localResponse');
      print(localResponse);
      if (isNotNull(localResponse)) {
        localResponse.forEach((assessment) {

          var parseData = json.decode(assessment['data']);
          
          data.add({
            'id': assessment['id'],
            'data': parseData['body'],
            'meta': parseData['meta']
          });
        });
        
      }

      return data;

    }

    if (response['error'] != null && !response['error']) {
      await response['data'].forEach((assessment) {
        data.add({
          'id': assessment['id'],
          'data': assessment['body'],
          'meta': assessment['meta']
        });
      });
    }

    
    return data;
  }

  getAssessmentById(id) async {
    var assessment = await AssessmentRepository().getAssessmentsById(id);

    var data;

    // if (assessment['error'] != null && !assessment['error']) {
    //   data = {
    //     'id': assessment['data']['id'],
    //     'data': assessment['data']['body'],
    //     'meta': assessment['data']['meta']
    //   };
    // }

    return assessment;
  }

  /// Get all the assessments.
  getAllAssessments() async {
    var assessments = await AssessmentRepositoryLocal().getAllAssessments();
    var data = [];
    var parsedData;

    await assessments.forEach((assessment) {
      parsedData = jsonDecode(assessment['data']);
      data.add({
        'id': assessment['id'],
        'data': parsedData['body'],
        'meta': parsedData['meta']
      });
    });
    return data;
  }

  getAllLocalAssessments() async {
    var assessments = await AssessmentRepositoryLocal().getAllAssessments();
    var data = [];
    var parsedData;

    await assessments.forEach((assessment) {
      parsedData = jsonDecode(assessment['data']);
      data.add({
        'id': assessment['id'],
        'data': parsedData['body'],
        'meta': parsedData['meta']
      });
    });
    return data;
  }

  /// Get observations under a specific assessment.
  /// [assessment] object is required as parameter.
  getObservationsByAssessment(assessment) async {
    var observations = await AssessmentRepositoryLocal().getAllObservations();
    var data = [];
    var parsedData;

    await observations.forEach((item) {
      parsedData = jsonDecode(item['data']);
      if (parsedData['body']['patient_id'] == Patient().getPatient()['id'] && parsedData['body']['assessment_id'] == assessment['id']) {
        data.add({
          'id': item['id'],
          'body': {
            'type': parsedData['body']['type'],
            'data': parsedData['body']['data'],
            'comment': parsedData['body']['comment'],
            'patient_id': parsedData['body']['patient_id'],
            'assessment_id': parsedData['body']['assessment_id'],
          },
          'meta': parsedData['meta']
        });
      }
    });
    return data;
  }

  /// Get observations under a specific assessment.
  /// [assessment] object is required as parameter.
  getLiveObservationsByAssessment(assessment) async {
    var response = await AssessmentRepository().getObservationsByAssessment(assessment['id']);
    var data = [];

    if (response['error'] != null && !response['error']) {
      await response['data'].forEach((item) {
        data.add({
          'id': item['id'],
          'body': {
            'type': item['body']['type'],
            'data': item['body']['data'],
            'comment': item['body']['comment'],
            'patient_id': item['body']['patient_id'],
            'assessment_id': item['body']['assessment_id'],
          },
          'meta': item['meta']
        });
      });
    }
    return data;
  }

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  create(type, screening_type, comment) async {

    var data = _prepareData(type, screening_type, comment);
    var status = await AssessmentRepositoryLocal().create(data);
    if (status == 'success') {
      Helpers().clearObservationItems();
    }

    print('before health report');

    await Future.delayed(const Duration(seconds: 20));

    print('after health report');

    await HealthReportController().getReport();

    print('after health report');

    return status;
  }

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  createOnlyAssessment(type, screening_type, comment) async {

    var data = _prepareData(type, screening_type, comment);
    var status = await AssessmentRepositoryLocal().create(data);
    if (status == 'success') {
      Helpers().clearObservationItems();
    }

    print('before health report');

    return status;
  }



  createSyncAssessment(context, type, screening_type, comment) async {

    var data = _prepareData(type, screening_type, comment);

    var assessmentId = Uuid().v4();
    
    Map<String, dynamic> apiData = {
      'id': assessmentId
    };

    apiData.addAll(data);

    var response = await createAssessment(context, assessmentId, data, apiData);

    if (isNotNull(response)) {
      await ObservationController().prepareAndCreateObservations(context, assessmentId);
    }
    


  }

  createAssessment(context, assessmentId, data, apiData) async {

    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.

      print('connected');
      // return;

      print('live assessment create');

      var apiResponse = await AssessmentRepository().create(apiData);
      print('apiResponse');

      print(apiResponse);

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

        response = await assesmentRepoLocal.createLocalAssessment(assessmentId, data, false);
        return response;
      } else if (apiResponse['error'] != null && apiResponse['error']) {
        //TODO: need to change the logic
        if (apiResponse['message'] == 'Patient already exists.') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                "Error: ${AppLocalizations.of(context).translate('nidValidation')}"),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${apiResponse['message']}"),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
      } else if (apiResponse['error'] != null && !apiResponse['error']) {
        print('into success');
        response = await assesmentRepoLocal.createLocalAssessment(assessmentId, data, true);

        // response = await await PatientReposioryLocal()
        //         .createFromLive(response['patient']['id'], data);


        if (isNotNull(apiResponse['data']['sync']) && isNotNull(apiResponse['data']['sync']['key'])) {
          print('into assessment sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
        
 
        return response;
      }

      return response;
      // response = await PatientReposioryLocal().create(data);

    } else {
      print('not connected');
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Warning: No Internet. Using offline...'),
        backgroundColor: kPrimaryYellowColor,
      ));
      response = await assesmentRepoLocal.createLocalAssessment(assessmentId, data, false);
      return response;
    }
  }





  update(type, comment) {
    var data = _prepareUpdateData(type, comment);
    var status = AssessmentRepositoryLocal().update(data);
    if (status == 'success') {
      Helpers().clearObservationItems();
    }

    return status;
  }

  /// Prepare data to create an assessment.
  /// Assessment [type] and [comment] is required as parameter.
  _prepareUpdateData(type, comment) {
    var data = {
      "meta": Assessment().getSelectedAssessment()['meta'],
      "body": {
        "type": type == 'In-clinic Screening' ? 'in-clinic' : 'visit',
        "comment": comment,
        "performed_by": Assessment().getSelectedAssessment()['data']['performed_by'],
        "assessment_date": Assessment().getSelectedAssessment()['data']['assessment_date'],
        "patient_id": Assessment().getSelectedAssessment()['data']['patient_id']
      }
    };

    return data;
  }

  /// Prepare data to create an assessment.
  /// Assessment [type] and [comment] is required as parameter.
  _prepareData(type, screening_type, comment) {
    var data = {
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateTime.now().toString()
      },
      "body": {
        "type": type == 'In-clinic Screening' ? 'in-clinic' : type,
        "screening_type": screening_type,
        "comment": comment,
        "performed_by": Auth().getAuth()['uid'],
        "assessment_date": DateFormat('y-MM-dd').format(DateTime.now()),
        "patient_id": Patient().getPatient()['id']
      }
    };

    return data;
  }

  edit(assessment, observations) {
    Assessment().selectAssessment(assessment);
    Helpers().clearObservationItems();
    observations.forEach((item) {
      if (item['body']['type'] == 'body_measurement') {
        BodyMeasurement().addBmItemsForEdit(item);
      } else if (item['body']['type'] == 'blood_test') {
        BloodTest().addBtItemsForEdit(item);
      } else if (item['body']['type'] == 'blood_pressure') {
        BloodPressure().addBpItemsForEdit(item);
      } else if (item['body']['type'] == 'survey') {
        Questionnaire().addQnItemsForEdit(item);
        // BloodPressure().addBpItemsForEdit(item);
      }
    });
  }
  
}

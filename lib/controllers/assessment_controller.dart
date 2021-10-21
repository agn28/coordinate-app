import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/referral_controller.dart';
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
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:nhealth/repositories/local/observation_repository_local.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'package:nhealth/repositories/local/referral_repository_local.dart';
import 'package:nhealth/repositories/observation_repository.dart';
import 'package:nhealth/repositories/referral_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../app_localizations.dart';
import 'package:nhealth/repositories/sync_repository.dart';

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
    print('AssessmentController return data:  $data');
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
      var localResponse =
          await AssessmentRepositoryLocal().getAssessmentsByPatient(patientId);
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
  getLastAssessmentByPatientLocal({key: '', value: ''}) async {
    

    var data = {};

    // if (isNull(response) || isNotNull(response['exception'])) {
      print('into exception');
      var patientId = Patient().getPatient()['id'];
      var assessments = await AssessmentRepositoryLocal().getAssessmentsByPatient(patientId);
      print('localResponse');
      print(assessments);
      if (isNotNull(assessments)) {
        var lastAssessment = assessments.first;
        print('lastAssessment $lastAssessment');
        var parseData = json.decode(lastAssessment['data']);
        if(key == 'screening_type' && value == 'follow-up') {
          if(parseData['body']['screening_type'] == 'follow-up') {
            data = {
              'id': lastAssessment['id'],
              'data': parseData,
            };
          }
        } else {
          data = {
            'id': lastAssessment['id'],
            'data': parseData,
          };
        }
      }
        // localResponse.forEach((assessment) {
        //   var parseData = json.decode(assessment['data']);
        //   if(parseData['body']['screening_type'] == 'follow-up') {
        //     data.add({
        //       'id': assessment['id'],
        //       'data': parseData['body'],
        //       'meta': parseData['meta']
        //     });
        //   }
        // });
    // }
    return data;
  }

  getLastAssessmentByPatient({key: '', value: ''}) async {
    var response = await AssessmentRepository().getLastAssessment(key: key, value: value);
    
    if (response['error'] != null && !response['error']) {
      print('response ${response['data']['id']}');
      return response;
    }

    var data = {};

    if (isNull(response) || isNotNull(response['exception'])) {
      print('into exception');
      var patientId = Patient().getPatient()['id'];
      var assessments = await AssessmentRepositoryLocal().getAssessmentsByPatient(patientId);
      print('localResponse');
      print(assessments);
      if (isNotNull(assessments)) {
        var lastAssessment = assessments.first;
        var parseData = json.decode(lastAssessment['data']);
        if(key == 'screening_type' && value == 'follow-up') {
          if(parseData['body']['screening_type'] == 'follow-up') {
            data = {
              'id': lastAssessment['id'],
              'data': parseData,
            };
          }
        } else {
          data = {
            'id': lastAssessment['id'],
            'data': parseData,
          };
        }
      }
        // localResponse.forEach((assessment) {
        //   var parseData = json.decode(assessment['data']);
        //   if(parseData['body']['screening_type'] == 'follow-up') {
        //     data.add({
        //       'id': assessment['id'],
        //       'data': parseData['body'],
        //       'meta': parseData['meta']
        //     });
        //   }
        // });
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

  getIncompleteEncounterWithObservation(patientId, {key: '', value: ''}) async {
    var apiResponse;
    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.

      print('connected');

      print('live incomplete encounter');
      print(patientId);
      apiResponse = await AssessmentRepository().getIncompleteEncounterWithObservation(patientId, key: key, value: value);
      print('apiResponse');

      print(apiResponse);
      return apiResponse;
    } else {
      print('not connected');
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      var assessment = await AssessmentRepositoryLocal().getIncompleteAssessmentsByPatient(patientId);
      var observations = await getObservationsByAssessment(assessment.last);
      print('local assessment ${(assessment.last)}');
      print('local observations $observations');
      if (isNotNull(assessment) && assessment.isNotEmpty) {
        print('into local assessment');
        var parsedAssessment = {
          'id': assessment.last['id'],
          'body': jsonDecode(assessment.last['data'])['body'],
          'meta': jsonDecode(assessment.last['data'])['meta']
        };
        var response = {
          'data': {
            'assessment': parsedAssessment,
            'observations':(observations)
          },
          'error': false
        };
        print(response);
        return response;
      }

    }
    // var assessment = await AssessmentRepository()
    //     .getIncompleteEncounterWithObservation(patientId);

    // return assessment;
  }

  getIncompleteAssessmentsByPatient(patientId) async {
    var assessments = await AssessmentRepositoryLocal().getIncompleteAssessmentsByPatient(patientId);
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

  getIncompleteAssessmentWithObservations(patientId) async {
    var response = await AssessmentRepository().getIncompleteEncounterWithObservation(patientId);

    print('encounter respose ' + response.toString());
    var data = [];
    // if (response == null) {
    //   return data;
    // }

    if (isNull(response) || isNotNull(response['exception'])) {
      print('into exception');
      var patientId = Patient().getPatient()['id'];
      var localResponse =
          await AssessmentRepositoryLocal().getAssessmentsByPatient(patientId);
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

  /// Get observations under a specific assessment.
  /// [assessment] object is required as parameter.
  getObservationsByAssessment(assessment) async {
    var observations = await AssessmentRepositoryLocal().getAllObservations();
    var data = [];
    var parsedData;

    await observations.forEach((item) {
      parsedData = jsonDecode(item['data']);
      if (parsedData['body']['patient_id'] == Patient().getPatient()['id'] &&
          parsedData['body']['assessment_id'] == assessment['id']) {

      print(item);
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
  // getLiveAllAssessmentsByPatient() async {
  //   var response = await AssessmentRepository().getAllAssessments();

  //   print('encounter respose ' + response.toString());
  //   var data = [];
  //   // if (response == null) {
  //   //   return data;
  //   // }

  //   if (isNull(response) || isNotNull(response['exception'])) {
  //     print('into exception');
  //     var patientId = Patient().getPatient()['id'];
  //     var localResponse =
  //         await AssessmentRepositoryLocal().getAssessmentsByPatient(patientId);
  //     print('localResponse');
  //     print(localResponse);
  //     if (isNotNull(localResponse)) {
  //       localResponse.forEach((assessment) {
  //         var parseData = json.decode(assessment['data']);

  //         data.add({
  //           'id': assessment['id'],
  //           'data': parseData['body'],
  //           'meta': parseData['meta']
  //         });
  //       });
  //     }

  //     return data;
  //   }

  //   if (response['error'] != null && !response['error']) {
  //     await response['data'].forEach((assessment) {
  //       data.add({
  //         'id': assessment['id'],
  //         'data': assessment['body'],
  //         'meta': assessment['meta']
  //       });
  //     });
  //   }

  //   return data;
  // }

  /// Get observations under a specific assessment.
  /// [assessment] object is required as parameter.
  getLiveObservationsByAssessment(assessment) async {
    var response = await AssessmentRepository().getObservationsByAssessment(assessment['id']);
    var data = [];

    if (isNull(response) || isNotNull(response['exception'])) {
      print('into exception');
      var patientId = Patient().getPatient()['id'];
      var localResponse = await ObservationRepositoryLocal().getObservationsByPatient(patientId);
      print('localResponse');
      print(localResponse);
      if (isNotNull(localResponse)) {
        var localObservations = [];
        localResponse.forEach((observation) {
          var parseData = json.decode(observation['data']);
          print('observation ${parseData["body"]}');
          if(parseData['body']["assessment_id"] == assessment['id']) {
            data.add({
              'id': observation['id'],
              'body': {
                'type': parseData['body']['type'],
                'data': parseData['body']['data'],
                'comment': parseData['body']['comment'],
                'patient_id': observation['patient_id'],
                'assessment_id': parseData['body']['assessment_id'],
              },
              'meta': parseData['meta']
            });
          }
        });
      }

      return data;
    }

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
  createOnlyAssessment(context, type, screening_type, comment, status, nextVisitDate, {followupType: ''}) async 
  {
    var response;
    var data = _prepareData(type, screening_type, comment);
    data['body']['status'] = status;
    data['body']['next_visit_date'] = nextVisitDate;
    if (followupType != '') {
      data['body']['followup_type'] = followupType;
    }

    var assessmentId = Uuid().v4();
    Map<String, dynamic> apiData = {'id': assessmentId};
    apiData.addAll(data);

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.
      print('connected');
      //creating live assesment
      print('live assessment create');
      var apiResponse = await AssessmentRepository().create(apiData);
      print('assessment apiResponse $apiResponse');

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
        // exception type known (e.g: slow/no net)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));
        // creating local assessment with not synced status
        response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, false);
        // Identifying this patient with not synced data
        await PatientReposioryLocal().updateLocalStatus(data['body']['patient_id'], false);
      
        return response;
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        print('into success');
        // creating local assessment with synced status
        response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) && isNotNull(apiResponse['data']['sync']['key'])) {
          print('into assessment sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
        return response;
      }
      return response;
    } else {
      print('not connected');
      print(context);
      // return;
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      // creating local assessment with not synced status
      response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, false);
      // Identifying this patient with not synced data
      await PatientReposioryLocal().updateLocalStatus(data['body']['patient_id'], false);
      return response;
    }
  }

  // createSyncAssessment(context, type, screening_type, comment) async {

  //   var data = _prepareData(type, screening_type, comment);

  //   var assessmentId = Uuid().v4();

  //   Map<String, dynamic> apiData = {
  //     'id': assessmentId
  //   };

  //   apiData.addAll(data);

  //   var response = await createAssessment(context, assessmentId, data, apiData);

  //   if (isNotNull(response)) {
  //     await ObservationController().prepareAndCreateObservations(context, assessmentId);
  //   }

  // }

  createAssessment(context, assessmentId, data, apiData) async {
    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.
      print('connected');
      //creating live assesment
      print('live assessment create');
      var apiResponse = await AssessmentRepository().create(apiData);
      print('assessment apiResponse $apiResponse');

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
        // exception type known (e.g: slow/no net)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));
        // creating local assessment with not synced status
        response = await AssessmentRepositoryLocal()
            .createLocalAssessment(assessmentId, data, false);
        return response;
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        print('into success');
        // creating local assessment with synced status
        response = await AssessmentRepositoryLocal()
            .createLocalAssessment(assessmentId, data, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          print('into assessment sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
        return response;
      }
      return response;
    } else {
      print('not connected');
      print(context);
      // return;
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      // creating local assessment with not synced status
      response = await AssessmentRepositoryLocal()
          .createLocalAssessment(assessmentId, data, false);
      return response;
    }
  }

  createFollowupAssessment(type, screening_type, comment, completeStatus,
      nextVisitDate, followupType) async {
    var data = _prepareData(
      type,
      screening_type,
      comment,
    );
    data['body']['status'] = completeStatus;
    data['body']['followup_type'] = followupType;
    data['body']['next_visit_date'] = nextVisitDate;

    print('before health report');
    var status =
        await AssessmentRepositoryLocal().createOnlyAssessmentWithStatus(data);

    Future.delayed(const Duration(seconds: 5));
    print('after health report');

    if (completeStatus == 'complete') {
      HealthReportController().generateReport(data['body']['patient_id']);
    }
    Helpers().clearObservationItems();

    return status;
  }

  createSyncFollowUp(context, type, screening_type, comment, completeStatus,
      nextVisitDate, followupType) async {
    var data = _prepareData(type, screening_type, comment);
    data['body']['status'] = completeStatus;
    data['body']['followup_type'] = followupType;
    data['body']['next_visit_date'] = nextVisitDate;

    var assessmentId = Uuid().v4();
    Map<String, dynamic> apiData = {'id': assessmentId};

    apiData.addAll(data);

    //creating assesment
    var response = await createAssessment(context, assessmentId, data, apiData);

    //creating observations
    if (isNotNull(response)) {
      ObservationController()
          .prepareAndCreateObservations(context, assessmentId);

      if (completeStatus == 'complete') {
        HealthReportController().generateReport(data['body']['patient_id']);
      }
      Helpers().clearObservationItems();

      return response;
    }
  }

  createSyncAssessment(context, type, screening_type, comment, completeStatus,
      nextVisitDate) async {
    var data = _prepareData(type, screening_type, comment);
    data['body']['status'] = completeStatus;
    data['body']['next_visit_date'] = nextVisitDate;

    var assessmentId = Uuid().v4();
    Map<String, dynamic> apiData = {'id': assessmentId};

    apiData.addAll(data);

    //creating assesment
    var response = await createAssessment(context, assessmentId, data, apiData);

    //creating observations
    if (isNotNull(response)) {
      ObservationController()
          .prepareAndCreateObservations(context, assessmentId);

      if (completeStatus == 'complete') {
        HealthReportController().generateReport(data['body']['patient_id']);
      }
      Helpers().clearObservationItems();

      return response;
    }
  }

  createOnlyAssessmentWithStatus(
      type, screening_type, comment, completeStatus, nextVisitDate) async {
    var data = _prepareData(type, screening_type, comment);
    data['body']['status'] = completeStatus;
    data['body']['next_visit_date'] = nextVisitDate;
    print('before health report');
    var status =
        await AssessmentRepositoryLocal().createOnlyAssessmentWithStatus(data);

    Future.delayed(const Duration(seconds: 5));
    print('after health report');

    if (completeStatus == 'complete') {
      HealthReportController().generateReport(data['body']['patient_id']);
    }

    Helpers().clearObservationItems();

    return status;
  }

  createObservations(status, encounter, observations) async {
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    encounter['body']['status'] = status;

    var obsRepo = ObservationRepository();

    var bmobs = observations
        .where(
            (observation) => observation['body']['type'] == 'body_measurement')
        .toList();
    print('bmobs ${bmobs}');
    for (var bm in bodyMeasurements) {
      if (bmobs.isNotEmpty) {
        var matchedObs = bmobs.where((bmob) =>
            bmob['body']['data']['name'] == bm['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bm);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('body Measurements_if $apiData');
          await obsRepo.create(apiData);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bm);
        apiData['body']['assessment_id'] = encounter['id'];
        print('body Measurements_else $apiData');
        await obsRepo.create(apiData);
      }
    }

    var bpobs = observations
        .where((observation) => observation['body']['type'] == 'blood_pressure')
        .toList();
    print('bpobs ${bpobs}');

    for (var bp in bloodPressures) {
      if (bpobs.isNotEmpty) {
        var matchedObs = bpobs.where((bpob) =>
            bpob['body']['data']['name'] == bp['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bp);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('Blood Pressure_if $apiData');
          await obsRepo.create(apiData);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bp);
        apiData['body']['assessment_id'] = encounter['id'];
        print('Blood Pressure_else $apiData');
        await obsRepo.create(apiData);
      }
    }

    var btobs = observations
        .where((observation) => observation['body']['type'] == 'blood_test')
        .toList();
    print('btobs ${btobs}');
    for (var bt in bloodTests) {
      if (btobs.isNotEmpty) {
        var matchedObs = btobs.where((btob) =>
            btob['body']['data']['name'] == bt['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bt);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('Blood Test_if $apiData');
          await obsRepo.create(apiData);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bt);
        apiData['body']['assessment_id'] = encounter['id'];
        print('Blood Test_else $apiData');
        await obsRepo.create(apiData);
      }
    }

    var qstnobs = observations
        .where((observation) => observation['body']['type'] == 'survey')
        .toList();
    for (var qstn in questionnaires) {
      print('qstn ${qstn['body']['data']['name']}');
      if (qstnobs.isNotEmpty) {
        var matchedObs = qstnobs.where((qstnob) =>
            qstnob['body']['data']['name'] == qstn['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(qstn);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('Questionnaires_if $apiData');
          await obsRepo.create(apiData);
        } else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(qstn);
          apiData['body']['assessment_id'] = encounter['id'];
          print('Questionnaires_else $apiData');
          await obsRepo.create(apiData);
        }
      }
    }

    print('before health report');

    if (status == 'complete') {
      HealthReportController().generateReport(encounter['body']['patient_id']);
    }

    print('after health report');

    Helpers().clearObservationItems();
  }

  updateSyncIncompleteAssessment(context, status, encounter, observations) async {
    //creating assesment
    encounter['body']['status'] = status;
    print('upencounter $encounter');
    var response = await updateAssessment(context, encounter["id"], encounter);
    print('update response $response');
    //creating observations
    if (isNotNull(response)) {
      ObservationController().UpdateOrCreateObservations(context, status, encounter, observations);

      // if (completeStatus == 'complete') {
      //   HealthReportController().generateReport(data['body']['patient_id']);
      // }
      Helpers().clearObservationItems();

      return response;
    }
  }

  updateAssessment(context, assessmentId, data) async {
    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.
      print('connected');
      //creating live assesment
      print('live assessment update');
      var apiResponse = await AssessmentRepository().create(data);
      print('assessment apiResponse $apiResponse');

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
        // exception type known (e.g: slow/no net)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));
        // creating local assessment with not synced status
        response = await AssessmentRepositoryLocal()
            .updateLocalAssessment(assessmentId, data, false);
        return response;
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        print('into success');
        // creating local assessment with synced status
        response = await AssessmentRepositoryLocal()
            .updateLocalAssessment(assessmentId, data, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          print('into assessment sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
        return response;
      }
      return response;
    } else {
      print('not connected');
      // return;
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      // creating local assessment with not synced status
      response = await AssessmentRepositoryLocal()
          .updateLocalAssessment(assessmentId, data, false);
      return response;
    }
  }

  updateIncompleteAssessmentData(status, encounter, observations) async {
    createObservations(status, encounter, observations);
    print('before assessment');
    print(DateTime.now());
    await AssessmentRepository().createOnlyAssessment(encounter);

    return 'success';
  }
  createReferralByAssessmentLocal(type, referralData) async {
    var referral = await ReferralRepositoryLocal().getReferralById(referralData['id']);
    if(isNotNull(referral) && referral.isNotEmpty) {
      await ReferralRepositoryLocal().update(referralData['id'], referralData, false, localStatus: 'incomplete');
    } else {
      var incompleteAssessments = [];
      incompleteAssessments = await this.getAssessmentsByPatientWithLocalStatus('incomplete', assessmentType: type);
      if(incompleteAssessments.isNotEmpty) {
        print('not empty');
        referralData['meta']['assessment_id'] = incompleteAssessments.first['id'];
        print('testt: referralData ${referralData}');
        var referralId = Uuid().v4();
        await ReferralRepositoryLocal().create(referralId, referralData, false, localStatus: 'incomplete');
      }
    } 
  }

  createAssessmentWithObservationsLocal(context, type, screening_type, comment, completeStatus, nextVisitDate, {followupType: ''}) async {
    var incompleteAssessments = [];
    incompleteAssessments = await this.getAssessmentsByPatientWithLocalStatus('incomplete', assessmentType: type);
    if(incompleteAssessments.isNotEmpty) {
      print('not empty');
      print('assessmentId ${incompleteAssessments.first['id']}');
      var obs = await this.getObservationsByAssessment(incompleteAssessments.first);
      print('obs $obs');
      var apiDataObservations = await updateObservations(completeStatus, incompleteAssessments.first, obs);

      // await updateLocalAssessmentWithObservations(incompleteAssessments.first, apiDataObservations, false);
      await AssessmentRepositoryLocal().updateLocalAssessment(incompleteAssessments.first['id'], incompleteAssessments.first, false, localStatus: 'incomplete');
      for (var observation in apiDataObservations) {
        await ObservationRepositoryLocal().update(observation['id'], observation, false, localStatus: 'incomplete');
      }
      await PatientReposioryLocal().updateLocalStatus(incompleteAssessments.first['body']['patient_id'], false);
    } else {
      print('empty');
      var response;
      var assessmentData = _prepareData(type, screening_type, comment);
      print('data prepareData: $assessmentData');
      assessmentData['body']['status'] = completeStatus;
      assessmentData['body']['next_visit_date'] = nextVisitDate;
      if (followupType != '') {
        assessmentData['body']['followup_type'] = followupType;
      }
      var assessmentId = Uuid().v4();

      print('assessmentId ${assessmentId})');
      // Preparing all observations related to assessment
      var observations = await AssessmentRepositoryLocal().prepareObservations(assessmentId);

      response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, assessmentData, false, localStatus: 'incomplete');
      for (var observation in observations['localData']) {
        await ObservationRepositoryLocal().create(observation['id'], observation['data'], false, localStatus: 'incomplete');
      }
      await PatientReposioryLocal().updateLocalStatus(assessmentData['body']['patient_id'], false);
    }
    // var response;
    // var data = _prepareData(type, screening_type, comment);
    // print('data prepareData: $data');
    // data['body']['status'] = completeStatus;
    // data['body']['next_visit_date'] = nextVisitDate;
  //   if (followupType != '') {
  //     data['body']['followup_type'] = followupType;
  //   }

  //   var assessmentId = Uuid().v4();

  //  // Preparing all observations related to assessment
  //   var observations = await AssessmentRepositoryLocal().prepareObservations(assessmentId);

  //   response = await storeLocalAssessmentWithObservations(assessmentId, data, observations['localData'], false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Saved in Local"),
      backgroundColor: kPrimaryGreenColor,
    ));
    // print('localResponse $response');
    
    // return response;
  }
  createAssessmentWithObservationsLive(type, {assessmentStatus:'incomplete', followupType:'', createdAt:''}) async {
    var localNotSyncedAssessment = [];
    localNotSyncedAssessment = await this.getAssessmentsByPatientWithLocalStatus('incomplete', assessmentType: type);
    if(localNotSyncedAssessment.isNotEmpty) {
      var localNotSyncedObservations = await this.getObservationsByAssessment(localNotSyncedAssessment.first);
      var localNotSyncedReferral = await ReferralController().getReferralByAssessment(localNotSyncedAssessment.first['id']);
      print('ref $localNotSyncedReferral');
      print('obs $localNotSyncedObservations');
      print('localNotSyncedAssessment ${localNotSyncedAssessment.first})');
      localNotSyncedAssessment.first['body']['status'] = assessmentStatus;
      assessmentStatus == 'complete' ? localNotSyncedAssessment.first['meta']['completed_at'] = DateTime.now().toString() : null;
      createdAt == '' ? localNotSyncedAssessment.first['meta']['created_at'] = DateTime.now().toString() : createdAt;
      var apiDataObservations = await updateObservations(localNotSyncedAssessment.first['body']['status'], localNotSyncedAssessment.first, localNotSyncedObservations);
      Map<String, dynamic> apiData = {
        'assessment': localNotSyncedAssessment.first,
        'observations': apiDataObservations
      };
      print('apiData $apiData');
      if(localNotSyncedAssessment.first['body']['type'] == 'community clinic assessment' || localNotSyncedAssessment.first['body']['type'] == 'community clinic followup') {
        createdAt == '' ? localNotSyncedReferral['meta']['created_at'] = DateTime.now().toString() : createdAt;
        var response = await storeAssessmentWithObservationsLive(localNotSyncedAssessment.first, apiDataObservations, apiData, referralData: localNotSyncedReferral);
      } else {
        var response = await storeAssessmentWithObservationsLive(localNotSyncedAssessment.first, apiDataObservations, apiData);
      }
    }
    if (localNotSyncedAssessment.first['body']['status'] == 'complete') {
      await HealthReportController().generateReport(localNotSyncedAssessment.first['body']['patient_id']);
    }
    Helpers().clearObservationItems();
  }

  updateAssessmentWithObservationsLive(assessmentStatus, encounter, observations) async {
    
    var apiDataObservations = await updateObservations(assessmentStatus, encounter, observations);
    assessmentStatus == 'complete' ? encounter['meta']['completed_at'] = DateTime.now().toString() : null;
    Map<String, dynamic> apiData = {
      'assessment': encounter,
      'observations': apiDataObservations
    };
    print('apiData $apiData');
    
    var response = await storeAssessmentWithObservationsLive(encounter, apiDataObservations, apiData);
  
    if (assessmentStatus == 'complete') {
      await HealthReportController().generateReport(encounter['patient_id']);
    }
    Helpers().clearObservationItems();
  }

  storeAssessmentWithObservationsLive(assessmentData, observationsData, apiData, {referralData:''}) async {
    var response;
    response = await AssessmentRepositoryLocal().updateLocalAssessment(assessmentData['id'], assessmentData, false, localStatus: 'complete');
    for (var observation in observationsData) {
      await ObservationRepositoryLocal().update(observation['id'], observation, false, localStatus: 'complete');
    }
    if(referralData != '' && referralData != null && referralData.isNotEmpty) {
      await ReferralRepositoryLocal().update(referralData['id'], referralData, false, localStatus: 'complete');
    }
    // Identifying this patient with not synced data
    await PatientReposioryLocal().updateLocalStatus(assessmentData['body']['patient_id'], false);
      
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.
      print('connected');
      var apiResponse = await AssessmentRepository().createAssessmentWithObservations(apiData);
      print('apiResponse $apiResponse');
      //API responded success with no error
      if (apiResponse['error'] != null && !apiResponse['error']) {
        print('into success');
        // updating local assessment with synced status
        // response = await updateLocalAssessmentWithObservations(assessmentData, observationsData, true);
        response = await AssessmentRepositoryLocal().updateLocalAssessment(assessmentData['id'], assessmentData, true, localStatus: 'complete');
        for (var observation in observationsData) {
          await ObservationRepositoryLocal().update(observation['id'], observation, true);
        }
        // Identifying this patient with not synced data
        await PatientReposioryLocal().updateLocalStatus(assessmentData['body']['patient_id'], true);
      
        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) && isNotNull(apiResponse['data']['sync']['key'])) {
          print('into sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
      } 

      //calling referral create API
      var referalResponse = await ReferralRepository().create(referralData);
      print('referalResponse $referalResponse');
      //API responded success with no error
      if (referalResponse['error'] != null && !referalResponse['error']) {
        print('into success');
        // updating local assessment with synced status
        response = await ReferralRepositoryLocal().update(referralData['id'], referralData, true, localStatus: 'complete');
        
        // Identifying this patient with not synced data
        await PatientReposioryLocal().updateLocalStatus(referralData['meta']['patient_id'], true);
      
        //updating sync key
        if (isNotNull(referalResponse['data']['sync']) && isNotNull(referalResponse['data']['sync']['key'])) {
          print('into sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(referalResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
      } 
    }
    return response;
  }

  getAssessmentsByPatientWithLocalStatus(localStatus, {assessmentType: ''}) async {
    var data = [];
    var patientId = Patient().getPatient()['id'];
    var localResponse = await AssessmentRepositoryLocal().getAssessmentsByPatientWithLocalStatus(patientId, localStatus);
    print('localResponse $localResponse');
    print(localResponse);
    if (isNotNull(localResponse)) {
      localResponse.forEach((assessment) {
        var parseData = json.decode(assessment['data']);
        if (assessmentType != '') {
          if(parseData['body']['type'] == assessmentType) {
            data.add({
              'id': assessment['id'],
              'body': parseData['body'],
              'meta': parseData['meta']
            });
          }
        } else {
          data.add({
            'id': assessment['id'],
            'body': parseData['body'],
            'meta': parseData['meta']
          });
        }
      });
    }

    return data;
  }

  createAssessmentWithObservations(context, type, screening_type, comment, completeStatus, nextVisitDate, {followupType: ''}) async {
    var response;
    var data = _prepareData(type, screening_type, comment);
    print('data prepareData: $data');
    data['body']['status'] = completeStatus;
    data['body']['next_visit_date'] = nextVisitDate;
    if (followupType != '') {
      data['body']['followup_type'] = followupType;
    }

    // Preparing assessment data for API
    var assessmentId = Uuid().v4();
    Map<String, dynamic> apiDataAssessment = {'id': assessmentId};
    apiDataAssessment.addAll(data);

    // await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, false);

    // Preparing all observations related to assessment
    var observations = await AssessmentRepositoryLocal().prepareObservations(assessmentId);

    // Preparing API request data
    Map<String, dynamic> apiData = {
      'assessment': apiDataAssessment,
      'observations': observations['apiData']
    };
    print('apiData $apiData');
    response = await storeAssessmentWithObservations(context, assessmentId, data, observations['localData'], apiData);
    print('apiResponse $response');

    //TODO: online offline generate
    if (completeStatus == 'complete') {
      await HealthReportController().generateReport(data['body']['patient_id']);
    }

    Helpers().clearObservationItems();

    print('createAssessmentWithObservations response:  $response');

    return response;
  }

  storeAssessmentWithObservations(context, assessmentId, assessmentData, observationsData, apiData) async {
    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.
      print('connected');
      //creating live assesment & observation
      print('live assessment & observation create');
      var apiResponse = await AssessmentRepository().createAssessmentWithObservations(apiData);
      print('apiResponse $apiResponse');

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
        // exception type known (e.g: slow/no net)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));
        // creating local assessment with not synced status
        // response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, false);
        response = await storeLocalAssessmentWithObservations(assessmentId, assessmentData, observationsData, false);
        return response;
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        print('into success');
        // creating local assessment with synced status
        response = await storeLocalAssessmentWithObservations(assessmentId, assessmentData, observationsData, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) && isNotNull(apiResponse['data']['sync']['key'])) {
          print('into sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
        return response;
      }
      return response;
    } else {
      print('not connected');
      print(context);
      // return;
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      // creating local assessment with not synced status
      response = await storeLocalAssessmentWithObservations(assessmentId, assessmentData, observationsData, false);
      return response;
    }
  }

  storeUpdatedAssessmentWithObservations(context, assessmentData, observationsData, apiData) async {
    var response;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.
      print('connected');
      //creating live assesment & observation
      print('live assessment & observation create');
      var apiResponse = await AssessmentRepository().createAssessmentWithObservations(apiData);
      print('apiResponse $apiResponse');

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
        // exception type known (e.g: slow/no net)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));
        // creating local assessment with not synced status
        // response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, false);
        response = await updateLocalAssessmentWithObservations(assessmentData, observationsData, false);
        return response;
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        print('into success');
        // creating local assessment with synced status
        response = await updateLocalAssessmentWithObservations(assessmentData, observationsData, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) && isNotNull(apiResponse['data']['sync']['key'])) {
          print('into sync update');
          var updateSync = await SyncRepository().updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }
        return response;
      }
      return response;
    } else {
      print('not connected');
      print(context);
      // return;
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));
      // creating local assessment with not synced status
      response = await updateLocalAssessmentWithObservations(assessmentData, observationsData, false);
      return response;
    }
  }

  storeLocalAssessmentWithObservations(assessmentId, assessmentData, observationsData, isSynced) async {
    var response;
    response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, assessmentData, isSynced);
    for (var observation in observationsData) {
      await ObservationRepositoryLocal().create(observation['id'], observation['data'], isSynced);
    }
    // Identifying this patient with not synced data
    await PatientReposioryLocal().updateLocalStatus(assessmentData['body']['patient_id'], isSynced);

  }
  updateLocalAssessmentWithObservations(assessmentData, observationsData, isSynced) async {
    var response;
    response = await AssessmentRepositoryLocal().updateLocalAssessment(assessmentData['id'], assessmentData, isSynced);
    for (var observation in observationsData) {
      await ObservationRepositoryLocal().update(observation['id'], observation, isSynced);
    }
    // Identifying this patient with not synced data
    await PatientReposioryLocal().updateLocalStatus(assessmentData['body']['patient_id'], isSynced);
  }

  updateObservations(status, encounter, observations) async {
    List apiDataObservations = [];
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;
    print(encounter);
    encounter['body']['status'] = status;

    var obsRepoLocal = ObservationRepositoryLocal();

    var bmobs = observations.where((observation) => observation['body']['type'] == 'body_measurement').toList();
    print('bmobs ${bmobs}');
    for (var bm in bodyMeasurements) {
      print('bm $bm');
      // If previous observation exists
      if (bmobs.isNotEmpty) {
        var matchedObs = bmobs.where((bmob) =>
            bmob['body']['data']['name'] == bm['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        // Previous observation is updated
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bm);
          apiData['body']['assessment_id'] = matchedObs['body']['assessment_id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('body Measurements_if $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.update(matchedObs['id'], apiData, false);
        }
        // new observation entered
        else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(bm);
          apiData['body']['assessment_id'] = encounter['id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('body Measurements_else $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.create(id, apiData, false);
        }
      }
      // If previous observation does not exist
      else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bm);
        apiData['body']['assessment_id'] = encounter['id'];
        apiData['meta']['created_at'] = encounter['meta']['created_at'];
        print('body Measurements_else $apiData');
        apiDataObservations.add(apiData);
        await obsRepoLocal.create(id, apiData, false);
      }
    }

    var bpobs = observations
        .where((observation) => observation['body']['type'] == 'blood_pressure')
        .toList();
    print('bpobs ${bpobs}');

    for (var bp in bloodPressures) {
      if (bpobs.isNotEmpty) {
        var matchedObs = bpobs.where((bpob) =>
            bpob['body']['data']['name'] == bp['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bp);
          apiData['body']['assessment_id'] = matchedObs['body']['assessment_id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('Blood Pressure_if $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.update(matchedObs['id'], apiData, false);
        } else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(bp);
          apiData['body']['assessment_id'] = encounter['id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('Blood Pressure_else $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.create(id, apiData, false);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bp);
        apiData['body']['assessment_id'] = encounter['id'];
        apiData['meta']['created_at'] = encounter['meta']['created_at'];
        print('Blood Pressure_else $apiData');
        apiDataObservations.add(apiData);
        await obsRepoLocal.create(id, apiData, false);
      }
    }

    var btobs = observations
        .where((observation) => observation['body']['type'] == 'blood_test')
        .toList();
    print('btobs ${btobs}');
    print('btests ${bloodTests}');
    for (var bt in bloodTests) {
      if (btobs.isNotEmpty) {
        // var matchedObs = btobs.where((btob) =>
        //     btob['body']['data']['name'] == bt['body']['data']['name']);
        // print('matchedObs ${matchedObs}');
        var matchedObs;
        if(bt['body']['data']['name'] == 'blood_sugar') {
          matchedObs = btobs.where((btob) {
            if(btob['body']['data']['name'] == bt['body']['data']['name']) {
              if(btob['body']['data']['type'] == null && bt['body']['data']['type'] == null) {
                print('btif');
                return true;
              } else if(btob['body']['data']['type'] != null && bt['body']['data']['type'] != null
                && btob['body']['data']['type'] == bt['body']['data']['type']) {
                print('btelif');
                return true;
              } 
              print('btel');
              return false;
            } return false;
          });
        } else {
          matchedObs = btobs.where((btob) => btob['body']['data']['name'] == bt['body']['data']['name']);
        }
        print('matchedbtObs ${matchedObs}');
        
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bt);
          apiData['body']['assessment_id'] = matchedObs['body']['assessment_id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('Blood Test_if $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.update(matchedObs['id'], apiData, false);
        } else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(bt);
          apiData['body']['assessment_id'] = encounter['id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('Blood Test_else $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.create(id, apiData, false);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bt);
        apiData['body']['assessment_id'] = encounter['id'];
        apiData['meta']['created_at'] = encounter['meta']['created_at'];
        print('Blood Test_else $apiData');
        apiDataObservations.add(apiData);
        await obsRepoLocal.create(id, apiData, false);
      }
    }

    var qstnobs = observations.where((observation) => observation['body']['type'] == 'survey').toList();
    for (var qstn in questionnaires) {
      print('qstn ${qstn['body']['data']['name']}');
      if (qstnobs.isNotEmpty) {
        var matchedObs = qstnobs.where((qstnob) =>
            qstnob['body']['data']['name'] == qstn['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(qstn);
          apiData['body']['assessment_id'] = matchedObs['body']['assessment_id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('Questionnaires_if $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.update(matchedObs['id'], apiData, false);
        } else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(qstn);
          apiData['body']['assessment_id'] = encounter['id'];
          apiData['meta']['created_at'] = encounter['meta']['created_at'];
          print('Questionnaires_else $apiData');
          apiDataObservations.add(apiData);
          await obsRepoLocal.create(id, apiData, false);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(qstn);
        apiData['body']['assessment_id'] = encounter['id'];
        apiData['meta']['created_at'] = encounter['meta']['created_at'];
        print('Questionnaires_else $apiData');
        apiDataObservations.add(apiData);
        await obsRepoLocal.create(id, apiData, false);
      }
    }

    return apiDataObservations;
  }

  updateAssessmentWithObservations(context, status, encounter, observations) async {
    var response;
    // Preparing all observations related to assessment
    // var observations = await AssessmentRepositoryLocal().prepareObservations(assessmentId);
    var apiDataObservations = await updateObservations(status, encounter, observations);

    // Preparing API request data
    Map<String, dynamic> apiData = {
      'assessment': encounter,
      'observations': apiDataObservations
    };
    print('apiData $apiData');
    response = await storeUpdatedAssessmentWithObservations(context, encounter, apiDataObservations, apiData);
    print('apiResponse $response');

    if (status == 'complete') {
      await HealthReportController().generateReport(encounter['body']['patient_id']);
    }
    Helpers().clearObservationItems();
    return response;

    // return;
    // var apiDataObservations = await updateObservations(status, encounter, observations);
    // print('apiDataObservations $apiDataObservations');
    // // Preparing API request data
    // Map<String, dynamic> apiData = {
    //   'assessment': encounter,
    //   'observations': apiDataObservations
    // };
    // print('apiData $apiData');
    // print('before assessment');
    // print(DateTime.now());
    // // Call API
    // var apiResponse = await AssessmentRepository().createAssessmentWithObservations(apiData);
    // //Could not get any response from API
    // if (apiResponse == null) {
    //   Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //         "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
    //     backgroundColor: kPrimaryRedColor,
    //   ));
    //   // return;
    // }
    // //API did not respond due to handled exception
    // else if (apiResponse['exception'] != null) {
    //   Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text('Error: ${apiResponse['message']}'),
    //     backgroundColor: kPrimaryRedColor,
    //   ));
    //   // return;
    // }
    // //API responded with error
    // else if (apiResponse['error'] != null && apiResponse['error']) {
    //   Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text("Error: ${apiResponse['message']}"),
    //     backgroundColor: kPrimaryRedColor,
    //   ));
    //   // return;
    // }
    // //API responded success with no error
    // else if (apiResponse['error'] != null && !apiResponse['error']) {
    //   print('into success');
    //   // creating local assessment with synced status
    //   // response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, true);
    //   // print('response $response');

    //   if (status == 'complete') {
    //     print('before health report');
    //     HealthReportController().generateReport(encounter['body']['patient_id']);
    //     print('after health report');
    //   }
    //   // return response;
    // }

    // return;
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
        "performed_by": Assessment().getSelectedAssessment()['data']
            ['performed_by'],
        "assessment_date": Assessment().getSelectedAssessment()['data']
            ['assessment_date'],
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
  deleteAssessment(id) {
    var response = AssessmentRepository().delete(id);
    return response;
  }
}

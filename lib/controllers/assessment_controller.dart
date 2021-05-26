import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
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
import 'package:nhealth/repositories/observation_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../app_localizations.dart';

var bloodPressures = [];

class AssessmentController {
  /// Get all the assessments.
  getAllAssessmentsByPatient() async {
    var assessments = await AssessmentRepositoryLocal().getAllAssessments();
    var data = [];
    var parsedData;

    await assessments.forEach((assessment) {
      parsedData = jsonDecode(assessment['data']);
      if (parsedData['body']['patient_id'] == Patient().getPatient()['uuid']) {
        data.add({
          'uuid': assessment['uuid'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      }
    });
    return data;
  }

  getLiveAllAssessmentsByPatient() async {
    var assessments = await AssessmentRepository().getAllAssessments();
    var data = [];
    if (assessments == null) {
      return data;
    }

    if (assessments['error'] != null && !assessments['error']) {
      await assessments['data'].forEach((assessment) {
        data.add({
          'uuid': assessment['id'],
          'data': assessment['body'],
          'meta': assessment['meta']
        });
      });
    }

    return data;
  }

  getLastAssessmentByPatient(followupType) async {
    var assessment =
        await AssessmentRepository().getLastAssessment(followupType);
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
        'uuid': assessment['uuid'],
        'data': parsedData['body'],
        'meta': parsedData['meta']
      });
    });
    return data;
  }

  getIncompleteEncounterWithObservation(patientId) async {
    var assessment = await AssessmentRepository().getIncompleteEncounterWithObservation(patientId);

    return assessment;
  }

  /// Get observations under a specific assessment.
  /// [assessment] object is required as parameter.
  getObservationsByAssessment(assessment) async {
    var observations = await AssessmentRepositoryLocal().getAllObservations();
    var data = [];
    var parsedData;

    await observations.forEach((item) {
      parsedData = jsonDecode(item['data']);
      if (parsedData['body']['patient_id'] == Patient().getPatient()['uuid'] &&
          parsedData['body']['assessment_id'] == assessment['uuid']) {
        data.add({
          'uuid': item['uuid'],
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
    var response = await AssessmentRepository()
        .getObservationsByAssessment(assessment['uuid']);
    var data = [];

    if (response['error'] != null && !response['error']) {
      await response['data'].forEach((item) {
        data.add({
          'uuid': item['id'],
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

  createOnlyAssessmentWithStatus(
      type, screening_type, comment, completeStatus, nextVisitDate) async {
    var data = _prepareData(
      type,
      screening_type,
      comment,
    );
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

  createAssessmentWithObservations(
      context, type, screening_type, comment, completeStatus, nextVisitDate,
      {followupType: ''}) async {
    var response;
    var data = _prepareData(type, screening_type, comment);
    data['body']['status'] = completeStatus;
    data['body']['next_visit_date'] = nextVisitDate;
    if (followupType != '') {
      data['body']['followup_type'] = followupType;
    }

    var assessmentId = Uuid().v4();

    await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data);

    // Preparing assessment data for API call
    Map<String, dynamic> apiDataAssessment = {'id': assessmentId};
    apiDataAssessment.addAll(data);

    // Preparing all observations related to assessment
    var apiDataObservations =
        await AssessmentRepositoryLocal().prepareObservations(assessmentId);

    // Preparing API request data
    Map<String, dynamic> apiData = {
      'assessment': apiDataAssessment,
      'observations': apiDataObservations
    };
    print('apiData $apiData');
    // Call API
    var apiResponse =
        await AssessmentRepository().createAssessmentWithObservations(apiData);
    //----
    //Could not get any response from API
    if (apiResponse == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
        backgroundColor: kPrimaryRedColor,
      ));
      // return;
    }
    //API did not respond due to handled exception
    else if (apiResponse['exception'] != null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${apiResponse['message']}'),
        backgroundColor: kPrimaryRedColor,
      ));
      // return;
    }
    //API responded with error
    else if (apiResponse['error'] != null && apiResponse['error']) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${apiResponse['message']}"),
        backgroundColor: kPrimaryRedColor,
      ));
      // return;
    }
    //API responded success with no error
    else if (apiResponse['error'] != null && !apiResponse['error']) {
      print('into success');
      // creating local assessment with synced status
      // response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, true);
      // print('response $response');

      if (completeStatus == 'complete') {
        print('before health report');
        HealthReportController().generateReport(data['body']['patient_id']);
        print('after health report');
      }
      // return response;
    }

    Helpers().clearObservationItems();

    return;
  }

  updateObservations(status, encounter, observations) async {
    List apiDataObservations = [];
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    encounter['body']['status'] = status;

    // var obsRepo = ObservationRepository();

    var bmobs = observations
        .where(
            (observation) => observation['body']['type'] == 'body_measurement')
        .toList();
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
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('body Measurements_if $apiData');
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        }
        // new observation entered
        else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(bm);
          apiData['body']['assessment_id'] = encounter['id'];
          print('body Measurements_else $apiData');
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        }
      }
      // If previous observation does not exist
      else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bm);
        apiData['body']['assessment_id'] = encounter['id'];
        print('body Measurements_else $apiData');
        apiDataObservations.add(apiData);
        // await obsRepo.create(apiData);
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
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        } else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(bp);
          apiData['body']['assessment_id'] = encounter['id'];
          print('Blood Pressure_else $apiData');
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bp);
        apiData['body']['assessment_id'] = encounter['id'];
        print('Blood Pressure_else $apiData');
        apiDataObservations.add(apiData);
        // await obsRepo.create(apiData);
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
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        } else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(bt);
          apiData['body']['assessment_id'] = encounter['id'];
          print('Blood Test_else $apiData');
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(bt);
        apiData['body']['assessment_id'] = encounter['id'];
        print('Blood Test_else $apiData');
        apiDataObservations.add(apiData);
        // await obsRepo.create(apiData);
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
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        } else {
          var id = Uuid().v4();
          Map<String, dynamic> apiData = {'id': id};
          apiData.addAll(qstn);
          apiData['body']['assessment_id'] = encounter['id'];
          print('Questionnaires_else $apiData');
          apiDataObservations.add(apiData);
          // await obsRepo.create(apiData);
        }
      } else {
        var id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(qstn);
        apiData['body']['assessment_id'] = encounter['id'];
        print('Questionnaires_else $apiData');
        apiDataObservations.add(apiData);
        // await obsRepo.create(apiData);
      }
    }

    return apiDataObservations;
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

  updateAssessmentWithObservations(context, status, encounter, observations) async {
    var apiDataObservations =
        await updateObservations(status, encounter, observations);
    print('apiDataObservations $apiDataObservations');
    // Preparing API request data
    Map<String, dynamic> apiData = {
      'assessment': encounter,
      'observations': apiDataObservations
    };
    print('apiData $apiData');
    print('before assessment');
    print(DateTime.now());
    // Call API
    var apiResponse =
        await AssessmentRepository().createAssessmentWithObservations(apiData);
    //Could not get any response from API
    if (apiResponse == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
        backgroundColor: kPrimaryRedColor,
      ));
      // return;
    }
    //API did not respond due to handled exception
    else if (apiResponse['exception'] != null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${apiResponse['message']}'),
        backgroundColor: kPrimaryRedColor,
      ));
      // return;
    }
    //API responded with error
    else if (apiResponse['error'] != null && apiResponse['error']) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${apiResponse['message']}"),
        backgroundColor: kPrimaryRedColor,
      ));
      // return;
    }
    //API responded success with no error
    else if (apiResponse['error'] != null && !apiResponse['error']) {
      print('into success');
      // creating local assessment with synced status
      // response = await AssessmentRepositoryLocal().createLocalAssessment(assessmentId, data, true);
      // print('response $response');

      if (status == 'complete') {
        print('before health report');
        HealthReportController().generateReport(encounter['body']['patient_id']);
        print('after health report');
      }
      // return response;
    }

    return;
  }

  updateIncompleteAssessmentData(status, encounter, observations) async {
    createObservations(status, encounter, observations);
    print('before assessment');
    print(DateTime.now());
    await AssessmentRepository().createOnlyAssessment(encounter);

    return 'success';
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
        "patient_id": Patient().getPatient()['uuid']
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

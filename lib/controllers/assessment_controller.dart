import 'package:nhealth/controllers/health_report_controller.dart';
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
import 'package:uuid/uuid.dart';

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
      if (parsedData['body']['patient_id'] == Patient().getPatient()['uuid'] && parsedData['body']['assessment_id'] == assessment['uuid']) {
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
    var response = await AssessmentRepository().getObservationsByAssessment(assessment['uuid']);
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

  createOnlyAssessmentWithStatus(type, screening_type, comment, completeStatus, nextVisitDate) async {

    var data = _prepareData(type, screening_type, comment,);
    data['body']['status'] = completeStatus;
    data['body']['next_visit_date'] = nextVisitDate;
    var status = await AssessmentRepositoryLocal().createOnlyAssessmentWithStatus(data);
    Helpers().clearObservationItems();

    print('before health report');

    return status;
  }

  updateIncompleteAssessmentData(status, encounter, observations) async {

    // var assessmentId = Uuid().v4();
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    // if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty && questionnaires.isEmpty) {
    //   return 'No observations added';
    // }

    print('before assessment');
    print(DateTime.now());

    // await _createOnlyAssessment(assessmentId, data);

    // print('after assessment ');
    // print(DateTime.now());

    // Future.forEach(bloodPressures, (item) async {
    //   print('into observations');
    //   var codings = await _getCodings(item);
    //   item['body']['data']['codings'] = codings;
    //   item['body']['assessment_id'] = assessmentId;
    //   await _createObservations(item);
    // });

    // print(encounter);

    // bloodPressures.forEach((element) { print(element); });
    // bloodTests.forEach((element) { print(element); });
    // bodyMeasurements.forEach((element) { print(element); });
    encounter['body']['status'] = status;

    
    var obsRepo = ObservationRepository();

    var bpUpdated = false;
    var btUpdated = false;
    var bmUpdated = false;
    // return;
    observations.forEach((obs) {
      // print(obs);
      if (obs['body']['type'] == 'survey') {
        questionnaires.forEach((qstn) {
          if (qstn['body']['data']['name'] == obs['body']['data']['name']) {
            var apiData = {
              'id': obs['id']
            };
            apiData.addAll(qstn);
            apiData['body']['assessment_id'] = obs['body']['assessment_id'];
            // obsRepo.create(apiData);
          }
        });
      }

      else if (obs['body']['type'] == 'blood_pressure') {
        bloodPressures.forEach((bp) {
          var apiData = {
            'id': obs['id']
          };
          apiData.addAll(bp);
          apiData['body']['assessment_id'] = obs['body']['assessment_id'];
          obsRepo.create(apiData);
          bpUpdated = true;
        });
      }

      else if (obs['body']['type'] == 'blood_test') {
        bloodTests.forEach((bp) {
          var apiData = {
            'id': obs['id']
          };
          apiData.addAll(bp);
          apiData['body']['assessment_id'] = obs['body']['assessment_id'];
          obsRepo.create(apiData);
          btUpdated = true;
        });
      }
      else if (obs['body']['type'] == 'body_measurement') {
        bodyMeasurements.forEach((bp) {
          var apiData = {
            'id': obs['id']
          };
          apiData.addAll(bp);
          apiData['body']['assessment_id'] = obs['body']['assessment_id'];
          obsRepo.create(apiData);
          bmUpdated = true;
        });
      }
    });


    if (!bpUpdated) {
      bloodPressures.forEach((bp) {
        // var id = Uuid().v4();
        // print(id);
        var id =  Uuid().v4();
        Map<String, dynamic> apiData = {
          'id': id
        };
        apiData.addAll(bp);
        // apiData['id'] = 'adsa';
        apiData['body']['assessment_id'] = encounter['id'];
        print('bloodPressure $apiData');
        obsRepo.create(apiData);
      });
    }
    if (!btUpdated) {
      bloodTests.forEach((bt) {
        // var id = Uuid().v4();
        // print(id);
        var id =  Uuid().v4();
        Map<String, dynamic> apiData = {
          'id': id
        };
        apiData.addAll(bt);
        // apiData['id'] = 'adsa';
        apiData['body']['assessment_id'] = encounter['id'];
        print('bloodPressure $apiData');
        obsRepo.create(apiData);
      });
    }
    if (!bmUpdated) {
      bodyMeasurements.forEach((bm) {
        // var id = Uuid().v4();
        // print(id);
        var id =  Uuid().v4();
        Map<String, dynamic> apiData = {
          'id': id
        };
        apiData.addAll(bm);
        // apiData['id'] = 'adsa';
        apiData['body']['assessment_id'] = encounter['id'];
        print('bloodPressure $apiData');
        obsRepo.create(apiData);
      });
    }
    // var data = _prepareData(type, screening_type, comment,);
    // data['body']['status'] = completeStatus;
    // var status = await AssessmentRepositoryLocal().createOnlyAssessmentWithStatus(data);
    // if (status == 'success') {
    //   Helpers().clearObservationItems();
    // }

    print('before health report');
    await AssessmentRepository().createOnlyAssessment(encounter);

    Future.delayed(const Duration(seconds: 5));
    print('after health report');

    HealthReportController().generateReport(encounter['body']['patient_id']);

    Helpers().clearObservationItems();

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

import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

var bloodPressures = [];

class AssessmentController {

  /// Get all the assessments.
  getAllAssessments() async {
    var assessments = await AssessmentRepositoryLocal().getAllAssessments();
    var data = [];
    var parsedData;

    await assessments.forEach((assessment) => {
      parsedData = jsonDecode(assessment['data']),
      if (parsedData['body']['patient_id'] == Patient().getPatient()['uuid']) {
        data.add({
          'uuid': assessment['uuid'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        })
      }
    });
    return data;
  }

  /// Get observations under a specific assessment.
  /// [assessment] object is required as parameter.
  getObservationsByAssessment(assessment) async {
    var observations = await AssessmentRepositoryLocal().getAllObservations();
    var data = [];
    var parsedData;

    await observations.forEach((item) => {
      parsedData = jsonDecode(item['data']),
      if (parsedData['body']['patient_id'] == Patient().getPatient()['uuid'] && parsedData['body']['assessment_id'] == assessment['uuid']) {
        data.add({
          'uuid': item['uuid'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        })
      }
    });
    return data;
  }

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  create(type, comment) {
    var data = _prepareData(type, comment);
    var status = AssessmentRepositoryLocal().create(data);
    if (status == 'success') {
      Helpers().clearObservationItems();
    }

    return status;
  }

  /// Prepare data to create an assessment.
  /// Assessment [type] and [comment] is required as parameter.
  _prepareData(type, comment) {
    var data = {
      "meta": {
        "collected_by": "8vLsBJkEOGOQyyLXQ2vZzycmqQX2",
        "start_time": "17 December, 2019 12:00",
        "end_time": "17 December, 2019 12:05"
      },
      "body": {
        "type": type,
        "comment": comment,
        "performed_by": "Feroj Bepari",
        "assessment_date": DateFormat('d MMMM, y').format(DateTime.now()),
        "patient_id": Patient().getPatient()['uuid']
      }
    };

    return data;
  }
  
}

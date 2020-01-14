import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import '../constants/constants.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

var bloodPressures = [];

class AssessmentController {

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

  getObservationsByAssessment() async {
    var observations = await AssessmentRepositoryLocal().getAllObservations();
    print(observations);
    return;
    var data = [];
    var parsedData;

    await observations.forEach((assessment) => {
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

  create(type, comment) {
    print(type);
    var data = _prepareData(type, comment);
    return AssessmentRepositoryLocal().create(data);
  }

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
  
  static addBloodPressure(formData) async {
    var data;

    print(bloodPressures);
    // return;

    await formData['items'].forEach((item) => {
      
      data = _prepareBloodPressureData(formData, item),
      bloodPressures.add(data),
    });
    print(BloodPressure().items);

  }

  static _prepareBloodPressureData(formData, item) {
    var data = {
      "meta": {
        "collected_by": "8vLsBJkEOGOQyyLXQ2vZzycmqQX2",
        "start_time": "17 December, 2019 12:00",
        "end_time": "17 December, 2019 12:05"
      },
      "body": {
        "type": "blood_pressure",
        "data": {
          'arm': item.arm,
          'systolic': item.systolic,
          'diastolic': item.diastolic,
          'pulse_rate': item.pulse,
        },
        "comment": formData['comment'],
        'patient_id': Patient().getPatient()['uuid'],
        'performed_by': formData['performed_by']
      }
    };

    return data;
  }

}
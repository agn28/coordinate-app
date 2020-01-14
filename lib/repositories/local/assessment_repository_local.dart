import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:uuid/uuid.dart';
import '../../constants/constants.dart';
import 'dart:convert';

class AssessmentRepositoryLocal {
  getAllAssessments() async {
    final sqlAssessments = '''SELECT * FROM ${DatabaseCreator.assessmentTable}''';
    var assessments = await db.rawQuery(sqlAssessments);
    
    return assessments;
  }

  getAllObservations() async {
    final sqlObservations = '''SELECT * FROM ${DatabaseCreator.observationTable}''';
    final observations = await db.rawQuery(sqlObservations);

    return observations;
  }

  create(data) {
    var assessmentId = Uuid().v4();
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;

    if (bloodPressures.isEmpty || bloodTests.isEmpty || bodyMeasurements.isEmpty) {
      return 'Observations are not completed';
    }

    _createAssessment(assessmentId, jsonEncode(data));

    bloodPressures.forEach((item) => {
      item['body']['assessment_id'] = assessmentId,
      _createObservations(jsonEncode(item))
    });

    bloodTests.forEach((item) => {
      item['body']['assessment_id'] = assessmentId,
      _createObservations(jsonEncode(item))
    });

    bodyMeasurements.forEach((item) => {
      item['body']['assessment_id'] = assessmentId,
      _createObservations(jsonEncode(item))
    });

    return 'success';
    
  }

  _createObservations(data) async {
    String id = Uuid().v4();
    final sql = '''INSERT INTO ${DatabaseCreator.observationTable}
    (
      uuid,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [id, data, 'not synced'];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add observation', sql, null, result, params);
  }

  _createAssessment(id, data) async {
    final sql = '''INSERT INTO ${DatabaseCreator.assessmentTable}
    (
      uuid,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [id, data, 'not synced'];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add assessment', sql, null, result, params);
  }
  
}

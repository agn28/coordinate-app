import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class AssessmentRepositoryLocal {

  /// Get all assessments.
  getAllAssessments() async {
    final sqlAssessments = '''SELECT * FROM ${DatabaseCreator.assessmentTable}''';
    var assessments = await db.rawQuery(sqlAssessments);
    
    return assessments;
  }

  /// Get all observations.
  getAllObservations() async {
    final sqlObservations = '''SELECT * FROM ${DatabaseCreator.observationTable}''';
    final observations = await db.rawQuery(sqlObservations);

    return observations;
  }

  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(data) {
    var assessmentId = Uuid().v4();
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;

    if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty) {
      return 'No observations added';
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

  update(data) async {
    var assessment = Assessment().getSelectedAssessment();
    var assessmentId = assessment['uuid'];
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;

    if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty) {
      return 'Observations are not completed';
    }

   _updateAssessment(assessmentId, jsonEncode(data));

    // bloodPressures.forEach((item) => {
      
    //   _updateObservations(item)
    // });

    bloodTests.forEach((item) => {
      print('potrewporip'),
      print(item),
      item['uuid'] != null ? _updateObservations(item) : _createObservations(item)
      // _updateObservations(item)
    });

    // bodyMeasurements.forEach((item) => {
    //   _updateObservations(item)
    // });

    return 'success';
    
  }

  ///Update observations.
  /// Observations [data] is required as parameter
  _updateObservations(data) async {
    String id = data['uuid'];
    data.remove('uuid');
    final sql = '''UPDATE ${DatabaseCreator.observationTable}
    SET data = ?
    WHERE uuid = ?''';
    List<dynamic> params = [jsonEncode(data), id];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Add observation', sql, null, result, params);
  }

  ///Create observations.
  /// Observations [data] is required as parameter
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

  /// Create assessment.
  /// Assessment uuid [id] and [data] are required as paremeter.
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

  /// Create assessment.
  /// Assessment uuid [id] and [data] are required as paremeter.
  _updateAssessment(id, data) async {

    final sql = '''UPDATE ${DatabaseCreator.assessmentTable} SET
      data = ?
      WHERE uuid = ?''';
    List<dynamic> params = [data, id];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Update assessment', sql, null, result, params);
  }
  
}

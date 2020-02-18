import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/repositories/assessment_repository.dart';
import 'package:nhealth/repositories/local/concept_manager_repository_local.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
import 'package:nhealth/repositories/observation_repository.dart';
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
    var questionnaires = Questionnaire().qnItems;

    if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty) {
      return 'No observations added';
    }

    _createAssessment(assessmentId, data);

    bloodPressures.forEach((item,) async {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    bloodTests.forEach((item) async {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    bodyMeasurements.forEach((item) async {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    questionnaires.forEach((item) async {
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    return 'success';
    
  }

  _getCodings(item) async {
    var type = item['body']['type'] == 'blood_pressure' ? item['body']['type'] : item['body']['data']['type'];
    var observationConcept = await ObservationConceptsRepositoryLocal().getConceptByObservation(type);
      if (observationConcept != null && observationConcept['concept_id'] != '' ) {
        var concept = await ConceptManagerRepositoryLocal().getConceptById(observationConcept['concept_id']);
        if (concept != null) {
          return jsonDecode(concept['codings']);
        }
      } 

      return {};
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

    bloodPressures.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      item['uuid'] != null ? _updateObservations(item) : _createObservations(item);
    });

    bloodTests.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      item['uuid'] != null ? _updateObservations(item) : _createObservations(item);
    });


    bodyMeasurements.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      item['uuid'] != null ? _updateObservations(item) : _createObservations(item);
    });

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
    List<dynamic> params = [id, jsonEncode(data), 'not synced'];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add observation', sql, null, result, params);

    print('observation controller');
    Map<String, dynamic> apiData = {
      'id': id
    };

    apiData.addAll(data);

    ObservationRepository().create(apiData);
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
    List<dynamic> params = [id, jsonEncode(data), 'not synced'];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add assessment', sql, null, result, params);

    Map<String, dynamic> apiData = {
      'id': id
    };

    apiData.addAll(data);

    AssessmentRepository().create(apiData);
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

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
  create(data) async {
    var assessmentId = Uuid().v4();
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty && questionnaires.isEmpty) {
      return 'No observations added';
    }

    await _createAssessment(assessmentId, data);

    print('after assessment ' + bloodPressures.length.toString());

    Future.forEach(bloodPressures, (item) async {
      print('into observations');
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    Future.forEach(bloodTests, (item) async {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    Future.forEach(bodyMeasurements, (item) async {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    Future.forEach(questionnaires, (item) async {
      print('into questionnaire');
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    return 'success';
    
  }

  _getCodings(item) async {
    var type = item['body']['type'] == 'blood_pressure' ? item['body']['type'] : item['body']['data']['name'];
    if (type == 'hdl') {
      return {
        'snomed': {
          'id': '17888004',
          'origin': 'Snomed CT',
          'version': 'Internation Edition 2020-03-09'
        }
      };
    }
    if (type == 'tg') {
      return {
        'snomed': {
          'id': '14740000',
          'origin': 'Snomed CT',
          'version': 'Internation Edition 2020-03-09'
        }
      };
    }
    if (type == 'blood_sugar') {
      return {
        'snomed': {
          'id': '33747003',
          'origin': 'Snomed CT',
          'version': 'Internation Edition 2020-03-09'
        }
      };
    }

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
    var questionnaires = Questionnaire().qnItems;

    if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty) {
      return 'Observations are not completed';
    }

    _updateAssessment(assessmentId, data);

    await BloodPressure().deleteIds.forEach((item) {
      _deleteObservations(item);
    });
    BloodPressure().removeDeleteIds();

    // return 'success';
    bloodPressures.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      if (item['body']['data']['id'] == null) {
        _createObservations(item);
      } else {
      }
      // item['body']['assessment_id'] = assessmentId;
      // item['uuid'] != null ? _updateObservations(item) : _createObservations(item);
    });

    bloodTests.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      item['uuid'] != null ? _updateObservations(item) : _createObservations(item);
    });

    bodyMeasurements.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      item['uuid'] != null ? _updateObservations(item) : _createObservations(item);
    });

    questionnaires.forEach((item) async {
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

    Map<String, dynamic> apiData = {
      'id': id
    };

    apiData.addAll(data);
    ObservationRepository().update(id, apiData);
  }

  ///Update observations.
  /// Observations [data] is required as parameter
  _deleteObservations(id) async {
    // final sql = '''DELETE FROM ${DatabaseCreator.observationTable}
    // WHERE uuid = ?''';
    // List<dynamic> params = [id];

    final sql = '''SELECT * FROM ${DatabaseCreator.observationTable} WHERE uuid = $id''';
    final observations = await db.rawQuery('DELETE FROM ${DatabaseCreator.observationTable} WHERE uuid = ?', [id]);
    // final result = await db.rawDelete(sql, params);
    // DatabaseCreator.databaseLog('Delete observation', sql, null, result, params);

    ObservationRepository().delete(id);
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

    Map<String, dynamic> apiData = {
      'id': id
    };

    apiData.addAll(data);

    await ObservationRepository().create(apiData);
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

    print('before encounter');
    await AssessmentRepository().create(apiData);

    print('into encounter');
  }

  /// Create assessment.
  /// Assessment uuid [id] and [data] are required as paremeter.
  _updateAssessment(id, data) async {

    final sql = '''UPDATE ${DatabaseCreator.assessmentTable} SET
      data = ?
      WHERE uuid = ?''';
    List<dynamic> params = [jsonEncode(data), id];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Update assessment', sql, null, result, params);

    Map<String, dynamic> apiData = {
      'id': id
    };

    apiData.addAll(data);
    AssessmentRepository().update(id, apiData);
  }
  
}

import 'package:nhealth/helpers/functions.dart';
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
import 'package:sqflite/sqlite_api.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class AssessmentRepositoryLocal {
  /// Get all assessments.
  getAllAssessments() async {
    final sqlAssessments =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} ORDER BY created_at DESC''';
    var assessments = await db.rawQuery(sqlAssessments);
    return assessments;
  }

  /// Get all assessments.
  getAssessmentsByPatients(patientIds) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.assessmentTable}''';
    var assessments;

    try {
      assessments = await db.rawQuery(sql);
    } catch (error) {

      return;
    }
    return assessments;
  }
  getAssessmentsByPatientWithLocalStatus(id ,localStatus) async {

    final sql =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE (patient_id="$id") AND (local_status="$localStatus")''';
    var assessments;

    try {
      assessments = await db.rawQuery(sql);
    } catch (error) {

      return;
    }
    return assessments;
  }
  getLastEncounterByPatient(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE patient_id="$id" ORDER BY created_at DESC LIMIT 1''';
    try {
      return await db.rawQuery(sql);
    } catch (error) {
      return;
    }
  }

  getAssessmentsByPatient(id) async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE patient_id="$id" ORDER BY created_at DESC''';
    var assessments;

    try {
      assessments = await db.rawQuery(sql);
    } catch (error) {

      return;
    }
    return assessments;
  }

  getAssessmentById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE id = "$id"''';
    
    try {
      return await db.rawQuery(sql);
    } catch (error) {

      return;
    }
  }

  getIncompleteAssessmentsByPatient(id) async {

    var status = 'incomplete';
    final sql =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE (status='incomplete') AND (patient_id='$id') ORDER BY created_at ASC''';

    var assessments;

    try {
      assessments = await db.rawQuery(sql);

    } catch (error) {
      return;
    }
    return assessments;
  }

  getNotSyncedAssessments() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE (is_synced=0) AND (local_status!='incomplete') ''';
    var response = await db.rawQuery(sql);

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

      return;
    }

    return response;
  }

  /// Get all observations.
  getAllObservations() async {
    final sqlObservations = '''SELECT * FROM ${DatabaseCreator.observationTable}''';
    final observations = await db.rawQuery(sqlObservations);

    return observations;
  }
  // Get observation by patient
  getObservationsByPatient(patientId) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.observationTable} WHERE patient_id="$patientId"''';
    var observations;

    try {
      observations = await db.rawQuery(sql);
    } catch (error) {

      return;
    }
    return observations;
  }

  createObservationsForOnlyAssessmentWithStatus(assessmentId) async {
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    for (var item in bloodPressures) {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    }

    for (var item in bloodTests) {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    }
    for (var item in bodyMeasurements) {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    }
    for (var item in questionnaires) {
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    }
  }

  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  createOnlyAssessmentWithStatus(data) async {
    var assessmentId = Uuid().v4();

    // if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty && questionnaires.isEmpty) {
    //   return 'No observations added';
    // }
    createObservationsForOnlyAssessmentWithStatus(assessmentId);

    await _createOnlyAssessment(assessmentId, data);

    // Future.forEach(bloodPressures, (item) async {
    //   print('into observations');
    //   var codings = await _getCodings(item);
    //   item['body']['data']['codings'] = codings;
    //   item['body']['assessment_id'] = assessmentId;
    //   await _createObservations(item);
    // });

    // Future.forEach(bloodTests, (item) async {
    //   var codings = await _getCodings(item);
    //   item['body']['data']['codings'] = codings;
    //   item['body']['assessment_id'] = assessmentId;
    //   await _createObservations(item);
    // });
    // Future.forEach(bodyMeasurements, (item) async {
    //   var codings = await _getCodings(item);
    //   item['body']['data']['codings'] = codings;
    //   item['body']['assessment_id'] = assessmentId;
    //   await _createObservations(item);
    // });

    // Future.forEach(questionnaires, (item) async {
    //   print('into questionnaire');
    //   item['body']['assessment_id'] = assessmentId;
    //   await _createObservations(item);
    // });

    return 'success';
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

    Future.forEach(bloodPressures, (item) async {
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
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(item);
    });

    return 'success';
  }

  createFromLive(id, data) {}

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
    var assessmentId = assessment['id'];
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
      } else {}
      // item['body']['assessment_id'] = assessmentId;
      // item['id'] != null ? _updateObservations(item) : _createObservations(item);
    });

    bloodTests.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      item['id'] != null
          ? _updateObservations(item)
          : _createObservations(item);
    });

    bodyMeasurements.forEach((item) {
      item['body']['assessment_id'] = assessmentId;
      item['id'] != null
          ? _updateObservations(item)
          : _createObservations(item);
    });

    questionnaires.forEach((item) async {
      item['body']['assessment_id'] = assessmentId;
      item['id'] != null
          ? _updateObservations(item)
          : _createObservations(item);
    });

    return 'success';
  }

  ///Update observations.
  /// Observations [data] is required as parameter
  _updateObservations(data) async {
    String id = data['id'];
    data.remove('id');
    final sql = '''UPDATE ${DatabaseCreator.observationTable}
    SET data = ?
    WHERE uuid = ?''';
    List<dynamic> params = [jsonEncode(data), id];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Add observation', sql, null, result, params);

    Map<String, dynamic> apiData = {'id': id};

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
      id,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [id, jsonEncode(data), 'not synced'];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add observation', sql, null, result, params);

    Map<String, dynamic> apiData = {'id': id};

    apiData.addAll(data);

    await ObservationRepository().create(apiData);
  }

  /// Create assessment.
  /// Assessment uuid [id] and [data] are required as paremeter.
  _createAssessment(id, data) async {
    final sql = '''INSERT INTO ${DatabaseCreator.assessmentTable}
    (
      id,
      data,
      status
    )
    VALUES (?,?,?)''';

    List<dynamic> params = [id, jsonEncode(data), 'not synced'];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add assessment', sql, null, result, params);

    Map<String, dynamic> apiData = {'id': id};

    apiData.addAll(data);

    await AssessmentRepository().create(apiData);

  }

  _createOnlyAssessment(id, data) async {
    final sql = '''INSERT INTO ${DatabaseCreator.assessmentTable}
        (
          id,
          data,
          status
        )
        VALUES (?,?,?)''';
        List<dynamic> params = [id, jsonEncode(data), 'not synced'];
        final result = await db.rawInsert(sql, params);
        DatabaseCreator.databaseLog('Add assessment', sql, null, result, params);

        Map<String, dynamic> apiData = {'id': id};

        apiData.addAll(data);

        await AssessmentRepository().createOnlyAssessment(apiData);

  }

  createLocalAssessment(id, data, isSynced, {localStatus:''}) async {
    final sql = '''INSERT INTO ${DatabaseCreator.assessmentTable}
    (
      id,
      data,
      patient_id,
      type,
      screening_type,
      status,
      is_synced,
      local_status,
      created_at
    )
    VALUES (?,?,?,?,?,?,?,?,?)''';

    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['body']['patient_id'],
      data['body']['status'],
      data['body']['screening_type'],
      data['body']['status'],
      isSynced,
      localStatus,
      data['meta']['created_at']
    ];
    var response;

    try {
      response = await db.rawInsert(sql, params);
    } catch (error) {

    }
    DatabaseCreator.databaseLog('Add assessment', sql, null, response, params);
    return response;
  }

  syncFromLive(tempSyncs, isSynced, {localStatus:''}) async {
    Batch batch = db.batch();
    final sql = '''INSERT OR REPLACE INTO ${DatabaseCreator.assessmentTable}
    (
      id,
      data,
      patient_id,
      type,
      screening_type,
      status,
      is_synced,
      local_status,
      created_at
    )
    VALUES (?,?,?,?,?,?,?,?,?)''';
    for (var item in tempSyncs) {
      List<dynamic> params = [item['id'], 
      jsonEncode(item), 
      item['body']['patient_id'], 
      item['body']['type'], 
      item['body']['screening_type'], 
      item['body']['status'], 
      isSynced, 
      localStatus,
      item['meta']['created_at']];
      // DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.parse(item['meta']['created_at']))];
      await batch.rawInsert(sql, params);
      print('rawInsert');
    }
    try {
      await batch.commit(noResult: true);
      print('commit');
    } catch (error) {
      //TODO: create log here
      print('error $error');
    } finally {
      print('subAssessments batch inserted');
    }
  }

  updateLocalAssessment(id, data, isSynced, {localStatus:''}) async {
    final sql = '''UPDATE ${DatabaseCreator.assessmentTable} SET
      data = ? ,
      patient_id = ?,
      type = ?,
      screening_type = ?,
      status = ?,
      is_synced = ?,
      local_status = ?
      created_at = ?
      WHERE id = ?''';
    List<dynamic> params = [
    jsonEncode(data), 
    data['body']['patient_id'],
    data['body']['type'], 
    data['body']['screening_type'], 
    data['body']['status'], 
    isSynced, 
    localStatus, 
    data['meta']['created_at'], 
    id];
    var response;
    try {
      response = await db.rawUpdate(sql, params);
    } catch (error) {

    }
    DatabaseCreator.databaseLog('Update assessment', sql, null, response, params);
    return response;
  }

  deleteLocalAssessment(id) async {
    var response;
    final sql = '''DELETE FROM ${DatabaseCreator.assessmentTable} WHERE id = "$id"''';
    try {
      response = await db.rawQuery(sql);

    } catch (err) {

      return;
    }
    return response;
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

    Map<String, dynamic> apiData = {'id': id};

    apiData.addAll(data);
    AssessmentRepository().update(id, apiData);
  }

  prepareObservations(assessmentId) async {
    var preparedObservations;
    List observations = [];
    List localObservations = [];
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    if (bloodPressures.isNotEmpty) {
      for (var item in bloodPressures) {
        var codings = await _getCodings(item);
        item['body']['data']['codings'] = codings;
        item['body']['assessment_id'] = assessmentId;
        // var itemData = await _createLocalObservations(item);
        String id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(item);
        observations.add(apiData);
        localObservations.add({
          'id': id,
          'data': item
        });
      }
    }
    if (bloodTests.isNotEmpty) {
      for (var item in bloodTests) {
        var codings = await _getCodings(item);
        item['body']['data']['codings'] = codings;
        item['body']['assessment_id'] = assessmentId;
        // var itemData = await _createLocalObservations(item);
        String id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(item);
        observations.add(apiData);
        localObservations.add({
          'id': id,
          'data': item
        });
      }
    }
    if (bodyMeasurements.isNotEmpty) {
      for (var item in bodyMeasurements) {
        var codings = await _getCodings(item);
        item['body']['data']['codings'] = codings;
        item['body']['assessment_id'] = assessmentId;
        // var itemData = await _createLocalObservations(item);
        String id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(item);
        observations.add(apiData);
        localObservations.add({
          'id': id,
          'data': item
        });
      }
    }
    if (questionnaires.isNotEmpty) {
      for (var item in questionnaires) {
        item['body']['assessment_id'] = assessmentId;
        // var itemData = await _createLocalObservations(item);
        String id = Uuid().v4();
        Map<String, dynamic> apiData = {'id': id};
        apiData.addAll(item);
        observations.add(apiData);
        localObservations.add({
          'id': id,
          'data': item
        });
      }
    }
    preparedObservations = {
      'apiData': observations,
      'localData': localObservations
    };

    return preparedObservations;
  }


  _createLocalObservations(data) async {
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

    Map<String, dynamic> apiData = {'id': id};

    apiData.addAll(data);

    return apiData;
  }

  Future<void> updateLocalStatus(uuid, isSynced) async {

    final sql = '''UPDATE ${DatabaseCreator.assessmentTable} SET
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [isSynced, uuid];
    var response;

    try {
      response = await db.rawUpdate(sql, params);
    } catch (error) {

      return;
    }
    return response;
  }
}

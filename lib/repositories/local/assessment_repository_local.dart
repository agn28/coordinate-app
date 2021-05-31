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
import 'package:uuid/uuid.dart';
import 'dart:convert';

class AssessmentRepositoryLocal {
  /// Get all assessments.
  getAllAssessments() async {
    final sqlAssessments =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable}''';
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
      print('error');
      print(error);
      return;
    }
    return assessments;
  }

  getAssessmentsByPatient(id) async {
    print('patient id ' + id);
    final sql =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE patient_id="$id"''';
    var assessments;

    try {
      assessments = await db.rawQuery(sql);
    } catch (error) {
      print('errors');
      print(error);
      return;
    }
    return assessments;
  }

  getIncompleteAssessmentsByPatient(id) async {
    print('patient id ' + id);
    var status = 'incomplete';
    final sql =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE (status='incomplete') AND (patient_id='$id')''';
    print('sql $sql');
    var assessments;

    try {
      print('local db');
      assessments = await db.rawQuery(sql);
      print('assessments $assessments');
    } catch (error) {
      print('errors');
      print(error);
      return;
    }
    return assessments;
  }

  getNotSyncedAssessments() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.assessmentTable} WHERE is_synced=0''';
    var response = await db.rawQuery(sql);

    try {
      response = await db.rawQuery(sql);
    } catch (error) {
      print('error');
      print(error);
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

  createObservationsForOnlyAssessmentWithStatus(assessmentId) async {
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    for (var item in bloodPressures) {
      print('into observations');
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
      print('into questionnaire');
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
    print('before assessment');
    print(DateTime.now());

    await _createOnlyAssessment(assessmentId, data);

    print('after assessment ');
    print(DateTime.now());
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

    print('after assessment');

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
    Map<String, dynamic> apiData = {'id': id};

    apiData.addAll(data);
    var apiResponse = await AssessmentRepository().create(apiData);
    if (isNotNull(apiResponse) &&
        isNotNull(apiResponse['error'] && !apiResponse['error'])) {}

    return;

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

    print('before encounter');
    await AssessmentRepository().createOnlyAssessment(apiData);

    print('into encounter');
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

        print('before encounter');
        await AssessmentRepository().createOnlyAssessment(apiData);

        print('into encounter');
  }

  createLocalAssessment(id, data, isSynced) async {
    print('into local assessment create ' + isSynced.toString());
    print('create patient id ' + data['body']['patient_id']);
    // print('create patient body ' + data['body']);
    final sql = '''INSERT INTO ${DatabaseCreator.assessmentTable}
    (
      id,
      data,
      patient_id,
      status,
      is_synced
    )
    VALUES (?,?,?,?,?)''';

    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['body']['patient_id'],
      data['body']['status'],
      isSynced
    ];
    var response;

    try {
      response = await db.rawInsert(sql, params);
    } catch (error) {
      print('local assessment error');
      print(error);
    }
    DatabaseCreator.databaseLog('Add assessment', sql, null, response, params);
    return response;
  }

  updateLocalAssessment(id, data, isSynced) async {
    final sql = '''UPDATE ${DatabaseCreator.assessmentTable} SET
      data = ? ,
      patient_id = ?,
      status = ?,
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [jsonEncode(data), data['body']['patient_id'],
      data['body']['status'], isSynced, id];
    var response;
    try {
      response = await db.rawUpdate(sql, params);
      print('sql $response');
    } catch (error) {
      print('local assessment update error');
      print(error);
    }
    DatabaseCreator.databaseLog('Update assessment', sql, null, response, params);
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
    List observations = [];
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    if (bloodPressures.isNotEmpty) {
      for (var item in bloodPressures) {
        print('into bloodPressures');
        var codings = await _getCodings(item);
        item['body']['data']['codings'] = codings;
        item['body']['assessment_id'] = assessmentId;
        var itemData = await _createLocalObservations(item);
        observations.add(itemData);
      }
    }
    if (bloodTests.isNotEmpty) {
      for (var item in bloodTests) {
        print('into bloodTests');
        var codings = await _getCodings(item);
        item['body']['data']['codings'] = codings;
        item['body']['assessment_id'] = assessmentId;
        var itemData = await _createLocalObservations(item);
        observations.add(itemData);
      }
    }
    if (bodyMeasurements.isNotEmpty) {
      for (var item in bodyMeasurements) {
        print('into bodyMeasurements');
        var codings = await _getCodings(item);
        item['body']['data']['codings'] = codings;
        item['body']['assessment_id'] = assessmentId;
        var itemData = await _createLocalObservations(item);
        observations.add(itemData);
      }
    }
    if (questionnaires.isNotEmpty) {
      for (var item in questionnaires) {
        print('into questionnaire');
        item['body']['assessment_id'] = assessmentId;
        var itemData = await _createLocalObservations(item);
        observations.add(itemData);
      }
    }
    print('bloodPressures $bloodPressures');
    print('bloodTests $bloodTests');
    print('bodyMeasurements $bodyMeasurements');
    print('observations $observations');

    return observations;
  }

  createLocalAssessment(id, data) async {
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
    print('into updating assessment status');
    print('uuid ' + uuid);

    final sql = '''UPDATE ${DatabaseCreator.assessmentTable} SET
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [isSynced, uuid];
    var response;

    try {
      response = await db.rawUpdate(sql, params);
      print('update local response');
      print(response);
    } catch (error) {
      print('error');
      print(error);
      return;
    }
    return response;
  }
}

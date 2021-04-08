import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/concept_manager_repository_local.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
import 'package:nhealth/repositories/observation_repository.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

var bloodPressures = [];

class ObservationController {
  /// Get all the assessments.
  getLiveSurveysByPatient() async {
    var observations = await ObservationRepository().getObservations();
    var data = [];
    if (observations == null) {
      return data;
    }
    await observations['data'].forEach((obs) {
      if (obs['body']['patient_id'] == Patient().getPatient()['uuid'] &&
          obs['body']['type'] == 'survey') {
        data.add(obs['body']);
      }
    });
    return data;
  }

  prepareObservations(assessmentId) async {
    List observations = [];
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;
    // if (bloodPressures.isEmpty && bloodTests.isEmpty && bodyMeasurements.isEmpty && questionnaires.isEmpty) {
    //   return 'No observations added';
    // }
    if (bloodPressures.isNotEmpty) {
      for (var item in bloodPressures) {
        print('into bloodPressures');
        var codings = await _getCodings(item);
        item['body']['data']['codings'] = codings;
        item['body']['assessment_id'] = assessmentId;
        var itemData = await _createLocalObservations(item);
        // await _createObservations(item);
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
        // await _createObservations(item);
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
        // await _createObservations(item);
        observations.add(itemData);
      }
    }
    if (questionnaires.isNotEmpty) {
      for (var item in questionnaires) {
        print('into questionnaire');
        item['body']['assessment_id'] = assessmentId;
        var itemData = await _createLocalObservations(item);
        // await _createObservations(item);
        observations.add(itemData);
      }
    }
    print('bloodPressures $bloodPressures');
    print('bloodTests $bloodTests');
    print('bodyMeasurements $bodyMeasurements');
    print('observations $observations');

    return observations;
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

  _getCodings(item) async {
    var type = item['body']['type'] == 'blood_pressure'
        ? item['body']['type']
        : item['body']['data']['name'];
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

    var observationConcept = await ObservationConceptsRepositoryLocal()
        .getConceptByObservation(type);
    if (observationConcept != null && observationConcept['concept_id'] != '') {
      var concept = await ConceptManagerRepositoryLocal()
          .getConceptById(observationConcept['concept_id']);
      if (concept != null) {
        return jsonDecode(concept['codings']);
      }
    }

    return {};
  }
}

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'package:nhealth/repositories/local/concept_manager_repository_local.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
import 'package:nhealth/repositories/local/observation_repository_local.dart';
import 'package:nhealth/repositories/observation_repository.dart';
import 'package:nhealth/repositories/sync_repository.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:uuid/uuid.dart';

var bloodPressures = [];

class ObservationController {
  var observationRepoLocal = ObservationRepositoryLocal();
  var observationRepo = ObservationRepository();

  prepareAndCreateObservations(context, assessmentId) async {
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    if (bloodPressures.isEmpty &&
        bloodTests.isEmpty &&
        bodyMeasurements.isEmpty &&
        questionnaires.isEmpty) {
      return 'No observations added';
    }


    for (var item in bloodPressures) {

      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(context, item);
    }

    for (var item in bloodTests) {

      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(context, item);
    }
    ;

    for (var item in bodyMeasurements) {
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(context, item);
    }
    ;

    for (var item in questionnaires) {
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(context, item);
    }
    ;

    return 'success';
  }

  _createObservations(context, data) async {
    String id = Uuid().v4();
    Map<String, dynamic> apiData = {'id': id};

    apiData.addAll(data);

    var response;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.

      var apiResponse = await ObservationRepository().create(apiData);

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
        // exception type known (e.g: slow/no net)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));

        // creating local observation with not synced status
        response = await observationRepoLocal.create(id, data, false);
        return response;
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        // creating local observation with synced status
        response = await observationRepoLocal.create(id, data, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          var updateSync = await SyncRepository()
              .updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
        }
        return response;
      }
      return response;
    } else {
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));

      // creating local observation with synced status
      response = await observationRepoLocal.create(id, data, false);
      return response;
    }
  }

  UpdateOrCreateObservations(context, status, encounter, observations) async {
    var bloodPressures = BloodPressure().bpItems;
    var bloodTests = BloodTest().btItems;
    var bodyMeasurements = BodyMeasurement().bmItems;
    var questionnaires = Questionnaire().qnItems;

    encounter['body']['status'] = status;

    var bmobs = observations
        .where(
            (observation) => observation['body']['type'] == 'body_measurement')
        .toList();
    for (var bm in bodyMeasurements) {
      if (bmobs.isNotEmpty) {
        var matchedObs = bmobs.where((bmob) =>
            bmob['body']['data']['name'] == bm['body']['data']['name']);
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bm);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          // await obsRepo.create(apiData);
          await _updateObservations(context, apiData);
        } else {
          // var id = Uuid().v4();
          // Map<String, dynamic> apiData = {'id': id};
          // apiData.addAll(bm);
          // apiData['body']['assessment_id'] = encounter['id'];
          // await obsRepo.create(apiData);
          var codings = await _getCodings(bm);
          bm['body']['data']['codings'] = codings;
          bm['body']['assessment_id'] = encounter['id'];
          await _createObservations(context, bm);
        }
      } else {
        // var id = Uuid().v4();
        // Map<String, dynamic> apiData = {'id': id};
        // apiData.addAll(bm);
        // apiData['body']['assessment_id'] = encounter['id'];
        // await obsRepo.create(apiData);
        var codings = await _getCodings(bm);
        bm['body']['data']['codings'] = codings;
        bm['body']['assessment_id'] = encounter['id'];
        await _createObservations(context, bm);
      }
    }

    var bpobs = observations
        .where((observation) => observation['body']['type'] == 'blood_pressure')
        .toList();

    for (var bp in bloodPressures) {
      if (bpobs.isNotEmpty) {
        var matchedObs = bpobs.where((bpob) =>
            bpob['body']['data']['name'] == bp['body']['data']['name']);

        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bp);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];

          // await obsRepo.create(apiData);
          await _updateObservations(context, apiData);
        } else {
          // var id = Uuid().v4();
          // Map<String, dynamic> apiData = {'id': id};
          // apiData.addAll(bp);
          // apiData['body']['assessment_id'] = encounter['id'];
          // print('Blood Pressure_else $apiData');
          // await obsRepo.create(apiData);
          var codings = await _getCodings(bp);
          bp['body']['data']['codings'] = codings;
          bp['body']['assessment_id'] = encounter['id'];
          await _createObservations(context, bp);
        }
      } else {
        // var id = Uuid().v4();
        // Map<String, dynamic> apiData = {'id': id};
        // apiData.addAll(bp);
        // apiData['body']['assessment_id'] = encounter['id'];
        // print('Blood Pressure_else $apiData');
        // await obsRepo.create(apiData);
        var codings = await _getCodings(bp);
        bp['body']['data']['codings'] = codings;
        bp['body']['assessment_id'] = encounter['id'];
        await _createObservations(context, bp);
      }
    }

    var btobs = observations
        .where((observation) => observation['body']['type'] == 'blood_test')
        .toList();
    for (var bt in bloodTests) {
      if (btobs.isNotEmpty) {
        var matchedObs = btobs.where((btob) =>
            btob['body']['data']['name'] == bt['body']['data']['name']);
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bt);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];

          // await obsRepo.create(apiData);
          await _updateObservations(context, apiData);
        } else {
          // var id = Uuid().v4();
          // Map<String, dynamic> apiData = {'id': id};
          // apiData.addAll(bt);
          // apiData['body']['assessment_id'] = encounter['id'];
          // print('Blood Test_else $apiData');
          // await obsRepo.create(apiData);
          var codings = await _getCodings(bt);
          bt['body']['data']['codings'] = codings;
          bt['body']['assessment_id'] = encounter['id'];
          await _createObservations(context, bt);
        }
      } else {
        // var id = Uuid().v4();
        // Map<String, dynamic> apiData = {'id': id};
        // apiData.addAll(bt);
        // apiData['body']['assessment_id'] = encounter['id'];
        // print('Blood Test_else $apiData');
        // await obsRepo.create(apiData);
        var codings = await _getCodings(bt);
        bt['body']['data']['codings'] = codings;
        bt['body']['assessment_id'] = encounter['id'];
        await _createObservations(context, bt);
      }
    }

    var qstnobs = observations
        .where((observation) => observation['body']['type'] == 'survey')
        .toList();
    for (var qstn in questionnaires) {
      if (qstnobs.isNotEmpty) {
        var matchedObs = qstnobs.where((qstnob) =>
            qstnob['body']['data']['name'] == qstn['body']['data']['name']);
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(qstn);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          // await obsRepo.create(apiData);
          await _updateObservations(context, apiData);
        } else {
          // var id = Uuid().v4();
          // Map<String, dynamic> apiData = {'id': id};
          // apiData.addAll(qstn);
          // apiData['body']['assessment_id'] = encounter['id'];
          // print('Questionnaires_else $apiData');
          // await obsRepo.create(apiData);
          qstn['body']['assessment_id'] = encounter['id'];
          await _createObservations(context, qstn);
        }
      } else {
        // var id = Uuid().v4();
        // Map<String, dynamic> apiData = {'id': id};
        // apiData.addAll(qstn);
        // apiData['body']['assessment_id'] = encounter['id'];
        // print('Questionnaires_else $apiData');
        // await obsRepo.create(apiData);
        qstn['body']['assessment_id'] = encounter['id'];
        await _createObservations(context, qstn);
      }
    }
  }

    _updateObservations(context, data) async {
    // String id = Uuid().v4();
    // Map<String, dynamic> apiData = {'id': id};

    // apiData.addAll(data);

    var response;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to internet.

      var apiResponse = await ObservationRepository().create(data);

      //Could not get any response from API
      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API did not respond due to handled exception
      else if (apiResponse['exception'] != null) {
        // exception type unknown
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
        // exception type known (e.g: slow/no net)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));

        // creating local observation with not synced status
        response = await observationRepoLocal.update(data['id'], data, false);
        return response;
      }
      //API responded with error
      else if (apiResponse['error'] != null && apiResponse['error']) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${apiResponse['message']}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
      //API responded success with no error
      else if (apiResponse['error'] != null && !apiResponse['error']) {
        // creating local observation with synced status
        response = await observationRepoLocal.update(data['id'], data, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {

          var updateSync = await SyncRepository()
              .updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
        }
        return response;
      }
      return response;
    } else {

      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));

      // creating local observation with synced status

      response = await observationRepoLocal.update(data['id'], data, false);
      return response;
    }
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

  getLocalSurveysByPatient(id) async {
    var observations = await observationRepoLocal.getObservationsByPatient(id);
    var data = [];
    if (observations == null) {
      return data;
    }

    var parsedData;
    await observations.forEach((obs) {
      parsedData = jsonDecode(obs['data']);
      if (parsedData['body']['type'] == 'survey') {
        data.add(parsedData['body']);
      }
    });
    return data;
  }


  getLiveObservationsById(id) async {
    return await observationRepo.getObservationById(id);
  }

  getLiveObservationsByIds(ids) async {
    return await observationRepo.getObservationsByIds(ids);
  }

  getAllLocalObservations() async {
    var observations = await observationRepoLocal.getAllObservations();
    var data = [];
    var parsedData;

    await observations.forEach((item) {
      parsedData = jsonDecode(item['data']);
      data.add({
        'id': item['id'],
        'body': {
          'type': parsedData['body']['type'],
          'data': parsedData['body']['data'],
          'comment': parsedData['body']['comment'],
          'patient_id': parsedData['body']['patient_id'],
          'assessment_id': parsedData['body']['assessment_id'],
        },
        'meta': parsedData['meta']
      });
    });
    return data;
  }
}

import 'dart:convert';
import 'package:connectivity/connectivity.dart';
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

    print('after assessment');

    for (var item in bloodPressures) {
      print('into bloodpressure');
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(context, item);
    }

    for (var item in bloodTests) {
      print('into bloodtest');
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(context, item);
    }
    ;

    for (var item in bodyMeasurements) {
      print('into bodymeasurement');
      var codings = await _getCodings(item);
      item['body']['data']['codings'] = codings;
      item['body']['assessment_id'] = assessmentId;
      await _createObservations(context, item);
    }
    ;

    for (var item in questionnaires) {
      print('into questionnaire');
      print('item $item');
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
      print('connected');
      // Creating live observations
      print('live observation create');
      var apiResponse = await ObservationRepository().create(apiData);
      print('observation apiResponse $apiResponse');

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
        print('into success');
        // creating local observation with synced status
        response = await observationRepoLocal.create(id, data, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          print('into observation sync update');
          var updateSync = await SyncRepository()
              .updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating observation sync key $updateSync');
        }
        return response;
      }
      return response;
    } else {
      print('not connected');
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
    print('bmobs ${bmobs}');
    for (var bm in bodyMeasurements) {
      if (bmobs.isNotEmpty) {
        var matchedObs = bmobs.where((bmob) =>
            bmob['body']['data']['name'] == bm['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bm);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('body Measurements_if $apiData');
          // await obsRepo.create(apiData);
          await _updateObservations(context, apiData);
        } else {
          // var id = Uuid().v4();
          // Map<String, dynamic> apiData = {'id': id};
          // apiData.addAll(bm);
          // apiData['body']['assessment_id'] = encounter['id'];
          // print('body Measurements_else $apiData');
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
        // print('body Measurements_else $apiData');
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
    print('bpobs ${bpobs}');

    for (var bp in bloodPressures) {
      if (bpobs.isNotEmpty) {
        var matchedObs = bpobs.where((bpob) =>
            bpob['body']['data']['name'] == bp['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bp);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('Blood Pressure_if $apiData');
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
    print('btobs ${btobs}');
    for (var bt in bloodTests) {
      if (btobs.isNotEmpty) {
        var matchedObs = btobs.where((btob) =>
            btob['body']['data']['name'] == bt['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(bt);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('Blood Test_if $apiData');
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
      print('qstn ${qstn['body']['data']['name']}');
      if (qstnobs.isNotEmpty) {
        var matchedObs = qstnobs.where((qstnob) =>
            qstnob['body']['data']['name'] == qstn['body']['data']['name']);
        print('matchedObs ${matchedObs}');
        if (matchedObs.isNotEmpty) {
          matchedObs = matchedObs.first;
          var apiData = {'id': matchedObs['id']};
          apiData.addAll(qstn);
          apiData['body']['assessment_id'] =
              matchedObs['body']['assessment_id'];
          print('Questionnaires_if $apiData');
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
      print('connected');
      // Creating live observations
      print('live observation create');
      var apiResponse = await ObservationRepository().create(data);
      print('observation apiResponse $apiResponse');

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
        print('into success');
        // creating local observation with synced status
        response = await observationRepoLocal.update(data['id'], data, true);

        //updating sync key
        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          print('into observation sync update');
          var updateSync = await SyncRepository()
              .updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating observation sync key $updateSync');
        }
        return response;
      }
      return response;
    } else {
      print('not connected');
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Warning: No Internet. Using offline...'),
      //   backgroundColor: kPrimaryYellowColor,
      // ));

      // creating local observation with synced status
      print(data);
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

  /// Get all the assessments.
  getLiveSurveysByPatient() async {
    var observations = await ObservationRepository().getObservations();
    var data = [];
    if (observations == null && observations['error'] != null) {
      return data;
    }
    await observations['data'].forEach((obs) {
      if (obs['body']['patient_id'] == Patient().getPatient()['id'] &&
          obs['body']['type'] == 'survey') {
        data.add(obs['body']);
      }
    });
    }
    return data;
  }

  getLiveObservationsById(id) async {
    var response = await observationRepo.getObservationById(id);
    var data = {};

    // if (response['error'] != null && !response['error']) {
    //   var item = response['data'];
    //   data = {
    //     'id': item['id'],
    //     'body': {
    //       'type': item['body']['type'],
    //       'data': item['body']['data'],
    //       'comment': item['body']['comment'],
    //       'patient_id': item['body']['patient_id'],
    //       'assessment_id': item['body']['assessment_id'],
    //     },
    //     'meta': item['meta']
    //   };
    // }
    return response;
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

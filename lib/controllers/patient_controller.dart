import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:nhealth/repositories/patient_repository.dart';
import 'package:nhealth/repositories/sync_repository.dart';
import 'package:uuid/uuid.dart';

import '../app_localizations.dart';

class PatientController {

  /// Get all the patients
  var patientRepoLocal = PatientReposioryLocal();

  getAllPatients() async {
    var patients = await PatientReposioryLocal().getAllPatients();
    var data = [];
    var parsedData;

    await patients.forEach((patient) {
      parsedData = jsonDecode(patient['data']);
      data.add({
        'id': patient['id'],
        'data': parsedData['body'],
        'meta': parsedData['meta']
      });
    });

    return data;
  }

  getAllLocalPatients() async {
    var patients = await PatientReposioryLocal().getAllPatients();
    var data = [];
    var parsedData;

    await patients.forEach((patient) {
      parsedData = jsonDecode(patient['data']);
      data.add({
        'id': patient['id'],
        'data': parsedData['body'],
        'meta': parsedData['meta']
      });
    });

    return data;
  }

  getFirstAssessmentPatients() async {
    var response = await PatientRepository().getFirstAssessmentPatients();

    return response;
  }

  getChcpPatients() async {
    var response = await PatientRepository().getChcpPatients();

    return response;
  }

  getFollowupPatients() async {
    var response = await PatientRepository().getFollowupPatients();

    return response;
  }

  getLocations() async {
    var response = await PatientRepository().getLocations();

    if (isNotNull(response) && isNull(response['exception'])) {
      return response;
    }

    var localResponse = await PatientReposioryLocal().getLocations();

    print('local lcations');
    print(localResponse);
    if (isNotNull(localResponse) && localResponse.isNotEmpty) {
      print('into local if');
      var locations = {
        'data': jsonDecode(localResponse[0]['data']),
        'error': false
      };
      print(locations);
      return locations;
    }

    return;
  }

  getPatient(patientId) async {
    var response = await PatientRepository().getPatient(patientId);

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'id': patient['id'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    return response;
  }
  getPatientsPendingWorklist(context) async {
    var response = await PatientRepository().getPatientsPendingWorklist();

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'id': patient['id'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    if (response['message'] != null && response['message'] == 'Unauthorized') {
      await Helpers().logout(context);
    }

    return response;
  }

  getPatientsWorklist(context, type) async {
    var response = await PatientRepository().getPatientsWorklist(type);

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'id': patient['id'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    if (response['message'] != null && response['message'] == 'Unauthorized') {
      await Helpers().logout(context);
    }

    return response;
  }

  getAllLivePatients() async {
    var response = await PatientRepository().getPatients();

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'id': patient['id'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    return response;
  }

  /// Get all the patients
  getNewPatients() async {
    var response = await PatientRepository().getNewPatients();

    if (isNull(response) || isNotNull(response['exception'])) {
      var localResponse = await patientRepoLocal.getAllPatients();
    }

    return response;
  }

  getExistingPatients() async {
    var response = await PatientRepository().getExistingPatients();

    return response;
  }

  getReferralPatients() async {
    var response;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      var apiResponse = await PatientRepository().getReferralPatients();

      return apiResponse;
    } else {
      response = PatientReposioryLocal().getReferralPatients();
    }

    return response;
  }

  // getCenter() async {
  //   var response;
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     var apiResponse = await PatientRepository().getCenter();

  //     return apiResponse;
  //   } else {
  //     response = PatientReposioryLocal().getReferralPatients();
  //   }
  //   return response;
  // }
  getCenter() async {
    var response = await PatientRepository().getCenter();

    if (isNotNull(response) && isNull(response['exception'])) {
      return response;
    }

    var localResponse = await PatientReposioryLocal().getCenters();

    print('local centers');
    print(localResponse);
    if (isNotNull(localResponse) && localResponse.isNotEmpty) {
      print('into local if');
      var locations = {
        'data': jsonDecode(localResponse[0]['data']),
        'error': false
      };
      print(locations);
      return locations;
    }

    return;
  }

  /// Create a new patient
  /// [formData] is required as parameter.
  create(context, formData) async {
    var uuid = Uuid().v4();
    final data = _prepareData(formData);
    print('create data');

    var apiResponse;
    var response;

    // response = await PatientReposioryLocal().create(context, uuid, data, false);

    var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    //   SyncController().initializeLocalToLiveSync();
    // }

    // return response;

    //TODO: checking the new process
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.
      print('connected');
      data['id'] = uuid;

      print('live patient create');
      print('before create patient id ' + uuid.toString());
      apiResponse = await PatientRepository().create(data);
      print('apiResponse');

      print(apiResponse);

      if (isNull(apiResponse)) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      } else if (apiResponse['message'] != null && apiResponse['message'] == 'Unauthorized') {
        Helpers().logout(context);
        return;
      } else if (apiResponse['exception'] != null) {
        if (apiResponse['type'] == 'unknown') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${apiResponse['message']}'),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }

        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Warning: ${apiResponse['message']}. Using offline...'),
          backgroundColor: kPrimaryYellowColor,
        ));

        response = await PatientReposioryLocal().create(context, uuid, data, false);
        return 'success';
      } else if (apiResponse['error'] != null && apiResponse['error']) {
        if (apiResponse['message'] == 'Patient already exists.') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                "Error: ${AppLocalizations.of(context).translate('nidValidation')}"),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${apiResponse['message']}"),
            backgroundColor: kPrimaryRedColor,
          ));
          return;
        }
      } else if (apiResponse['error'] != null && !apiResponse['error']) {
        response =
            await PatientReposioryLocal().create(context, uuid, data, true);

        // response = await await PatientReposioryLocal()
        //         .createFromLive(response['patient']['id'], data);

        if (isNotNull(apiResponse['data']['sync']) &&
            isNotNull(apiResponse['data']['sync']['key'])) {
          var updateSync = await SyncRepository()
              .updateLatestLocalSyncKey(apiResponse['data']['sync']['key']);
          print('after updating sync key');
          print(updateSync);
        }

        return 'success';
      }

      // response = await PatientReposioryLocal().create(data);

    } else {
      print('not connected');
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Warning: No Internet. Using offline...'),
        backgroundColor: kPrimaryYellowColor,
      ));
      response = await PatientReposioryLocal().create(context, uuid, data, false);
    }

    return 'success';
  }
  
  createOffline(context, formData) async {
    var uuid = Uuid().v4();
    final data = _prepareData(formData);
    print('patient create');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Saving data...'),
      backgroundColor: kPrimaryGreenColor,
    ));
    await PatientReposioryLocal().createNew(context, uuid, data, false);

    return 'success';
  }

  /// Create a new patient
  /// [formData] is required as parameter.
  update(formData, prepared) async {
    final data = prepared ? formData : _prepareData(formData);
    await PatientReposioryLocal().update(data);

    return 'success';
  }

  /// Prepare data to create a new patient.
  _prepareData(formData) {
    var age;
    var birthDate;
    if (formData['selected_dob_type'] == 'dob') {
      age = Helpers().calculateAge(formData['birth_year'], formData['birth_month'], formData['birth_date']);
      birthDate = formData['birth_year'] + '-' + formData['birth_month'] + '-' + formData['birth_date'];
    } else {
      age = int.tryParse(formData['age']);
      birthDate = Helpers().calculateDobFromAge(age);

    }

    var creationDateTime = formData['creationDateTime'];
    formData.remove('birth_date');
    formData.remove('birth_month');
    formData.remove('birth_year');
    formData.remove('creationDateTime');
    formData['age'] = age;
    formData['birth_date'] = birthDate;

    var data = {
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": creationDateTime
      },
      "body": formData
    };
    return data;
  }

  getMedicationsByPatient(patientId) async {
    var response = await PatientRepository().getMedicationsByPatient(patientId);
    return response;
  }

  dispenseMedicationByPatient(medId, dispensedMed) async {
    var response = await PatientRepository().dispenseMedicationByPatient(medId, dispensedMed);
    return response;
  }

}

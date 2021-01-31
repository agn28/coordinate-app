import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';

import 'package:nhealth/repositories/patient_repository.dart';

class PatientController {

  /// Get all the patients
  getAllPatients() async {
    var patients = await PatientReposioryLocal().getAllPatients();
    var data = [];
    var parsedData;

    await patients.forEach((patient) {
      parsedData = jsonDecode(patient['data']);
      data.add({
        'uuid': patient['uuid'],
        'data': parsedData['body'],
        'meta': parsedData['meta']
      });
    });

    return data;
  }

  getLocations() async {
    var response = await PatientRepository().getLocations();

    return response;
  }

  

  getPatient(patientId) async {
    var response = await PatientRepository().getPatient(patientId);

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'uuid': patient['uuid'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    return response;
  }

  getPatientsWorklist(context, type) async {
    var response = await PatientRepository().getPatientsWorklist(type);

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'uuid': patient['uuid'],
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
    //     'uuid': patient['uuid'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    return response;
  }

  /// Get all the patients
  getNewPatients() async {
    var response = await PatientRepository().getNewPatients();

    return response;
  }

  getExistingPatients() async {
    var response = await PatientRepository().getExistingPatients();

    return response;
  }

  getReferralPatients() async {
    var response = await PatientRepository().getReferralPatients();

    return response;
  }

  /// Create a new patient
  /// [formData] is required as parameter.
  create(formData) async {
    final data = _prepareData(formData);
    print('create data');

    var apiResponse;
    var response;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.

      print('connected');
      // return;

      apiResponse = await PatientRepository().create(data);
      print('apiResponse');
      print(apiResponse);
      // response = await PatientReposioryLocal().create(data);

    } else {
      print('not connected');
      return;
      response = await PatientReposioryLocal().create(data);
    }


    

    

    return response;
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
    final age = Helpers().calculateAge(formData['birth_year'], formData['birth_month'], formData['birth_date']);
    String birthDate = formData['birth_year'] + '-' + formData['birth_month'] + '-' + formData['birth_date'];
    formData.remove('birth_date');
    formData.remove('birth_month');
    formData.remove('birth_year');
    formData['age'] = age;
    formData['birth_date'] = birthDate;
    
    var data = {
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateTime.now().toString()
      },
      "body": formData
    };
    return data;
  }

}

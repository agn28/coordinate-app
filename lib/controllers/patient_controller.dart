import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'dart:convert';

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

  /// Create a new patient
  /// [formData] is required as parameter.
  create(formData) async {
    final data = _prepareData(formData);
    print('create data');
    await PatientReposioryLocal().create(data);

    return 'success';
  }

  /// Create a new patient
  /// [formData] is required as parameter.
  update(formData) async {
    final data = _prepareData(formData);
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

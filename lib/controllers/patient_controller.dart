import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:nhealth/repositories/local/local_patient_repository.dart';
import 'package:nhealth/repositories/patient_repository.dart';
import '../constants/constants.dart';
import 'dart:convert';

class PatientController {

  static create(formData) {

    final data = _prepareData(formData);

    var localData = jsonEncode(data);
    //LocalPatientReposiory.create(localData, 'not synced');
    LocalPatientReposiory.create(localData, 'not synced');
    PatientRepository.create(data);

    return;

  }

  static _prepareData(formData) {
    final age = _calculateAge(formData['birth_year'], formData['birth_month'], formData['birth_date']);

    formData.remove('birth_date');
    formData.remove('birth_month');
    formData.remove('birth_year');
    formData['age'] = age;
    
    var data = {
      "meta": {
        "performed_by": "9b900fa6-209e-11ea-978f-2e728ce88125",
      },
      "body": formData

    };
    return data;
  }

  static _calculateAge(year, month, date) {
    final birthDay = DateTime(int.parse(year), int.parse(month), int.parse(date));
    final now = DateTime.now();
    final ageInDays = now.difference(birthDay).inDays;
    final age = (ageInDays/365).floor();

    return age;
  }
}
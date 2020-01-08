import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:nhealth/repositories/local/local_patient_repository.dart';
import '../constants/constants.dart';
import 'dart:convert';

import './patient.dart';

class Patients with ChangeNotifier{
  List<Patient> _patients = [];
  Patient _patient;

  getPatientById(id) async {
    print(id);
    var patient;

    await http.get(
      Uri.encodeFull("$apiUrl/patients/$id"),
      headers: {
        "Accept": "appliaction/json"
      }
    ).then((response) => {
      patient = json.decode(response.body)['entry'][0],
      print(patient),
      _patient = Patient(
        id: patient['resource']['id'],
        name: patient['resource']['identifier'][0]['value'],
        details: patient['resource']['gender'],
        pid: patient['resource']['identifier'][0]['value']
      ),
      
    });
    return _patient;
  }

  getPatients() async {
    var patients;
    await http.get(
      Uri.encodeFull("$apiUrl/patients"),
      headers: {
        "Accept": "appliaction/json"
      }
    ).then((response) => {
      patients = json.decode(response.body)['entry'],

      patients.forEach((patient) => {
        if(patient['resource']['resourceType'] == 'Patient' &&  patient['resource']['identifier'] != null ) {
          _patients.add(
            Patient(
              id: patient['resource']['id'],
              name: patient['resource']['identifier'][0]['value'],
              details: patient['resource']['gender']
            )
          )
        }
      })
      // print(patients)
      
    });
    
    return _patients;
  }
  

}

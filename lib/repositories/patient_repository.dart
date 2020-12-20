import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import '../constants/constants.dart';
import 'dart:convert';

class PatientRepository {

  create(data) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    print(token);
    await http.post(
      apiUrl + 'patients',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      print('response');
      print(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  getPatient(patientId) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return http.get(
      apiUrl + 'patients/' + patientId,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  getPatients() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return http.get(
      apiUrl + 'patients',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  getNewPatients() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return http.get(
      apiUrl + 'patients/new',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      print("json.decode(response.body)['data'].length");
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  getExistingPatients() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return http.get(
      apiUrl + 'patients/existing',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  getReferralPatients() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return http.get(
      apiUrl + 'patients?type=referral',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  getPatientsWorklist(type) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    print('type ' + type);
    return http.get(
      apiUrl + 'patients?type=' + type,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      // print(json.decode(response.body));
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  update(data) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    var uuid = Patient().getPatient()['uuid'];
    print('token');
    print(data);
    await http.put(
      apiUrl + 'patients/' + uuid,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      print(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }
  
}

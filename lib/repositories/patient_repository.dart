import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import '../constants/constants.dart';
import 'dart:convert';

class PatientRepository {

  create(data) async {
    print('patient created');
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    await http.post(
      apiUrl + 'patients',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      
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

  update(data) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    await http.put(
      apiUrl + 'patients/' + data['id'],
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }
  
}

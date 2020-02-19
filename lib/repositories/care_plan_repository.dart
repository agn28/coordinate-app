import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:uuid/uuid.dart';
import '../constants/constants.dart';
import 'dart:convert';

class CarePlanRepository {

  getCarePlan() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    var patientID = Patient().getPatient()['uuid'];
    patientID = '4f77559c-2bec-40a1-b66f-edc401b9a2e9';
    return await http.get(
      apiUrl + 'care-plans/patient/' + patientID,
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

  getReports() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    var patientID = Patient().getPatient()['uuid'];
    patientID = '4f77559c-2bec-40a1-b66f-edc401b9a2e9';
    return await http.get(
      apiUrl + 'health-reports/',
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

  create(data) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return await http.post(
      apiUrl + 'health-reports',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      print('response ' + response.body);
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  update(data) async {
    print('update');
    print(data);
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    print(apiUrl);
    return await http.put(
      apiUrl + 'care-plans/' + data['id'],
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode({
        "status": "completed",
        "comment": "Completed becuase he has done it.",
        "completed_at": "17 january, 2019"
      })
    ).then((response) {
      print('response ' + response.body);
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }
  
}

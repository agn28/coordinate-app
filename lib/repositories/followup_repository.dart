import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import '../constants/constants.dart';
import 'dart:convert';

class FollowupRepository {

  create(data) async {
    print('folowup called');
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return await http.post(
      apiUrl + 'followups',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      return json.decode(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  update(data) async {
    print('folowup called');
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return await http.put(
      apiUrl + 'followups/' + data['id'],
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      return json.decode(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  getFollowupsByPatient(patientID) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return await http.get(
      apiUrl + 'patients/' + patientID + '/followups',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      print(json.decode(response.body));
      return json.decode(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  
}

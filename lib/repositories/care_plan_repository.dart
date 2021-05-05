import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import '../constants/constants.dart';
import 'dart:convert';

class CarePlanRepository {

  getCarePlan() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    var patientID = Patient().getPatient()['id'];

    var response;

    print(apiUrl + 'care-plans/' + patientID,);

    try {
      response = await http
      .get(apiUrl + 'care-plans/patient/' + patientID,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },).timeout(Duration(seconds: httpRequestTimeout));
      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      print('socket exception');
      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      print('timeout error');
      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {
      print('test error');
      print(err);
      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  getCarePlanById(id) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];

    var response;

    print(apiUrl + 'care-plans/' + id,);

    try {
      response = await http
      .get(apiUrl + 'care-plans/' + id,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },)
        
      .timeout(Duration(seconds: httpRequestTimeout));

      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      print('socket exception');
      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      print('timeout error');
      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {
      print('test error');
      print(err);
      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  getReports() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    var patientID = Patient().getPatient()['id'];
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
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  update(data, comment) async {
    print(apiUrl + 'care-plans/' + data['id']);
    var authData = await Auth().getStorageAuth();
    print('after get token');
    var token = authData['accessToken'];

    var response;

    try {
      response = await http.put(apiUrl + 'care-plans/' + data['id'],
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode({
        "status": "completed",
        "comment": comment,
        "completed_at": DateFormat('y-MM-d').format(DateTime.now())
      })).timeout(Duration(seconds: httpRequestTimeout));
      print('assessment created');
      print(response.body);
      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      print('socket exception');
      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      print('timeout error');
      return {'exception': true, 'message': 'Slow internet'};
    } on Error catch (err) {
      print('test error');
      print(err);
      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }
  
}

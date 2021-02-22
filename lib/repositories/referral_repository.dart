import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import '../constants/constants.dart';
import 'dart:convert';

class ReferralRepository {

  create(data) async {
    print('referral called');
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];

    var response;

    print(apiUrl + 'patients');

    try {
      response = await http
      .post(apiUrl + 'followups',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
        body: json.encode(data))
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

  getReferralById(id) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];

    var response;

    print(apiUrl + 'followups/' + id);

    try {
      response = await http
      .get(apiUrl + 'followups/' + id,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        })
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

  
}

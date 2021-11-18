import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import '../constants/constants.dart';
import 'dart:convert';

class CarePlanRepository {
  http.Client client = HttpClientWithInterceptor.build(interceptors: [
    ApiInterceptor(),
  ]);
  getCarePlan({checkAssignedTo: ''}) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    var patientID = Patient().getPatient()['id'];
    var qParam = '';

    if (checkAssignedTo != '') {
      qParam = '?check_assigned_to=' + checkAssignedTo;
    }

    var response;

    try {
      response = await client
      .get(apiUrl + 'care-plans/patient/' + patientID + qParam,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },).timeout(Duration(seconds: httpRequestTimeout));
      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {
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


    try {
      response = await client
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

      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  getCarePlanByIds(ids) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];

    var response;

    try {
      response = await client
      .post(apiUrl + 'care-plans/batch-mongo',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
        body: json.encode({"id": ids}),
        ).timeout(Duration(seconds: httpRequestTimeout));
      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);

      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {

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
    return await client.get(
      apiUrl + 'health-reports/',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      return json.decode(response.body);
      
    }).catchError((error) {

    });
  }

  create(data) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return await client.post(
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

    });
  }

  update(data, comment) async {

    var authData = await Auth().getStorageAuth();

    var token = authData['accessToken'];

    var response;

    try {
      response = await client.put(apiUrl + 'care-plans/' + data['id'],
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

      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);

      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return {'exception': true, 'message': 'Slow internet'};
    } on Error catch (err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  updateMongo(data) async {

    var authData = await Auth().getStorageAuth();

    var token = authData['accessToken'];

    var response;

    try {
      response = await client.put(apiUrl + 'care-plans/mongo/' + data['id'],
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode({
        "status": "completed",
        "comment": "",
        "completed_at": DateFormat('y-MM-d').format(DateTime.now())
      })).timeout(Duration(seconds: httpRequestTimeout));

      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);

      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return {'exception': true, 'message': 'Slow internet'};
    } on Error catch (err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }
  
}

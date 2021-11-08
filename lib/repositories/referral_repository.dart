import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import '../constants/constants.dart';
import 'dart:convert';

class ReferralRepository {
  http.Client client = HttpClientWithInterceptor.build(interceptors: [
    ApiInterceptor(),
  ]);
  create(data) async {

    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    var response;

    try {
      response = await client
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

      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return {
        'exception': true,
        'type': 'poor_network',
        'message': 'Slow internet'
      };
    } on Error catch (err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  update(data) async {

    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    return await client
        .put(apiUrl + 'followups/' + data['id'],
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + token
            },
            body: json.encode(data))
        .then((response) {
      return json.decode(response.body);
    }).catchError((error) {

    });
  }

  getFollowupsByPatient(patientID) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    return await client.get(
      apiUrl + 'patients/' + patientID + '/followups',
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

  getReferralById(id) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    var response;

    try {
      response = await client.get(apiUrl + 'followups/' + id, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      }).timeout(Duration(seconds: httpRequestTimeout));

      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);

      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      return {
        'exception': true,
        'type': 'poor_network',
        'message': 'Slow internet'
      };
    } on Error catch (err) {
      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  getReferralByIds(ids) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    var response;

    try {
      response = await client.post(apiUrl + 'followups/batch',
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

      return {
        'exception': true,
        'type': 'poor_network',
        'message': 'Slow internet'
      };
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

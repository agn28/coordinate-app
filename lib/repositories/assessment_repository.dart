import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import '../constants/constants.dart';
import 'dart:convert';

class AssessmentRepository {
  http.Client client = HttpClientWithInterceptor.build(interceptors: [
    ApiInterceptor(),
  ]);
  create(data) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    var response;
    try {
      response = await client
          .post(apiUrl + 'assessments/except-oha-mongo',
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

  getAssessmentsByIds(ids) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    return client.post(
      apiUrl + 'assessments/batch-mongo',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode({"ids": ids}),
    ).then((response) {
      return json.decode(response.body);
    }).catchError((error) {

    });
  }

  getObservationsByAssessment(assessmentId) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    var response;

    try {
      response = await client
          .get(apiUrl + 'assessments/' + assessmentId + '/observations',
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

  getAllObservations() async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var patientId = Patient().getPatient()['id'];

    return client.get(
      apiUrl + 'patients/' + patientId + '/observations',
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

  update(id, data) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    await client
        .put(apiUrl + 'assessments/' + id,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + token
            },
            body: json.encode(data))
        .then((response) {})
        .catchError((error) {

    });
  }

  delete(id) async {
    await client
        .delete(
          apiUrl + 'assessments/' + id,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        )
        .then((response) {})
        .catchError((error) {

        });
  }

}

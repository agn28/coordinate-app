import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import '../constants/constants.dart';
import 'dart:convert';

class AssessmentRepository {
  createOnlyAssessment(data) async {
    var authData = await Auth().getStorageAuth();
    print('after get token');
    var token = authData['accessToken'];

    await http
        .post(apiUrl + 'assessments/except-oha',
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + token
            },
            body: json.encode(data))
        .then((response) {
      print('assessment created');
      print(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }


  create(data) async {
    var authData = await Auth().getStorageAuth();
    print('after get token');
    var token = authData['accessToken'];

    var response;

    try {
      response = await http
          .post(apiUrl + 'assessments/except-oha',
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
              },
              body: json.encode(data))
          .timeout(Duration(seconds: httpRequestTimeout));
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

  createAssessmentWithObservations(data) async {
    var authData = await Auth().getStorageAuth();
    print('after get token');
    var token = authData['accessToken'];
    print('jsonData ${json.encode(data)}');
    var response;

    try {
      response = await http
        .post(apiUrl + 'assessments/full',
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + token
            },
            body: json.encode(data))
        .timeout(Duration(seconds: httpRequestTimeout));
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

  getAllAssessments() async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var patientId = Patient().getPatient()['id'];

    var response;

    try {
      response = await http.get(
        apiUrl + 'patients/' + patientId + '/assessments',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
      ).timeout(Duration(seconds: httpRequestTimeout));
      print('assessment get');
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

  getAssessmentsById(id) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    return http.get(
      apiUrl + 'assessments/' + id,
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

  getLastAssessment(key, value) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var patientId = Patient().getPatient()['id'];
    var qParam = '';

    if (key != null && value!= null) {
      qParam = '?'+ key +'=' + value;
    }
    var response;
    try {
      response = await http.get(
        apiUrl + 'assessments/patients/' + patientId + '/last' + qParam,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
      ).timeout(Duration(seconds: httpRequestTimeout));
      print('last assessment get');
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

  getIncompleteEncounterWithObservation(patientId) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    print(patientId);
    var response;
    try {
      response = await http.get(
        apiUrl + 'assessments/patients/' + patientId + '/incomplete-assessment',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
      ).timeout(Duration(seconds: httpRequestTimeout));
      print('incomplete assessment get');
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

  getObservationsByAssessment(assessmentId) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    var response;

    try {
      response = await http
          .get(apiUrl + 'assessments/' + assessmentId + '/observations',
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
              },)
          .timeout(Duration(seconds: httpRequestTimeout));
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

  getAllObservations() async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var patientId = Patient().getPatient()['id'];

    return http.get(
      apiUrl + 'patients/' + patientId + '/observations',
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

  update(id, data) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    await http
        .put(apiUrl + 'assessments/' + id,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + token
            },
            body: json.encode(data))
        .then((response) {})
        .catchError((error) {
      print('error ' + error.toString());
    });
  }
}

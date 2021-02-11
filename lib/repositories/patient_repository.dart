import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/services/api_service.dart';
import '../constants/constants.dart';
import 'dart:convert';
import 'package:get/get.dart';

class PatientRepository {
  // var syncController = SyncController();

  create(data) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var api = ApiService();

    var response;

    print(apiUrl + 'patients');

    try {
      response = await http
      .post(apiUrl + 'patients',
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

  getLocations() async {
    var response;

    try {
      response = await http.get(
        apiUrl + 'locations',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      ).timeout(Duration(seconds: httpRequestTimeout));

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

  getPatient(patientId) async {
    var authData = await Auth().getStorageAuth();
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
    var authData = await Auth().getStorageAuth();
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
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var response;

    try {
      response = await http
        .get(apiUrl + 'patients/new',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
          },
        )
        .timeout(Duration(seconds: httpRequestTimeout));

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

  getExistingPatients() async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var response;

    try {
      response = await http
        .get(apiUrl + 'patients/existing',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
          },
        )
        .timeout(Duration(seconds: httpRequestTimeout));

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

  getReferralPatients() async {
    var authData = await Auth().getStorageAuth();
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
    var authData = await Auth().getStorageAuth();
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
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var uuid = Patient().getPatient()['id'];
    print('token');
    print(data);
    await http
        .put(apiUrl + 'patients/' + uuid,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + token
            },
            body: json.encode(data))
        .then((response) {
      print(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }
}

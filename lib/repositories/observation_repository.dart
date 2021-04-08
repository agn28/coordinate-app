import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import '../constants/constants.dart';
import 'dart:convert';

class ObservationRepository {
  getObservations() async {
    return await http.get(
      apiUrl + 'observations',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    ).then((response) {
      return json.decode(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  create(data) async {
    print('into live observation create');
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    var response;
    print(json.encode(data));
    try {
      response = await http
          .post(apiUrl + 'observations',
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
              },
              body: json.encode(data))
          .timeout(Duration(seconds: httpRequestTimeout));
      print('observations created');
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

  update(id, data) async {
    await http
        .put(apiUrl + 'observations/' + id,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json'
            },
            body: json.encode(data))
        .then((response) {})
        .catchError((error) {
      print('error ' + error.toString());
    });
  }

  delete(id) async {
    await http
        .delete(
          apiUrl + 'observations/' + id,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        )
        .then((response) {})
        .catchError((error) {
          print('error ' + error.toString());
        });
  }

  getObservationById(id) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];

    return http.get(
      apiUrl + 'observations/' + id,
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
}

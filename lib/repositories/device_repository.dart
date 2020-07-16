import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import '../constants/constants.dart';
import 'dart:convert';

class DeviceRepository {

  getDevices() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return http.get(
      apiUrl + 'devices',
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

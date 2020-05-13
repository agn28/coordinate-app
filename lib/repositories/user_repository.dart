import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import '../constants/constants.dart';
import 'dart:convert';

class UserRepository {



  getUsers() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return http.get(
      apiUrl + 'users?role=nurse,doctor,chw',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      print('users');
      print(json.decode(response.body));
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  
  
}

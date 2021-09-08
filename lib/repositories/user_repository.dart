import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import '../constants/constants.dart';
import 'dart:convert';

class UserRepository {
  http.Client client = HttpClientWithInterceptor.build(interceptors: [
    ApiInterceptor(),
  ]);
  getUsers() async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return client.get(
      apiUrl + 'users?role=',
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

  getUser(userId) async {
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    return client.get(
      apiUrl + 'users/' + userId,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      print('getuser ${response.body}');
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }
  
}

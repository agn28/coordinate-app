import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'dart:convert';

class AuthRepository {
    login(email, password) async {

    return await http.post(
      apiUrl + 'users/login',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'email': email,
        'password': password
      })
    ).then((response) {

      return json.decode(response.body);
      
    }).catchError((error) {

    });
  } 
}

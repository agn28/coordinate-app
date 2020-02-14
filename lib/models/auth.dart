
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

var localAuth = {};

class Auth {
  setAuth(auth) async {
    final prefs = await SharedPreferences.getInstance();
    localAuth = auth;
    await prefs.setString('auth', jsonEncode(auth));

  }

  getAuth() {
    return localAuth;
  }

  getStorageAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth = prefs.getString('auth');

    if (auth == null) {
      return {
        'status': false
      };
    }

    var authData = jsonDecode(auth);
    

    return {
      'status': true,
      'id': authData['uid'],
      'name': authData['name'],
      'email': authData['email'],
      'accessToken': authData['accessToken'],
      'expirationTime': authData['expirationTime']
    };
  }

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
    localAuth = {};
    return 'success';
  }
}

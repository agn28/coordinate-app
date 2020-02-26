
import 'dart:convert';
import 'package:intl/intl.dart';
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

    // print(DateTime.parse('Fri, 14 Feb 2020 09:35:32'));
    localAuth = authData;
    if (isExpired()) {
      return {
        'status': false
      };
    }
    
    return {
      'status': true,
      'id': authData['uid'],
      'name': authData['name'],
      'email': authData['email'],
      'accessToken': authData['accessToken'],
      'expirationTime': authData['expirationTime']
    };
  }

  isExpired() {

    if (localAuth != {} && localAuth['expirationTime'] != null) {
      return DateTime.parse(localAuth['expirationTime']).add(DateTime.now().timeZoneOffset).isBefore(DateTime.now());
    }
    return true;
  }

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
    localAuth = {};
    return 'success';
  }
}


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

    // print(jsonDecode(auth)['expirationTime']);

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
      'role': authData['role'],
      'accessToken': authData['accessToken'],
      'expirationTime': authData['expirationTime']
    };
  }

  isExpired() {
    print('local auth');
    print(localAuth);
    if (localAuth != {} && localAuth['expirationTime'] != null) {
      print(localAuth['expirationTime']);
      return DateTime.parse(localAuth['expirationTime']).add(DateTime.now().timeZoneOffset).add(Duration(hours: 12)).isBefore(DateTime.now());
    } else return true;
  }

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
    localAuth = {};
    return 'success';
  }
}

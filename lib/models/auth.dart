
import 'dart:convert';
import 'package:device_info/device_info.dart';
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

    localAuth = authData;
    if (isExpired()) {
      return {
        'status': false
      };
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    
    return {
      'status': true,
      'id': authData['uid'],
      'name': authData['name'],
      'email': authData['email'],
      'role': authData['role'],
      'address': authData['address'],
      'accessToken': authData['accessToken'],
      'refreshToken': authData['refreshToken'],
      'expirationTime': authData['expirationTime'],
      'deviceId': androidInfo.androidId
    };
  }

  isExpired() {
    if (localAuth != {} && localAuth['expirationTime'] != null) {
      print('isexpired ${DateTime.parse(localAuth['expirationTime']).add(DateTime.now().timeZoneOffset).add(Duration(hours: 12)).isBefore(DateTime.now())}');
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

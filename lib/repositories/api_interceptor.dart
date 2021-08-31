import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/models/auth.dart';
import 'package:http/http.dart' as http;

class ApiInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    try {
      var authData = await Auth().getStorageAuth() ;
      var currentTime = DateTime.now();
      var currentTimeTz = int.parse(DateTime.now().timeZoneOffset.inHours.toString());
      var expireTime = DateTime.parse(authData['expirationTime']).add(Duration(hours: currentTimeTz));
      var diff = (expireTime.difference(currentTime).inMinutes);
      print('expireTime ${expireTime}');
      print('currentTime ${currentTime}');
      print('currentTimeTz ${currentTimeTz}');
      print('diff ${diff}');
      // if(diff <= 5) 
      {
        // call api to replace access token
        var newAuthData = await getNewToken(authData['refreshToken']);
        print('newAuthData $newAuthData');
      }
    } catch (e) {
      print(e);
    }
    return data;
  }

  getNewToken(refreshToken) async {
    var reqBody =
    {
        "grant_type": "refresh_token",
        "refresh_token": refreshToken
    };
    print(reqBody);
    http.post('https://securetoken.googleapis.com/v1/token?key=AIzaSyCl7r4QoD06uiVTRSRDtjLySwoamlfD6zM',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode(reqBody)
    ).then((response) {
      print('reponse ${json.decode(response.body)}');
      return json.decode(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async => data;
}
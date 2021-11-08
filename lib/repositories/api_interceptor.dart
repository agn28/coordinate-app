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
      var timeDifference = (expireTime.difference(currentTime).inMinutes);
      // var expireTime = DateTime.parse(authData['expirationTime']).add(DateTime.now().timeZoneOffset);
      // var timeDifference = (expireTime.difference(DateTime.now()).inMinutes);
      if(timeDifference <= 5) 
      {
        // call api to replace access token
        var newAuthData = await getNewToken(authData['refreshToken']);
        if (newAuthData['access_token'] != null) {
          authData['uid'] = newAuthData['user_id'];
          authData['accessToken'] = newAuthData['access_token'];
          authData['refreshToken'] = newAuthData['refresh_token'];
          authData['expirationTime'] = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now().toUtc().add(Duration(seconds: int.parse(newAuthData['expires_in']))));
          await Auth().setAuth(authData);
          // return response;
        }
      }
      data.headers["Accept"] = "application/json";
      data.headers["Content-Type"] = "application/json";
      data.headers["Authorization"] = "Bearer " + authData['accessToken'];
    } catch (e) {

    }
    return data;
  }

  getNewToken(refreshToken) async {
    var reqBody =
    {
        "grant_type": "refresh_token",
        "refresh_token": refreshToken
    };
    return await http.post('https://securetoken.googleapis.com/v1/token?key=AIzaSyCl7r4QoD06uiVTRSRDtjLySwoamlfD6zM',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode(reqBody)
    ).then((response) {
      return json.decode(response.body);
    }).catchError((error) {

    });
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async => data;
}

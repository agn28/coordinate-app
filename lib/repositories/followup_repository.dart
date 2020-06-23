import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import '../constants/constants.dart';
import 'dart:convert';

class FollowupRepository {

  create(data) async {
    print('folowup called');
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    await http.post(
      apiUrl + 'followups',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      print(response.body);
      return json.decode(response.body);
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  
}

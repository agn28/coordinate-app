import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import '../constants/constants.dart';
import 'dart:convert';

class PatientRepository {

  create(data) async {
    print('patient created');
    print(data);
    var token = Auth().getAuth()['accessToken'] ;
    await http.post(
      apiUrl + 'patients',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data)
    ).then((response) {
      print('response ' + response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }
  
}

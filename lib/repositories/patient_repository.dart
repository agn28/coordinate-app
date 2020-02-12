import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'dart:convert';

class PatientRepository {

  create(data) async {
    await http.post(
      apiUrl + 'patients',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode(data)
    ).then((response) {
      print('response ' + response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }
  
}

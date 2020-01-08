import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'dart:convert';

class PatientRepository {

  static create(data) async {
    // print(jsonEncode(data));
    // return;
    await http.post(
      localUrl + 'patients',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode(data)
    ).then((response) => {
      print('response ' + response.body)
      
    }).catchError((error) => {
      print('error ' + error.toString())
    });
  }
  
}
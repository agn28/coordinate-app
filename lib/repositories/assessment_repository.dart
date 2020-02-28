import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'dart:convert';

class AssessmentRepository {

  create(data) async {
    
    await http.post(
      apiUrl + 'assessments',
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

  update(id, data) async {
    
    await http.put(
      apiUrl + 'assessments/' + id,
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

import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import '../constants/constants.dart';
import 'dart:convert';

class WorklistRepository {

  getWorklist() async {

    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];

    return await http.get(
      apiUrl + 'care-plans/work-list' ,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).then((response) {
      return jsonDecode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
    
    
  }
  
}

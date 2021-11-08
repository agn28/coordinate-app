import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import '../constants/constants.dart';
import 'dart:convert';

class MedicalIssuesRepository {
  http.Client client = HttpClientWithInterceptor.build(interceptors: [
    ApiInterceptor(),
  ]);
  getIssues() async {

    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];

    return await client.get(
      apiUrl + 'medications' ,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    ).then((response) {
      return jsonDecode(response.body);
      
    }).catchError((error) {

    });
    
  }
  
}

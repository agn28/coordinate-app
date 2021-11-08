import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import '../constants/constants.dart';
import 'dart:convert';

class WorklistRepository {
  http.Client client = HttpClientWithInterceptor.build(interceptors: [
    ApiInterceptor(),
  ]);
  getWorklist() async {

    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];

    return await client.get(
      apiUrl + 'care-plans/work-list' ,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).then((response) {
      return jsonDecode(response.body);
      
    }).catchError((error) {

    });
    
  }
  
}

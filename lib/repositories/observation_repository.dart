import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'dart:convert';

class ObservationRepository {

  getObservations() async {
    return await http.get(
      apiUrl + 'observations',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    ).then((response) {
      return json.decode(response.body);
      
    }).catchError((error) {
      print('error ' + error.toString());
    });
  }

  create(data) async {
    
    await http.post(
      apiUrl + 'observations',
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

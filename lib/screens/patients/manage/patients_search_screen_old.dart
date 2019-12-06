import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:nhealth/screens/patients/manage/patient_records_screen.dart';

class SearchPatientsScreen extends StatefulWidget {
  @override
  _SearchPatientsScreenState createState() => _SearchPatientsScreenState();
}

class _SearchPatientsScreenState extends State<SearchPatientsScreen> {

  Future<String> getData() async {
    http.Response response = await http.get(
      Uri.encodeFull("https://fhirapi.monarko.com/patients"),
      headers: {
        "Accept": "appliaction/json"
      }
    );

    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Patients'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 40, right: 40),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40,),
                  Text('Enter Patient ID', style: TextStyle(fontSize: 22)),
                  SizedBox(height: 10,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Patient ID",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 30,),
                  Text('Or', style: TextStyle(fontSize: 22)),
                  SizedBox(height: 40,),
                  Text('Enter Patient NID', style: TextStyle(fontSize: 22)),
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "NID",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  
                  SizedBox(height: 20,),
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: RaisedButton(
                      onPressed: () {},
                      child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 22),),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

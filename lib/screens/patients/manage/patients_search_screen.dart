import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:search_widget/search_widget.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'package:nhealth/screens/patients/manage/patient_records_screen.dart';


class SearchPatientsScreen extends CupertinoPageRoute {
  SearchPatientsScreen()
      : super(builder: (BuildContext context) => new SearchPatients());

}

class SearchPatients extends StatefulWidget {
  @override
  _SearchPatientsState createState() => _SearchPatientsState();
}


class _SearchPatientsState extends State<SearchPatients> {

  bool isLoading = true;
  Future getData() async {
    showSearch(context: context, delegate: DataSearch());
  }

  @override
  void initState() {
    var patients = PatientController().getAllPatients();

    patients.then((data) => {
      isLoading = false,
      showSearch(context: context, delegate: DataSearch(patients: data, isLoading: isLoading))

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Patients', style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {
            var patients = PatientController().getAllPatients();
            patients.then((data) => {
              isLoading = false,
              showSearch(context: context, delegate: DataSearch(patients: data, isLoading: isLoading))
            });
            
          },)
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {

  final patients;
  bool isLoading;

  DataSearch({this.patients, this.isLoading});

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for app bar
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () {
        query = '';
      },)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of the app bar
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ), onPressed: () {
      close(context, null);
    },);
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on the selection
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionList = patients.where((c) => c['data']['name'].toString().startsWith(query)).toList();

    return isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () => {
          Patient().setPatient(patients[index]),
          Navigator.of(context).push(PatientRecordsScreen())
        },
        title: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: RichText(text: TextSpan(
                  text: suggestionList[index]['data']['name'].toString().substring(0, query.length),
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                  children: [TextSpan(
                    text: suggestionList[index]['data']['name'].toString().substring(query.length),
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w400),
                  )]
                )),
              ),
              Expanded(
                child: Text(suggestionList[index]['data']['age'].toString() + 'Y ' + '${suggestionList[index]['data']['gender'][0].toUpperCase()}' + ' - ' + suggestionList[index]['data']['nid'].toString(), 
                style: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.w400
                  ), 
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
        )
      ),
      itemCount: suggestionList.length,
    );
  }
  
}

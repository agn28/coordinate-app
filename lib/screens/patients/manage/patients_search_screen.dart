import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/patients.dart';
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
    // var data = jsonDecode(response.body);
  
    // print(data['entry']);
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var test = Patients().getPatients();

    test.then((test) => {
      isLoading = false,
      showSearch(context: context, delegate: DataSearch(data: test, isLoading: isLoading))

    });
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
            var test = Patients().getPatients();

            test.then((test) => {
              isLoading = false,
              showSearch(context: context, delegate: DataSearch(data: test, isLoading: isLoading))
            });
            
          },)
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {

  final data;
  bool isLoading;

  final patients = [
    {
      "name": 'Aklima Khatun',
      "details": '31Y F - 19912312932'
    }, 
    {
      "name": 'Ahnaf Begum',
      "details": '45Y F - 12341245511'
    },
    {
      "name": 'Amir Jahan',
      "details": '18Y F - 42413562436'
    }
  ];
  DataSearch({this.data, this.isLoading});

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
    // print(data);
    // final suggestionList = query.isEmpty ? recentCities : cities.where((c) => c.startsWith(query)).toList();
    final suggestionList = patients.where((c) => c['name'].toString().startsWith(query)).toList();

    return isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () => Navigator.of(context).push(PatientRecordsScreen()),
        title: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: RichText(text: TextSpan(
                  text: suggestionList[index]['name'].toString().substring(0, query.length),
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                  children: [TextSpan(
                    text: suggestionList[index]['name'].toString().substring(query.length),
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w400),
                  )]
                )),
              ),
              Expanded(
                child: Text(suggestionList[index]['details'], 
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

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/screens/settings/settings_screen.dart';
import 'package:nhealth/screens/work-list/work_list_search_screen.dart';
import 'package:nhealth/app_localizations.dart';


class ChwHomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ChwHomeScreen> {
  String userName = '';
  String role = '';
  int _currentIndex = 0;
  @override
  initState() {
    _getAuthData();
    super.initState();
  }
  

  _getAuthData() async {
    var data = await Auth().getStorageAuth();
    print('hello');
    print(data);
    if (!data['status']) {
      await Auth().logout();
      Navigator.of(context).pushNamed('/login',);
    }
    // Navigator.of(context).pushNamed('/login',);
    setState(() {
      userName = data['name'];
      role = data['role'];
    });
  }
  var navigationItems = [
    Center(child: Text('worklist'),),
    Center(child: Text('patients'),),
    Center(child: Text('new patient'),),
    Center(child: Text('more'),)
  ];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('home'), style: TextStyle(color: Colors.white, fontSize: 22),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      
      body: navigationItems[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        unselectedFontSize: 16,
        selectedFontSize: 16,
        elevation: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Work List')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text('Patients')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            title: Text('New Patient')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            title: Text('More')
          )
        ],
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
    );
  }
}


import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_search_screen.dart';
import 'package:nhealth/screens/chw/work-list/work_list_search_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/screens/settings/settings_screen.dart';
import 'package:nhealth/screens/work-list/work_list_search_screen.dart';
import 'package:nhealth/app_localizations.dart';


class ChwNavigationScreen extends StatefulWidget {
  final pageIndex;
  ChwNavigationScreen({this.pageIndex});

  @override
  _ChwNavigationState createState() => _ChwNavigationState();
}

class _ChwNavigationState extends State<ChwNavigationScreen> {
  String userName = '';
  String role = '';
  int _currentIndex = 0;
  @override
  initState() {
    _getAuthData();
    super.initState();
    setPage();
  }

  setPage() {
    if (widget.pageIndex != null && widget.pageIndex < 4) {
      setState(() {
        _currentIndex = widget.pageIndex;
      });
    }
  }
  

  _getAuthData() async {
    var data = await Auth().getStorageAuth();
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
    ChwWorkListSearchScreen(),
    ChwPatientSearchScreen(),
    Container(),
  ];
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/chwHome');
        return true;
      },
      child: Scaffold(
        // appBar: new AppBar(
        //   title: new Text(AppLocalizations.of(context).translate('home'), style: TextStyle(color: Colors.white, fontSize: 22),),
        //   backgroundColor: kPrimaryColor,
        //   elevation: 0.0,
        //   iconTheme: IconThemeData(color: Colors.white),
        //   actions: <Widget>[
        //     FlatButton(
        //       child: Text('Logout', style: TextStyle(color: Colors.white),),
        //       onPressed: () async {
        //         await Auth().logout();
        //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
        //       },
        //     )
        //   ],
        // ),
        
        body: navigationItems[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(3, 0), // changes position of shadow
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            unselectedFontSize: 16,
            selectedFontSize: 16,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                title: Text(AppLocalizations.of(context).translate('workList'))
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                title: Text(AppLocalizations.of(context).translate('patients'))
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_add),
                title: Text(AppLocalizations.of(context).translate('newPatient'))
              ),
            ],
            onTap: (value) {
              if(value == 2) {
                Navigator.of(context).push(RegisterPatientScreen());
              } else {
                setState(() {
                  _currentIndex = value;
                });
              }
            },
          ),
        )
      ),
    );
  }
}


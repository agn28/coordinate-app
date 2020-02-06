import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen_new.dart';
import 'package:nhealth/screens/settings/settings_screen.dart';
import 'package:nhealth/screens/work-list/work_list_search_screen_new.dart';
import './patients/register_patient_screen.dart';


class HomeScreen extends CupertinoPageRoute {
  HomeScreen()
      : super(builder: (BuildContext context) => new Home());

}
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Home", style: TextStyle(color: Colors.white, fontSize: 22),),
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
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 60,),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.perm_identity, size: 40, color: Colors.black54,),
                  ),
                  SizedBox(height: 30,),
                  Text('Rokeya Khatun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                  Text('Nurse', style: TextStyle(fontSize: 17, height: 1.8),),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Go to Profile', style: TextStyle(fontSize: 17, height: 2.5, color: kPrimaryColor),),
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.black26)
                )
              ),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.only(left: 10, right: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    color: kLightPrimaryColor,
                    height: 50,
                    child: FlatButton(
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.home, color: kPrimaryColor,),
                          SizedBox(width: 20,),
                          Text('Home',style: TextStyle( fontSize: 18,fontWeight: FontWeight.w500, color: kPrimaryColor))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).push(PatientSearchScreenNew());
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.supervisor_account, color: Colors.black54,),
                          SizedBox(width: 20,),
                          Text('Patients',style: TextStyle( fontSize: 18,fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).push(WorkListSearchScreenNew());
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.list, color: Colors.black54,),
                          SizedBox(width: 20,),
                          Text('Work List',style: TextStyle( fontSize: 18,fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.black26)
                )
              ),
            ),

            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.only(left: 10, right: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () => Navigator.of(context).push(SettingsScreen()),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.settings, color: Colors.black54),
                          SizedBox(width: 20,),
                          Text('Settings',style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.exit_to_app, color: Colors.black54),
                          SizedBox(width: 20,),
                          Text('Logout', style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 18),
                    child: Row(
                      children: <Widget>[
                        Text('Version 0.0.1 (beta)', style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400)),
                      ],
                    )
                  )
                ],
              )
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: 360,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_home.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 70, top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Text('Welcome', style: TextStyle(color: Colors.white70, fontSize: 21),),
                        SizedBox(height: 15,),
                        Text('Rokeya Khatun', style: TextStyle(color: Colors.white, fontSize: 26),),
                        SizedBox(height: 15,),
                        Text('Nurse', style: TextStyle(color: Colors.white70, fontSize: 16),),
                        SizedBox(height: 40,),
                        Text('What would you like to do?', style: TextStyle(color: Colors.white, fontSize: 36),)
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 40, right: 40),
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        
                        SizedBox(height: 40,),

                        GestureDetector(
                          onTap: () => Navigator.of(context).push(PatientSearchScreenNew()),
                          child: Container(
                            height: 190,
                            width: double.infinity,
                            child: Card(
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('assets/images/icons/manage_patient.png'),
                                  FlatButton(
                                    onPressed: () {
                                      print('hello');
                                      // Navigator.of(context).push(PatientSearchScreenNew());
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Text('Manage an Existing Patients',textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 24),),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                                          ),
                                        )
                                      ],
                                    )
                                  ),
                                ],
                              )
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: () => Navigator.of(context).push(RegisterPatientScreen()),
                          child: Container(
                            height: 190,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Card(
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('assets/images/icons/register_patient.png'),
                                  FlatButton(
                                    onPressed: () => Navigator.of(context).push(RegisterPatientScreen()),
                                    child: Row(

                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: Text('Register a New Patient',textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 24),),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                                          ),
                                        )
                                      ],
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:expandable/expandable.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/user_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';


class VerifyPatientScreen extends StatefulWidget {
  @override
  _VerifyPatientState createState() => _VerifyPatientState();
}

class _VerifyPatientState extends State<VerifyPatientScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();

  }

  _checkAvatar() async {
    avatarExists = await File(Patient().getPatient()['data']['avatar']).exists();
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('New Community visit', style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(RegisterPatientScreen(isEdit: true));
            },
            child: Container(
              margin: EdgeInsets.only(right: 30),
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit, color: Colors.white,),
                  SizedBox(width: 10),
                  Text(AppLocalizations.of(context).translate('viewOrEditPatient'), style: TextStyle(color: Colors.white))
                ],
              )
            )
          )
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30,),
                    Container(
                      child: Text('Verify Patient', style: TextStyle(fontSize: 23),)
                    ),
                    SizedBox(height: 30,),
                    CircleAvatar(
                      radius: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Image.asset(
                          'assets/images/patient_big.png',
                          height: 140.0,
                          width: 140.0,
                        ),
                      ),
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    SizedBox(height: 30,),
                    Text('Nurul Begum', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 20,),
                    Text('45 Y F', style: TextStyle(fontSize: 20, color: kTextGrey),),
                    SizedBox(height: 30,),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      height: 60,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(3)
                      ),
                      child: FlatButton(
                        onPressed: () async {
                          Navigator.of(context).pushNamed('/patientFeeling');
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text('CONFIRM PATIENT & CONTINUE', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                      ),
                    ),
                    SizedBox(height: 30,),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: kPrimaryColor)
                      ),
                      child: FlatButton(
                        onPressed: () async {
                          setState(() {
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text('MARK AS UNSUCCESSFULL VISIT', style: TextStyle(fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.w500),)
                      ),
                    ),
                    
                  ], 
                  
                ),
              ),
              isLoading ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Color(0x90FFFFFF),
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
                ),
              ) : Container(),
              // Container(
              //   height: 300,
              //   width: double.infinity,
              //   color: Colors.black12,
              // )
            ],
          ),
        ),
      ),
    );
  }
}

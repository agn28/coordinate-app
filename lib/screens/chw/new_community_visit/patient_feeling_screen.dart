import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

class PatientFeelingScreen extends StatefulWidget {
  final communityClinic;
  PatientFeelingScreen({this.communityClinic});
  @override
  _PatientFeelingState createState() => _PatientFeelingState();
}

class _PatientFeelingState extends State<PatientFeelingScreen> {
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
        title: new Text(AppLocalizations.of(context).translate('newCommunityVisit'), style: TextStyle(color: Colors.white, fontSize: 20),),
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
              Column(
                children: <Widget>[
                  PatientTopbar(),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 40,),
                        Container(
                          child: Text(AppLocalizations.of(context).translate('howIsFeelingToday'), style: TextStyle(fontSize: 23),)
                        ),
                        SizedBox(height: 40,),

                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                height: 180,
                                decoration: BoxDecoration(
                                  color: kPrimaryGreenColor,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: FlatButton(
                                  onPressed: () async {
                                    // Navigator.of(context).pushNamed(NewPatientQuestionnaireScreen.path);
                                    if (widget.communityClinic != null) {
                                      Navigator.of(context).pushNamed('/chwNewEncounter', arguments: { 'communityClinic': true });
                                      return;
                                    }
                                    
                                    Navigator.of(context).pushNamed('/chwPatientSummary', arguments: true);
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('assets/images/icons/well.png'),
                                      SizedBox(height: 20,),
                                      Text(AppLocalizations.of(context).translate('well'), style: TextStyle(fontSize: 21, color: Colors.white, fontWeight: FontWeight.normal),)
                                    ],
                                  )
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                height: 180,
                                decoration: BoxDecoration(
                                  color: kPrimaryRedColor,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: FlatButton(
                                  onPressed: () async {
                                    Navigator.of(context).pushNamed('/chwFollowup');
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('assets/images/icons/unwell.png'),
                                      SizedBox(height: 20,),
                                      Text(AppLocalizations.of(context).translate('unwell'), style: TextStyle(fontSize: 21, color: Colors.white, fontWeight: FontWeight.normal),)
                                    ],
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 30,),
                        
                        
                      ], 
                      
                    ),
                  ),
                  
                ],
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

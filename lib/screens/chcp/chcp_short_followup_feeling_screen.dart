import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/followup/well_followup_screen.dart';
import 'package:nhealth/screens/chw/new_patient_questionnairs/new_patient_questionnaire_screen.dart';
import 'package:nhealth/screens/chw/new_patient_questionnairs/new_questionnaire_acute_screen.dart';
import 'package:nhealth/screens/chw/unwell/followup_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_acute_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_visit_screen.dart';
import 'package:nhealth/screens/patients/ncd/search/unwell_followup_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

import 'followup_visit_chcp_screen.dart';
import 'full_assessment_chcp_screen.dart';
import 'unwell_chcp_screen.dart';
import 'unwell_full_assessment_chcp_screen.dart';
import 'unwell_short_followup_chcp_screen.dart';

class ChcpShortFollowupFeelingScreen extends StatefulWidget {
  static const path = '/chcpShortFollowupFeelingScreen';

  final communityClinic;
  ChcpShortFollowupFeelingScreen({this.communityClinic});
  @override
  _ChcpShortFollowupFeelingScreenState createState() => _ChcpShortFollowupFeelingScreenState();
}

class _ChcpShortFollowupFeelingScreenState extends State<ChcpShortFollowupFeelingScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    print('chcp short followup feeling screen');

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
        title: new Text(AppLocalizations.of(context).translate('followupVisit'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
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
                                    // Navigator.of(context).pushNamed(WellFollowupScreen.path);
                                    // Navigator.of(context).pushNamed('/editIncompleteEncounterChcp',);
                                    // Navigator.of(context).pushNamed(FullAssessmentChcpScreen.path);
                                    Navigator.of(context).pushNamed(FollowupVisitChcpScreen.path);
                                    
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
                                    
                                    Navigator.of(context).pushNamed(UnwellShortFollowupChcpScreen.path);
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

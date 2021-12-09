import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/nurse/new_patient_questionnairs/followup/full_assessment_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/screens/patients/ncd/followup_visit_screen.dart';

class NewFollowupScreen extends StatefulWidget {
  static const path = '/newFollowup';

  var checkInState = false;
  NewFollowupScreen({this.checkInState});
  @override
  _NewFollowupScreenState createState() => _NewFollowupScreenState();
}

class _NewFollowupScreenState extends State<NewFollowupScreen> {
  var _patient;
  bool isLoading = true;
  bool avatarExists = false;
  String lastFullAssessmentDate = '';
  String lastShortAssessmentDate = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    
    _checkAvatar();
    _checkAuth();
    getLastAssessments();
    
  }

  getLastAssessments() async {
  
    var lastFullAssessment = await AssessmentController().getLastAssessmentByPatient(key:'followup_type', value:'full');
    if (lastFullAssessment['error'] == true) {

    } else if (lastFullAssessment['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        lastFullAssessmentDate = DateFormat("MMMM d, y").format(DateTime.parse(lastFullAssessment['data']['meta']['created_at']));
      });
    }

    var lastShortAssessment = await AssessmentController().getLastAssessmentByPatient(key:'followup_type', value:'short');
    if (lastShortAssessment['error'] == true) {

    } else if (lastFullAssessment['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        lastShortAssessmentDate = DateFormat("MMMM d, y").format(DateTime.parse(lastShortAssessment['data']['meta']['created_at']));
      });
    }
    setState(() {
      isLoading = false;
    });
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
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('followUp'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[

        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  PatientTopbar(),
                  SizedBox(height: 15,),
                  Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 35, top: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 20,),
                                  Text(AppLocalizations.of(context).translate('selectPurpose'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                  SizedBox(height: 20,),
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: FlatButton(
                                      onPressed: () async {
                                        Navigator.of(context).pushNamed(FullAssessmentScreen.path);
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Text(AppLocalizations.of(context).translate('fullassessment').toUpperCase(), style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.normal),)
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Text(AppLocalizations.of(context).translate('lastFullAssessment')+lastFullAssessmentDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                  SizedBox(height: 20,),
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: FlatButton(
                                      onPressed: () async {
                                        Navigator.of(context).pushNamed(FollowupVisitScreen.path);
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Text(AppLocalizations.of(context).translate('shortFollowUp').toUpperCase(), style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.normal),)
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Text(AppLocalizations.of(context).translate('lastShortFollowUp')+lastShortAssessmentDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                  SizedBox(height: 20,),
                                ],
                              ),
                            ),                  
                          ],
                        )
                      ),
                    ],
                  ),
                )
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
            ],
          ),
        ),
      ),
    );
  }
}

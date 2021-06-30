import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/user_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
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
  var users = [];
  String lastFullAssessmentDate = '';
  String lastShortAssessmentDate = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    
    _checkAvatar();
    _checkAuth();
    getUsers();
    getLastAssessments();
    
  }

  getLastAssessments() async {
  
    var lastFullAssessment = await AssessmentController().getLastAssessmentByPatient(key:'followup_type', value:'full');
    print('lastFullAssessment ${lastFullAssessment['data']['meta']['created_at']}');

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
    print('lastShortAssessment $lastShortAssessment');
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

  getUsers() async {
  
    var data = await UserController().getUsers();


    setState(() {
      users = data;
      isLoading = false;
    });
  }

  getUser(uid) {
    var user = users.where((user) => user['uid'] == uid);
    if (user.isNotEmpty) {
      return user.first['name'];
    }

    return '';
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

  convertDateFromSeconds(date) {
    if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);

      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  getTitle(encounter) {
    var screening_type =  encounter['data']['screening_type'];
    if (screening_type != null && screening_type != '') {
      if (screening_type == 'ncd') {
        screening_type = screening_type.toUpperCase() + ' ';
      } else {
        screening_type = screening_type[0].toUpperCase() + screening_type.substring(1) + ' ';
      }
      
      return screening_type + 'Encounter: ' + encounter['data']['type'][0].toUpperCase() + encounter['data']['type'].substring(1);
    }
    
    return 'Encounter: ' + encounter['data']['type'][0].toUpperCase() + encounter['data']['type'].substring(1);
  }

  // String getLastVisitDate() {
  //   var date = '';

  //   if (encounters.length > 0) {
  //     var lastEncounter = encounters[0];
  //     var parsedDate = DateTime.tryParse(lastEncounter['meta']['created_at']);
  //     if (parsedDate != null) {
  //       date = DateFormat('yyyy-MM-dd').format(parsedDate);
  //     }
  //   }

  //   return date;
  // }


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
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: <Widget>[
                                  //     Text("What was the outcome?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                  //     SizedBox(height: 20,),
                                  //     TextField(
                                  //       keyboardType: TextInputType.multiline,
                                  //       maxLines: 5,
                                  //       style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                                  //       // controller: commentController,
                                  //       decoration: InputDecoration(
                                  //         contentPadding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 20, right: 20),
                                  //         filled: true,
                                  //         fillColor: kSecondaryTextField,
                                  //         border: new UnderlineInputBorder(
                                  //           borderSide: new BorderSide(color: Colors.white),
                                  //           borderRadius: BorderRadius.only(
                                  //             topLeft: Radius.circular(4),
                                  //             topRight: Radius.circular(4),
                                  //           )
                                  //         ),
                                        
                                  //         hintText: '',
                                  //         hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  Text(AppLocalizations.of(context).translate('selectPurpose'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                  SizedBox(height: 20,),
                                  Container(
                                    width: double.infinity,
                                      //margin: EdgeInsets.only(left: 15, right: 15),
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
                                      //margin: EdgeInsets.only(left: 15, right: 15),
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
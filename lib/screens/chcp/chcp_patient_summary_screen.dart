import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/user_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chcp/edit_incomplete_encounter_chcp_screen.dart';

import 'chcp_feeling_screen.dart';
import 'new_visit/new_visit_chcp_feeling_screen.dart';

var dueCarePlans = [];
var completedCarePlans = [];
var upcomingCarePlans = [];
var referrals = [];
var pendingReferral;

class ChcpPatientSummaryScreen extends StatefulWidget {
  var checkInState = false;
  ChcpPatientSummaryScreen({this.checkInState});
  @override
  _ChcpPatientSummaryScreenState createState() => _ChcpPatientSummaryScreenState();
}

class _ChcpPatientSummaryScreenState extends State<ChcpPatientSummaryScreen> {
  var _patient;
  bool isLoading = true;
  var carePlans = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  bool avatarExists = false;
  var encounters = [];
  var lastAssessment;
  var nextVisitDate = '';
  String lastEncounterType = '';
  String lastEncounterDate = '';
  String lastAssessmentdDate = '';
  String lastCarePlanDate = '';
  String incompleteEncounterDate = '';
  var performer;
  String performerName = '';
  String performerRole = '';
  var conditions = [];
  var medications = [];
  var allergies = [];
  var users = [];
  var report;
  var bmi;
  var cholesterol;
  var bp;
  var cvd;
  int interventionIndex = 0;
  bool actionsActive = false;
  bool carePlansEmpty = false;
  var dueDate = '';
  var encounter;
  bool hasIncompleteAssessment = false;

  @override
  void initState() {
    super.initState();

    _patient = Patient().getPatient();

    dueCarePlans = [];
    completedCarePlans = [];
    upcomingCarePlans = [];
    conditions = [];
    referrals = [];
    pendingReferral = null;
    carePlansEmpty = false;

    
    _checkAvatar();
    _checkAuth();
    // _getCarePlan();
    // getEncounters();
    // getIncompleteAssessmentLocal();
    // // getAssessments();
    // getMedicationsConditions();
    // getReport();
    getIncompleteAssessment();
    getLastAssessment();
    // getUsers();
    // getReferrals();
    // getAssessmentDueDate();

  }
  getIncompleteAssessment() async {
    var patientId = Patient().getPatient()['id'];
    encounter = await AssessmentController().getIncompleteAssessmentsByPatient(patientId);

    if(encounter.isNotEmpty && (encounter.last['data']['type'] == 'new questionnaire' || (encounter.last['data']['type'] == 'community clinic assessment' && encounter.last['local_status'] == 'incomplete'))) {

      setState(() {
        hasIncompleteAssessment = true;
        incompleteEncounterDate = DateFormat("MMMM d, y").format(DateTime.parse(encounter.last['meta']['created_at']));
        isLoading = false;
      });
    } else {

      setState(() {
        hasIncompleteAssessment = false;
        isLoading = false;
      });
    }
  }
  getIncompleteAssessmentLocal() async {
    encounter = await AssessmentController().getAssessmentsByPatientWithLocalStatus('incomplete', assessmentType: 'community clinic assessment');

    if(encounter.isNotEmpty) {

      setState(() {
        hasIncompleteAssessment = true;
        isLoading = false;
      });
    } else {

      setState(() {
        hasIncompleteAssessment = false;
        isLoading = false;
      });
    }
  }
  deleteIncompleteAssessmentLocal() async {
    if(encounter.isNotEmpty) {
      await AssessmentRepositoryLocal().deleteLocalAssessment(encounter.first['id']);
    }
  }
  
  getAssessmentDueDate() {
    // print(DateFormat("MMMM d, y").format(DateTime.parse(_patient['data']['next_assignment']['body']['activityDuration']['start'])));

    if (_patient != null && _patient['data']['next_assignment'] != null && _patient['data']['next_assignment']['body']['activityDuration']['start'] != null) {
      setState(() {
        DateFormat format = new DateFormat("E LLL d y");
        
        try {
          dueDate = DateFormat("MMMM d, y").format(format.parse(_patient['data']['next_assignment']['body']['activityDuration']['start']));
        } catch(err) {
          dueDate = DateFormat("MMMM d, y").format(DateTime.parse(_patient['data']['next_assignment']['body']['activityDuration']['start']));
        }
      });
    }
    

    // if (_patient['data']['body']['activityDuration'] != null && item['body']['activityDuration']['start'] != '' && item['body']['activityDuration']['end'] != '') {
    //   var start = DateTime.parse(item['body']['activityDuration']['start']);
    // }
  }

  getStatus(item) {
    var status = 'completed';
    item['items'].forEach( (goal) {
      if (goal['meta']['status'] == 'pending') {
        setState(() {
          status = 'pending';
        });
      }
    });

    return status;
  }

  getCount(item) {
    var count = 0;

    item['items'].forEach( (goal) {
      setState(() {
        count += 1;
      });
    });
    

    return count.toString();
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

  // getIncompleteAssessment() async {

  //   print("getIncompleteAssessment");

  //   if (Auth().isExpired()) {
  //     Auth().logout();
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
  //   }

  //   setState(() {
  //     isLoading = true;
  //   });
  //   var patientId = Patient().getPatient()['id'];
  //   var data = await AssessmentController().getIncompleteEncounterWithObservation(patientId);
  //   print('incompleteData ${data}');
  //   //TODO: need to get performer name from local
  //   // if(data != null && data['data']['assessment']['body']['performed_by'] != null)
  //   // {
  //   //   performer = await getPerformer(data['data']['assessment']['body']['performed_by']);
  //   //   print('performer $performer');
  //   // }
  //   setState(() {
  //     isLoading = false;
  //     incompleteEncounterDate = !data['error'] && data['data'] != null ? DateFormat("MMMM d, y").format(DateTime.parse(data['data']['assessment']['meta']['created_at'])) : '';
  //     performerName = performer != null ? performer['data']['name'] : '';
  //     performerRole = performer != null ? performer['data']['role'] : '';
  //   });

  //   if (data == null) {
  //     return;
  //   } else if (data['message'] == 'Unauthorized') {
  //     Auth().logout();
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
  //     return;
  //   } else if (data['error'] != null && data['error']) {
  //     return;
  //   }

  // }

  getCompletedDate(goal) {
    var data = '';
    DateTime date;
    // print(goal['items']);
    goal['items'].forEach((item) {
      // print(item['body']['activityDuration']['end']);
      DateFormat format = new DateFormat("E LLL d y");
      var endDate;
      try {
        endDate = format.parse(item['body']['activityDuration']['end']);
      } catch(err) {
        endDate = DateTime.parse(item['body']['activityDuration']['end']);
      }
      // print(endDate);
      date = endDate;
      if (date != null) {
        date  = endDate;
      } else {
        if (endDate.isBefore(date)) {
          date = endDate;
        }
      }
      
    });
    if (date != null) {
      var test = DateFormat('MMMM d, y').format(date);
      data = 'Complete By ' + test;
    }
    return data;
  }

  getReferrals() async {

    setState(() {
      isLoading = true;
    });

    var patientID = Patient().getPatient()['id'];

    var data = await FollowupController().getFollowupsByPatient(patientID);

    
    if (data['error'] == true) {

      // Toast.show('No Health assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        referrals = data['data'];
      });
    }

    referrals.forEach((referral) {
      if (referral['meta']['status'] == 'pending') {
        setState(() {
          pendingReferral = referral;
        });
      }
    });
  }

  getReport() async {

    setState(() {
      isLoading = true;
    });

    var data = await HealthReportController().getLastReport(context);
    
    if (data['error'] == true) {
      setState(() {
        carePlansEmpty = true;
      });
      // Toast.show('No Health assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        report = data['data'];
      });
    }
    setState(() {
      bmi = report != null && report['body']['result']['assessments']['body_composition'] != null && report['body']['result']['assessments']['body_composition']['components']['bmi'] != null ? report['body']['result']['assessments']['body_composition']['components']['bmi'] : null;
      cvd = report != null && report['body']['result']['assessments']['cvd'] != null ? report['body']['result']['assessments']['cvd'] : null;
      bp = report != null && report['body']['result']['assessments']['blood_pressure'] != null ? report['body']['result']['assessments']['blood_pressure'] : null;
      cholesterol = report != null && report['body']['result']['assessments']['cholesterol'] != null && report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ? report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] : null;
    });

  }

  getMedicationsConditions() async {
    isLoading = true;
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
    var fetchedSurveys = await ObservationController().getLiveSurveysByPatient();

    if(fetchedSurveys.isNotEmpty) {
      fetchedSurveys.forEach((item) {
        if (item['data']['name'] == 'medical_history') {

          allergies = item['data']['allergy_types'] != null ? item['data']['allergy_types'] : [];

          item['data'].keys.toList().forEach((key) {
            if (item['data'][key] == 'yes') {
              setState(() {
                var text = key.replaceAll('_', ' ');
                var upperCased = text[0].toUpperCase() + text.substring(1);
                if (!conditions.contains(upperCased)) {
                  conditions.add(upperCased);
                }
                
              });
            }
          });
        }
        if (item['data']['name'] == 'current_medication' && item['data']['medications'].isNotEmpty) {
          setState(() {
            medications = item['data']['medications'];
          });
        }
      });
    }

  }

  getAssessments() async {
    setState(() {
      isLoading = true;
    });
    var response = await HealthReportController().getLastReport(context);
    if (response == null || response['error']) {
      return;
    }

    setState(() {
      lastAssessmentdDate = '';
      // lastAssessmentdDate = DateFormat("MMMM d, y").format(DateTime.parse(response['data']['meta']['created_at']));
    });

  }

  getDueCounts() {
    var goalCount = 0;
    var actionCount = 0;
    carePlans.forEach((item) {
      if(item['meta']['status'] == 'pending') {
        goalCount = goalCount + 1;
        if (item['body']['components'] != null) {
          actionCount = actionCount + item['body']['components'].length;
        }
      }
    });

    return "$goalCount goals & $actionCount actions";
  }

  getDate(date) {
    if (date.runtimeType == String && date != null && date != '') {
      return DateFormat("MMMM d, y").format(DateTime.parse(date)).toString();
    } else if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);

      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  getLastAssessment() async {
    lastAssessment = await AssessmentController().getLastAssessmentByPatient();

    if(lastAssessment != null && lastAssessment.isNotEmpty) {
      // lastEncounterDate = lastAssessment['data']['meta']['created_at'];
      // nextVisitDate = lastAssessment['data']['body']['next_visit_date'];
      setState(() {
        nextVisitDate = lastAssessment['data']['body']['next_visit_date'] != null && lastAssessment['data']['body']['next_visit_date'] != '' ? DateFormat("MMMM d, y").format(DateTime.parse(lastAssessment['data']['body']['next_visit_date'])):'';
        lastEncounterType = lastAssessment['data']['body']['type'];
        lastEncounterDate = getDate(lastAssessment['data']['meta']['created_at']);
      });
    }
    
  }

  // getEncounters() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   encounters = await AssessmentController().getLiveAllAssessmentsByPatient();


  //   if (encounters.isNotEmpty) {

  //     var allEncounters = encounters;
  //     await Future.forEach(allEncounters, (item) async {
  //       var data = await getObservations(item);
  //       var completed_observations = [];
  //       if (data.isNotEmpty) {
  //         data.forEach((obs) {
            
  //           if (obs['body']['type'] == 'survey') {
  //             if (!completed_observations.contains(obs['body']['data']['name'])) {
  //               completed_observations.add(obs['body']['data']['name']);
  //             }
  //           } else  {
  //             if (!completed_observations.contains(obs['body']['type'])) {
  //               completed_observations.add(obs['body']['type']);
  //             }
  //           }
  //         });
  //       }
  //       encounters[encounters.indexOf(item)]['completed_observations'] = completed_observations;
  //     });
  //     // print(encounters);
  //     encounters.sort((a, b) {
  //       return DateTime.parse(b['meta']['created_at']).compareTo(DateTime.parse(a['meta']['created_at']));
  //     });

  //     setState(() {
  //       isLoading = false;
  //     });

  //   }
    
  // }

  getPerformer(userId) async {
    var data =  await UserController().getUser(userId);
    return data;

  }

  getObservations(assessment) async {
    // _observations =  await AssessmentController().getObservationsByAssessment(widget.assessment);
    var data =  await AssessmentController().getLiveObservationsByAssessment(assessment);
    // print(data);
    return data;

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

  _getCarePlan() async {

    var data = await CarePlanController().getCarePlan();
    
    if (data != null && data['message'] == 'Unauthorized') {

      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else if (data == null || data['error'] == true) {

    } else {
      // print( data['data']);
      // DateTime.parse(localAuth['expirationTime']).add(DateTime.now().timeZoneOffset).add(Duration(hours: 12)).isBefore(DateTime.now())
      setState(() {
        carePlans = data['data'];
      });
      // carePlans = data['data'];
      data['data'].forEach( (item) {
        DateFormat format = new DateFormat("E LLL d y");
        
        var todayDate = DateTime.now();

        var endDate;
        var startDate;

        try {
          endDate = format.parse(item['body']['activityDuration']['end']);
          startDate = format.parse(item['body']['activityDuration']['start']);
        } catch(err) {


          DateFormat newFormat = new DateFormat("yyyy-MM-dd");
          endDate = DateTime.parse(item['body']['activityDuration']['end']);
          startDate = DateTime.parse(item['body']['activityDuration']['start']);
          // startDate = DateTime.parse(item['body']['activityDuration']['start']);
          
        }


        // check due careplans
        if (item['meta']['status'] == 'pending') {
          if (todayDate.isAfter(startDate) && todayDate.isBefore(endDate)) {
            var existedCp = dueCarePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);


            if (existedCp.isEmpty) {
              var items = [];
              items.add(item);
              dueCarePlans.add({
                'items': items,
                'title': item['body']['goal']['title'],
                'id': item['body']['goal']['id']
              });
            } else {
              dueCarePlans[dueCarePlans.indexOf(existedCp.first)]['items'].add(item);

            }
          } else if (todayDate.isBefore(startDate)) {
            var existedCp = upcomingCarePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);


            if (existedCp.isEmpty) {
              var items = [];
              items.add(item);
              upcomingCarePlans.add({
                'items': items,
                'title': item['body']['goal']['title'],
                'id': item['body']['goal']['id']
              });
            } else {
              upcomingCarePlans[upcomingCarePlans.indexOf(existedCp.first)]['items'].add(item);

            }
          }
        } else {
          var existedCp = completedCarePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);


          if (existedCp.isEmpty) {
            var items = [];
            items.add(item);
            completedCarePlans.add({
              'items': items,
              'title': item['body']['goal']['title'],
              'id': item['body']['goal']['id']
            });
          } else {
            completedCarePlans[completedCarePlans.indexOf(existedCp.first)]['items'].add(item);

          }
        }
      });

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('patientSummary'), style: TextStyle(color: Colors.white, fontSize: 20),),
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
                  Container(
                    color: Colors.transparent,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: kBorderLighter)
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Patient().getPatient()['data']['avatar'] == '' ? 
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30.0),
                                      child: Image.asset(
                                        'assets/images/avatar.png',
                                        height: 70.0,
                                        width: 70.0,
                                      ),
                                    ) :
                                    CircleAvatar(
                                      radius: 30,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30.0),
                                        child: Image.network(
                                          Patient().getPatient()['data']['avatar'],
                                          height: 70.0,
                                          width: 70.0,
                                          errorBuilder: (BuildContext context,
                                              Object exception, StackTrace stackTrace) {
                                            return Image.asset(
                                              'assets/images/avatar.png',
                                              height: 70.0,
                                              width: 70.0,
                                            );
                                          },
                                        ),
                                      ),
                                      backgroundImage: AssetImage('assets/images/avatar.png'),
                                    ),

                                    SizedBox(width: 20,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(Helpers().getPatientName(_patient), style: TextStyle( fontSize: 19, fontWeight: FontWeight.w600),),
                                        
                                        SizedBox(height: 7,),
                                        Row(
                                          children: <Widget>[
                                            Text(Helpers().getPatientAgeAndGender(_patient), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                      ],
                                    ),
                                    
                                    SizedBox(width: 100,),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/chwPatientDetails');
                                },
                                child: Container(
                                  child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 35,)
                                ),
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  
                  hasIncompleteAssessment ?

                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15,),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context).translate('incompleteEncounterDate')+': $incompleteEncounterDate', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                            SizedBox(height: 15,),
                            // Text('$performerRole: '+'$performerName', style: TextStyle(fontSize: 17,),),
                            // SizedBox(height: 10,),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: FlatButton(
                                onPressed: () {
                                  // Navigator.of(context).pushNamed('/editIncompleteEncounter',);
                                  Navigator.of(context).pushNamed(ChcpFeelingScreen.path);

                                },
                                color: kPrimaryColor,
                                child: Text(AppLocalizations.of(context).translate("completePrevEncounter"), style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            SizedBox(width: 20),
                          ]
                        ),
                      ],
                    )
                  ) : Container(),
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: kBorderLighter),
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).translate('lastEncounter')+'${(lastEncounterType)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        SizedBox(height: 15,),
                        Text(AppLocalizations.of(context).translate('lastEncounterDate')+'$lastEncounterDate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  // SizedBox(height: 20,),


                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 4, color: kBorderLighter)
                      ),
                    ),
                    padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[

                            ],
                          ),
                        ),
                        widget.checkInState != null && widget.checkInState ? Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                          height: 50,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(3)
                          ),
                          child: FlatButton(
                            onPressed: () async {
                              showDialog(
                                context: _scaffoldKey.currentContext,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      width: double.infinity,
                                      height: 160.0,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            width: 350,
                                            alignment: Alignment.center,
                                            child: Text(AppLocalizations.of(context).translate('medicalIssueInVisit'), style: TextStyle(
                                            fontSize: 22
                                          ), textAlign: TextAlign.center,),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: kPrimaryRedColor,
                                                    borderRadius: BorderRadius.circular(3)
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.of(context).pushNamed('/reportMedicalIssues');
                                                    },
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    child: Text(AppLocalizations.of(context).translate("yes"), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: kPrimaryGreenColor,
                                                    borderRadius: BorderRadius.circular(3)
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      var result = '';
                                                      setState(() {
                                                        isLoading = true;
                                                      });

                                                      await Future.delayed(const Duration(seconds: 5));

                                                      
                                                      result = await AssessmentController().create('visit', 'follow-up', '');

                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Navigator.of(_scaffoldKey.currentContext).pushNamed('/chwNavigation');

                                                      
                                                    },
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    child: Text(AppLocalizations.of(context).translate("NO"), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            child: Text(AppLocalizations.of(context).translate('completeVisit'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                          ),
                        ) : Container(),
                      ],
                    )
                  ),
                  SizedBox(height: 15,),
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
      floatingActionButton: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context){
              return Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 50,
                    right: 0,
                    child: AlertDialog(
                      contentPadding: EdgeInsets.all(0),
                      elevation: 0,
                      content: Container(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            hasIncompleteAssessment ?
                            FloatingButton(text: AppLocalizations.of(context).translate('updateLastEncounter'), onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(ChcpFeelingScreen.path);
                            }, ) : Container(),
                            FloatingButton(
                              text: AppLocalizations.of(context).translate('newVisit'), 
                              onPressed: () {
                                // Navigator.of(context).pop();
                                // hasIncompleteAssessment ?
                                // showDialog(
                                //   context: context,
                                //   builder: (BuildContext context){
                                //     return AlertDialog(
                                //       content: new Text(AppLocalizations.of(context).translate("editExistingAssessment"), style: TextStyle(fontSize: 22),),
                                //       actions: <Widget>[
                                //         // usually buttons at the bottom of the dialog
                                //         Container(  
                                //           margin: EdgeInsets.all(20),  
                                //           child:FlatButton(
                                //             child: new Text(AppLocalizations.of(context).translate("edit"), style: TextStyle(fontSize: 20),),
                                //             color: kPrimaryColor,  
                                //             textColor: Colors.white,
                                //             onPressed: () {
                                //               Navigator.of(context).pushNamed(EditIncompleteEncounterChcpScreen.path);
                                //             },
                                //           ),
                                //         ),
                                //         Container(  
                                //           margin: EdgeInsets.all(20),  
                                //           child:FlatButton(
                                //             child: new Text(AppLocalizations.of(context).translate("newVisit"), style: TextStyle(fontSize: 20),),
                                //             color: kPrimaryColor,  
                                //             textColor: Colors.white,
                                //             onPressed: () async {
                                //               await deleteIncompleteAssessmentLocal();
                                //               Navigator.of(context).pushNamed(NewVisitChcpFeelingScreen.path);
                                //             },
                                //           ),
                                //         ),
                                //       ],
                                //     );     
                                //   }
                                // ) :
                                // Navigator.of(context).pop();
                                Navigator.of(context).pushNamed(NewVisitChcpFeelingScreen.path);
                                // Navigator.of(context).pushNamed(EditIncompleteEncounterChwScreen.path);
                              },
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  )
                ],
              );
            }
          );
        },
        // icon: Icon(Icons.add),
        // label: null,
        // backgroundColor: kPrimaryColor,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: kPrimaryColor,
            boxShadow: [
              new BoxShadow(
                offset: Offset(0.0, 1.0),
                color: Color(0xFF000000),
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Center(
            child: Icon(Icons.add, color: Colors.white,),
          ),
        ),
      ),

      
      // floatingActionButton: widget.checkInState == null ? FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.of(context).pushNamed('/verifyPatient');
      //   },
      //   icon: Icon(Icons.add),
      //   label: Text(AppLocalizations.of(context).translate('newCommunityVisit')),
      //   backgroundColor: kPrimaryColor,
      // ) : Container(),
    );
  }
}


class FloatingButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const FloatingButton({this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      width: 300,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            Icon(Icons.add),
            SizedBox(width: 10,),
            Text(text, style: TextStyle(fontSize: 17),)
          ],
        ),
      )
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0.0);
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

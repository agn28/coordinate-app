import 'dart:io';
// import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:expandable/expandable.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/user_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/careplan_feeling_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/careplan_delivery_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/counselling_framwork_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_feeling_screen.dart';

var dueCarePlans = [];
var completedCarePlans = [];
var upcomingCarePlans = [];
var referrals = [];
var pendingReferral;

class ChwPatientRecordsScreen extends StatefulWidget {
  var checkInState = false;
  ChwPatientRecordsScreen({this.checkInState});
  @override
  _PatientRecordsState createState() => _PatientRecordsState();
}

class _PatientRecordsState extends State<ChwPatientRecordsScreen> {
  var _patient;
  bool isLoading = true;
  var carePlans = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  bool avatarExists = false;
  var encounters = [];
  String lastEncounterType = '';
  String lastEncounterdDate = '';
  String lastAssessmentdDate = '';
  String lastCarePlanDate = '';
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

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    print(_patient['meta']['review_required']);
    dueCarePlans = [];
    completedCarePlans = [];
    upcomingCarePlans = [];
    conditions = [];
    referrals = [];
    pendingReferral = null;
    carePlansEmpty = false;
    print(widget.checkInState);
    
    _checkAvatar();
    _checkAuth();
    getUsers();
    getAssessmentDueDate();
    _getCarePlan();
    getReferrals();
    getEncounters();
    getAssessments();
    getMedicationsConditions();
    getReport();
    
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

    var patientID = Patient().getPatient()['uuid'];

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
      bmi = report['body']['result']['assessments']['body_composition'] != null && report['body']['result']['assessments']['body_composition']['components']['bmi'] != null ? report['body']['result']['assessments']['body_composition']['components']['bmi'] : null;
      cvd = report['body']['result']['assessments']['cvd'] != null ? report['body']['result']['assessments']['cvd'] : null;
      bp = report['body']['result']['assessments']['blood_pressure'] != null ? report['body']['result']['assessments']['blood_pressure'] : null;
      cholesterol = report['body']['result']['assessments']['cholesterol'] != null && report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ? report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] : null;
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
    if (response == null) {
      return;
    }
    if (response['error']) {
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

  getEncounters() async {
    setState(() {
      isLoading = true;
    });
    encounters = await AssessmentController().getLiveAllAssessmentsByPatient();


    if (encounters.isNotEmpty) {
      var allEncounters = encounters;
      await Future.forEach(allEncounters, (item) async {
        var data = await getObservations(item);
        var completed_observations = [];
        if (data.isNotEmpty) {
          data.forEach((obs) {
            
            if (obs['body']['type'] == 'survey') {
              if (!completed_observations.contains(obs['body']['data']['name'])) {
                completed_observations.add(obs['body']['data']['name']);
              }
            } else  {
              if (!completed_observations.contains(obs['body']['type'])) {
                completed_observations.add(obs['body']['type']);
              }
            }
          });
        }
        encounters[encounters.indexOf(item)]['completed_observations'] = completed_observations;
      });
      // print(encounters);
      encounters.sort((a, b) {
        return DateTime.parse(b['meta']['created_at']).compareTo(DateTime.parse(a['meta']['created_at']));
      });

      setState(() {
        isLoading = false;
        lastEncounterdDate = DateFormat("MMMM d, y").format(DateTime.parse(encounters.first['meta']['created_at']));
        lastEncounterType = encounters.first['data']['type'];
      });

    }
    
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
    } else if (data['error'] == true) {

    } else {
      // print( data['data']);
      // DateTime.parse(localAuth['expirationTime']).add(DateTime.now().timeZoneOffset).add(Duration(hours: 12)).isBefore(DateTime.now())
      carePlans = data['data'];
      print('carePlans $carePlans');
      data['data'].forEach( (item) {
        DateFormat format = new DateFormat("E LLL d y");
        
        var todayDate = DateTime.now();

        var endDate;
        var startDate;

        try {
          endDate = format.parse(item['body']['activityDuration']['end']);
          startDate = format.parse(item['body']['activityDuration']['start']);
        } catch(err) {
          print(item['body']['activityDuration']['start']);
          print(item['body']['activityDuration']['end']);
          // print('failed: ' );
          print(err);
          DateFormat newFormat = new DateFormat("yyyy-MM-dd");
          endDate = DateTime.parse(item['body']['activityDuration']['end']);
          startDate = DateTime.parse(item['body']['activityDuration']['start']);
          // startDate = DateTime.parse(item['body']['activityDuration']['start']);
          
        }

        print('endDate');
        print(endDate);
        print(startDate);


        print(endDate);
        print(todayDate.isBefore(endDate));
        print(todayDate.isAfter(startDate));

        // check due careplans
        if (item['meta']['status'] == 'pending') {
          if (todayDate.isAfter(startDate) && todayDate.isBefore(endDate)) {
            var existedCp = dueCarePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);
            // print(existedCp);
            // print(item['body']['activityDuration']['start']);

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
            // print(existedCp);
            // print(item['body']['activityDuration']['start']);

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
          // print(existedCp);
          // print(item['body']['activityDuration']['start']);

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

        
        
        // var existedCp = carePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);
        // // print(existedCp);
        // // print(item['body']['activityDuration']['start']);
        

        // if (existedCp.isEmpty) {
        //   var items = [];
        //   items.add(item);
        //   carePlans.add({
        //     'items': items,
        //     'title': item['body']['goal']['title'],
        //     'id': item['body']['goal']['id']
        //   });
        // } else {
        //   carePlans[carePlans.indexOf(existedCp.first)]['items'].add(item);

        // }
      });

      // setState(() {
      //   carePlans = data['data'];
      //   isLoading = false;
      // });

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

    String getLastVisitDate() {
    var date = '';

    if (encounters.length > 0) {
      var lastEncounter = encounters[0];
      var parsedDate = DateTime.tryParse(lastEncounter['meta']['created_at']);
      if (parsedDate != null) {
        date = DateFormat('yyyy-MM-dd').format(parsedDate);
      }
    }

    return date;
  }
  String getNextVisitDate() {
    var date = '';

    if (encounters.length > 0) {
    print('encounters ${encounters[0]}');
      var lastEncounter = encounters[0];
      date = lastEncounter['data']['next_visit_date'] ?? '';
    }

    return date;
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
                  
            
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                    
                    child: Row( 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(AppLocalizations.of(context).translate('currentConditions'), style: TextStyle(fontSize: 17,),),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          // padding: EdgeInsets.symmetric(vertical: 9),
                          child: Wrap(
                            children: <Widget>[
                              ...conditions.map((item) {
                                return Text(item + '${conditions.length - 1 == conditions.indexOf(item) ? '' : ', '}', style: TextStyle(fontSize: 17,));
                              }).toList()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  report != null && report['body']['result']['assessments']['cvd'] != null ?
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          // top: BorderSide(color: kBorderLighter)
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('cvdRisk')+": ", style: TextStyle(fontSize: 17)),
                              SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('${report['body']['result']['assessments']['cvd']['eval']} (${report['body']['result']['assessments']['cvd']['value']})',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: ColorUtils.statusColor[report['body']['result']['assessments']['cvd']['tfl']] ?? Colors.black
                                        ),
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            ],
                          ),

                          SizedBox(height: 20,),

                        ],
                      ),
                    ) : Container(),

                  report != null && report['body']['result']['assessments']['lifestyle'] != null && report['body']['result']['assessments']['lifestyle']['components']['smoking'] != null ?
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(AppLocalizations.of(context).translate('smoker') + ": ", style: TextStyle(fontSize: 17)),
                            SizedBox(width: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(report['body']['result']['assessments']['lifestyle']['components']['smoking']['value'] == 'current smoker' ? 
                                      'Yes' : 'No',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[report['body']['result']['assessments']['lifestyle']['components']['smoking']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                  ]
                                ),
                              ]
                            )
                          ],
                        ),

                        SizedBox(height: 20,),

                      ],
                    ),
                  ) : Container(),

                  
                  report != null && report['body']['result']['assessments']['body_composition'] != null && report['body']['result']['assessments']['body_composition']['components']['bmi'] != null ?
                  Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('bmi') + ": ", style: TextStyle(fontSize: 17)),
                              SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(report['body']['result']['assessments']['body_composition']['components']['bmi']['eval'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: ColorUtils.statusColor[report['body']['result']['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black
                                        ),
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            ],
                          ),

                          SizedBox(height: 20,),

                        ],
                      ),
                    ) : Container(),


                  report != null && report['body']['result']['assessments']['lifestyle'] != null && report['body']['result']['assessments']['lifestyle']['components']['physical_activity'] != null ?
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('physicalActivity') + ": ", style: TextStyle(fontSize: 17)),
                              SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(report['body']['result']['assessments']['lifestyle']['components']['physical_activity']['eval'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: ColorUtils.statusColor[report['body']['result']['assessments']['lifestyle']['components']['physical_activity']['tfl']] ?? Colors.black
                                        ),
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            ],
                          ),

                          SizedBox(height: 20,),

                        ],
                      ),
                    ) : Container(),


                  report != null && report['body']['result']['assessments']['cholesterol'] != null && report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('cholesterol') + ": ", style: TextStyle(fontSize: 17)),
                              SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['eval'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: ColorUtils.statusColor[report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black
                                        ),
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            ],
                          ),

                          SizedBox(height: 20,),

                        ],
                      ),
                    ) : Container(),

                  report != null && report['body']['result']['assessments']['blood_pressure'] != null ?
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('bloodPressure') + ": ", style: TextStyle(fontSize: 17)),
                              SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(report['body']['result']['assessments']['blood_pressure']['eval'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: ColorUtils.statusColor[report['body']['result']['assessments']['blood_pressure']['tfl']] ?? Colors.black
                                        ),
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            ],
                          ),

                          SizedBox(height: 20,),

                        ],
                      ),
                    ) : Container(),

                  report != null && report['body']['result']['assessments']['diabetes'] != null ?
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('bloodSugar') + ": ", style: TextStyle(fontSize: 17)),
                              SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(report['body']['result']['assessments']['diabetes']['eval'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: ColorUtils.statusColor[report['body']['result']['assessments']['diabetes']['tfl']] ?? Colors.black
                                        ),
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            ],
                          ),

                          SizedBox(height: 20,),

                        ],
                      ),
                    ) : Container(),
                    



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
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: kBorderLighter),
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('ncdCenterVisit'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                              SizedBox(height: 15,),
                              Text(AppLocalizations.of(context).translate('nextVisitDate')+getNextVisitDate(), style: TextStyle(fontSize: 17,)),
                              SizedBox(height: 10,),
                              Text(AppLocalizations.of(context).translate('lastVisitDate')+getLastVisitDate(), style: TextStyle(fontSize: 17,))
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: kBorderLighter),
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('lastEncounter')+'$lastEncounterType', style: TextStyle(fontSize: 17,)),
                              SizedBox(height: 10,),
                              Text(AppLocalizations.of(context).translate('lastEncounterDate')+'$dueDate', style: TextStyle(fontSize: 17,)),
                            ],
                          ),
                        ),
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
                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(AppLocalizations.of(context).translate('careplanAcions'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                    if (_patient['meta']['review_required'] != null && _patient['meta']['review_required'])
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 9),
                                        child: Text(AppLocalizations.of(context).translate('pendingDoctorConsultation').toUpperCase(), style: TextStyle(fontSize: 17, color: kPrimaryYellowColor, fontWeight: FontWeight.w500),)
                                        ,
                                      )
                                    else if(carePlans.length > 0)
                                      if(dueCarePlans.length > 0 || upcomingCarePlans.length > 0)
                                        Container(
                                          padding: EdgeInsets.symmetric(vertical: 9),
                                          child: Text(AppLocalizations.of(context).translate('pending').toUpperCase(), style: TextStyle(fontSize: 17, color: kPrimaryRedColor, fontWeight: FontWeight.w500),)
                                          ,
                                        )
                                      else
                                        Container(
                                          padding: EdgeInsets.symmetric(vertical: 9),
                                          child: Text(AppLocalizations.of(context).translate('completedPendingFollowUp').toUpperCase(), style: TextStyle(fontSize: 17, color: kPrimaryGreenColor, fontWeight: FontWeight.w500),)
                                          ,
                                        )
                                    else Container(
                                          padding: EdgeInsets.symmetric(vertical: 9),
                                          child: Text(AppLocalizations.of(context).translate('none').toUpperCase(), style: TextStyle(fontSize: 17, color: kPrimaryRedColor, fontWeight: FontWeight.w500),)
                                          ,
                                        ),
                                  ],
                                ),
                              ),
                            ],
                          )
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
                               //Navigator.of(context).pushNamed('/chwPatientSummary');
                              
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
                            FloatingButton(text: AppLocalizations.of(context).translate('followUp'), onPressed: () {
                              // Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(FollowupFeelingScreen.path);
                            }, ),

                            FloatingButton(text: AppLocalizations.of(context).translate('deliverCarePlan'), onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(ChwCareplanDeliveryScreen.path);
                            },),
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

    );
  }
}

class GoalItem extends StatefulWidget {
  final item;
  GoalItem({this.item});

  @override
  _GoalItemState createState() => _GoalItemState();
}

class _GoalItemState extends State<GoalItem> {
  var status = 'pending';

    @override
  void initState() {
    super.initState();
    getStatus();
  }

  getStatus() {
    status = 'completed';
    widget.item['items'].forEach( (goal) {
      if (goal['meta']['status'] == 'pending') {
        setState(() {
          status = 'pending';
        });
      }
    });
  }
  setStatus(completedItem) {
    // print(completedItem);

    //set all the actions as completed
    setState(() {
      dueCarePlans.remove(completedItem);
      var data = completedItem;
      data['items'].forEach( (goal) {
        completedItem['items'][completedItem['items'].indexOf(goal)]['meta']['status'] = 'completed';
      });
      completedCarePlans.add(completedItem);
      // status = 'completed';
    });
  }
  getCount() {
    var count = 0;
    if (status == 'pending') {
      widget.item['items'].forEach( (goal) {
        if (goal['meta']['status'] == 'pending') {
          setState(() {
            count += 1;
          });
        }
      });
    } else {
      widget.item['items'].forEach( (goal) {
        setState(() {
          count += 1;
        });
      });
    }

    return count.toString();
  }
  
  getCompletedDate(goal) {
    var data = '';
    DateTime date;
    print('asdknas');
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

  @override
  Widget build(BuildContext context) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //     padding: EdgeInsets.only(bottom: 10),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(color: kBorderLighter)
  //       )
  //     ),
  //     child: GestureDetector(
  //       onTap: () {
  //         if (status == 'pending') {
  //           if (widget.item['title'] == 'Improve blood pressure control') {
  //             Navigator.of(context).pushNamed('/chwImproveBp', arguments: { 'data': widget.item, 'parent': this });
  //           } else {
  //             Navigator.of(context).pushNamed('/chwOtherActions', arguments: { 'data': widget.item, 'parent': this });
  //           }
  //         }
  //       },
  //       child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         Text(widget.item['title'], style: TextStyle(fontSize: 16, color: kPrimaryColor)),
  //         status != 'completed' ? Text(getCompletedDate(widget.item), style: TextStyle(fontSize: 15, color: kBorderLight)) : Container(),
  //         Container(
  //           child: Row(
  //             children: <Widget>[
  //               Container(
  //                 padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor),
  //                   borderRadius: BorderRadius.circular(3)
  //                 ),
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     if (widget.item['title'] == 'Improve blood pressure control') {
  //                       Navigator.of(context).pushNamed('/chwImproveBp', arguments: { 'data': widget.item, 'parent': this });
  //                     } else {
  //                       Navigator.of(context).pushNamed('/chwOtherActions', arguments: { 'data': widget.item, 'parent': this });
  //                     }
  //                   },
  //                   child: Row(
  //                     children: <Widget>[
  //                       // Text('${report['body']['result']['actions'].length} Actions  ', style: TextStyle(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor, fontWeight: FontWeight.w500),),
  //                       Text('${getCount()}'+AppLocalizations.of(context).translate("actions"), style: TextStyle(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor, fontWeight: FontWeight.w500),),
  //                       if (status != 'pending') 
  //                       Icon(Icons.check_circle, color: kPrimaryGreenColor, size: 14,)
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Icon(Icons.chevron_right, color: kBorderLight,)
  //             ],
  //           ),
  //         ),
  //       ],),
  //     ),
  //   );
  // }
  
  return Container(
    child: Column(
      children: [
      // Container(
      //   width: double.infinity,
      //   child: Text(AppLocalizations.of(context).translate('pendingActions'), style: TextStyle( fontSize: 16),),
      //   padding: EdgeInsets.only(bottom: 15, left: 20),
      //   decoration: BoxDecoration(
      //     border: Border(
      //       bottom: BorderSide(color: kBorderLighter)
      //     )
      //   ),
      // ),
      Column(
        children: <Widget>[
          ...widget.item['items'].map((item) {
            return ActionItem(item: item, parent: this);
          }).toList(),
        ],
      ),
      ],
    ),
  );
  }
}
bool btnDisabled = true;
class ActionItem extends StatefulWidget {
  const ActionItem({
    this.item,
    this.parent
  });

  final item;
  final parent;

  @override
  _ActionItemState createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  String status = 'pending';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatus();
  }

  getStatus() {
    setState(() {
      status = widget.item['meta']['status'];
    });
  }

  isCounselling() {
    print(widget.item['body']['title']);
    return widget.item['body']['title'].split(" ").contains('Counseling') || widget.item['body']['title'].split(" ").contains('Counselling');
  }

  setStatus() {
    setState(() {
      btnDisabled = false;
      status = 'completed';
    });

    widget.parent.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(widget.item['body']);
        print(isCounselling());
        if (isCounselling()) {
          Navigator.of(context).pushNamed(CounsellingFrameworkScreen.path, arguments: { 'data': widget.item, 'parent': this});
          return;
        }
        Navigator.of(context).pushNamed('/chwActionsSwipper', arguments: { 'data': widget.item, 'parent': this});
      },
      child: Container(
        padding: EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
        decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: kBorderLighter)
        )
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.item['body']['title'] ?? '', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                        SizedBox(height: 15,),
                        Text(status, style: TextStyle(fontSize: 14, color: status == 'completed' ? kPrimaryGreenColor : kPrimaryRedColor),),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                ],
              ),
            ),
            SizedBox(height: 20,),
            
          ],
        ),
      ),
    );
  }
}



class CareplanAction extends StatefulWidget {

  CareplanAction({this.checkInState, this.carePlans, this.text});

  bool checkInState;
  var carePlans = [];
  String text = '';
  @override
  _CareplanActionState createState() => _CareplanActionState();
}

class _CareplanActionState extends State<CareplanAction> {

  getCount(item) {
    var count = 0;

    item['items'].forEach( (goal) {
      setState(() {
        count += 1;
      });
    });
    

    return count.toString();
  }

  getCompletedDate(goal) {
    var data = '';
    DateTime date;
    // print(goal['items']);
    goal['items'].forEach((item) {
      // print(item['body']['activityDuration']['end']);
      if (item['meta']['status'] != 'completed') {
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
      }
      
    });
    if (date != null) {
      var test = DateFormat('MMMM d, y').format(date);
      data = 'Complete By ' + test;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20,),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 13,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              // Text(getDueCounts(),)
            ],
          ),
        ),
        widget.text == 'Due Today' && widget.checkInState != null ? Container(
          margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(Icons.check_circle, color: kPrimaryGreenColor,),
              SizedBox(width: 10,),
              Text(AppLocalizations.of(context).translate("checkInComplete"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            ],
          ),
        ) : Container(),
        widget.checkInState == null ? Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),
                      ...widget.carePlans.map( (item) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: kBorderLighter)
                            )
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.of(context).pushNamed('/carePlanInterventions', arguments: {
                              //   'carePlan' : item,
                              //   'parent': this
                              // });
                            },
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(item['title'], style: TextStyle(fontSize: 16, color: kBorderLight)),
                              Text(getCompletedDate(item), style: TextStyle(fontSize: 15, color: kBorderLight)),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: kBorderLight),
                                        borderRadius: BorderRadius.circular(3)
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                        },
                                        // child: Text('${item['body']['actions'].length} Actions', style: TextStyle(color: kBorderLight, fontWeight: FontWeight.w500),),
                                        child: Text('${getCount(item)} Actions', style: TextStyle(color: kBorderLight, fontWeight: FontWeight.w500),),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: kBorderLight,)
                                  ],
                                ),
                              ),
                            ],),
                          ),
                        );
                    }).toList()
                  
                    
                  ],
                ),
              ),
            ],
          ),
        )

        : Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),
                    Container(
                      
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: Text(AppLocalizations.of(context).translate('pendingActions'), style: TextStyle( fontSize: 18, fontWeight: FontWeight.w500),),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.25),
                        border: Border(
                          bottom: BorderSide(color: kBorderLighter)
                        )
                      ),
                    ),

                    SizedBox(height: 10,),
                      ...widget.carePlans.map( (item) {                     
                        return GoalItem(item: item);
                    }).toList()
                  
                    
                  ],
                ),
              ),
              
            ],
          ),
        ),

      ],
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

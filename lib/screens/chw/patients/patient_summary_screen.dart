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
import 'package:nhealth/screens/chw/patients/patient_search_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';


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
  bool avatarExists = false;
  var encounters = [];
  String lastEncounterdDate = '';
  String lastAssessmentdDate = '';
  String lastCarePlanDate = '';
  var conditions = [];
  var medications = [];
  var users = [];
  var report;
  var bmi;
  var cholesterol;
  var bp;
  var cvd;
  int interventionIndex = 0;
  bool actionsActive = false;

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    _checkAvatar();
    _checkAuth();
    _getCarePlan();
    getEncounters();
    getAssessments();
    getMedicationsConditions();
    getReport();
    getUsers();
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
  
    users = await UserController().getUsers();


    setState(() {
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

  getReport() async {

    var data = await HealthReportController().getLastReport();
    
    if (data['error'] == true) {
      
      Toast.show('No Health assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
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
          item['data'].keys.toList().forEach((key) {
            if (item['data'][key] == 'yes') {
              setState(() {
                var text = key.replaceAll('_', ' ');
                conditions.add(text[0].toUpperCase() + text.substring(1));
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
    var response = await HealthReportController().getLastReport();
    if (response == null) {
      return;
    }
    if (response['error']) {
      return;
    }

    setState(() {
      lastAssessmentdDate = DateFormat("MMMM d, y").format(DateTime.parse(response['data']['meta']['created_at']));
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
      encounters.sort((a, b) {
        return DateTime.parse(b['meta']['created_at']).compareTo(DateTime.parse(a['meta']['created_at']));
      });

      setState(() {
        lastEncounterdDate = DateFormat("MMMM d, y").format(DateTime.parse(encounters.first['meta']['created_at']));
      });

    }
    
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
      data['data'].forEach( (item) {
        var existedCp = carePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);
        // print(existedCp);
        if (existedCp.isEmpty) {
          var items = [];
          items.add(item);
          carePlans.add({
            'items': items,
            'title': item['body']['goal']['title'],
            'id': item['body']['goal']['id']
          });
        } else {
          carePlans[carePlans.indexOf(existedCp.first)]['items'].add(item);

        }
      });

      // setState(() {
      //   carePlans = data['data'];
      //   isLoading = false;
      // });

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Patient Summary', style: TextStyle(color: Colors.white, fontSize: 20),),
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
                                    // NetworkImage(Patient().getPatient()['data']['avatar'])
                                    // ClipRRect(
                                    //   borderRadius: BorderRadius.circular(100),
                                    //   child: Image.file(
                                    //     File(Patient().getPatient()['data']['avatar']),
                                    //     height: 60.0,
                                    //     width: 60.0,
                                    //     fit: BoxFit.fitWidth,
                                    //   ),
                                    // ),
                                    SizedBox(width: 20,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(Helpers().getPatientName(_patient), style: TextStyle( fontSize: 19, fontWeight: FontWeight.w600),),
                                        SizedBox(height: 7,),
                                        Row(
                                          children: <Widget>[
                                            Text(Helpers().getPatientAgeAndGender(_patient), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                                            SizedBox(width: 10,),
                                            SizedBox(width: 10,),
                                            Row(
                                              children: <Widget>[
                                                report['body']['result']['assessments'] != null && report['body']['result']['assessments']['lifestyle']['components']['diet'] != null && report['body']['result']['assessments']['lifestyle']['components']['diet']['components']['fruit'] != null ?
                                                CircleAvatar(
                                                  child: Image.asset('assets/images/icons/fruit.png', width: 11,),
                                                  radius: 11,
                                                  backgroundColor: ColorUtils.statusColor[report['body']['result']['assessments']['lifestyle']['components']['diet']['components']['fruit']['tfl']],
                                                ) : Container(),
                                                SizedBox(width: 5,),

                                                report['body']['result']['assessments'] != null && report['body']['result']['assessments']['lifestyle']['components']['diet'] != null && report['body']['result']['assessments']['lifestyle']['components']['diet']['components']['vegetable'] != null ?
                                                CircleAvatar(
                                                  child: Image.asset('assets/images/icons/vegetables.png', width: 11,),
                                                  radius: 11,
                                                  backgroundColor: ColorUtils.statusColor[report['body']['result']['assessments']['lifestyle']['components']['diet']['components']['vegetable']['tfl']],
                                                ) : Container(),
                                                SizedBox(width: 5,),

                                                report['body']['result']['assessments'] != null && report['body']['result']['assessments']['lifestyle']['components']['physical_activity'] != null ?
                                                CircleAvatar(
                                                  child: Image.asset('assets/images/icons/activity.png', width: 11,),
                                                  radius: 11,
                                                  backgroundColor: ColorUtils.statusColor[report['body']['result']['assessments']['lifestyle']['components']['physical_activity']['tfl']],
                                                ) : Container()
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            report != null && bmi != null ?
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: ColorUtils.statusColor[bmi['tfl']]),
                                                borderRadius: BorderRadius.circular(2)
                                              ),
                                              child: Text('BMI',style: TextStyle(
                                                  color: ColorUtils.statusColor[bmi['tfl']],
                                                  fontWeight: FontWeight.w500
                                                )  
                                              ),
                                            ) 
                                            : Container(),
                                            SizedBox(width: 7,),
                                            report != null && bp != null ?
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: ColorUtils.statusColor[bp['tfl']]),
                                                borderRadius: BorderRadius.circular(2)
                                              ),
                                              child: Text('BP',style: TextStyle(
                                                  color: ColorUtils.statusColor[bp['tfl']],
                                                  fontWeight: FontWeight.w500
                                                )  
                                              ),
                                            ) : Container(),
                                            SizedBox(width: 7,),
                                            report != null && cvd != null ?
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: ColorUtils.statusColor[cvd['tfl']]),
                                                borderRadius: BorderRadius.circular(2)
                                              ),
                                              child: Text('CVD Risk',style: TextStyle(
                                                  color: ColorUtils.statusColor[cvd['tfl']],
                                                  fontWeight: FontWeight.w500
                                                )  
                                              ),
                                            ) : Container(),
                                            SizedBox(width: 7,),
                                            report != null && cholesterol != null ?
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: ColorUtils.statusColor[cholesterol['tfl']]),
                                                borderRadius: BorderRadius.circular(2)
                                              ),
                                              child: Text('Cholesterol',style: TextStyle(
                                                  color: ColorUtils.statusColor[cholesterol['tfl']],
                                                  fontWeight: FontWeight.w500
                                                )  
                                              ),
                                            ) : Container(),
                                          ],
                                        ),

                                        // Text('Registered on Jan 5, 2019', style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w400),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 35,)
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Table(
                      children: [
                        TableRow( 
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text('Last Encounter date:', style: TextStyle(fontSize: 17,),),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text(lastEncounterdDate, style: TextStyle(fontSize: 17,),),
                            ),
                          ]
                        ),
                        TableRow( 
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text('Next Assessment Due on:', style: TextStyle(fontSize: 17,),),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text('Feb 15, 2020', style: TextStyle(fontSize: 17,),),
                            ),
                          ]
                        ),
                        TableRow( 
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text('Current Conditions:', style: TextStyle(fontSize: 17,),),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Wrap(
                                children: <Widget>[
                                  Container(),
                                  ...conditions.map((item) {
                                    return Text(item + '${conditions.length - 1 == conditions.indexOf(item) ? '' : ', '}', style: TextStyle(fontSize: 17,));
                                  }).toList()
                                ],
                              ),
                            ),
                          ]
                        ),
                        TableRow( 
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text('Allergies:', style: TextStyle(fontSize: 17,),),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text('Pollen', style: TextStyle(fontSize: 17,),),
                            ),
                          ]
                        ),
                        TableRow( 
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text('Medications', style: TextStyle(fontSize: 17,),),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Wrap(
                                children: <Widget>[
                                  Container(),
                                  ...medications.map((item) {
                                    return Text(item + '${medications.length - 1 == medications.indexOf(item) ? '' : ', '}', style: TextStyle(fontSize: 17,));
                                  }).toList()
                                ],
                              ),
                            ),
                          ]
                        ),
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
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Care Plan Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: kPrimaryColor),
                                  borderRadius: BorderRadius.circular(3)
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/carePlanDetails', arguments: carePlans);
                                  },
                                  child: Text('VIEW CARE PLAN', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Due Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              // Text(getDueCounts(),)
                            ],
                          ),
                        ),
                        widget.checkInState != null ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.check_circle, color: kPrimaryGreenColor,),
                              SizedBox(width: 10,),
                              Text('Check in Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
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
                                      ...carePlans.map( (item) {
                                        interventionIndex = interventionIndex + 1;
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
                                      ...carePlans.map( (item) {
                                        interventionIndex = interventionIndex + 1;
                                        return GoalItem(item: item);
                                    }).toList()
                                  
                                    
                                  ],
                                ),
                              ),
                              Container(
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
                                      context: context,
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
                                                  child: Text('In the course of your visit, were there any medical issues identified?', style: TextStyle(
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
                                                          child: Text('YES', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
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
                                                          onPressed: () {
                                                            Navigator.of(context).pushNamed('/chwHome');
                                                          },
                                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          child: Text('No', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
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
                                  child: Text('COMPLETE VISIT', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                ),
                              ),
                            ],
                          ),
                        ),

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
      floatingActionButton: widget.checkInState == null ?FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/verifyPatient');
        },
        icon: Icon(Icons.add),
        label: Text("NEW COMMUNITY VISIT"),
        backgroundColor: kPrimaryColor,
      ) : Container(),
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
  setStatus() {
    setState(() {
      status = 'completed';
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

  @override
  Widget build(BuildContext context) {
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
          if (status == 'pending') {
            if (widget.item['title'] == 'Improve blood pressure control') {
              Navigator.of(context).pushNamed('/chwImproveBp', arguments: { 'data': widget.item, 'parent': this });
            } else {
              Navigator.of(context).pushNamed('/chwOtherActions', arguments: { 'data': widget.item, 'parent': this });
            }
          }
        },
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(widget.item['title'], style: TextStyle(fontSize: 16, color: kPrimaryColor)),
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor),
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.item['title'] == 'Improve blood pressure control') {
                        Navigator.of(context).pushNamed('/chwImproveBp', arguments: { 'data': widget.item, 'parent': this });
                      } else {
                        Navigator.of(context).pushNamed('/chwOtherActions', arguments: { 'data': widget.item, 'parent': this });
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        // Text('${report['body']['result']['actions'].length} Actions  ', style: TextStyle(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor, fontWeight: FontWeight.w500),),
                        Text('${getCount()} Actions  ', style: TextStyle(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor, fontWeight: FontWeight.w500),),
                        if (status != 'pending') 
                        Icon(Icons.check_circle, color: kPrimaryGreenColor, size: 14,)
                      ],
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: kBorderLight,)
              ],
            ),
          ),
        ],),
      ),
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

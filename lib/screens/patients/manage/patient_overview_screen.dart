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
import 'package:nhealth/repositories/user_repository.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/new_encounter_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';


class PatientRecordsScreen extends StatefulWidget {
  @override
  _PatientRecordsState createState() => _PatientRecordsState();
}

class _PatientRecordsState extends State<PatientRecordsScreen> {
  var _patient;
  bool isLoading = false;
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

  getUsers() async {
    setState(() {
      isLoading = true;
    });
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
    isLoading = true;
    var data = await HealthReportController().getLastReport();
    
    if (data['error'] == true) {
      setState(() {
        isLoading = false;
      });
      Toast.show('No Health assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        isLoading = false;
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


    setState(() {
      isLoading = false;
    });
  }

  getDueCounts() {
    var goalCount = 0;
    var actionCount = 0;
    carePlans.forEach((item) {
      if(item['meta']['status'] == 'pending') {
        goalCount = goalCount + 1;
        if (item['body']['components'] != null) {
          // actionCount = actionCount + item['body']['components'].length;
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

    setState(() {
      isLoading = false;
    });

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
    setState(() {
      isLoading = true;
    });
    
    var data = await CarePlanController().getCarePlan();
    
    if (data != null && data['message'] == 'Unauthorized') {
      setState(() {
        isLoading = false;
      });
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else if (data['error'] == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        carePlans = data['data'];
        isLoading = false;
      });

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('patientOverview'), style: TextStyle(color: Colors.white, fontSize: 20),),
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
                                                CircleAvatar(
                                                  child: Image.asset('assets/images/icons/fruit.png', width: 11,),
                                                  radius: 11,
                                                  backgroundColor: kPrimaryRedColor,
                                                ),
                                                SizedBox(width: 5,),
                                                CircleAvatar(
                                                  child: Image.asset('assets/images/icons/vegetables.png', width: 11,),
                                                  radius: 11,
                                                  backgroundColor: kPrimaryRedColor,
                                                ),
                                                SizedBox(width: 5,),
                                                CircleAvatar(
                                                  child: Image.asset('assets/images/icons/activity.png', width: 11,),
                                                  radius: 11,
                                                  backgroundColor: kPrimaryAmberColor,
                                                )
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
                                                  color: ColorUtils.statusColor[bmi['tfl']],
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
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                          child: ExpandableTheme(
                            data: ExpandableThemeData(
                              iconColor: kBorderGrey,
                              iconPlacement: ExpandablePanelIconPlacement.left,
                              useInkWell: true,
                              iconPadding: EdgeInsets.only(top: 12, left: 8, right: 8)
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                    child: ExpandableNotifier(
                                      child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1, color: kBorderLighter)
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            ScrollOnExpand(
                                              scrollOnExpand: true,
                                              scrollOnCollapse: false,
                                              child: ExpandablePanel(
                                                theme: const ExpandableThemeData(
                                                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                                                  tapBodyToCollapse: true,
                                                ),
                                                header: Container(
                                                  padding: EdgeInsets.only(top:10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "Due Today",
                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(right: 20),
                                                        child: Text(getDueCounts(), style: TextStyle(color: Colors.black54, fontSize: 16),),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                expanded: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(height: 10,),
                                                      ...carePlans.map( (item) {
                                                      if (item['meta']['status'] == 'pending') {
                                                        return Container(
                                                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                          padding: EdgeInsets.only(bottom: 20),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              bottom: BorderSide(color: kBorderLighter)
                                                            )
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              if (item['body']['goal'] != null && item['body']['goal']['title'] != null)
                                                                Text(item['body']['goal']['title'], style: TextStyle(fontSize: 16)),
                                                              SizedBox(height: 15,),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.of(context).pushNamed('/carePlanInterventions', arguments: {
                                                                    'carePlan' : item,
                                                                    'parent': this
                                                                  });
                                                                },
                                                                child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  if (item['body']['title'] != null)
                                                                    Text(item['body']['title'], style: TextStyle(fontSize: 17, color: kPrimaryColor)),
                                                                  Icon(Icons.chevron_right, color: kPrimaryColor,)
                                                                ],),
                                                              ),
                                                            ],
                                                          )
                                                        );
                                                      } else return Container();
                                                    }).toList()
                                                  
                                                    
                                                  ],
                                                ),
                                                builder: (_, collapsed, expanded) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Expandable(
                                                      collapsed: collapsed,
                                                      expanded: expanded,
                                                      theme: const ExpandableThemeData(crossFadePoint: 0),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: ExpandableTheme(
                            data: ExpandableThemeData(
                              iconColor: kBorderGrey,
                              iconPlacement: ExpandablePanelIconPlacement.left,
                              useInkWell: true,
                              iconPadding: EdgeInsets.only(top: 12, left: 8, right: 8)
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                    child: ExpandableNotifier(
                                      child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1, color: kBorderLighter)
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            ScrollOnExpand(
                                              scrollOnExpand: true,
                                              scrollOnCollapse: false,
                                              child: ExpandablePanel(
                                                theme: const ExpandableThemeData(
                                                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                                                  tapBodyToCollapse: true,
                                                ),
                                                header: Container(
                                                  padding: EdgeInsets.only(top:10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "Upcoming",
                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(right: 20),
                                                        child: Text('2 goals & 6 actions', style: TextStyle(color: Colors.black54, fontSize: 16),),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                expanded: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                      padding: EdgeInsets.only(bottom: 20),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(color: kBorderLighter)
                                                        )
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text('Improve glycemic control', style: TextStyle(fontSize: 16)),
                                                          SizedBox(height: 15,),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: <Widget>[
                                                              Text('Councelling about diet/ physical exercise', style: TextStyle(fontSize: 17, color: kPrimaryColor)),
                                                              Icon(Icons.chevron_right, color: kPrimaryColor,)
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                      padding: EdgeInsets.only(bottom: 20),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(color: kBorderLighter)
                                                        )
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text('Improve glycemic control', style: TextStyle(fontSize: 16)),
                                                          SizedBox(height: 15,),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: <Widget>[
                                                              Text('Councelling about diet/ physical exercise', style: TextStyle(fontSize: 17, color: kPrimaryColor)),
                                                              Icon(Icons.chevron_right, color: kPrimaryColor,)
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ),
                                                  
                                                  ],
                                                ),
                                                builder: (_, collapsed, expanded) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Expandable(
                                                      collapsed: collapsed,
                                                      expanded: expanded,
                                                      theme: const ExpandableThemeData(crossFadePoint: 0),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    )
                  ),
                  SizedBox(height: 15,),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 5, color: kBorderLighter)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Patient History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                              Icon(Icons.filter_list, color: kPrimaryColor,)
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20,),

                        //Terminal
                        Container(
                          
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Text('Jan 2020', style: TextStyle(fontSize: 17),),
                              ),
                              SizedBox(height: 15,),
                              ...encounters.map((encounter) {
                                return Container(
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 25),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(width: 1, color: kBorderGrey)
                                          )
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(width: 30),
                                            Expanded(
                                              
                                              child: Container(
                                                margin: EdgeInsets.only(bottom: 20),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: kBorderLighter)
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(Helpers().convertDate(encounter['data']['assessment_date']), style: TextStyle(fontSize: 16)),
                                                      SizedBox(height: 15,),
                                                      Text('Follow-up Encounter: ' + encounter['data']['type'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),

                                                      SizedBox(height: 15,),
                                                      Row(
                                                        children: <Widget>[
                                                          CircleAvatar(
                                                            radius: 15,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(30.0),
                                                              child: Image.network(
                                                                Patient().getPatient()['data']['avatar'],
                                                                height: 30.0,
                                                                width: 30.0,
                                                              ),
                                                            ),
                                                            backgroundImage: AssetImage('assets/images/avatar.png'),
                                                          ),
                                                          SizedBox(width: 20,),
                                                          Text(getUser(encounter['meta']['collected_by']), style: TextStyle(fontSize: 17)),
                                                        ],
                                                      ),

                                                      SizedBox(height: 20,),
                                                      Row(
                                                        children: <Widget>[
                                                          Column(
                                                            children: <Widget>[
                                                              Image.asset('assets/images/icons/questionnaire.png', width: 20,),
                                                              SizedBox(height: 10,),
                                                              Text('Health \nHistory', textAlign: TextAlign.center,)
                                                            ],
                                                          ),
                                                          SizedBox(width: 25,),
                                                          Column(
                                                            children: <Widget>[
                                                              Image.asset('assets/images/icons/body_measurements.png', width: 20,),
                                                              SizedBox(height: 10,),
                                                              Text('Body\nMeasurement', textAlign: TextAlign.center,)
                                                            ],
                                                          ),
                                                          SizedBox(width: 25,),
                                                          Column(
                                                            children: <Widget>[
                                                              Image.asset('assets/images/icons/blood_pressure.png', width: 20,),
                                                              SizedBox(height: 10,),
                                                              Text('Blood\nPressure', textAlign: TextAlign.center,)
                                                            ],
                                                          ),
                                                          SizedBox(width: 25,),
                                                          Column(
                                                            children: <Widget>[
                                                              Image.asset('assets/images/icons/blood_test.png', width: 20,),
                                                              SizedBox(height: 10,),
                                                              Text('Blood\nTest', textAlign: TextAlign.center,)
                                                            ],
                                                          ),
                                                          SizedBox(width: 25,),
                                                          Column(
                                                            children: <Widget>[
                                                              Image.asset('assets/images/icons/blood_glucose.png', width: 20,),
                                                              SizedBox(height: 10,),
                                                              Text('Medical\nHistory', textAlign: TextAlign.center,)
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      
                                                      SizedBox(height: 20,),
                                                      // Row(
                                                      //   children: <Widget>[
                                                      //     Container(
                                                      //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                      //       decoration: BoxDecoration(
                                                      //         border: Border.all(width: 1, color: kPrimaryRedColor),
                                                      //         borderRadius: BorderRadius.circular(2)
                                                      //       ),
                                                      //       child: Text('BMI',style: TextStyle(
                                                      //           color: kPrimaryRedColor,
                                                      //           fontWeight: FontWeight.w500
                                                      //         )  
                                                      //       ),
                                                      //     ),
                                                      //     SizedBox(width: 7,),
                                                      //     Container(
                                                      //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                      //       decoration: BoxDecoration(
                                                      //         border: Border.all(width: 1, color: kPrimaryRedColor),
                                                      //         borderRadius: BorderRadius.circular(2)
                                                      //       ),
                                                      //       child: Text('CVD Risk',style: TextStyle(
                                                      //           color: kPrimaryRedColor,
                                                      //           fontWeight: FontWeight.w500
                                                      //         )  
                                                      //       ),
                                                      //     ),
                                                      //     SizedBox(width: 7,),
                                                      //     Container(
                                                      //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                      //       decoration: BoxDecoration(
                                                      //         border: Border.all(width: 1, color: kPrimaryAmberColor),
                                                      //         borderRadius: BorderRadius.circular(2)
                                                      //       ),
                                                      //       child: Text('Cholesterol',style: TextStyle(
                                                      //           color: kPrimaryAmberColor,
                                                      //           fontWeight: FontWeight.w500
                                                      //         )  
                                                      //       ),
                                                      //     ),
                                                      //   ],
                                                      // ),
                                                      // SizedBox(height: 20),
                                                      GestureDetector(
                                                        onTap: () {
                                                          return;
                                                          Navigator.of(context).pushNamed('/encounterDetails', arguments: encounter);
                                                        },
                                                        child: Text('View Encounter Details', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w400, fontSize: 16),)
                                                      ),
                                                      SizedBox(height: 20,),
                                                      // Container(
                                                      //   padding: EdgeInsets.only(top: 20),
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     border: Border(
                                                      //       top: BorderSide(width: 1, color: kBorderLighter),
                                                      //     ),
                                                      //   ),
                                                      //   child: Column(
                                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                                      //     children: <Widget>[
                                                      //       Text('Interventions', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),),
                                                      //       SizedBox(height: 15,),
                                                      //       Text('Counselling on smoking cessation', style: TextStyle(fontSize: 16),),
                                                      //       SizedBox(height: 15,),
                                                      //       Text('Intimate METFORMIN 250 - 500 mg once daily', style: TextStyle(fontSize: 16),),
                                                      //     ],
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                )
                                              ),
                                            )
                                          ],
                                        ),
                                    
                                      ),
                                      Positioned(
                                        left: 15,
                                        top:30,
                                        child: Container(
                                          child: CircleAvatar(
                                            backgroundColor: kPrimaryLight,
                                            radius: 10,
                                            child: CircleAvatar(
                                              backgroundColor: kPrimaryColor,
                                              radius: 6,
                                            )
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 41,
                                        top: 33,
                                        child: Transform.rotate(angle: 90 * pi/180, 
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                              )
                                            ),
                                            child: ClipPath(
                                              child: Container(
                                                width: 24,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black54,
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0,
                                                      offset: Offset(
                                                        2.0, 
                                                        5.0, 
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              ),
                                              clipper: CustomClipPath(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    ;
                            
                              }).toList()  
                            ],
                          )
                        ),
                      ],
                    )
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
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
                            FloatingButton(text: 'FOLLOW-UP', onPressed: () {},),
                            FloatingButton(text: 'ACUTE', onPressed: () {},),
                            FloatingButton(text: 'CHILD', onPressed: () {},),
                            FloatingButton(text: 'MATERIAL', onPressed: () {},),
                            FloatingButton(text: 'HEALTH SCREENING', onPressed: () {},),
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
        icon: Icon(Icons.add),
        label: Text("NEW ENCOUNTER"),
        backgroundColor: kPrimaryColor,
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

class OverviewIntervention extends StatefulWidget {
  var carePlan;
  OverviewIntervention({this.carePlan});

  @override
  _OverviewInterventionState createState() => _OverviewInterventionState();
}

class _OverviewInterventionState extends State<OverviewIntervention> {
  var status;

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  getStatus() {
    String completedDate = '';
    if (widget.carePlan['meta']['status'] == 'completed') {
      if (widget.carePlan['meta']['completed_at'] != null && widget.carePlan['meta']['completed_at']['_seconds'] != null) {
        var parsedDate = DateTime.fromMillisecondsSinceEpoch(widget.carePlan['meta']['completed_at']['_seconds'] * 1000);

        completedDate = DateFormat("MMMM d, y").format(parsedDate).toString();
      }

      setState(() {
        status = widget.carePlan['meta']['status'] + ' on ' + completedDate;
      });
      
    } else {
      setState(() {
        status = widget.carePlan['meta']['status'];
      });
    }
    
  }

  setStatus() {
    //  var index = careplans.indexOf(carePlan);

    setState(() {
      widget.carePlan['meta']['status'] = 'completed';
      status = 'completed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: .5, color: Colors.black12),
        )
      ),
      child: FlatButton(
        onPressed: () {
          if (widget.carePlan['meta']['status'] == 'pending') {
            // Navigator.of(context).push(CarePlanInterventionScreen(carePlan: widget.carePlan, parent: this));
            Navigator.of(context).pushNamed('/carePlanInterventions', arguments: {'carePlan' : widget.carePlan, 'parent': this });
          }
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Container(
          padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.carePlan['body']['goal']['title'], style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,)),
                    SizedBox(height: 15,),
                    Text('Intervention: ${widget.carePlan['body']['title']}', overflow: TextOverflow.fade, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400,)),
                    SizedBox(height: 15,),
                    Text('${status != 'pending' ? status[0].toUpperCase() + status.substring(1) : 'Pending'}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: status != 'pending' ? kPrimaryGreenColor : kPrimaryRedColor)),
                  ],
                ),
              ),
              Container(
                child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
              )
            ],
          ),
        ),
      ),
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

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

// The entire multilevel list displayed by this app.


class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

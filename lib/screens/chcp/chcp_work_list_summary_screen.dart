import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'chcp_careplan_feeling_screen.dart';
import 'followup_patient_chcp_summary_screen.dart';

var dueCarePlans = [];
var completedCarePlans = [];
var upcomingCarePlans = [];

class ChcpWorkListSummaryScreen extends StatefulWidget {
  var checkInState = false;
  var prevScreen = '';
  var encounterData = {};
  ChcpWorkListSummaryScreen({this.prevScreen, this.encounterData});
  @override
  _ChcpWorkListSummaryScreenState createState() => _ChcpWorkListSummaryScreenState();
}

class _ChcpWorkListSummaryScreenState extends State<ChcpWorkListSummaryScreen> {
  var _patient;
  bool isLoading = true;
  var carePlans = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  bool avatarExists = false;
  var lastAssessment;
  var lastFollowup;
  bool hasIncompleteFollowup = false;
  String lastEncounterType = '';
  String lastEncounterDate = '';
  String nextVisitDateChw = '';
  String nextVisitPlaceChw = '';
  String nextVisitDateCc = '';
  String nextVisitPlaceCc = '';
  var conditions = [];
  var medications = [];
  var allergies = [];
  var report;
  var bmi;
  var cholesterol;
  var bp;
  var cvd;
  bool carePlansEmpty = false;
  var dueDate = '';

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    dueCarePlans = [];
    completedCarePlans = [];
    upcomingCarePlans = [];
    conditions = [];
    carePlansEmpty = false;
    
    _checkAvatar();
    _checkAuth();
    getAssessmentDueDate();
    getMedicationsConditions();
    getReport();
    getLastAssessment();
    getLastFollowup();
    _getCarePlan();
    isLoading = false;
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
    setState(() {
      isLoading = true;
    });
    lastAssessment = await AssessmentController().getLastAssessmentByPatient();


    if(lastAssessment != null && lastAssessment.isNotEmpty) {
      if(lastAssessment['data']['body']['follow_up_info'] != null && lastAssessment['data']['body']['follow_up_info'].isNotEmpty){
        var followUpInfoChw = lastAssessment['data']['body']['follow_up_info'].where((info)=> info['type'] == 'chw');
        if(followUpInfoChw.isNotEmpty) {
          followUpInfoChw = followUpInfoChw.first;
        }
        var followUpInfoCc= lastAssessment['data']['body']['follow_up_info'].where((info)=> info['type'] == 'cc');
        if(followUpInfoCc.isNotEmpty) {
          followUpInfoCc = followUpInfoCc.first;
        }
        setState(() {
          nextVisitDateChw = (followUpInfoChw['date'] != null && followUpInfoChw['date'].isNotEmpty) ? getDate(followUpInfoChw['date']) : '' ;
          nextVisitPlaceChw = (followUpInfoChw['place'] != null && followUpInfoChw['place'].isNotEmpty) ? (followUpInfoChw['place']) : '' ;
          nextVisitDateCc = (followUpInfoCc['date'] != null && followUpInfoCc['date'].isNotEmpty) ? getDate(followUpInfoCc['date']) : '' ;
          nextVisitPlaceCc = (followUpInfoCc['place'] != null && followUpInfoCc['place'].isNotEmpty) ? (followUpInfoCc['place']) : '' ;
        });
      }

      setState(() {
        lastEncounterType = lastAssessment['data']['body']['type'];
        lastEncounterDate = getDate(lastAssessment['data']['meta']['created_at']);
      });
    }
    
  }
  getLastFollowup() async {
    setState(() {
      isLoading = true;
    });
    lastFollowup = await AssessmentController().getLastAssessmentByPatient(key:'screening_type', value:'follow-up');

    if(lastFollowup != null && lastFollowup.isNotEmpty) {
      if(lastFollowup['data']['body']['type'] == 'follow up visit (center)'
        && lastFollowup['data']['body']['status'] == 'incomplete') {
          setState(() {
            hasIncompleteFollowup = true;
          });
        }
    }
  }


  getAssessmentDueDate() {
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
  }

  getReport() async {
    setState(() {
      isLoading = true;
    });
    var data = await HealthReportController().getLastReport(context);
    if (data.isEmpty) {
      setState(() {
        carePlansEmpty = true;
      });
    } 
    else {
      setState(() {
        report = data['data'];
        bmi = report['body']['result']['assessments']['body_composition'] != null && report['body']['result']['assessments']['body_composition']['components']['bmi'] != null ? report['body']['result']['assessments']['body_composition']['components']['bmi'] : null;
        cvd = report['body']['result']['assessments']['cvd'] != null ? report['body']['result']['assessments']['cvd'] : null;
        bp = report['body']['result']['assessments']['blood_pressure'] != null ? report['body']['result']['assessments']['blood_pressure'] : null;
        cholesterol = report['body']['result']['assessments']['cholesterol'] != null && report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ? report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] : null;
      });
    }
  }

  getMedicationsConditions() async {
    var patientId = Patient().getPatient()['id'];
    var fetchedSurveys = await ObservationController().getLocalSurveysByPatient(patientId);

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
      setState(() {
        carePlans = data;
      });

      if(data != null) {
        data.forEach( (item) {
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
        }

        // check due careplans
        if (item['meta']['status'] == 'pending') {
          if (todayDate.isAfter(startDate) && todayDate.isBefore(endDate)) {
            if(item['body']['goal'] != null){
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      if(widget.prevScreen == 'followup') {
          Navigator.of(context).pushNamed( '/chcpNavigation', arguments: 1);
          return true;
        } else {
          Navigator.pop(context);
          return true;
        }
      },
      child: Scaffold(
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
                                nextVisitDateChw == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitDateChw') +  ': $nextVisitDateChw', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                nextVisitPlaceChw == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitPlaceChw') +  ': $nextVisitPlaceChw', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                nextVisitDateCc == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitDateCc') +  ': $nextVisitDateCc', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                nextVisitPlaceCc == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitPlaceCc') +  ': $nextVisitPlaceCc', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                Text(AppLocalizations.of(context).translate('lastVisitDate') +  ': $lastEncounterDate', style: TextStyle(fontSize: 17,))
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
                                Text(AppLocalizations.of(context).translate('lastEncounter')+'${(lastEncounterType)}', style: TextStyle(fontSize: 17,)),
                                SizedBox(height: 10,),
                                Text(AppLocalizations.of(context).translate('lastEncounterDate')+  ': $lastEncounterDate', style: TextStyle(fontSize: 17,)),
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
                                      else if(carePlans != null && carePlans.length > 0)
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
                                
                                SizedBox(height: 20,),
                                (widget.prevScreen == 'followup') && widget.encounterData['dataStatus'] != 'complete' ?
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
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if(widget.prevScreen == 'followup') {
                                      if((widget.encounterData).containsKey("encounter") && (widget.encounterData).containsKey("observations"))
                                      {
                                      } else {
                                      }
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    // return;
                                    Navigator.of(context).pushNamed('/chwHome',);
                                  },
                                  color: kPrimaryColor,
                                  child: Text(AppLocalizations.of(context).translate('saveForLater'), style: TextStyle(color: Colors.white),),
                                  ),
                                ) : Container(),
                                SizedBox(height: 20,),
                                (widget.prevScreen == 'followup')?
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(3)
                                  ),
                                  child: FlatButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if(widget.prevScreen == 'followup') {
                                      var status = widget.encounterData['dataStatus'] == 'incomplete' ? 'incomplete' : 'complete';
                                      if((widget.encounterData).containsKey("encounter") && (widget.encounterData).containsKey("observations"))
                                      {

                                      } else {
                                        }
                                      status == 'complete' ? Patient().setPatientReviewRequiredTrue() : null;
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.of(context).pushNamed('/chwHome',);
                                  },
                                  color: kPrimaryColor,
                                  child: Text(AppLocalizations.of(context).translate('completeEncounter'), style: TextStyle(color: Colors.white),),
                                  ),
                                ) : Container(),
                              ],
                            )
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
                                Navigator.of(context).pushNamed(FollowupPatientChcpSummaryScreen.path, arguments: {'prevScreen' : 'home', 'encounterData': {},});
                              }, ),

                              FloatingButton(text: AppLocalizations.of(context).translate('deliverCarePlan'), onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamed(ChcpCareplanFeelingScreen.path);
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


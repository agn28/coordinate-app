import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_details_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/new_encounter_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/past_encounters_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/create_health_report_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/past_health_report_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';


class PatientRecordsScreen extends CupertinoPageRoute {
  PatientRecordsScreen()
      : super(builder: (BuildContext context) => new PatientRecords());
}

class PatientRecords extends StatefulWidget {
  @override
  _PatientRecordsState createState() => _PatientRecordsState();
}

class _PatientRecordsState extends State<PatientRecords> {
  var _patient;
  bool isLoading = false;
  var carePlans;
  bool avatarExists = false;

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    _checkAvatar();
    _checkAuth();
    _getCarePlan();
    print(Patient().getPatient()['data']['avatar']);
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
    print(data);
    
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
              Container(
                height: 260,
                color: kPrimaryColor,
              ),
              Container(
                color: Colors.transparent,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                      child: Row(
                        children: <Widget>[
                          Patient().getPatient()['data']['avatar'] == '' ? 
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Image.asset(
                              'assets/images/avatar.png',
                              height: 60.0,
                              width: 60.0,
                            ),
                          ) :
                          CircleAvatar(
                            radius: 30,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
                              child: Image.network(
                                Patient().getPatient()['data']['avatar'],
                                height: 60.0,
                                width: 60.0,
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
                              SizedBox(height: 20,),
                              Text(Helpers().getPatientName(_patient), style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600),),
                              SizedBox(height: 15,),
                              Row(
                                children: <Widget>[
                                  Text(Helpers().getPatientAgeAndGender(_patient), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),),
                                  SizedBox(width: 10,),
                                  Text('${AppLocalizations.of(context).translate('nid')}: ${_patient["data"]["nid"]}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),),
                                  SizedBox(width: 10,),
                                  Text('PID: N-213452351', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Text('${AppLocalizations.of(context).translate('registeredOn')} ${Helpers().convertDate(_patient["meta"]["created_at"])}', style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w400),),
                              // Text('Registered on Jan 5, 2019', style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w400),),
                            ],
                          ),
                        ],
                      )
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 40, right: 40),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          
                          SizedBox(height: 20,),

                          Container(
                            // height: 190,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 1.0)
                                ),
                              ]
                            ),
                            child: Card(
                              elevation: 0,
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(AppLocalizations.of(context).translate('encounters'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                        ),
                                        // Expanded(
                                        //   child: Text('Last encounter on Jan 27, 2020', style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)
                                        // )
                                      ],
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Helpers().clearObservationItems();
                                      Helpers().clearAssessment();
                                      Navigator.of(context).push(NewEncounterScreen());
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      padding: EdgeInsets.only(bottom: 17, top: 17),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(width: .5, color: Colors.black12)
                                        )
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.add, color: kPrimaryColor, size: 30,),
                                          SizedBox(width: 20),
                                          Text('Create a New Encounter', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
                                        ],
                                      ),
                                    ),
                                  ),

                                  FlatButton(
                                    onPressed: () => Navigator.of(context).push(PastEncountersScreen()),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      padding: EdgeInsets.only(bottom: 17, top: 17),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.visibility, color: kPrimaryColor, size: 30,),
                                          SizedBox(width: 20),
                                          Text('View Past Encounters', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20,)
                                ],
                              )
                            ),
                          ),

                          SizedBox(height: 20,),

                          Container(
                            // height: 190,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 1.0)
                                ),
                              ]
                            ),
                            child: Card(
                              elevation: 0,
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(AppLocalizations.of(context).translate('assessments'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                        ),
                                        // Expanded(
                                        //   child: Text('Last encounter on Jan 5, 2019', style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)
                                        // )
                                      ],
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () => Navigator.of(context).push(CreateHealthReportScreen()),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      padding: EdgeInsets.only(bottom: 17, top: 17),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(width: .5, color: Colors.black12)
                                        )
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.add, color: kPrimaryColor, size: 30,),
                                          SizedBox(width: 20),
                                          Text(AppLocalizations.of(context).translate('newHealthAssessment'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
                                        ],
                                      ),
                                    ),
                                  ),

                                  FlatButton(
                                    onPressed: () => Navigator.of(context).push(PastHealthReportScreen()),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      padding: EdgeInsets.only(bottom: 17, top: 17),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.visibility, color: kPrimaryColor, size: 30,),
                                          SizedBox(width: 20),
                                          Text(AppLocalizations.of(context).translate('pastHealthAssessments'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 30,)
                                ],
                              )
                            ),
                          ),
                          
                          SizedBox(height: 20,),

                          carePlans != null ? Container(
                            // height: 190,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 1.0)
                                ),
                              ]
                            ),
                            child: Card(
                              elevation: 0,
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(AppLocalizations.of(context).translate('carePlan'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                        ),
                                        Expanded(
                                          child: Text('Last modified on Jan 5, 2019', style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)
                                        )
                                      ],
                                    ),
                                  ),
                                  // Container(
                                  //   margin: EdgeInsets.symmetric(horizontal: 30),
                                  //   child: Text('Hypertension, high Blood Pressure', style: TextStyle( fontSize: 16),),
                                  // ),
                                  // Container(
                                  //   margin: EdgeInsets.only(top: 20),
                                  //   decoration: BoxDecoration(
                                  //     border: Border(
                                  //       bottom: BorderSide(width: .5, color: Colors.black12),
                                  //       top: BorderSide(width: .5, color: Colors.black12)
                                  //     )
                                  //   ),
                                  //   child: FlatButton(
                                  //     onPressed: () {
                                  //       Navigator.of(context).push(CarePlanMedicationScreen());
                                  //     },
                                  //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  //     child: Container(
                                  //       padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
                                  //       child: Row(
                                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //         children: <Widget>[
                                  //           Text('Napa 12 mg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400,), textAlign: TextAlign.right,),
                                  //           Container(
                                  //             child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                                  //           )
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     border: Border(
                                  //       bottom: BorderSide(width: .5, color: Colors.black12),
                                  //     )
                                  //   ),
                                  //   child: FlatButton(
                                  //     onPressed: () {
                                  //       Navigator.of(context).push(CarePlanMedicationScreen());
                                  //     },
                                  //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  //     child: Container(
                                  //       padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
                                  //       child: Row(
                                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //         children: <Widget>[
                                  //           Text('Metfornim 50 mg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400,), textAlign: TextAlign.right,),
                                  //           Container(
                                  //             child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                                  //           )
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  ...carePlans.map<Widget>((item) =>
                                    item['body']['goal'] != null ? OverviewIntervention(carePlan: item) : Container(),
                                  ).toList(),

                                  Container(
                                    margin: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Text('Followup after 3 months', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,)),
                                        // SizedBox(height: 30,),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: kPrimaryColor,
                                            borderRadius: BorderRadius.circular(4)
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              Navigator.of(context).push(CarePlanDetailsScreen(carePlans: carePlans));
                                            },
                                            padding: EdgeInsets.symmetric(vertical: 20),
                                            child: Text('VIEW CARE PLAN DETAILS', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                ],
                              )
                            ),
                          ) : Container(),
                          SizedBox(height: 50,)
                        ],
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
            ],
          ),
        ),
      ),
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
        print(completedDate);
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
            Navigator.of(context).push(CarePlanInterventionScreen(carePlan: widget.carePlan, parent: this));
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
                    Text('Intervention: ${widget.carePlan['body']['title']}', overflow: TextOverflow.fade, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,)),
                    SizedBox(height: 15,),
                    Text('${status != 'pending' ? status[0].toUpperCase() + status.substring(1) : 'Pending'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: status != 'pending' ? kPrimaryGreenColor : kPrimaryRedColor)),
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

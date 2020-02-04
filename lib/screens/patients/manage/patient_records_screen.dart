import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_details_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_list_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_medication_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/new_encounter_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/past_encounters_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/create_health_report_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/past_health_report_screen.dart';


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
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _patient = Patient().getPatient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Patient Overview', style: TextStyle(color: Colors.white, fontSize: 22),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: 30),
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit, color: Colors.white,),
                  SizedBox(width: 10),
                  Text('View/Edit Patient Details', style: TextStyle(color: Colors.white))
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
                          Container(
                            height: 60,
                            width: 60,
                            child: Icon(Icons.perm_identity, size: 35, color: kPrimaryColor,),
                            decoration: BoxDecoration(
                              color: kLightButton,
                              shape: BoxShape.circle
                            ),
                          ),
                          SizedBox(width: 20,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 20,),
                              Text(_patient['data']['name'], style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600),),
                              SizedBox(height: 15,),
                              Row(
                                children: <Widget>[
                                  Text('${_patient["data"]["age"]}Y ${_patient["data"]["gender"].toUpperCase()}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),),
                                  SizedBox(width: 10,),
                                  Text('NID: ${_patient["data"]["nid"]}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),),
                                  SizedBox(width: 10,),
                                  Text('PID: N-213452351', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Text('Registered on Jan 5, 2019', style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w400),),
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
                                          child: Text('Encounters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                        ),
                                        Expanded(
                                          child: Text('Last encounter on Jan 27, 2020', style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)
                                        )
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
                                          child: Text('Assessments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                        ),
                                        Expanded(
                                          child: Text('Last encounter on Jan 5, 2019', style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)
                                        )
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
                                          Text('Create a New Health Assessment', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
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
                                          Text('View Past Health Assessments', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
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

                          Container(
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
                                          child: Text('Care Plan Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                        ),
                                        Expanded(
                                          child: Text('Last modified on Jan 5, 2019', style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 30),
                                    child: Text('Hypertension, high Blood Pressure', style: TextStyle( fontSize: 16),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: .5, color: Colors.black12),
                                        top: BorderSide(width: .5, color: Colors.black12)
                                      )
                                    ),
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).push(CarePlanMedicationScreen());
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text('Napa 12 mg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400,), textAlign: TextAlign.right,),
                                            Container(
                                              child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: .5, color: Colors.black12),
                                      )
                                    ),
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).push(CarePlanMedicationScreen());
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text('Metfornim 50 mg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400,), textAlign: TextAlign.right,),
                                            Container(
                                              child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: .5, color: Colors.black12),
                                      )
                                    ),
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).push(CarePlanInterventionScreen());
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Improve blood pressure control', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,)),
                                                SizedBox(height: 15,),
                                                Text('Intervention: Counselling about reduced salt intake', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,)),
                                                SizedBox(height: 15,),
                                                Text('Completed on Jan 10 2019', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kPrimaryGreenColor)),
                                              ],
                                            ),
                                            Container(
                                              child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: .5, color: Colors.black12),
                                      )
                                    ),
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).push(CarePlanInterventionScreen());
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Decrease cholesterol levels', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,)),
                                                SizedBox(height: 15,),
                                                Text('Intervention: Counselling about lipid lowering diet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,)),
                                                SizedBox(height: 15,),
                                                Text('Pending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kPrimaryRedColor)),
                                              ],
                                            ),
                                            Container(
                                              child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Followup after 3 months', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,)),
                                        SizedBox(height: 30,),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: kPrimaryColor,
                                            borderRadius: BorderRadius.circular(4)
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              Navigator.of(context).push(CarePlanDetailsScreen());
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
                          ),
                          SizedBox(height: 50,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

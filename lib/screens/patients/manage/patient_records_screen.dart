import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/home_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_list_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/new_encounter_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/past_encounters_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/create_health_report_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/past_health_report_screen.dart';


class PatientRecordsScreen extends CupertinoPageRoute {
  PatientRecordsScreen()
      : super(builder: (BuildContext context) => new PatientRecords());


}

class PatientRecords extends StatefulWidget {
  
  // final String patientId;
  // PatientRecordsScreen(this.patientId);

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
     print(_patient);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Patient Overview', style: TextStyle(color: Colors.white, fontSize: 23),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, size: 25,),
          onPressed: () => Navigator.of(context).pushReplacement(HomeScreen()),
        ),
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
                                  Text('${_patient["data"]["age"]}Y ${_patient["data"]["gender"].toUpperCase()}', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),),
                                  SizedBox(width: 10,),
                                  Text('NID: ${_patient["data"]["nid"]}', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),),
                                  SizedBox(width: 10,),
                                  Text('PID: N-213452351', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),),
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
                                          child: Text('Last encounter on Jan 5, 2019', style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)
                                        )
                                      ],
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () => Navigator.of(context).push(new NewEncounterScreen()),
                                      child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      padding: EdgeInsets.only(bottom: 17, top: 17),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(width: .5, color: Colors.black38)
                                        )
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.add, color: kPrimaryColor, size: 30,),
                                          SizedBox(width: 20),
                                          Text('Create a New Assessment', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
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
                                          Text('View Past Assessments', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
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
                                          child: Text('Health Assessments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
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
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.add, color: kPrimaryColor, size: 30,),
                                          SizedBox(width: 20),
                                          Text('Create a New Health Report', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
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
                                          Text('View Past Health Reports', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: kPrimaryColor), textAlign: TextAlign.right,)
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
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0.0, 1.0,)
                                ),
                              ]
                            ),
                            child: Card(
                              elevation: 0,
                              child: FlatButton(
                                onPressed: () => Navigator.of(context).push(CarePlanListScreen()),
                                child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset('assets/images/care_plan.png'),
                                              SizedBox(width: 20,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Care Plan', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w600),),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    children: <Widget>[
                                                      Image.asset('assets/images/dot_red.png'),
                                                      SizedBox(width: 7,),
                                                      Text('3 Actions Pending', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),)
                                                    ],
                                                  ),
                                                  
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            child: Icon(Icons.chevron_right, size: 40, color: kPrimaryColor,),
                                          )
                                        )
                                      ],
                                    ),
                                  ),  

                                ],
                              )
                              )
                            ),
                          ),
                          SizedBox(height: 30,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),



/*
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 40, right: 40),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 40,),
                        Text('Patient Records', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10,),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text('Name: ', style: TextStyle(fontSize: 20, height: 1.5),),
                                  Text('Demo Name', style: TextStyle(fontSize: 20, height: 1.5))
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Age: ', style: TextStyle(fontSize: 20, height: 1.5),),
                                  Text('60 Years', style: TextStyle(fontSize: 20, height: 1.5))
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Patient ID: ', style: TextStyle(fontSize: 20, height: 1.5),),
                                  Text('PA457897', style: TextStyle(fontSize: 20, height: 1.5))
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                children: <Widget>[
                                  Text('Registered: ', style: TextStyle(fontSize: 20, height: 1.5),),
                                  Text('20/10/2017', style: TextStyle(fontSize: 20, height: 1.5))
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Last Encounter: ', style: TextStyle(fontSize: 20),),
                                  Text('01/10/2017', style: TextStyle(fontSize: 20))
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 100,),
                        Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              onPressed: () => Navigator.push(context, 
                                MaterialPageRoute(builder: (ctx) => NewEncounterScreen())
                              ),
                              child: Text("Create Screening Encounter", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              onPressed: () {},
                              child: Text("View Previous Encounter", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              onPressed: () {},
                              child: Text("Health Assessments", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              onPressed: () {},
                              child: Text("Care Plan", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}

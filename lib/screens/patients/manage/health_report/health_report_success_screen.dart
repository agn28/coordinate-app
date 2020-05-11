import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/home_screen.dart';

class HealthReportSuccessScreen extends CupertinoPageRoute {
  HealthReportSuccessScreen()
      : super(builder: (BuildContext context) => new HealthReportSuccess());

}

class HealthReportSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(left: 40, right: 40),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50,),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: kSuccessColor,
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.done, size: 80, color: Colors.white,)
                  ),
                  SizedBox(height: 30,),
                  Text('Health Assessment Created', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 40,),
                  Text(Helpers().getPatientName(Patient().getPatient()), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,)),
                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(Helpers().getPatientAgeAndGender(Patient().getPatient()), style: TextStyle(fontSize: 16,)),
                      SizedBox(width: 30,),
                      Text('PID: N-121233333', style: TextStyle(fontSize: 16,)),
                    ],
                  ),
                  SizedBox(height: 20,),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/patientOverview');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Patient Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: kPrimaryColor),),
                        Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/patientSearch');
                    },
                    child: Container(
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
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset('assets/images/care_plan.png'),
                                        SizedBox(width: 20,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text('Patients', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w600),),
                                            
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
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
                    },
                    child: Container(
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
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset('assets/images/care_plan.png'),
                                        SizedBox(width: 20,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text('Go to Home', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w600),),
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
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

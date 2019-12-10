import 'package:flutter/material.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-test/blood_test_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/body-measurements/measurements_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaire_screen.dart';
import './blood-pressure/add_blood_pressure_screen.dart';

class NewObservationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Observations'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  Text('Enter Observations (Tap to enter)', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10,),
                  Text('Select encounter type', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 50,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              color: Colors.grey,
                              onPressed: () => Navigator.of(context).push(AddBloodPressureScreen()
                              ),
                              child: Text("Blood Pressure", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 60,),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              color: Colors.grey,
                              onPressed: () => Navigator.of(context).push(MeasurementsScreen()
                              ),
                              child: Text("Body Measurements", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 60,),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              color: Colors.grey,
                              onPressed: () => Navigator.of(context).push(BloodTestScreen()
                              ),
                              child: Text("Blood Tests", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 60,),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              color: Colors.grey,
                              onPressed: () => Navigator.of(context).push(QuestionnaireScreen()),
                              child: Text("Questionnaire", style: TextStyle(color: Colors.white, fontSize: 22),),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 60,),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 80,),
                  Container(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        fillColor: Color(0xFFeff0f1),
                        filled: true,
                        hintText: 'Comments/Notes (Optional)',
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    )
                  ),
                  
                  SizedBox(height: 50,),
                  
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: 200,
                      height: 60.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 22),),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

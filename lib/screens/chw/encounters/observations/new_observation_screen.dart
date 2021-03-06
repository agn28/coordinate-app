import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-test/blood_test_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/body-measurements/measurements_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaires_screen.dart';
import './blood-pressure/add_blood_pressure_screen.dart';

class NewObservationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('observations')),
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
                  Text(AppLocalizations.of(context).translate('enterObservations'), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10,),
                  Text(AppLocalizations.of(context).translate("selectEncounterType"), style: TextStyle(fontSize: 20)),
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
                              child: Text(AppLocalizations.of(context).translate('bloodPressure'), style: TextStyle(color: Colors.white, fontSize: 22),),
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
                              child: Text(AppLocalizations.of(context).translate('bodyMeasurements'), style: TextStyle(color: Colors.white, fontSize: 22),),
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
                              child: Text(AppLocalizations.of(context).translate('bloodTests'), style: TextStyle(color: Colors.white, fontSize: 22),),
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
                              onPressed: () => Navigator.of(context).push(QuestionnairesScreen()),
                              child: Text(AppLocalizations.of(context).translate('questionnaire'), style: TextStyle(color: Colors.white, fontSize: 22),),
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
                        hintText: AppLocalizations.of(context).translate('comments'),
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
                        child: Text(AppLocalizations.of(context).translate('done'), style: TextStyle(color: Colors.white, fontSize: 22),),
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

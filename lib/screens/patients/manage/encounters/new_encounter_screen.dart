import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-test/blood_test_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/body-measurements/measurements_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaires_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/encounter_details_screen.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class NewEncounterScreen extends CupertinoPageRoute {

  EncounterDetailsState encounterDetailsState;
  NewEncounterScreen({this.encounterDetailsState})
      : super(builder: (BuildContext context) => new NewEncounter(encounterDetailsState: encounterDetailsState));

}

class NewEncounter extends StatefulWidget {
  EncounterDetailsState encounterDetailsState;
  NewEncounter({this.encounterDetailsState});
  @override
  _NewEncounterState createState() => _NewEncounterState();
}

class _NewEncounterState extends State<NewEncounter> {
  String selectedType = 'In-clinic Screening';
  final commentController = TextEditingController();
  bool _dataSaved = false;

  @override
  void initState() {
    super.initState();
    BloodPressure().removeDeleteIds();
    if (Assessment().getSelectedAssessment() != {}) {
      setState(() {
        commentController.text = Assessment().getSelectedAssessment()['data'] != null ? Assessment().getSelectedAssessment()['data']['comment'] : '';
        var type = Assessment().getSelectedAssessment()['data'] != null ? Assessment().getSelectedAssessment()['data']['type'] : 'in-clinic';
        print(type);
        selectedType = type == 'in-clinic' ? 'In-clinic Screening' : 'Home Visit';
      });
    }
  }

  _changeType(value) {
    setState(() {
      selectedType = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('createNewAssessment'), style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 17, horizontal: 10),
                decoration: BoxDecoration(
                color: Colors.white,
                  boxShadow: [BoxShadow(
                    blurRadius: 20.0,
                    color: Colors.black,
                    offset: Offset(0.0, 1.0)
                  )]
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Patient().getPatient()['data']['avatar'] == null ? Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: kLightPrimaryColor,
                                shape: BoxShape.circle
                              ),
                              child: Icon(Icons.perm_identity),
                            ) :
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.file(
                                File(Patient().getPatient()['data']['avatar']),
                                height: 35.0,
                                width: 35.0,
                              ),
                            ),
                            SizedBox(width: 15,),
                            Text(Helpers().getPatientName(Patient().getPatient()), style: TextStyle(fontSize: 18))
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(Helpers().getPatientAgeAndGender(Patient().getPatient()), style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
                    ),
                    Expanded(
                      child: Text('PID: N-121933421', style: TextStyle(fontSize: 18))
                    )
                  ],
                ),
              ),

              Container(
                height: 90,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 40),
                decoration: BoxDecoration(
                  color: Color(0xFFF9F9F9),
                  border: Border(
                    bottom: BorderSide(width: .5, color: Color(0x50000000))
                  )
                ),
                child: Text(AppLocalizations.of(context).translate('completeAllSections'), style: TextStyle(fontSize: 20),)
              ),

              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    EncounnterSteps(
                      icon: Image.asset('assets/images/icons/blood_pressure.png'),
                      text: Text('Blood Pressure', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                      status: Helpers().getBpStatus(),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.of(context).push(AddBloodPressureScreen());
                      }
                    ),
                    EncounnterSteps(
                      icon: Image.asset('assets/images/icons/body_measurements.png'),
                      text: Text('Body Measurements', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                      status: Helpers().getBmStatus(),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.of(context).push(MeasurementsScreen());
                      }
                    ),

                    EncounnterSteps(
                      icon: Image.asset('assets/images/icons/blood_test.png'),
                      text: Text('Blood Test', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                      status: Helpers().getBtStatus(),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.of(context).push(BloodTestScreen());
                      }
                    ),

                    EncounnterSteps(
                      icon: Image.asset('assets/images/icons/questionnaire.png'),
                      text: Text('Questionnaire', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                      status: Helpers().getQnStatus(),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.of(context).push(QuestionnairesScreen());
                      }
                    ),
                  ],
                )
              ),

              SizedBox(height: 30,),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                  controller: commentController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 20, right: 20),
                    filled: true,
                    fillColor: kSecondaryTextField,
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      )
                    ),

                    hintText: AppLocalizations.of(context).translate('comments'),
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                  ),
                )
              ),

              SizedBox(height: 30,),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: <Widget>[
                    Text('Encounter Type', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                    SizedBox(width: 20,),
                    Radio(
                      value: 'In-clinic Screening',
                      groupValue: selectedType,
                      activeColor: kPrimaryColor,
                      onChanged: (value) {
                        _changeType(value);
                      },
                    ),
                    Text(AppLocalizations.of(context).translate("clinincScreening"), style: TextStyle(color: Colors.black)),

                    Radio(
                      value: 'Home Visit',
                      activeColor: kPrimaryColor,
                      groupValue: selectedType,
                      onChanged: (value) {
                        _changeType(value);
                      },
                    ),
                    Text(
                      "Home Visit",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30,),
            ],
          ),
        ),
      ),

      
      bottomNavigationBar: Container(
        height: 120,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: .5, color: Color(0xFF50000000))
          )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black45,),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(AppLocalizations.of(context).translate("cancel"), style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                ),
              )
            ),
            SizedBox(width: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FlatButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return Dialog(
                          elevation: 0.0,
                          backgroundColor: Colors.transparent,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: 30, left: 30, right: 30),
                            height: 230.0,
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('confirmSave'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                SizedBox(height: 20,),
                                Text(AppLocalizations.of(context).translate('missingSections'),
                                  style: TextStyle(fontSize: 18, height: 1.5),
                                ),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 30),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500),)
                                          ),
                                          SizedBox(width: 30,),
                                          GestureDetector(
                                            onTap: () async {
                                              var result = '';
                                              if (Assessment().getSelectedAssessment().isEmpty) {
                                                result = await AssessmentController().create(selectedType, commentController.text);
                                              } else {
                                                result = await AssessmentController().update(selectedType, commentController.text);
                                              }

                                              if (result == 'success') {
                                                _dataSaved = true;
                                                _scaffoldKey.currentState.showSnackBar(
                                                  SnackBar(
                                                    content: Text(AppLocalizations.of(context).translate('dataSaved')),
                                                    backgroundColor: Color(0xFF4cAF50),
                                                  )
                                                );
                                                Navigator.of(context).pop();

                                                if (widget.encounterDetailsState != null) {
                                                  widget.encounterDetailsState.setState(() async {
                                                    await widget.encounterDetailsState.getObservations();
                                                  });
                                                }
                                                
                                              } else {
                                                Navigator.of(context).pop();
                                                _scaffoldKey.currentState.showSnackBar(
                                                  SnackBar(
                                                    content: Text(result.toString()),
                                                    backgroundColor: kPrimaryRedColor,
                                                  )
                                                );
                                              }
                                            },
                                            child: Text(AppLocalizations.of(context).translate('save'), style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500))
                                          ),
                                        ],
                                      )
                                    )
                                  ],
                                )
                              ],
                            )
                          )

                        );
                      },
                    );
                    if (_dataSaved) {
                      await Future.delayed(const Duration(seconds: 1));
                      Navigator.pop(context);
                    }
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(Assessment().getSelectedAssessment().isNotEmpty ? AppLocalizations.of(context).translate('updateAssessment') : AppLocalizations.of(context).translate('saveAssessment'),
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)
                ),
              )
            ))
          ],
        )
      )
    );
  }
}

class EncounnterSteps extends StatelessWidget {
   EncounnterSteps({this.text, this.onTap, this.icon, this.status});

   final Text text;
   final Function onTap;
   final Image icon;
   final String status;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onTap,
      child: Container(
        // padding: EdgeInsets.only(left: 20, right: 20),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: .5, color: Color(0x40000000))
          )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: icon,
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: text,
              )
            ),
            Expanded(
              flex: 2,
              child: Text(status, style: TextStyle(
                color: status == 'Complete' ? kPrimaryGreenColor : kPrimaryRedColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),),
            ),
            
            Expanded(
              flex: 1,
              child: Container(
                child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 50,),
              ),
            )
          ],
        )
      )
    );
  }
}


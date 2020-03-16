import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/alcohol_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/current_medication_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/diet_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/medical_history_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/physical_activity_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/tobacco_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class QuestionnairesScreen extends CupertinoPageRoute {
  QuestionnairesScreen()
      : super(builder: (BuildContext context) => new Questionnaires());

}

class Questionnaires extends StatefulWidget {

  @override
  _QuestionnairesState createState() => _QuestionnairesState();
}

class _QuestionnairesState extends State<Questionnaires> {

  bool avatarExists = false;

  @override
  void initState() {
    super.initState();
    _checkAvatar();
  }

  _checkAvatar() async {
    var data = await File(Patient().getPatient()['data']['avatar']).exists();
    setState(() {
      avatarExists = data;
    });
  }

  _getStatus(type) {
    return BodyMeasurement().hasItem(type) ? 'Complete' : 'Incomplete';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Questionnaire', style: TextStyle(color: kPrimaryColor),),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
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
              child: Text('Complete all the sections that are applicable', style: TextStyle(fontSize: 22),)
            ),
            
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_pressure.png'),
                    text: 'Tobacco',
                    // goTo: TobaccoScreen(),
                    onTap: () {
                      // Navigator.of(context).push(TobaccoScreen(parent: ));
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_test.png'),
                    text: 'Alcohol',
                    onTap: () {
                      Navigator.of(context).push(AlcoholScreen());
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: 'Diet',
                    onTap: () {
                      Navigator.of(context).push(DietScreen());
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: 'Physical Activity',
                    onTap: () {
                      Navigator.of(context).push(PhysicalActivityScreen());
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: 'Current Medication',
                    onTap: () {
                      Navigator.of(context).push(CurrentMedicationScreen());
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: 'Medical History',
                    onTap: () {
                      Navigator.of(context).push(MedicalHistoryScreen());
                    },
                  ),
                ],
              )
            ),

            SizedBox(height: 30,),

            SizedBox(height: 30,),
          ],
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
                  border: Border.all(width: 1, color: Colors.black54),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FlatButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return SkipAlert();
                      },
                    );
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('UNABLE TO PERFORM', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('SAVE', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                ),
              )
            )
          ],
        )
      )
    );
  }
}

class EncounnterSteps extends StatefulWidget {
   EncounnterSteps({this.text, this.onTap, this.icon});

  final String text;
  final Function onTap;
  final Image icon;


  @override
  EncounnterStepsState createState() => EncounnterStepsState();
}

class EncounnterStepsState extends State<EncounnterSteps> {
  String status = 'Incomplete';
  bool avatarExists = false;

  @override
  void initState() {
    super.initState();
    _checkAvatar();
    setStatus();
  }

  _checkAvatar() async {
    var data = await File(Patient().getPatient()['data']['avatar']).exists();
    setState(() {
      avatarExists = data;
    });
  }

  setStatus() {
    status = Questionnaire().isCompleted(widget.text) ? 'Complete' : 'Incomplete';
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        if (widget.text.toString() == 'Tobacco') {
          Navigator.of(context).push(TobaccoScreen(parent: this));
        } else if (widget.text.toString() == 'Alcohol') {
          Navigator.of(context).push(AlcoholScreen(parent: this));
        } else if (widget.text.toString() == 'Diet') {
          Navigator.of(context).push(DietScreen(parent: this));
        } else if (widget.text.toString() == 'Physical Activity') {
          Navigator.of(context).push(PhysicalActivityScreen(parent: this));
        } else if (widget.text.toString() == 'Medical History') {
          Navigator.of(context).push(MedicalHistoryScreen(parent: this));
        } else if (widget.text.toString() == 'Current Medication') {
          Navigator.of(context).push(CurrentMedicationScreen(parent: this));
        }
      },
      child: Container(
        // padding: EdgeInsets.only(left: 20, right: 20),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: .5, color: kBorderLight)
          )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: widget.icon,
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(widget.text, style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
              )
            ),
            Expanded(
              flex: 2,
              child: Text(status, style: TextStyle(color: status == 'Complete' ? kPrimaryGreenColor : kPrimaryRedColor, fontSize: 18, fontWeight: FontWeight.w500),),
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



class AddDialogue extends StatefulWidget {
  String title;
  String inputText;

  AddDialogue({this.title, inputText});

  @override
  _AddDialogueState createState() => _AddDialogueState();
}

class _AddDialogueState extends State<AddDialogue> {

   int selectedUnit;
   final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

   final valueController = TextEditingController();
   final deviceController = TextEditingController();
   final commentController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedUnit = 1;
  }

  _addItem() {
    String unit = _getUnit();
    BodyMeasurement().addItem(widget.title, valueController.text, unit, commentController != null ? commentController.text : "", deviceController.text);
    EncounnterStepsState().initState();
  }

  _getUnit() {
    if (widget.title == 'Weight') {
      return selectedUnit == 1 ? 'kg' : 'pound';
    }
    return selectedUnit == 1 ? 'cm' : 'inch';
  }

  _clearDialogForm() {
    valueController.clear();
    deviceController.clear();
    commentController.clear();
    selectedUnit = 1;
  }

  changeArm(val) {
    setState(() {
      selectedUnit = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30),
        height: 460.0,
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppLocalizations.of(context).translate('add') + widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
              Container(
                // margin: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: <Widget>[
                    // SizedBox(width: 20,),
                    Container(
                      width: 150,
                      child: PrimaryTextField(
                        hintText: widget.title,
                        topPaadding: 15,
                        bottomPadding: 15,
                        validation: true,
                        type: TextInputType.number,
                        controller: valueController,
                      ),
                    ),
                    Radio(
                      activeColor: kPrimaryColor,
                      value: 1,
                      groupValue: selectedUnit,
                      onChanged: (val) {
                        changeArm(val);
                      },
                    ),
                    Text(widget.title == 'Weight' ? 'kg' : 'cm', style: TextStyle(color: Colors.black)),

                    Radio(
                      activeColor: kPrimaryColor,
                      value: 2,
                      groupValue: selectedUnit,
                      onChanged: (val) {
                        changeArm(val);
                      },
                    ),
                    Text(
                      widget.title == 'Weight' ? 'pound' : 'inch',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: double.infinity,
                child: PrimaryTextField(
                  hintText: AppLocalizations.of(context).translate('selectDevice'),
                  topPaadding: 15,
                  bottomPadding: 15,
                  controller: deviceController,
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: double.infinity,
                child: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 20.0,),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  controller: commentController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 15.0, bottom: 25.0, left: 10, right: 10),
                    filled: true,
                    fillColor: kSecondaryTextField,
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      )
                    ),
                  
                    hintText: AppLocalizations.of(context).translate('comment'),
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                  ),
                )
              ),

              Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context).translate('unablePerform'), style: TextStyle(color: kPrimaryColor, fontSize: 18),)
                          ),
                        ),
                        SizedBox(width: 30,),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 18),)
                        ),
                        SizedBox(width: 30,),
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState.validate()) {
                              Navigator.of(context).pop();
                              _addItem();
                              _clearDialogForm();
                            }
                          },
                          child: Text(AppLocalizations.of(context).translate('add'), style: TextStyle(color: kPrimaryColor, fontSize: 18))
                        ),
                      ],
                    )
                  )
                ],
              )
            ],
          ),
        )
      )
      
    );
  }
}

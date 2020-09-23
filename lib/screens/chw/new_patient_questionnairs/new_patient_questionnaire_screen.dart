import 'package:basic_utils/basic_utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../custom-classes/custom_stepper.dart';

final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _causesFormKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final _temperatureController = TextEditingController();
final _systolicController = TextEditingController();
final _diastolicController = TextEditingController();
final _pulseController = TextEditingController();
final _glucoseController = TextEditingController();
final _deviceController = TextEditingController();
List causes = ['Fever', 'Shortness of breath', 'Feeling faint', 'Stomach discomfort'];
List issues = ['Vision', 'Smell', 'Mental Health', 'Other'];
List selectedCauses = [];
List selectedIssues = [];
final otherIssuesController = TextEditingController();
String selectedArm = 'left';
String selectedGlucoseType = 'fasting';
String selectedGlucoseUnit = 'mg/dL';

var _questions = {};
var medicalHistoryQuestions = {};
var medicalHistoryAnswers = [];
var medicationQuestions = {};
var medicationAnswers = [];
var riskQuestions = {};
var riskAnswers = [];
var answers = [];

int _firstQuestionOption = 1;
int _secondQuestionOption = 1;
int _thirdQuestionOption = 1;
int _fourthQuestionOption = 1;
bool isLoading = false;


class NewPatientQuestionnaireScreen extends StatefulWidget {

  static const path = '/newPatientQuestionnaire';
  @override
  _NewPatientQuestionnaireScreenState createState() => _NewPatientQuestionnaireScreenState();
}

class _NewPatientQuestionnaireScreenState extends State<NewPatientQuestionnaireScreen> {
  
  int _currentStep = 0;

  String nextText = 'NEXT';
  bool nextHide = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    clearForm();
    isLoading = false;

    prepareQuestions();
    prepareAnswers();
  }

  prepareQuestions() {
    medicalHistoryQuestions = Questionnaire().questions['new_patient']['medical_history'];
    medicationQuestions = Questionnaire().questions['new_patient']['medication'];
    riskQuestions = Questionnaire().questions['new_patient']['risk_factors'];
  }

  prepareAnswers() {
    medicalHistoryAnswers = [];
    medicationAnswers = [];
    riskAnswers = [];
    medicalHistoryQuestions['items'].forEach((qtn) {
      medicalHistoryAnswers.add('no');
    });
    medicationQuestions['items'].forEach((qtn) {
      medicationAnswers.add('no');
    });
    riskQuestions['items'].forEach((qtn) {
      riskAnswers.add('no');
    });
  }

  nextStep() {
    setState(() {
      if (_currentStep == 3) {
        _currentStep = _currentStep + 1;
        nextText = 'COMPLETE';
      } else if (_currentStep == 4) {
        checkData();
      } else {
        _currentStep = _currentStep + 1;
      }
    });
  }

  clearForm() {
    selectedCauses = [];
    selectedIssues = [];
    _temperatureController.text = '';
    _systolicController.text = '';
    _diastolicController.text = '';
    _pulseController.text = '';
    _glucoseController.text = '';
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } 
  }

  setLoader(value) {
    setState(() {
      isLoading = value;
    });
  }

  goToHome() {
    Navigator.of(context).pushNamed('/chwHome',);
  }

  checkData() async {
    int temp = 0;
    int systolic = 0;
    int diastolic = 0;
    int glucose = 0;

    var data = {
      'meta': {
        'patient_id': Patient().getPatient()['uuid'],
        "collected_by": Auth().getAuth()['uid'],
        "status": "pending"
      },
      'body': {
        'causes' : selectedCauses,
        'issues': selectedIssues,
        'blood_pressure': {
          'arm': selectedArm,
          'systolic': _systolicController.text,
          'diastolic': _diastolicController.text,
        },
        'fasting_glucose': {
          'type': selectedGlucoseType,
          'value': _glucoseController.text,
          'unit': selectedGlucoseUnit
        },
        'chest_pain': {
          'value': firstAnswer,
        },
        'weekness': {
          'value': secondAnswer,
        }
      }
    };
    if (_temperatureController.text != '') {
      temp = int.parse(_temperatureController.text);
    }
    if (_systolicController.text != '') {
      // print(_systolicController.text);
      systolic = int.parse(_systolicController.text);
    }
    if (_diastolicController.text != '') {
      diastolic = int.parse(_diastolicController.text);
    }
    if (_glucoseController.text != '') {
      glucose = int.parse(_glucoseController.text);
    }

    if (temp > 39 || glucose > 250 || systolic > 160 || diastolic > 100 || firstAnswer == 'yes' || secondAnswer == 'yes') {
      // var response = FollowupController().create(data);
      // print(response);
      // if (response['error'] != null && !response['error'])
        Navigator.of(context).pushReplacementNamed('/medicalRecommendation', arguments: data);
    } else {
      // var response = FollowupController().create(data);
      // print(response);
      // if (response['error'] != null && !response['error'])
        Navigator.of(context).pushReplacementNamed('/chwContinue');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('newPatientQuestionnaire')),
      ),
      body: !isLoading ? GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: CustomStepper(
          isHeader: false,
          physics: ClampingScrollPhysics(),
          type: CustomStepperType.horizontal,
          
          controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Row();
        },
          onStepTapped: (step) {
            setState(() {
              this._currentStep = step;
            });
          },
          steps: _mySteps(),
          currentStep: this._currentStep,
        ),
      ) : Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Color(0x90FFFFFF),
        child: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
        ),
      ),
      bottomNavigationBar: Container(
        color: kBottomNavigationGrey,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _currentStep != 0 ? FlatButton(
                onPressed: () {
                  
                  setState(() {
                    nextHide = false;
                    _currentStep = _currentStep - 1;
                    nextText = AppLocalizations.of(context).translate('next');
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.chevron_left),
                    Text(AppLocalizations.of(context).translate('back'), style: TextStyle(fontSize: 20)),
                  ],
                ),
              ) : Text('')
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _mySteps().length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.lens, size: 15, color: _currentStep == index ? kPrimaryColor : kStepperDot,)
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: _currentStep < _mySteps().length || nextHide ? FlatButton(
                onPressed: () {
                  setState(() {
                    print(_currentStep);
                    if (_currentStep == 0) {
                      Questionnaire().addNewMedicalHistory('medical_history', medicalHistoryAnswers);
                      print(Questionnaire().qnItems);
                    }

                    if (_currentStep == 1) {
                      Questionnaire().addNewMedication('medication', medicationAnswers);
                      print(Questionnaire().qnItems);
                    }

                    if (_currentStep == 2) {
                      Questionnaire().addNewRiskFactors('risk_factors', riskAnswers);
                      print(Questionnaire().qnItems);
                    }
                    if (nextText =='COMPLETE') {

                    }
                    if (_currentStep == 2) {
                      print('asdas');
                      print(_currentStep);
                      nextHide = true;
                      nextText = 'COMPLETE';
                    }
                    if (_currentStep < 4) {
                     
                        // If the form is valid, display a Snackbar.
                        _currentStep = _currentStep + 1;
                    }
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(nextText, style: TextStyle(fontSize: 20)),
                    Icon(Icons.chevron_right)
                  ],
                ),
              ) : Container()
            ),
          ],
        )
      ),
    );
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [
      CustomStep(
        title: Text('Causes', textAlign: TextAlign.center,),
        content: MedicalHistory(),
        isActive: _currentStep >= 0,
      ),
      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: Medication(),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: RiskFactors(),
        isActive: _currentStep >= 2,
      ),

      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: InitialCounselling(parent: this),
        isActive: _currentStep >= 3,
      ),
    ];

    if (Configs().configAvailable('isThumbprint')) {
      _steps.add(
        CustomStep(
          title: Text(AppLocalizations.of(context).translate('thumbprint')),
          content: Text(''),
          isActive: _currentStep >= 3,
        )
      );
    }
      
    return _steps;
  }

}

class MedicalHistory extends StatefulWidget {

  @override
  _MedicalHistoryState createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 20,),
            Container(
              // alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Text(AppLocalizations.of(context).translate('medicalHistory'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 35, top: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kBorderLighter)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...medicalHistoryQuestions['items'].map((question) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(question['question'],
                                  style: TextStyle(fontSize: 18, height: 1.7),
                                )
                              ),
                              SizedBox(height: 20,),
                              Container(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Row(
                                  children: <Widget>[
                                    ...question['options'].map((option) => 
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          margin: EdgeInsets.only(right: 20, left: 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 1, color: medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFF01579B) : Colors.black),
                                            borderRadius: BorderRadius.circular(3),
                                            color: medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFFE1F5FE) : null
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(question)] = question['options'][question['options'].indexOf(option)];
                                                print(medicalHistoryAnswers);
                                                // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                              });
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            child: Text(StringUtils.capitalize(option),
                                              style: TextStyle(color: medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? kPrimaryColor : null),
                                            ),
                                          ),
                                        )
                                      ),
                                    ).toList()
                                  ],
                                )
                              ),

                              SizedBox(height: 20,)
                            ],
                          );
                        }).toList()
                        
                      ],
                    )
                  ),

                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}


class Medication extends StatefulWidget {

  @override
  _MedicationState createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              // alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Text(AppLocalizations.of(context).translate('medicationTitle'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
            ),
            SizedBox(height: 20,),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 35, top: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kBorderLighter)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...medicationQuestions['items'].map((question) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(question['question'],
                                  style: TextStyle(fontSize: 18, height: 1.7),
                                )
                              ),
                              SizedBox(height: 20,),
                              Container(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Row(
                                  children: <Widget>[
                                    ...question['options'].map((option) => 
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          margin: EdgeInsets.only(right: 20, left: 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 1, color: medicationQuestions[medicationQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFF01579B) : Colors.black),
                                            borderRadius: BorderRadius.circular(3),
                                            color: medicationAnswers[medicationQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFFE1F5FE) : null
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                medicationAnswers[medicationQuestions['items'].indexOf(question)] = question['options'][question['options'].indexOf(option)];
                                                print(medicalHistoryAnswers);
                                                // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                              });
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            child: Text(StringUtils.capitalize(option),
                                              style: TextStyle(color: medicationAnswers[medicationQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? kPrimaryColor : null),
                                            ),
                                          ),
                                        )
                                      ),
                                    ).toList()
                                  ],
                                )
                              ),

                              SizedBox(height: 20,)
                            ],
                          );
                        }).toList()
                        
                      ],
                    )
                  ),

                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}


class RiskFactors extends StatefulWidget {

  @override
  _RiskFactorsState createState() => _RiskFactorsState();
}

class _RiskFactorsState extends State<RiskFactors> {
  

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              // alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Text(AppLocalizations.of(context).translate('riskFactors'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
            ),
            SizedBox(height: 20,),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 35, top: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kBorderLighter)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...riskQuestions['items'].map((question) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(question['question'],
                                  style: TextStyle(fontSize: 18, height: 1.7),
                                )
                              ),
                              SizedBox(height: 20,),
                              Container(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Row(
                                  children: <Widget>[
                                    ...question['options'].map((option) => 
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          margin: EdgeInsets.only(right: 20, left: 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 1, color: riskAnswers[riskQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFF01579B) : Colors.black),
                                            borderRadius: BorderRadius.circular(3),
                                            color: riskAnswers[riskQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFFE1F5FE) : null
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                riskAnswers[riskQuestions['items'].indexOf(question)] = question['options'][question['options'].indexOf(option)];
                                                // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                              });
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            child: Text(StringUtils.capitalize(option),
                                              style: TextStyle(color: riskAnswers[riskQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? kPrimaryColor : null),
                                            ),
                                          ),
                                        )
                                      ),
                                    ).toList()
                                  ],
                                )
                              ),

                              SizedBox(height: 20,)
                            ],
                          );
                        }).toList()
                        
                      ],
                    )
                  ),

                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

class InitialCounselling extends StatefulWidget {
  _NewPatientQuestionnaireScreenState parent;
  InitialCounselling({this.parent});
  @override
  _InitialCounsellingState createState() => _InitialCounsellingState();
}

class _InitialCounsellingState extends State<InitialCounselling> {
  

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              // alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Text('Based on patients responses, the patient requires advice in the following areas.', style: TextStyle(fontSize: 18,),),
            ),
            SizedBox(height: 20,),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 35, top: 20),
                    decoration: BoxDecoration(
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: ExpandableNotifier(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
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
                                          padding: EdgeInsets.only(top:10, left: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Smoking Cessation',
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                              ),
                                            ],
                                          ),
                                        ),
                                        expanded: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 10,),
                                            Row(
                                              children: <Widget>[
                                                Checkbox(
                                                  activeColor: kPrimaryColor,
                                                  value: false,
                                                  onChanged: (value) {
                                         
                                                  },
                                                ),
                                                Text('Provide material on harms of smoking', style: TextStyle(color: Colors.black, fontSize: 18)),
                                              ],
                                            ),

                                            Row(
                                              children: <Widget>[
                                                Checkbox(
                                                  activeColor: kPrimaryColor,
                                                  value: true,
                                                  onChanged: (value) {
                                         
                                                  },
                                                ),
                                                Text('Discuss strategis to stop smoking', style: TextStyle(color: Colors.black, fontSize: 18)),
                                              ],
                                            ),

                                            SizedBox(height: 20,),

                                            Text('Counselling was given to patients?', style: TextStyle(color: Colors.black, fontSize: 18)),

                                            SizedBox(height: 20,),
                                            Container(
                                              width: MediaQuery.of(context).size.width * .5,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      height: 40,
                                                      margin: EdgeInsets.only(right: 20, left: 0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(width: 1, color:  kPrimaryColor),
                                                        borderRadius: BorderRadius.circular(3),
                                                        color:  Color(0xFFE1F5FE)
                                                      ),
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                          });
                                                        },
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        child: Text('YES',
                                                          style: TextStyle(color:  kPrimaryColor),
                                                        ),
                                                      ),
                                                    )
                                                  ),

                                                  Expanded(
                                                    child: Container(
                                                      height: 40,
                                                      margin: EdgeInsets.only(right: 20, left: 0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(width: 1, color:  Colors.black),
                                                        borderRadius: BorderRadius.circular(3),
                                                        color:  null
                                                      ),
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                          });
                                                        },
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        child: Text('NO',
                                                          style: TextStyle(color:  null),
                                                        ),
                                                      ),
                                                    )
                                                  ),
                                                ],
                                              )
                                            ),

                                            SizedBox(height: 20,),
                                          
                                            
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
                          ),
                        ),

                        SizedBox(height: 30,),
                        
                        Container(
                          child: ExpandableNotifier(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
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
                                          padding: EdgeInsets.only(top:10, left: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Diet',
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                              ),
                                            ],
                                          ),
                                        ),
                                        expanded: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            

                                            SizedBox(height: 20,),
                                          
                                            
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
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          child: ExpandableNotifier(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
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
                                          padding: EdgeInsets.only(top:10, left: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Physical Activity',
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                              ),
                                            ],
                                          ),
                                        ),
                                        expanded: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            

                                            SizedBox(height: 20,),
                                          
                                            
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
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          child: ExpandableNotifier(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
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
                                          padding: EdgeInsets.only(top:10, left: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Medication Adherence',
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                              ),
                                            ],
                                          ),
                                        ),
                                        expanded: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            

                                            SizedBox(height: 20,),
                                          
                                            
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
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          child: ExpandableNotifier(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
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
                                          padding: EdgeInsets.only(top:10, left: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Alcohol Reduction',
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                              ),
                                            ],
                                          ),
                                        ),
                                        expanded: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            
                                            SizedBox(height: 20,),
                                          
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
                          ),
                        ),
                        
                      
                        SizedBox(height: 50,),

                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(3)
                                ),
                                child: FlatButton(
                                  onPressed: () async {

                                    widget.parent.setLoader(true);

                                    var response = await AssessmentController().createOnlyAssessment('new patient questionnaire', '', '');
                                    
                                    widget.parent.setLoader(false);
                                    print('response');
                                    print(response);

                                    widget.parent.goToHome();
                                    
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: Text(AppLocalizations.of(context).translate('completeQuestionnaire').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),

                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}




class Temperature extends StatefulWidget {
  Temperature({this.parent});
  final parent;

  @override
  _TemperatureState createState() => _TemperatureState();
}

class _TemperatureState extends State<Temperature> {
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text('What is patient\'s temperature?', style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: PrimaryTextField(
                hintText: AppLocalizations.of(context).translate('tempReading'),
                controller: _temperatureController,
                topPaadding: 10,
                bottomPadding: 10,
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {
                widget.parent.nextStep();
              },
              child: Container(
                // margin: EdgeInsets.symmetric(horizontal: 30),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context).translate('skipDeviceUnavailable'), style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500,)),
              ),
            )

          ],
        ),
      )
    );
  }
}

class BloodPressure extends StatefulWidget {
  BloodPressure({this.parent});
  final parent;

  @override
  _BloodPressureState createState() => _BloodPressureState();
}

class _BloodPressureState extends State<BloodPressure> {
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text('What is blood pressure?', style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 170),
              width: 300,
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'left',
                    groupValue: selectedArm,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedArm = value;
                      });
                    },
                  ),
                  Text('Left Arm', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 30,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'right',
                    groupValue: selectedArm,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedArm = value;
                      });
                    },
                  ),
                  Text('Right Arm', style: TextStyle(color: Colors.black)),
                ],
                  ),
            ),
            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 170),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 20,),
                  Expanded(
                    child: PrimaryTextField(
                      hintText: AppLocalizations.of(context).translate('systolic'),
                      controller: _systolicController,
                      topPaadding: 10,
                      bottomPadding: 10,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text('/', style: TextStyle(fontSize: 20),),
                  SizedBox(width: 10,),
                  Expanded(
                    child: PrimaryTextField(
                      hintText: AppLocalizations.of(context).translate('diastolic'),
                      controller: _diastolicController,
                      topPaadding: 10,
                      bottomPadding: 10,
                    ),
                  ),
                ],
                  ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 240),
              alignment: Alignment.center,
              child: PrimaryTextField(
                hintText: 'Pulse Rate',
                controller: _pulseController,
                topPaadding: 10,
                bottomPadding: 10,
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {
                widget.parent.nextStep();
              },
              child: Container(
                // margin: EdgeInsets.symmetric(horizontal: 30),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context).translate('skipDeviceUnavailable'), style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500,)),
              ),
            )

          ],
        ),
      )
    );
  }
}

class AcuteIssues extends StatefulWidget {
  AcuteIssues({this.parent});
  final parent;

  @override
  _AcuteIssuesState createState() => _AcuteIssuesState();
}

var firstQuestionText = 'Are you having any pain or discomfort or pressure or heaviness in your chest?';
var secondQuestionText = 'Are you having any difficulty in talking, or any weakness or numbness of arms, legs or face?';
var firstQuestionOptions = ['yes', 'no'];
var secondQuestionOptions = ['yes', 'no'];

var firstAnswer = 'no';
var secondAnswer = 'no';

class _AcuteIssuesState extends State<AcuteIssues> {

  List devices = [];

  

  var selectedDevice = 0;

  @override
  initState() {
    super.initState();
    firstAnswer = 'no';
    secondAnswer = 'no';

    devices = Device().getDevices();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              padding: EdgeInsets.only(bottom: 35, top: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kBorderLighter)
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                    // child: Text(_questions['items'][0]['question'],
                    child: Text(firstQuestionText,
                      style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                    width: MediaQuery.of(context).size.width * .5,
                    child: Row(
                      children: <Widget>[
                        ...firstQuestionOptions.map((option) => 
                          Expanded(
                            child: Container(
                              height: 40,
                              margin: EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                // border: Border.all(width: 1, color:  Color(0xFF01579B)),
                                border: Border.all(width: 1, color: firstAnswer == option ? Color(0xFF01579B) : Colors.black),
                                borderRadius: BorderRadius.circular(3),
                                color: firstAnswer == option ? Color(0xFFE1F5FE) : null
                                // color: Color(0xFFE1F5FE) 
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    firstAnswer = option;
                                  });
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(option.toUpperCase(),
                                  style: TextStyle(color: firstAnswer == option ? kPrimaryColor : null),
                                  // style: TextStyle(color: kPrimaryColor),
                                ),
                              ),
                            )
                          ),
                        ).toList()
                      ],
                    )
                  ),

                  SizedBox(height: 30,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                    // child: Text(_questions['items'][0]['question'],
                    child: Text(secondQuestionText,
                      style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                    width: MediaQuery.of(context).size.width * .5,
                    child: Row(
                      children: <Widget>[
                        ...secondQuestionOptions.map((option) => 
                          Expanded(
                            child: Container(
                              height: 40,
                              margin: EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                // border: Border.all(width: 1, color:  Color(0xFF01579B)),
                                border: Border.all(width: 1, color: secondAnswer == option ? Color(0xFF01579B) : Colors.black),
                                borderRadius: BorderRadius.circular(3),
                                color: secondAnswer == option ? Color(0xFFE1F5FE) : null
                                // color: Color(0xFFE1F5FE) 
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    secondAnswer = option;
                                  });
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(option.toUpperCase(),
                                  style: TextStyle(color: secondAnswer == option ? kPrimaryColor : null),
                                  // style: TextStyle(color: kPrimaryColor),
                                ),
                              ),
                            )
                          ),
                        ).toList()
                      ],
                    )
                  ),

                ],
              )
            ),
          ],
        ),
      )
    );
  }
}


class Glucose extends StatefulWidget {
  Glucose({this.parent});
  final parent;

  @override
  _GlucoseState createState() => _GlucoseState();
}

class _GlucoseState extends State<Glucose> {

  List devices = [];

  var selectedDevice = 0;

  @override
  initState() {
    super.initState();

    devices = Device().getDevices();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text('What is blood glucose level?', style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              width: 300,
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'fasting',
                    groupValue: selectedGlucoseType,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedGlucoseType = value;
                      });
                    },
                  ),
                  Text(AppLocalizations.of(context).translate('fasting'), style: TextStyle(color: Colors.black)),
                  SizedBox(width: 30,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'random',
                    groupValue: selectedGlucoseType,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedGlucoseType = value;
                      });
                    },
                  ),
                  Text(AppLocalizations.of(context).translate('random'), style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 20,),
                  Expanded(
                    child: PrimaryTextField(
                      hintText: 'Fasting Glucose',
                      controller: _glucoseController,
                      topPaadding: 10,
                      bottomPadding: 10,
                    ),
                  ),
                  SizedBox(width: 20,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'mg/dL',
                    groupValue: selectedGlucoseUnit,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedGlucoseUnit = value;
                      });
                    },
                  ),
                  Text('mg/dL', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 20,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'mmol/L',
                    groupValue: selectedGlucoseUnit,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedGlucoseUnit = value;
                      });
                    },
                  ),
                  Text('mmol/L', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
            Container(
              color: kSecondaryTextField,
              margin: EdgeInsets.symmetric(horizontal: 100),
              child: DropdownButtonFormField(
                hint: Text('Select Device', style: TextStyle(fontSize: 20, color: kTextGrey),),
                decoration: InputDecoration(
                  fillColor: kSecondaryTextField,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  border: UnderlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  )
                ),
                ),
                items: [
                  ...devices.map((item) =>
                    DropdownMenuItem(
                      child: Text(item['name']),
                      value: devices.indexOf(item)
                    )
                  ).toList(),
                ],
                value: selectedDevice,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedDevice = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: () {
                widget.parent.nextStep();
              },
              child: Container(
                // margin: EdgeInsets.symmetric(horizontal: 30),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context).translate('skipDeviceUnavailable'), style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500,)),
              ),
            )

          ],
        ),
      )
    );
  }
}

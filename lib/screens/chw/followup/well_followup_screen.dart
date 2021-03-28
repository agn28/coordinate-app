import 'package:basic_utils/basic_utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';
import 'package:nhealth/screens/chw/unwell/create_referral_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_patient_summary_screen.dart';
import 'package:nhealth/screens/chw/unwell/medical_recomendation_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../custom-classes/custom_stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _temperatureController = TextEditingController();
final _systolicController = TextEditingController();
final _diastolicController = TextEditingController();
final _pulseController = TextEditingController();
final _glucoseController = TextEditingController();
List causes = ['Fever', 'Shortness of breath', 'Feeling faint', 'Stomach discomfort'];
List issues = ['Vision', 'Smell', 'Mental Health', 'Other'];
List selectedCauses = [];
List selectedIssues = [];
final otherIssuesController = TextEditingController();
String selectedArm = 'left';
String selectedGlucoseType = 'fasting';
String selectedGlucoseUnit = 'mg/dL';

var medicalHistoryQuestions = {};
var medicalHistoryAnswers = [];
var medicationQuestions = {};
var medicationAnswers = [];
var riskQuestions = {};
var relativeQuestions = {};
var counsellingQuestions = {};
var riskAnswers = [];
var relativeAnswers = [];
var counsellingAnswers = [];
var answers = [];
var authUser = {};

bool isLoading = false;

getQuestionText(context, question) {
  var locale = Localizations.localeOf(context);

  if (locale == Locale('bn', 'BN')) {
    print('true');
    return question['question_bn'];
  }
  return question['question'];
}

getOptionText(context, question, option) {
  var locale = Localizations.localeOf(context);

  if (locale == Locale('bn', 'BN')) {
    if (question['options_bn'] != null) {
      return question['options_bn'][question['options'].indexOf(option)];
    }
    return option;
    
  }
  return StringUtils.capitalize(option);
}


class WellFollowupScreen extends StatefulWidget {

  static const path = '/wellFollowupVisit';
  @override
  _WellFollowupScreenState createState() => _WellFollowupScreenState();
}

class _WellFollowupScreenState extends State<WellFollowupScreen> {
  
  int _currentStep = 0;

  String nextText = 'NEXT';
  bool nextHide = false;

  @override
  void initState() {
    super.initState();
    print('asd');
    _checkAuth();
    clearForm();
    isLoading = false;

    getAuth();
    
    
    // print(Language().getLanguage());

    prepareQuestions();
    prepareAnswers();

    getLanguage();
  }
  getAuth() async {
    var data = await Auth().getStorageAuth();
    setState(() {
      authUser = data;
    });
  }

  getLanguage() async {
    print('language s');
    final prefs = await SharedPreferences.getInstance();

    print(Localizations.localeOf(context));
  }

  

  prepareQuestions() {
    medicalHistoryQuestions = Questionnaire().questions['new_patient']['medical_history'];
    medicationQuestions = Questionnaire().questions['new_patient']['medication'];
    riskQuestions = Questionnaire().questions['new_patient']['risk_factors'];
    relativeQuestions = Questionnaire().questions['new_patient']['relative_problems'];
    counsellingQuestions = Questionnaire().questions['new_patient']['counselling_provided'];
  }

  prepareAnswers() {
    medicalHistoryAnswers = [];
    medicationAnswers = [];
    riskAnswers = [];
    counsellingAnswers = [];
    medicalHistoryQuestions['items'].forEach((qtn) {
      medicalHistoryAnswers.add('');
    });
    medicationQuestions['items'].forEach((qtn) {
      medicationAnswers.add('');
    });
    counsellingQuestions['items'].forEach((qtn) {
      counsellingAnswers.add('');
    });
    riskQuestions['items'].forEach((qtn) {
      riskAnswers.add('');
    });
    relativeQuestions['items'].forEach((qtn) {
      relativeAnswers.add('');
    });
  }

  nextStep() {
    setState(() {
      if (_currentStep == 1) {
        _currentStep = _currentStep + 1;
        nextText = 'COMPLETE';
      } else if (_currentStep == 3) {
        print("sttep3");
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
    systolicEditingController.text = '';
    diastolicEditingController.text = '';
    pulseRateEditingController.text = '';

    randomBloodController.text = '';
    fastingBloodController.text = '';
    habfController.text = '';
    hba1cController.text = '';
    cholesterolController.text = '';
    ldlController.text = '';
    hdlController.text = '';
    tgController.text = '';
    creatinineController.text = '';
    sodiumController.text = '';
    potassiumController.text = '';
    ketonesController.text = '';
    proteinController.text = '';

    occupationController.text = '';
    incomeController.text = '';
    educationController.text = '';

    selectedRandomBloodUnit = 'mg/dL';
    selectedFastingBloodUnit = 'mg/dL';
    selectedHabfUnit = 'mg/dL';
    selectedHba1cUnit = 'mg/dL';
    selectedCholesterolUnit = 'mg/dL';
    selectedLdlUnit = 'mg/dL';
    selectedHdlUnit = 'mg/dL';
    selectedTgUnit = 'mg/dL';
    selectedCreatinineUnit = 'mg/dL';
    selectedSodiumUnit = 'mg/dL';
    selectedPotassiumUnit = 'mg/dL';
    selectedKetonesUnit = 'mg/dL';
    selectedProteinUnit = 'mg/dL';
    nextVisitDate = '';
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

  goToHome(recommendation, data) {
    print('after complete');
    
    if (recommendation) {
      Navigator.of(context).pushReplacementNamed(MedicalRecommendationScreen.path, arguments: data);
    } else {
      if (authUser['role'] == 'chw') {
        print('into chw');
        Navigator.of(context).pushNamed('/chwPatientSummary');
        return;
      }
      print('into nurse');
      Navigator.of(context).pushNamed('/home',);
    }
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

  createObservations() {

    print('_currentStep $_currentStep');
    if (diastolicEditingController.text != '' && systolicEditingController.text != '') {
      BloodPressure().addItem('left', int.parse(systolicEditingController.text), int.parse(diastolicEditingController.text), int.parse(pulseRateEditingController.text), null);
      var formData = {
        'items': BloodPressure().items,
        'comment': '',
        'patient_id': Patient().getPatient()['uuid'],
        'device': '',
        'performed_by': '',
      };
      
      BloodPressure().addBloodPressure(formData);
    }

    BodyMeasurement().addBmItem();

    if (randomBloodController.text != '') {
      BloodTest().addItem('blood_sugar', randomBloodController.text, selectedRandomBloodUnit, '', '');
    }
    if (fastingBloodController.text != '') {
      BloodTest().addItem('blood_glucose', fastingBloodController.text, selectedFastingBloodUnit, '', '');
    }
    if (habfController.text != '') {
      BloodTest().addItem('2habf', habfController.text, selectedHabfUnit, '', '');
    }
    if (hba1cController.text != '') {
      BloodTest().addItem('a1c', hba1cController.text, selectedHba1cUnit, '', '');
    }
    
    if (cholesterolController.text != '') {
      BloodTest().addItem('total_cholesterol', cholesterolController.text, selectedCholesterolUnit, '', '');
    }

    if (ldlController.text != '') {
      BloodTest().addItem('ldl', ldlController.text, selectedLdlUnit, '', '');
    }
    if (hdlController.text != '') {
      BloodTest().addItem('hdl', hdlController.text, selectedHdlUnit, '', '');
    }
    if (tgController.text != '') {
      BloodTest().addItem('triglycerides', tgController.text, selectedTgUnit, '', '');
    }
    if (creatinineController.text != '') {
      BloodTest().addItem('creatinine', creatinineController.text, selectedCreatinineUnit, '', '');
    }
    if (sodiumController.text != '') {
      BloodTest().addItem('sodium', sodiumController.text, selectedSodiumUnit, '', '');
    }
    if (potassiumController.text != '') {
      BloodTest().addItem('potassium', potassiumController.text, selectedPotassiumUnit, '', '');
    }
    if (ketonesController.text != '') {
      BloodTest().addItem('ketones', ketonesController.text, selectedKetonesUnit, '', '');
    }
    if (proteinController.text != '') {
      BloodTest().addItem('protein', proteinController.text, selectedProteinUnit, '', '');
    }

    BloodTest().addBtItem();



    var relativeAdditionalData = {
      'religion': selectedReligion,
      'occupation': occupationController.text,
      'ethnicity': selectedEthnicity,
      'monthly_income': incomeController.text,
      'blood_group': selectedBloodGroup,
      'education': educationController.text,
      'tribe': isTribe
    };
    Questionnaire().addNewPersonalHistory('relative_problems', relativeAnswers, relativeAdditionalData);
      
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('followupVisit')),
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
                onPressed: ()async {
                  setState(() {
                    print(_currentStep);
                    // if (_currentStep == 0) {
                      
                    // }

                    // if (_currentStep == 1) {

                    // }

                    // if (_currentStep == 2) {
                      
                    // }
                    
                    if (nextText =='COMPLETE') {

                      _completeStep();
                      return;
                    }
                    if (_currentStep == 0) {
                      print('hello');
                      createObservations();
                      nextText = 'COMPLETE';
                    }
                    if (_currentStep < 6) {
                     
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

  missingDataAlert() async {
   var response = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text(AppLocalizations.of(context).translate("incompleteNcdFollowup"), style: TextStyle(fontSize: 20),),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text(AppLocalizations.of(context).translate("back"), style: TextStyle(color: kPrimaryColor)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: new Text(AppLocalizations.of(context).translate("continue"), style: TextStyle(color: kPrimaryColor)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      }
    );
    print("NoYes : $response");
    return response;
  }


  Future _completeStep() async {
    
    print('before missing popup');
    var hasMissingData = checkMissingData();

    if (hasMissingData) {
      var continueMissing = await missingDataAlert();
      if (!continueMissing) {
        return;
      }
    }

    setLoader(true);

    var patient = Patient().getPatient();
  
    print(patient['data']['age']);
    var status = hasMissingData ? 'incomplete' : 'complete';
    var response = await AssessmentController().createFollowupAssessment('follow up visit (community)', 'follow up community', '', status, nextVisitDate, 'short');
    !hasMissingData ? Patient().setPatientReviewRequiredTrue() : null;
    setLoader(false);

    // if age greater than 40 redirect to referral page
    // if (patient['data']['age'] != null && patient['data']['age'] > 40) {
    //   var data = {
    //     'meta': {
    //       'patient_id': Patient().getPatient()['uuid'],
    //       "collected_by": Auth().getAuth()['uid'],
    //       "status": "pending"
    //     },
    //     'body': {},
    //     'referred_from': 'new questionnaire'
    //   };
    //   goToHome(true, data);

    //   return;
    // }

    if (isReferralRequired) {
      var data = {
        'meta': {
          'patient_id': Patient().getPatient()['uuid'],
          "collected_by": Auth().getAuth()['uid'],
          "status": "pending"
        },
        'body': {},
        'referred_from': 'new questionnaire'
      };
      goToHome(true, data);

      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChwPatientRecordsScreen()));
    // goToHome(false, null);
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [

      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: Measurements(),
        isActive: _currentStep >= 2,
      ),
      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: BloodTests(),
      //   isActive: _currentStep >= 2,
      // ),

      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: Followup(parent: this),
        isActive: _currentStep >= 2,
      ),

      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: InitialCounselling(parent: this),
      //   isActive: _currentStep >= 3,
      // ),
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

checkMissingData() {
  if (diastolicEditingController.text == '' || systolicEditingController.text == '' || pulseRateEditingController.text == '') {
    print('blood pressure missing');
    return true;
  }

  

  // if (heightEditingController.text == '' || weightEditingController.text == '') {
  //   print('body measurement missing');
  //   return true;
  // }

  if (
    randomBloodController.text == '' &&
    fastingBloodController.text == '' &&
    habfController.text == '' && 
    hba1cController.text == '') {
    print('blood sugar missing');
    return true;
  }

  return false;

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
                                child: Text(getQuestionText(context, question),
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
                                            child: Text(getOptionText(context, question, option),
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

  bool showLastMedicationQuestion = false;
  bool isEmpty = true;

checkMedicalHistoryAnswers(medicationQuestion) {

  // if (medicationQuestions['items'].length -1 == medicationQuestions['items'].indexOf(medicationQuestion)) {
  //   if (showLastMedicationQuestion) {
  //     return true;
  //   }
    
  // }
  // return true;

  if (medicationQuestion['type'].contains('medication')) {

    var mainType = medicationQuestion['type'].replaceAll('_regular_medication', '');
    print('mainType ' + mainType);
    var matchedMedicationQuestion = medicationQuestions['items'].where((item) => item['type'] == mainType).first;
    var medicationAnswer = medicationAnswers[medicationQuestions['items'].indexOf(matchedMedicationQuestion)];
    if (medicationAnswer == 'yes') {
      return true;
    }

    return false;
  }

  var matchedQuestion;
  bool matchedHBD = false;
  medicalHistoryQuestions['items'].forEach((item) {
    if (item['type'] != null && item['type'] == medicationQuestion['type']) {
      matchedQuestion =  item;
    }
    else if (medicationQuestion['type'] == 'heart_bp_diabetes') {
      if (item['type'] == 'heart' || item['type'] == 'blood_pressure' || item['type'] == 'diabetes') {
        
        var answer = medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(item)];
        if (answer == 'yes') {
          matchedHBD = true;
          // return true;
        }
      }
    }
  });

  if (matchedHBD) {
    return true;
  }

  if (matchedQuestion != null) {
    // print(matchedQuestion.first);
    var answer = medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(matchedQuestion)];
    if (answer == 'yes') {
      return true;
    }
  }
  return false;
  
}

  checkAnswer() {
    setState(() {
      
    });

    return;

    var isPositive = false;
    var answersLength = medicationAnswers.length;

    for (var answer in medicationAnswers) {
      if (medicationAnswers.indexOf(answer) != answersLength - 1) {
        if (answer == 'yes') {
          setState(() {
            isPositive = true;
          });
          break;
        }
      }
    }

    setState(() {
      showLastMedicationQuestion = isPositive;
    });

  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
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
                          
                          if (checkMedicalHistoryAnswers(question)) {
                            isEmpty = false;
                            return Container(
                              margin: question['category'] == 'sub' ? EdgeInsets.only(left: 40, bottom: 20) : null,
                              padding: question['category'] == 'sub' ? EdgeInsets.symmetric(horizontal: 20,) : null,
                              decoration: question['category'] == 'sub' ? BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(3)
                              ) : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(getQuestionText(context, question),
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
                                                    print(medicalHistoryAnswers);
                                                    medicationAnswers[medicationQuestions['items'].indexOf(question)] = question['options'][question['options'].indexOf(option)];
                                                    checkAnswer();
                                                    // print(medicalHistoryAnswers);
                                                    // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                  });
                                                },
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                child: Text(getOptionText(context, question, option),
                                                  style: TextStyle(color: medicationAnswers[medicationQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? kPrimaryColor : null),
                                                ),
                                              ),
                                            )
                                          ),
                                        ).toList()
                                      ],
                                    )
                                  ),

                                  SizedBox(height: 20,),

                                ],
                              ),
                            ); 
                          } else return Container();
                        }).toList(),

                        isEmpty ? Container(
                          child: Text( AppLocalizations.of(context).translate('noQuestionFound') + ' ' + AppLocalizations.of(context).translate('goToNextStep'), style: TextStyle(fontSize: 16),),
                        ) : Container()
                        
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


class Measurements extends StatefulWidget {

  @override
  _MeasurementsState createState() => _MeasurementsState();
}

String selectedBloodSugarType = 'FBS';
var systolicEditingController = TextEditingController();
var pulseRateEditingController = TextEditingController();
var diastolicEditingController = TextEditingController();
var commentsEditingController = TextEditingController();

//Blood Test
var selectedRandomBloodUnit = 'mg/dL';
var randomBloodController = TextEditingController();
var selectedFastingBloodUnit = 'mg/dL';
var fastingBloodController = TextEditingController();
var selectedHabfUnit = 'mg/dL';
var habfController = TextEditingController();
var selectedHba1cUnit = 'mg/dL';
var hba1cController = TextEditingController();
var selectedCholesterolUnit = 'mg/dL';
var cholesterolController = TextEditingController();
var selectedLdlUnit = 'mg/dL';
var ldlController = TextEditingController();
var selectedHdlUnit = 'mg/dL';
var hdlController = TextEditingController();
var selectedTgUnit = 'mg/dL';
var tgController = TextEditingController();
var selectedCreatinineUnit = 'mg/dL';
var creatinineController = TextEditingController();
var selectedSodiumUnit = 'mg/dL';
var sodiumController = TextEditingController();
var selectedPotassiumUnit = 'mg/dL';
var potassiumController = TextEditingController();
var selectedKetonesUnit = 'mg/dL';
var ketonesController = TextEditingController();
var selectedProteinUnit = 'mg/dL';
var proteinController = TextEditingController();

class _MeasurementsState extends State<Measurements> {

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).translate('bloodPressure'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
            SizedBox(height: 24,),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('systolic'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 20,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: systolicEditingController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //Spacer(),
                              SizedBox(width: 50),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate("diastolic"), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 14,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: diastolicEditingController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              )


                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(AppLocalizations.of(context).translate("pulseRate"), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 24,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: pulseRateEditingController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          child: Container(),
                        )
                      ],
                    ),
                  ),

                  Container(
                   child: Row(
                     children: [
                       Text(AppLocalizations.of(context).translate("comment"), style: TextStyle(color: Colors.black, fontSize: 16,)),
                       SizedBox(width: 8,),
                       Expanded(
                         child: Container(
                           width: 80,
                           height: 40,
                           child: TextFormField(
                             textAlign: TextAlign.center,
                             keyboardType: TextInputType.text,
                             controller: commentsEditingController,
                             onChanged: (value) {
                           
                             },
                             decoration: InputDecoration(  
                               contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                               border: OutlineInputBorder(
                                 borderSide: BorderSide(color: Colors.red, width: 0.0)
                               ), 
                             ),
                           ),
                         ),
                       ),
                     ],
                   ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 24,),
            Text(AppLocalizations.of(context).translate('bloodSugar'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
            SizedBox(height: 24,),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('randomBloodSugar'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 15,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: randomBloodController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                              Row(
                                children: <Widget>[
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mg/dL',
                                    groupValue: selectedRandomBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRandomBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text("mg/dL", style: TextStyle(color: Colors.black)),
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mmol/L',
                                    groupValue: selectedRandomBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRandomBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    "mmol/L",
                                  ),
                                  
                                  SizedBox(width: 20,),
                                ],
                              )
                            ],
                          ),
                        ),
                      

                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('fastingBloodSugar'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 20,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: fastingBloodController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                              Row(
                                children: <Widget>[
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mg/dL',
                                    groupValue: selectedFastingBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFastingBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text("mg/dL", style: TextStyle(color: Colors.black)),
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mmol/L',
                                    groupValue: selectedFastingBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFastingBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    "mmol/L",
                                  ),
                                  
                                  SizedBox(width: 20,),
                                ],
                              )
                            ],
                          ),
                        ),
                      

                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('2HABF'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 113,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: habfController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                              Row(
                                children: <Widget>[
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mg/dL',
                                    groupValue: selectedHabfUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHabfUnit = value;
                                      });
                                    },
                                  ),
                                  Text("mg/dL", style: TextStyle(color: Colors.black)),
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mmol/L',
                                    groupValue: selectedHabfUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHabfUnit = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    "mmol/L",
                                  ),
                                  
                                  SizedBox(width: 20,),
                                ],
                              )
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('hba1c'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 117,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: hba1cController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15,),

                  Container(
                   child: Row(
                     children: [
                       Text(AppLocalizations.of(context).translate("comment"), style: TextStyle(color: Colors.black, fontSize: 16,)),
                       SizedBox(width: 35,),
                       Expanded(
                         child: Container(
                           width: 80,
                           height: 40,
                           child: TextFormField(
                             textAlign: TextAlign.center,
                             keyboardType: TextInputType.text,
                             controller: commentsEditingController,
                             onChanged: (value) {
                           
                             },
                             decoration: InputDecoration(  
                               contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                               border: OutlineInputBorder(
                                 borderSide: BorderSide(color: Colors.red, width: 0.0)
                               ), 
                             ),
                           ),
                         ),
                       ),
                     ],
                   ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 32,),
            
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).translate('lipidProfile'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
                  SizedBox(height: 24,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('totalCholesterol'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 25,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: cholesterolController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedCholesterolUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCholesterolUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedCholesterolUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCholesterolUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('ldl'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 117,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: ldlController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedLdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedLdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedLdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedLdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('hdl'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 115,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: hdlController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedHdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedHdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedHdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedHdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('triglycerides'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 55,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: tgController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedTgUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTgUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedTgUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTgUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32,),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).translate('additional'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
                  SizedBox(height: 24,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('creatinine'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 35,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: creatinineController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedCreatinineUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCreatinineUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedCreatinineUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCreatinineUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('sodium'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 50,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: sodiumController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedSodiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedSodiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedSodiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedSodiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('potassium'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 28,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: potassiumController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedPotassiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedPotassiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedPotassiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedPotassiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('ketones'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 45,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: ketonesController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedKetonesUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedKetonesUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedKetonesUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedKetonesUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('protein'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 45,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: proteinController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedProteinUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedProteinUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedProteinUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedProteinUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            
                            ],
                          ),
                        ),
                      ],
                    ),
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


class BloodTests extends StatefulWidget {

  @override
  _BloodTestsState createState() => _BloodTestsState();
}

// var selectedRandomBloodUnit = 'mg/dL';
// var randomBloodController = TextEditingController();
// var selectedFastingBloodUnit = 'mg/dL';
// var fastingBloodController = TextEditingController();
// var selectedHabfUnit = 'mg/dL';
// var habfController = TextEditingController();
// var selectedHba1cUnit = 'mg/dL';
// var hba1cController = TextEditingController();
// var selectedCholesterolUnit = 'mg/dL';
// var cholesterolController = TextEditingController();
// var selectedLdlUnit = 'mg/dL';
// var ldlController = TextEditingController();
// var selectedHdlUnit = 'mg/dL';
// var hdlController = TextEditingController();
// var selectedTgUnit = 'mg/dL';
// var tgController = TextEditingController();
// var selectedCreatinineUnit = 'mg/dL';
// var creatinineController = TextEditingController();

class _BloodTestsState extends State<BloodTests> {




  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).translate('bloodSugar'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
            SizedBox(height: 24,),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('randomBloodSugar'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 15,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: randomBloodController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                              Row(
                                children: <Widget>[
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mg/dL',
                                    groupValue: selectedRandomBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRandomBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text("mg/dL", style: TextStyle(color: Colors.black)),
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mmol/L',
                                    groupValue: selectedRandomBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRandomBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    "mmol/L",
                                  ),
                                  
                                  SizedBox(width: 20,),
                                ],
                              )
                            ],
                          ),
                        ),
                      

                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('fastingBloodSugar'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 20,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: fastingBloodController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                              Row(
                                children: <Widget>[
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mg/dL',
                                    groupValue: selectedFastingBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFastingBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text("mg/dL", style: TextStyle(color: Colors.black)),
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mmol/L',
                                    groupValue: selectedFastingBloodUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFastingBloodUnit = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    "mmol/L",
                                  ),
                                  
                                  SizedBox(width: 20,),
                                ],
                              )
                            ],
                          ),
                        ),
                      

                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('2HABF'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 113,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: habfController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                              Row(
                                children: <Widget>[
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mg/dL',
                                    groupValue: selectedHabfUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHabfUnit = value;
                                      });
                                    },
                                  ),
                                  Text("mg/dL", style: TextStyle(color: Colors.black)),
                                  Radio(
                                    activeColor: kPrimaryColor,
                                    value: 'mmol/L',
                                    groupValue: selectedHabfUnit,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHabfUnit = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    "mmol/L",
                                  ),
                                  
                                  SizedBox(width: 20,),
                                ],
                              )
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('hba1c'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 117,),
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: hba1cController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15,),

                  Container(
                   child: Row(
                     children: [
                       Text(AppLocalizations.of(context).translate("comment"), style: TextStyle(color: Colors.black, fontSize: 16,)),
                       SizedBox(width: 35,),
                       Expanded(
                         child: Container(
                           width: 80,
                           height: 40,
                           child: TextFormField(
                             textAlign: TextAlign.center,
                             keyboardType: TextInputType.text,
                             controller: commentsEditingController,
                             onChanged: (value) {
                           
                             },
                             decoration: InputDecoration(  
                               contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                               border: OutlineInputBorder(
                                 borderSide: BorderSide(color: Colors.red, width: 0.0)
                               ), 
                             ),
                           ),
                         ),
                       ),
                     ],
                   ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 32,),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).translate('lipidProfile'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
                  SizedBox(height: 24,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('totalCholesterol'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 25,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: cholesterolController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedCholesterolUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCholesterolUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedCholesterolUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCholesterolUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('ldl'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 117,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: ldlController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedLdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedLdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedLdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedLdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('hdl'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 115,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: hdlController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedHdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedHdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedHdlUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedHdlUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('triglycerides'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 55,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: tgController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedTgUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTgUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedTgUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTgUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32,),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).translate('additional'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
                  SizedBox(height: 24,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('creatinine'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 35,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: creatinineController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedCreatinineUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCreatinineUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedCreatinineUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCreatinineUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('sodium'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 50,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: sodiumController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedSodiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedSodiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedSodiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedSodiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('potassium'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 28,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: potassiumController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedPotassiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedPotassiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedPotassiumUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedPotassiumUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('ketones'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 45,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: ketonesController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedKetonesUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedKetonesUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedKetonesUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedKetonesUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context).translate('protein'), style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(width: 45,),
                                    Container(
                                      width: 80,
                                      height: 40,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: proteinController,
                                        onChanged: (value) {
                                      
                                        },
                                        decoration: InputDecoration(  
                                          contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.0)
                                          ), 
                                        ),
                                      ),
                                    ),
                                  
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mg/dL',
                                          groupValue: selectedProteinUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedProteinUnit = value;
                                            });
                                          },
                                        ),
                                        Text("mg/dL", style: TextStyle(color: Colors.black)),
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: 'mmol/L',
                                          groupValue: selectedProteinUnit,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedProteinUnit = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          "mmol/L",
                                        ),
                                        
                                        SizedBox(width: 20,),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class History extends StatefulWidget {

  @override
  _HistoryState createState() => _HistoryState();
}

var occupationController = TextEditingController();
var incomeController = TextEditingController();
var educationController = TextEditingController();

var religions = ['Muslim', 'Hindu', 'Cristian', 'Others'];
var selectedReligion = null;
var ethnicity = ['Bengali', 'Others'];
var selectedEthnicity = null;
var bloodGroups = ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'];
var selectedBloodGroup = null;
var isTribe = null;

class _HistoryState extends State<History> {

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).translate('familyHistory'), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
            SizedBox(height: 24,),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('religion'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 85,),
                            
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                color: kSecondaryTextField,
                                child: DropdownButton<String>(
                                  items: religions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: selectedReligion,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      selectedReligion = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),
                      

                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('occupation'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 60,),
                              Container(
                                width: 110,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  controller: occupationController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                            ],
                          ),
                        ),
                      
                        

                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).translate('ethnicity'), style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 80,),
                            
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                color: kSecondaryTextField,
                                child: DropdownButton<String>(
                                  items: ethnicity.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: selectedEthnicity,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      selectedEthnicity = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        


                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Monthly Income', style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 27,),
                              Container(
                                width: 110,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: incomeController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                            ],
                          ),
                        ),
                      
                        
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Blood Group', style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 53,),
                            
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                color: kSecondaryTextField,
                                child: DropdownButton<String>(
                                  items: bloodGroups.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: selectedBloodGroup,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      selectedBloodGroup = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        

                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Education (years)', style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 18,),
                              Container(
                                width: 110,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: educationController,
                                  onChanged: (value) {
                                
                                  },
                                  decoration: InputDecoration(  
                                    contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 0.0)
                                    ), 
                                  ),
                                ),
                              ),
                            
                            ],
                          ),
                        ),


                        SizedBox(height: 16),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Tribe', style: TextStyle(color: Colors.black, fontSize: 16)),
                              SizedBox(width: 110,),
                              Container(
                                width: 200,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        height: 25,
                                        width: 100,
                                        margin: EdgeInsets.only(right: 20, left: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1, color: (isTribe != null && isTribe) ? Color(0xFF01579B) : Colors.black),
                                          borderRadius: BorderRadius.circular(3),
                                          color: (isTribe != null && isTribe) ? Color(0xFFE1F5FE) : null
                                        ),
                                        child: FlatButton(
                                          onPressed: () {
                                            setState(() {
                                                isTribe = true;
                                            });
                                          },
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          child: Text(AppLocalizations.of(context).translate('yes'),
                                            style: TextStyle(color: (isTribe != null && isTribe) ? kPrimaryColor : null),
                                          ),
                                        ),
                                      )
                                    ),

                                    Expanded(
                                      child: Container(
                                        height: 25,
                                        width: 100,
                                        margin: EdgeInsets.only(right: 20, left: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1, color: (isTribe == null || isTribe) ? Colors.black : Color(0xFF01579B) ),
                                          borderRadius: BorderRadius.circular(3),
                                          color: (isTribe == null || isTribe) ? null : Color(0xFFE1F5FE)
                                        ),
                                        child: FlatButton(
                                          onPressed: () {
                                            setState(() {
                                                isTribe = false;
                                            });
                                          },
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          child: Text(AppLocalizations.of(context).translate('NO'),
                                            style: TextStyle(color:(isTribe == null || isTribe) ? null : kPrimaryColor),
                                          ),
                                        ),
                                      )
                                    ),
                                  ],
                                )
                              ),
                            
                            ],
                          ),
                        ),
                      
                      ],
                    ),
                  ),

                  SizedBox(height: 15,),

                ],
              ),
            ),
            SizedBox(height: 32,),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Does any of your blood relative such as father, mother, uncle, aunty had or have?', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),), 
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
                        ...relativeQuestions['items'].map((question) {
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(getQuestionText(context, question),
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
                                            border: Border.all(width: 1, color: relativeAnswers[relativeQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFF01579B) : Colors.black),
                                            borderRadius: BorderRadius.circular(3),
                                            color: relativeAnswers[relativeQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFFE1F5FE) : null
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                relativeAnswers[relativeQuestions['items'].indexOf(question)] = question['options'][question['options'].indexOf(option)];
                                                // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                              });
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            child: Text(getOptionText(context, question, option),
                                              style: TextStyle(color: relativeAnswers[relativeQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? kPrimaryColor : null),
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


class Followup extends StatefulWidget {
  _WellFollowupScreenState parent;
  Followup({this.parent});

  @override
  _FollowupState createState() => _FollowupState();
}

var isReferralRequired = false;
var followups = ['1 week', '2 weeks', '1 month', '2 months', '3 months', '6 months', '1 year'];
var selectedFollowup = null;
var nextVisitDate = '';
class _FollowupState extends State<Followup> {

  bool tobaccoTitleAdded = false;
  bool dietTitleAdded = false;
  bool activityTitleAdded = false;

  checkCounsellingQuestions(counsellingQuestion) {

    // if (medicationQuestions['items'].length - 1 == medicationQuestions['items'].indexOf(medicationQuestion)) {
    //   if (showLastMedicationQuestion) {
    //     return true;
    //   }
      
    // }

    var matchedQuestion;
    riskQuestions['items'].forEach((item) {
      if (item['type'] != null && item['type'] == counsellingQuestion['type']) {
        matchedQuestion =  item;
      }
    });

    

    if (matchedQuestion != null) {
      // print(matchedQuestion.first);
      var answer = riskAnswers[riskQuestions['items'].indexOf(matchedQuestion)];
      if (answer == 'yes') {
        return true;
      }
    }
    return false;
  
  }

  addCounsellingGroupTitle(question) {
    if (question['group'] == 'unhealthy-diet') {
      print('group');
      if (!dietTitleAdded) {
        dietTitleAdded = true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            Container(
              margin: EdgeInsets.only(top: 25, bottom: 30),
              child: Text(AppLocalizations.of(context).translate('unhealthyDiet'),style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
            ),
          ],
        );
      }
      
    }
    else if (question['type'] == 'physical-activity-high') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Container(
            margin: EdgeInsets.only(top: 25, bottom: 10),
          ),
        ],
      );
    }

    return Container();
  }

  Widget titleWidget(title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Container(
          margin: EdgeInsets.only(top: 25, bottom: 30),
          child: Text('$title',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
        ),
      ],
    );
  }

  getNextVisitDate() {
    print(selectedFollowup);
    // ['1 week', '2 weeks', '1 month', '2 months', '3 months', '6 months', '1 year'];
    var date = '';
    if (selectedFollowup == '1 week') {
      date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 7)));
      
    } else if (selectedFollowup == '2 weeks') {
      date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 14)));
    } else if (selectedFollowup == '1 month') {
      date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 30)));
    } else if (selectedFollowup == '2 months') {
      date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 60)));
    } else if (selectedFollowup == '3 months') {
      date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 90)));
    } else if (selectedFollowup == '6 months') {
      date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 180)));
    } else if (selectedFollowup == '1 year') {
      date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 365)));
    }

    setState(() {
      nextVisitDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              // alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).translate('followupVisit'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                ],
              )
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).translate('followupVisit') + ' in', style: TextStyle(color: Colors.black, fontSize: 16)),
                  SizedBox(width: 30,),
                
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    color: kSecondaryTextField,
                    child: DropdownButton<String>(
                      items: checkMissingData() ? [] : followups.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: selectedFollowup,
                      onChanged: (String newValue) {
                        setState(() {
                          selectedFollowup = newValue;
                          getNextVisitDate();
                        });
                      },
                    ),
                  ),
                  
                ],
              ),
            ),
            
            nextVisitDate != '' ? Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Next visit date: $nextVisitDate', style: TextStyle(color: Colors.black, fontSize: 16)),
                  SizedBox(width: 30,),
                ]
              )
            ) : Container(),

            Container(
              width: double.infinity,
              margin: EdgeInsets.only( top: 60, left: 50, right: 50),
              height: 50,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(3)
              ),
              child: FlatButton(
                onPressed: () async {
                  widget.parent._completeStep();
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(AppLocalizations.of(context).translate('completeVisit'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
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
  addRiskGroupTitle(question) {
    if (question['type'] == 'smoking') {
      return titleWidget(AppLocalizations.of(context).translate('tobaccoUse'));
    } else if (question['type'] == 'eat-vegetables') {
      return titleWidget(AppLocalizations.of(context).translate('unhealthyDiet'));
    } else if (question['type'] == 'physical-activity-high') {
      return titleWidget(AppLocalizations.of(context).translate('physicalActivity'));
    } else if (question['type'] == 'alcohol-status') {
      return titleWidget(AppLocalizations.of(context).translate('alcohol'));
    }

    return Container();
  }

  Widget titleWidget(title) {
    return Container(
      margin: EdgeInsets.only(top: 25, bottom: 30),
      child: Text('$title',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
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
                              addRiskGroupTitle(question),
                              Container(
                                child: Text(getQuestionText(context, question),
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
                                            child: Text(getOptionText(context, question, option),
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
  _WellFollowupScreenState parent;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              // alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Text(AppLocalizations.of(context).translate("requiredDevice"), style: TextStyle(fontSize: 18,),),
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
                                                AppLocalizations.of(context).translate('smokingCessation'),
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
                                                Text(AppLocalizations.of(context).translate("harmSmoking"), style: TextStyle(color: Colors.black, fontSize: 18)),
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
                                                Text(AppLocalizations.of(context).translate("stopSmoking"), style: TextStyle(color: Colors.black, fontSize: 18)),
                                              ],
                                            ),

                                            SizedBox(height: 20,),

                                            Text(AppLocalizations.of(context).translate("givenPatient"), style: TextStyle(color: Colors.black, fontSize: 18)),

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
                                                        child: Text(AppLocalizations.of(context).translate("yes"),
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
                                                        child: Text(AppLocalizations.of(context).translate("no"),
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
                                                AppLocalizations.of(context).translate("diet"),
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
                                                AppLocalizations.of(context).translate("physicalActivity"),
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
                                                AppLocalizations.of(context).translate("medicationAdherence"),
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
                                                AppLocalizations.of(context).translate("alcohol"),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context).translate("patientTemperature"), style: TextStyle(fontSize: 21),),
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

class BloodPressures extends StatefulWidget {
  BloodPressures({this.parent});
  final parent;

  @override
  _BloodPressureState createState() => _BloodPressureState();
}

class _BloodPressureState extends State<BloodPressures> {
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context).translate("whatPressure"), style: TextStyle(fontSize: 21),),
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
                  Text(AppLocalizations.of(context).translate("leftArm"), style: TextStyle(color: Colors.black)),
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
                  Text(AppLocalizations.of(context).translate("leftArm"), style: TextStyle(color: Colors.black)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context).translate("bloodGlucoseLevel"), style: TextStyle(fontSize: 21),),
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
                hint: Text(AppLocalizations.of(context).translate("selectDevice"), style: TextStyle(fontSize: 20, color: kTextGrey),),
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

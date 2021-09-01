import 'package:basic_utils/basic_utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:nhealth/screens/chw/unwell/create_referral_screen.dart';
import 'package:nhealth/screens/chw/unwell/medical_recomendation_screen.dart';
import 'package:nhealth/screens/nurse/new_patient_questionnairs/new_patient_questionnaire_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_overview_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../custom-classes/custom_stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _causesFormKey = new GlobalKey<FormState>();
final _temperatureController = TextEditingController();
final _systolicController = TextEditingController();
final _diastolicController = TextEditingController();
final _pulseController = TextEditingController();
final _glucoseController = TextEditingController();
final _deviceController = TextEditingController();
List causes = [
  'Fever',
  'Shortness of breath',
  'Feeling faint',
  'Stomach discomfort'
];
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
var counsellingQuestions = {};
var riskAnswers = [];
var counsellingAnswers = [];
var answers = [];

int _firstQuestionOption = 1;
int _secondQuestionOption = 1;
int _thirdQuestionOption = 1;
int _fourthQuestionOption = 1;
bool isLoading = false;

var encounter;
var observations = [];

// bool _isBloodPressureEnable = false;
// bool _isBodyMeasurementsEnable = false;
// bool _isTestsEnable = false;


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

class EditIncompleteEncounterChwScreen extends StatefulWidget {
  static const path = '/editIncompleteEncounterChw';
  @override
  _EditIncompleteEncounterChwScreenState createState() =>
      _EditIncompleteEncounterChwScreenState();
}

class _EditIncompleteEncounterChwScreenState
    extends State<EditIncompleteEncounterChwScreen> {
  int _currentStep = 0;

  String nextText = 'NEXT';
  bool nextHide = false;



  @override
  void initState() {
    super.initState();
    _checkAuth();
    clearForm();
    isLoading = false;

    print(Language().getLanguage());
    nextText = (Language().getLanguage() == 'Bengali') ? 'পরবর্তী' : 'NEXT';

    prepareQuestions();
    prepareAnswers();

    getLanguage();

    getIncompleteAssessmentLocal();
  }

  getIncompleteAssessmentLocal() async {
    encounter = await AssessmentController().getAssessmentsByPatientWithLocalStatus('incomplete', assessmentType: 'new questionnaire');
    if(encounter.isNotEmpty) {
      encounter = encounter.first;
      observations = await AssessmentController().getObservationsByAssessment(encounter);
    }
    print("encounter: $encounter");
    print("observations: $observations");
    
    populatePreviousAnswers();
  }
  
  populatePreviousAnswers() {
    observations.forEach((obs) {
      print('obs $obs');
      if (obs['body']['type'] == 'survey') {
        print('into survey');
        var obsData = obs['body']['data'];
        if (obsData['name'] == 'medical_history') {
          print('into medical history');
          var keys = obsData.keys.toList();
          print(keys);
          keys.forEach((key) {
            if (obsData[key] != '') {
              print('into keys');
              var matchedMhq = medicalHistoryQuestions['items']
                  .where((mhq) => mhq['key'] == key);
              if (matchedMhq.isNotEmpty) {
                matchedMhq = matchedMhq.first;
                setState(() {
                  medicalHistoryAnswers[medicalHistoryQuestions['items']
                      .indexOf(matchedMhq)] = obsData[key];
                });
              }
            }
          });
        } else if (obsData['name'] == 'medication') {
          print('into medical history');
          var keys = obsData.keys.toList();
          print(keys);
          keys.forEach((key) {
            if (obsData[key] != '') {
              print('into keys');
              var matchedMhq = medicationQuestions['items']
                  .where((mhq) => mhq['key'] == key);
              if (matchedMhq.isNotEmpty) {
                matchedMhq = matchedMhq.first;
                setState(() {
                  print("medication: ${obsData[key]}");
                  medicationAnswers[medicationQuestions['items'].indexOf(matchedMhq)] = obsData[key];
                  medicationAnswers[medicationQuestions['items']
                      .indexOf(matchedMhq)] = obsData[key];
                  print("medicationAnswers");
                  //print(medicationAnswers[medicationQuestions['items'].indexOf(matchedMhq)]);
                });
              }
            }
          });
        } else if (obsData['name'] == 'risk_factors') {
          print('into risk factors');
          var keys = obsData.keys.toList();
          print(keys);
          keys.forEach((key) {
            if (obsData[key] != '') {
              print('into keys');
              var matchedMhq =
                  riskQuestions['items'].where((mhq) => mhq['key'] == key);
              if (matchedMhq.isNotEmpty) {
                matchedMhq = matchedMhq.first;
                setState(() {
                  riskAnswers[riskQuestions['items'].indexOf(matchedMhq)] =
                      obsData[key];
                });
              }
            }
          });
        } else if (obsData['name'] == 'counselling_provided') {
          print('into counselling provided');
          var keys = obsData.keys.toList();
          print(keys);
          keys.forEach((key) {
            if (obsData[key] != '') {
              print('into keys $key: ${obsData[key]}');
              var matchedMhq = counsellingQuestions['items'].where((mhq) => mhq['key'] == key);
              if (matchedMhq.isNotEmpty) {
                print('here counse');
                matchedMhq = matchedMhq.first;
                setState(() {
                  counsellingAnswers[counsellingQuestions['items']
                      .indexOf(matchedMhq)] = obsData[key];
                });
              }
            }
          });
        }
      }
      if (obs['body']['type'] == 'blood_pressure') {
        print('into blood pressure');
        var obsData = obs['body']['data'];
        if (obsData.isNotEmpty) {
          print('into obsData');
          var systolicText = obsData['systolic'];
          var diastolicText = obsData['diastolic'];
          var pulseRateText = obsData['pulse_rate'];
          systolicEditingController.text = '${obsData['systolic']}';
          pulseRateEditingController.text = '${obsData['pulse_rate']}';
          diastolicEditingController.text = '${obsData['diastolic']}';
          print(systolicText);
          print(diastolicText);
          print(pulseRateText);
        }
      }
      if (obs['body']['type'] == 'body_measurement') {
        print('into body measurement');
        var obsData = obs['body']['data'];
        if (obsData.isNotEmpty) {
          print(obsData['name']);
          if (obsData['name'] == 'height' && obsData['value'] != '') {
            print('into height');
            var heightText = obsData['value'];
            heightEditingController.text = '${obsData['value']}';
            print(heightText);
          }
          if (obsData['name'] == 'weight' && obsData['value'] != '') {
            print('into weight');
            var weightText = obsData['value'];
            weightEditingController.text = '${obsData['value']}';
            print(weightText);
          }
          if (obsData['name'] == 'bmi' && obsData['value'] != '') {
            print('into bmi');
            var bmiText = obsData['value'];
            bmiEditingController.text = '${obsData['value']}';
            print(bmiText);
          }
        }
      }
      if (obs['body']['type'] == 'blood_test') {
        print('into blood test');
        var obsData = obs['body']['data'];
        if (obsData.isNotEmpty) {
          print(obsData['name']);
          
          if (obsData['name'] == 'blood_sugar' && obsData['value'] != '') {
            print('into blood_sugar');
            var bloodSugarText = obsData['value'];
            bloodSugerEditingController.text = '${obsData['value']}';
            selectedRandomBloodUnit = obsData['unit'];
            selectedBloodSugarType == 'RBS';
            print(bloodSugarText);
          }
          if (obsData['name'] == 'blood_glucose' && obsData['value'] != '') {
            print('into blood_glucose');
            var bloodGlucoseText = obsData['value'];
            bloodSugerEditingController.text = '${obsData['value']}';
            selectedFastingBloodUnit = obsData['unit'];
            selectedBloodSugarType == 'FBS';
            print(bloodGlucoseText);
          }
        }
      }
    });
  }

  getLanguage() async {
    print('language s');
    final prefs = await SharedPreferences.getInstance();

    print(Localizations.localeOf(context));
  }

  prepareQuestions() {
    medicalHistoryQuestions =
        Questionnaire().questions['new_patient']['medical_history'];
    medicationQuestions =
        Questionnaire().questions['new_patient']['medication'];
    riskQuestions = Questionnaire().questions['new_patient']['risk_factors'];
    counsellingQuestions =
        Questionnaire().questions['new_patient']['counselling_provided'];
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
  }

  nextStep() {
    setState(() {
      if (_currentStep == 3) {
        _currentStep = _currentStep + 1;
        nextText = 'COMPLETE';
      } else if (_currentStep == 4) {
        print("sttep4");
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
    heightEditingController.text = '';
    weightEditingController.text = '';
    bmiEditingController.text = '';
    bloodSugerEditingController.text = '';
    selectedGlucoseUnit = 'mg/dL';
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
  }

  setLoader(value) {
    setState(() {
      isLoading = value;
    });
  }

  goToHome(recommendation, data) {
    if (recommendation) {
      Navigator.of(context).pushReplacementNamed(
          MedicalRecommendationScreen.path,
          arguments: data);
    } else {
      // Navigator.of(context).pushNamed('/chwHome',);
      
      Navigator.of(context).pushNamed('/patientOverview', arguments: {'prevScreen' : 'encounter'});
    }
  }

  checkData() async {
    int temp = 0;
    int systolic = 0;
    int diastolic = 0;
    int glucose = 0;

    var data = {
      'meta': {
        'patient_id': Patient().getPatient()['id'],
        "collected_by": Auth().getAuth()['uid'],
        "status": "pending"
      },
      'body': {
        'causes': selectedCauses,
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

    if (temp > 39 ||
        glucose > 250 ||
        systolic > 160 ||
        diastolic > 100 ||
        firstAnswer == 'yes' ||
        secondAnswer == 'yes') {
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
    if (diastolicEditingController.text != '' &&
        systolicEditingController.text != '') {
      BloodPressure().addItem(
          'left',
          int.parse(systolicEditingController.text),
          int.parse(diastolicEditingController.text),
          int.parse(pulseRateEditingController.text),
          null);
      var formData = {
        'items': BloodPressure().items,
        'comment': '',
        'patient_id': Patient().getPatient()['id'],
        'device': '',
        'performed_by': '',
      };

      BloodPressure().addBloodPressure(formData);
    }

    if (heightEditingController.text != '') {
      BodyMeasurement()
          .addItem('height', heightEditingController.text, 'cm', '', '');
    }
    if (weightEditingController.text != '') {
      BodyMeasurement()
          .addItem('weight', weightEditingController.text, 'kg', '', '');
    }
    if (bmiEditingController.text != '') {
      BodyMeasurement()
          .addItem('bmi', bmiEditingController.text.toString(), 'bmi', '', '');
    }

    BodyMeasurement().addBmItem();

    if (bloodSugerEditingController.text != '') {
      var name = 'other';
      if (selectedBloodSugarType == 'RBS') {
        name = 'blood_sugar';
      } else if (selectedBloodSugarType == 'FBS') {
        name = 'blood_glucose';
      }
      BloodTest().addItem(name, bloodSugerEditingController.text, selectedGlucoseUnit, '', '');
      BloodTest().addBtItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
            onPressed: () {
              _currentStep != 0
                  ? setState(() {
                      nextHide = false;
                      _currentStep = _currentStep - 1;
                      nextText = AppLocalizations.of(context).translate('next');
                    })
                  : setState(() {
                      Navigator.pop(context);
                    });
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(AppLocalizations.of(context).translate('newQuestionnaire')),
      ),
      body: !isLoading
          ? GestureDetector(
              onTap: () {
                // FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: CustomStepper(
                isHeader: false,
                physics: ClampingScrollPhysics(),
                type: CustomStepperType.horizontal,
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
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
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Color(0x90FFFFFF),
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                backgroundColor: Color(0x30FFFFFF),
              )),
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
                  print(_currentStep);
                  if (_currentStep == 0) {
                      Questionnaire().addNewMedicalHistoryNcd('medical_history', medicalHistoryAnswers);
                      print("addNewMedicalHistoryNcd ${Questionnaire().qnItems}");
                      await AssessmentController().createAssessmentWithObservationsLocal(context, 'new questionnaire', 'new-questionnaire', '', 'incomplete', '');
                          
                    }

                    if (_currentStep == 1) {
                      Questionnaire().addNewMedicationNcd(
                          'medication', medicationAnswers);
                      print(Questionnaire().qnItems);
                      await AssessmentController().createAssessmentWithObservationsLocal(context, 'new questionnaire', 'new-questionnaire', '', 'incomplete', '');
                      
                    }

                    if (_currentStep == 2) {
                      Questionnaire().addNewRiskFactorsNcd(
                          'risk_factors', riskAnswers);
                      print(Questionnaire().qnItems);
                      await AssessmentController().createAssessmentWithObservationsLocal(context, 'new questionnaire', 'new-questionnaire', '', 'incomplete', '');
                      
                    }

                    if (_currentStep == 4) {
                      Questionnaire().addNewCounselling(
                          'counselling_provided', counsellingAnswers);
                      _completeStep();
                      return;
                    }
                    if (_currentStep == 3) {
                      print('hello');
                      if(diastolicEditingController.text == '' ||
                        systolicEditingController.text == '' ||
                        pulseRateEditingController.text == '' ||
                        heightEditingController.text == '' ||
                        weightEditingController.text == ''||
                        bloodSugerEditingController.text == '') 
                      {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              content: new Text(AppLocalizations.of(context).translate('missingData'), style: TextStyle(fontSize: 20),),
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
                                  onPressed: () async{
                                    // Navigator.of(context).pop(true);
                                    setState(() {
                                      _currentStep = _currentStep + 1;
                                    });
                                    // await AssessmentController().createAssessmentWithObservationsLocal(context, 'new questionnaire', 'new-questionnaire', '', 'incomplete', '');
                      
                                    createObservations();
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      } else {
                        createObservations();
                        await AssessmentController().createAssessmentWithObservationsLocal(context, 'new questionnaire', 'new-questionnaire', '', 'incomplete', '');
                      
                        setState(() {
                          nextText = (Language().getLanguage() == 'Bengali') ? 'সম্পন্ন করুন' : 'COMPLETE';
                          _currentStep = _currentStep + 1;
                        });
                        return;
                      }
                    }
                    if (_currentStep < 3) {
                      // If the form is valid, display a Snackbar.
                      setState(() {
                        _currentStep = _currentStep + 1;
                      });
                    }
                },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(nextText, style: TextStyle(fontSize: 20)),
                              Icon(Icons.chevron_right)
                            ],
                          ),
                      )
                      : Container()
                ),
            ],
          )
        ),
    );
  }

  // Future _completeStep()async{

  //   setLoader(true);

  //   var patient = Patient().getPatient();

  //   print(patient['data']['age']);
  //   var response = await AssessmentController().createOnlyAssessment('new patient questionnaire', '', '');

  //   setLoader(false);

  //   // if age greater than 40 redirect to referral page
  //   // if (patient['data']['age'] != null && patient['data']['age'] > 40) {
  //   //   var data = {
  //   //     'meta': {
  //   //       'patient_id': Patient().getPatient()['id'],
  //   //       "collected_by": Auth().getAuth()['uid'],
  //   //       "status": "pending"
  //   //     },
  //   //     'body': {},
  //   //     'referred_from': 'new questionnaire'
  //   //   };
  //   //   goToHome(true, data);

  //   //   return;
  //   // }

  //   if (isReferralRequired) {
  //     var data = {
  //       'meta': {
  //         'patient_id': Patient().getPatient()['id'],
  //         "collected_by": Auth().getAuth()['uid'],
  //         "status": "pending"
  //       },
  //       'body': {},
  //       'referred_from': 'new questionnaire'
  //     };
  //     goToHome(true, data);

  //     return;
  //   }

  //   goToHome(false, null);
  // }

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
    var response = await AssessmentController().createAssessmentWithObservationsLive('new questionnaire');
    // var response = await AssessmentController().createOnlyAssessmentWithStatus('new questionnaire', 'new-questionnaire', '', 'incomplete', nextVisitDate);

    setLoader(false);

    // if age greater than 40 redirect to referral page
    // if (patient['data']['age'] != null && patient['data']['age'] > 40) {
    //   var data = {
    //     'meta': {
    //       'patient_id': Patient().getPatient()['id'],
    //       "collected_by": Auth().getAuth()['uid'],
    //       "status": "pending"
    //     },
    //     'body': {},
    //     'referred_from': 'new questionnaire'
    //   };
    //   goToHome(true, data);

    //   return;
    // }

    if ((isReferralRequired != null && isReferralRequired)) {
      var data = {
        'meta': {
          'patient_id': Patient().getPatient()['id'],
          "collected_by": Auth().getAuth()['uid'],
          "status": "pending",
          "created_at": DateTime.now().toString()
        },
        'body': {},
        'referred_from': 'new questionnaire'
      };
      goToHome(true, data);

      return;
    }

    goToHome(false, null);
  }

  missingDataAlert() async {
    var response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: new Text(
              AppLocalizations.of(context).translate("incompleteNcd"),
              style: TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text(AppLocalizations.of(context).translate("back"),
                    style: TextStyle(color: kPrimaryColor)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: new Text(
                    AppLocalizations.of(context).translate("continue"),
                    style: TextStyle(color: kPrimaryColor)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
    print("NoYes : $response");
    return response;
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [
      CustomStep(
        title: Text(
          AppLocalizations.of(context).translate("causes"),
          textAlign: TextAlign.center,
        ),
        content: MedicalHistory(),
        isActive: _currentStep >= 0,
      ),
      CustomStep(
        title: Text(
          AppLocalizations.of(context).translate("permission"),
          textAlign: TextAlign.center,
        ),
        content: Medication(),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text(
          AppLocalizations.of(context).translate("permission"),
          textAlign: TextAlign.center,
        ),
        content: RiskFactors(),
        isActive: _currentStep >= 2,
      ),

      CustomStep(
        title: Text(
          AppLocalizations.of(context).translate("permission"),
          textAlign: TextAlign.center,
        ),
        content: Measurements(),
        isActive: _currentStep >= 2,
      ),

      CustomStep(
        title: Text(
          AppLocalizations.of(context).translate("permission"),
          textAlign: TextAlign.center,
        ),
        content: RecommendedCounselling(),
        isActive: _currentStep >= 2,
      ),

      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: InitialCounselling(parent: this),
      //   isActive: _currentStep >= 3,
      // ),
    ];

    if (Configs().configAvailable('isThumbprint')) {
      _steps.add(CustomStep(
        title: Text(AppLocalizations.of(context).translate('thumbprint')),
        content: Text(''),
        isActive: _currentStep >= 3,
      ));
    }

    return _steps;
  }
}

checkMissingData() {
  if (diastolicEditingController.text == '' ||
      systolicEditingController.text == '' ||
      pulseRateEditingController.text == '') {
    print('blood pressure missing');
    return true;
  }

  if (heightEditingController.text == '' ||
      weightEditingController.text == '') {
    print('body measurement missing');
    return true;
  }

  if (bloodSugerEditingController.text == '') {
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
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PatientTopbar(),
                SizedBox(
                  height: 20,
                ),
                Container(
                  // alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: Text(
                    AppLocalizations.of(context).translate('medicalHistory'),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
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
                                  bottom: BorderSide(color: kBorderLighter))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...medicalHistoryQuestions['items']
                                  .map((question) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: Text(
                                      getQuestionText(context, question),
                                      style:
                                          TextStyle(fontSize: 18, height: 1.7),
                                    )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Row(
                                          children: <Widget>[
                                            ...question['options']
                                                .map(
                                                  (option) => Expanded(
                                                      child: Container(
                                                    height: 40,
                                                    margin: EdgeInsets.only(
                                                        right: 20, left: 0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)]
                                                                ? Color(
                                                                    0xFF01579B)
                                                                : Colors.black),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                3),
                                                        color: medicalHistoryAnswers[
                                                                    medicalHistoryQuestions['items'].indexOf(
                                                                        question)] ==
                                                                question['options'][
                                                                    question['options']
                                                                        .indexOf(option)]
                                                            ? Color(0xFFE1F5FE)
                                                            : null),
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          medicalHistoryAnswers[
                                                              medicalHistoryQuestions[
                                                                      'items']
                                                                  .indexOf(
                                                                      question)] = question[
                                                                  'options'][
                                                              question[
                                                                      'options']
                                                                  .indexOf(
                                                                      option)];
                                                          var selectedOption = medicalHistoryAnswers[medicalHistoryQuestions['items'].indexOf(question)];
                                                          print('selectedOption $selectedOption');
                                                          medicationQuestions['items'].forEach((qtn) {
                                                            if(qtn['type'].contains('heart') || qtn['type'].contains('heart_bp_diabetes')) {

                                                              var medicalHistoryAnswerYes = false;
                                                              medicalHistoryAnswers.forEach((ans) {
                                                                if(ans == 'yes') {
                                                                  medicalHistoryAnswerYes = true;
                                                                  print('medicalHistoryAnswerYes $ans');
                                                                }
                                                              });
                                                              if (!medicalHistoryAnswerYes) {
                                                                medicationAnswers[medicationQuestions['items'].indexOf(qtn)] = '';
                                                                print('exceptional if');
                                                              }
                                                            } else if(qtn['type'].contains(question['type']) && selectedOption == 'no') {
                                                              medicationAnswers[medicationQuestions['items'].indexOf(qtn)] = '';
                                                              print('if');
                                                            }
                                                            print(qtn['type']);
                                                            print(question['type']);
                                                            print('qtn $qtn');
                                                            print('medicationAnswers ${medicationAnswers}');
                                                          });
                                                        });
                                                      },
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      child: Text(
                                                        getOptionText(context,
                                                            question, option),
                                                        style: TextStyle(
                                                            color: medicalHistoryAnswers[medicalHistoryQuestions[
                                                                            'items']
                                                                        .indexOf(
                                                                            question)] ==
                                                                    question[
                                                                        'options'][question[
                                                                            'options']
                                                                        .indexOf(
                                                                            option)]
                                                                ? kPrimaryColor
                                                                : null),
                                                      ),
                                                    ),
                                                  )),
                                                )
                                                .toList()
                                          ],
                                        )),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                );
                              }).toList()
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )),
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
    //


    // check if any medical histroy answer is yes. then return true if medication question is aspirin, or lower fat
    if (medicationQuestion['type'] == 'heart' || medicationQuestion['type'] == 'heart_bp_diabetes') {
      var medicalHistoryasYes = medicalHistoryAnswers.where((item) => item == 'yes');
      if (medicalHistoryasYes.isNotEmpty) {
        return true;
      }
    }

    if (medicationQuestion['type'].contains('medication')) {
      var mainType =
          medicationQuestion['type'].replaceAll('_regular_medication', '');
      var matchedMedicationQuestion = medicationQuestions['items']
          .where((item) => item['type'] == mainType)
          .first;
      var medicationAnswer = medicationAnswers[
          medicationQuestions['items'].indexOf(matchedMedicationQuestion)];
      if (medicationAnswer == 'yes') {
        return true;
      }

      return false;
    }

    var matchedQuestion;
    bool matchedHBD = false;
    medicalHistoryQuestions['items'].forEach((item) {
      if (item['type'] != null && item['type'] == medicationQuestion['type']) {
        matchedQuestion = item;
      } else if (medicationQuestion['type'] == 'heart_bp_diabetes') {
        if (item['type'] == 'stroke' ||
            item['type'] == 'heart' ||
            item['type'] == 'blood_pressure' ||
            item['type'] == 'diabetes') {
          var answer = medicalHistoryAnswers[
              medicalHistoryQuestions['items'].indexOf(item)];
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
      var answer = medicalHistoryAnswers[
          medicalHistoryQuestions['items'].indexOf(matchedQuestion)];
      if (answer == 'yes') {
        return true;
      }
    }
    return false;
  }

  checkAnswer() {
    setState(() {});

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
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PatientTopbar(),
                SizedBox(
                  height: 30,
                ),
                Container(
                  // alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: Text(
                    AppLocalizations.of(context).translate('medicationTitle'),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
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
                                  bottom: BorderSide(color: kBorderLighter))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...medicationQuestions['items'].map((question) {
                                if (checkMedicalHistoryAnswers(question)) {
                                  if (question['category'] == 'sub') {
                                    print('subCategoryQuestion $question');
                                    print('subCategory');
                                  }
                                  isEmpty = false;
                                  return Container(
                                    margin: question['category'] == 'sub'
                                        ? EdgeInsets.only(left: 40, bottom: 20)
                                        : null,
                                    padding: question['category'] == 'sub'
                                        ? EdgeInsets.symmetric(
                                            horizontal: 20,
                                          )
                                        : null,
                                    decoration: question['category'] == 'sub'
                                        ? BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black12),
                                            borderRadius:
                                                BorderRadius.circular(3))
                                        : null,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            child: Text(
                                          getQuestionText(context, question),
                                          style: TextStyle(
                                              fontSize: 18, height: 1.7),
                                        )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .5,
                                            child: Row(
                                              children: <Widget>[
                                                ...question['options']
                                                    .map(
                                                      (option) => Expanded(
                                                          child: Container(
                                                        height: 40,
                                                        margin: EdgeInsets.only(
                                                            right: 20, left: 0),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color: medicationQuestions[medicationQuestions['items'].indexOf(question)] ==
                                                                        question['options'][question['options'].indexOf(
                                                                            option)]
                                                                    ? Color(
                                                                        0xFF01579B)
                                                                    : Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                            color: medicationAnswers[medicationQuestions['items'].indexOf(question)] ==
                                                                    question['options']
                                                                        [question['options'].indexOf(option)]
                                                                ? Color(0xFFE1F5FE)
                                                                : null),
                                                        child: FlatButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              print(
                                                                  medicalHistoryAnswers);
                                                              medicationAnswers[
                                                                  medicationQuestions[
                                                                          'items']
                                                                      .indexOf(
                                                                          question)] = question[
                                                                  'options'][question[
                                                                      'options']
                                                                  .indexOf(
                                                                      option)];
                                                              checkAnswer();
                                                              // print(medicalHistoryAnswers);
                                                              // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                            });
                                                          },
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          child: Text(
                                                            getOptionText(
                                                                context,
                                                                question,
                                                                option),
                                                            style: TextStyle(
                                                                color: medicationAnswers[medicationQuestions['items'].indexOf(
                                                                            question)] ==
                                                                        question[
                                                                            'options'][question[
                                                                                'options']
                                                                            .indexOf(option)]
                                                                    ? kPrimaryColor
                                                                    : null),
                                                          ),
                                                        ),
                                                      )),
                                                    )
                                                    .toList()
                                              ],
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                } else
                                  return Container();
                              }).toList(),
                              isEmpty
                                  ? Container(
                                      child: Text(
                                        AppLocalizations.of(context)
                                                .translate('noQuestionFound') +
                                            ' ' +
                                            AppLocalizations.of(context)
                                                .translate('goToNextStep'),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                  : Container()
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )),
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
var heightEditingController = TextEditingController();
var weightEditingController = TextEditingController();
var bmiEditingController = TextEditingController();
var bloodSugerEditingController = TextEditingController();

class _MeasurementsState extends State<Measurements> {

  // @override
  // void initState() { 
  //   super.initState();
  //   bool _isBloodPressureEnable = false;
  //   bool _isBodyMeasurementsEnable = false;
  //   bool _isTestsEnable = false;
  // }

  calculateBmi() {
    if (heightEditingController != '' && weightEditingController.text != '') {
      var height = int.parse(heightEditingController.text) / 100;
      var weight = int.parse(weightEditingController.text);

      var bmi = weight / (height * height);

      bmiEditingController.text = bmi.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('bloodPressure'),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 24,
                ),
                Container(
                  height: 200, //250
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 0.5, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10)),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('systolic'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller:
                                                systolicEditingController,
                                            // enabled: _isBloodPressureEnable,
                                            // onChanged: (value) {},
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  top: 5, left: 10, right: 10),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: 0.0)),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate("diastolic"),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 14,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller:
                                                diastolicEditingController,
                                            // enabled: _isBloodPressureEnable,
                                            // onChanged: (value) {},
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  top: 5, left: 10, right: 10),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: 0.0)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate("pulseRate"),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 24,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: pulseRateEditingController,
                                      // enabled: _isBloodPressureEnable,
                                      // onChanged: (value) {},
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            top: 5, left: 10, right: 10),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 0.0)),
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
                            Text(
                                AppLocalizations.of(context)
                                    .translate("comment"),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.text,
                                  controller: commentsEditingController,
                                  // enabled: _isBloodPressureEnable,
                                  // onChanged: (value) {},
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        top: 5, left: 10, right: 10),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 0.0)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(height: 8),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     FlatButton(
                      //       color: Colors.blue[800],
                      //       textColor: Colors.white, 
                      //       onPressed: () {
                      //         print('before : $_isBloodPressureEnable');
                      //         setState(() {
                      //           _isBloodPressureEnable = true;
                      //         });
                      //         print('after : $_isBloodPressureEnable');
                      //       },
                      //       child: Text('Edit'),
                      //     ),
                      //     SizedBox(width: 20,),
                      //     FlatButton(
                      //       color: Colors.blue[800],
                      //       textColor: Colors.white, 
                      //       onPressed: () {
                      //         setState(() {
                      //           _isBloodPressureEnable = false;
                      //         });
                      //       },
                      //       child: Text('Save'),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate("bodyMeasurements"),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 24),
                      Container(
                        height: 190, // 240
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 0.5, color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                              .translate("height") +
                                          "*",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: heightEditingController,
                                      // enabled: _isBodyMeasurementsEnable,
                                      onChanged: (value) {
                                        calculateBmi();
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            top: 5, left: 10, right: 10),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 0.0)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate("cm"),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                              .translate("weight") +
                                          "*",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )),
                                  SizedBox(
                                    width: 28,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: weightEditingController,
                                      // enabled: _isBodyMeasurementsEnable,
                                      onChanged: (value) {
                                        calculateBmi();
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            top: 5, left: 10, right: 10),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 0.0)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate("kg"),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate("bmi"),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )),
                                  SizedBox(
                                    width: 56,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      readOnly: true,
                                      // enabled: false,
                                      controller: bmiEditingController,
                                      // enabled: _isBodyMeasurementsEnable,
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            top: 5, left: 10, right: 10),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 0.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 8),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     FlatButton(
                            //       color: Colors.blue[800],
                            //       textColor: Colors.white, 
                            //       onPressed: () {
                            //         setState(() {
                            //           _isBodyMeasurementsEnable = true;
                            //         });
                            //       },
                            //       child: Text('Edit'),
                            //     ),
                            //     SizedBox(width: 20,),
                            //     FlatButton(
                            //       color: Colors.blue[800],
                            //       textColor: Colors.white, 
                            //       onPressed: () {
                            //         setState(() {
                            //           _isBodyMeasurementsEnable = false;
                            //         });
                            //       },
                            //       child: Text('Save'),
                            //     ),                                                     
                            //   ],
                            // )             
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  AppLocalizations.of(context).translate("tests"),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 0.5, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                AppLocalizations.of(context)
                                    .translate("bloodSugar"),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 80,
                              height: 40,
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                controller: bloodSugerEditingController,
                                // enabled: _isTestsEnable,
                                onChanged: (value) {},
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      top: 5, left: 10, right: 10),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 0.0)),
                                ),
                              ),
                            ),
                            Radio(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: 'mg/dL',
                              groupValue: selectedGlucoseUnit,
                              activeColor: kPrimaryColor,
                              onChanged: (value) {
                                setState(() {
                                  selectedGlucoseUnit = value;
                                });
                              },
                            ),
                            Text('mg/dL',
                                style: TextStyle(color: Colors.black)),
                            SizedBox(
                              width: 20,
                            ),
                            Radio(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: 'mmol/L',
                              groupValue: selectedGlucoseUnit,
                              activeColor: kPrimaryColor,
                              onChanged: (value) {
                                setState(() {
                                  selectedGlucoseUnit = value;
                                });
                              },
                            ),
                            Text('mmol/L',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(AppLocalizations.of(context).translate("type"),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                            SizedBox(
                              width: 70,
                            ),
                            Container(
                              child: DropdownButton<String>(
                                items: <String>['FBS', 'RBS', 'Others']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                value: selectedBloodSugarType,
                                onChanged: (String newValue) {
                                  setState(() {
                                    selectedBloodSugarType = newValue;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      // SizedBox(height: 8),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     FlatButton(
                      //       color: Colors.blue[800],
                      //       textColor: Colors.white, 
                      //       onPressed: () {
                      //         setState(() {
                      //           _isTestsEnable = true;
                      //         });
                      //       },
                      //       child: Text('Edit'),
                      //     ),
                      //     SizedBox(width: 20,),
                      //     FlatButton(
                      //       color: Colors.blue[800],
                      //       textColor: Colors.white, 
                      //       onPressed: () {
                      //         setState(() {
                      //           _isTestsEnable = false;
                      //         });
                      //       },
                      //       child: Text('Save'),
                      //     ),                                                     
                      //   ],
                      // )             
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class RecommendedCounselling extends StatefulWidget {
  @override
  _RecommendedCounsellingState createState() => _RecommendedCounsellingState();
}

var isReferralRequired = null;
bool dietTitleAdded = false;
bool tobaccoTitleAdded = false;

class _RecommendedCounsellingState extends State<RecommendedCounselling> {

  bool activityTitleAdded = false;

  @override
  initState() {
    super.initState();
    dietTitleAdded = false;
    tobaccoTitleAdded = false;
    isReferralRequired = null;
  }

  checkCounsellingQuestions(counsellingQuestion) {
    // if (medicationQuestions['items'].length - 1 == medicationQuestions['items'].indexOf(medicationQuestion)) {
    //   if (showLastMedicationQuestion) {
    //     return true;
    //   }

    // }

    if (counsellingQuestion['type'] == 'medical-adherence') {
      print('medicationAdh $medicationAnswers');
      if (medicationAnswers[1] == 'no' || medicationAnswers[3] == 'no' ||medicationAnswers[5] == 'no' || medicationAnswers[7] == 'no') {
        return true;
      }
      return false;
    }

    if (counsellingQuestion['type'] == 'physical-activity-high') {
      if (riskAnswers[9] == 'no' || riskAnswers[10] == 'no') {
        return true;
      }
      return false;
    }

    var matchedQuestion;
    riskQuestions['items'].forEach((item) {
      if (item['type'] != null && item['type'] == counsellingQuestion['type']) {
        matchedQuestion = item;
      }
    });

    if (matchedQuestion != null) {
      // print(matchedQuestion.first);
      var answer = riskAnswers[riskQuestions['items'].indexOf(matchedQuestion)];
      if ((matchedQuestion['type'] == 'eat-vegetables' ||
          matchedQuestion['type'] == 'physical-activity-high')) {
        if (answer == 'no') {
          return true;
        }
      } else {
        if (answer == 'yes') {
          return true;
        }
        return false;
      }
    }
    return false;
  }

  addCounsellingGroupTitle(question) {
    if (question['group'] == 'unhealthy-diet') {
      print('unhealthy-diet');
      print(dietTitleAdded);
      if (!dietTitleAdded) {
        dietTitleAdded = true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            Container(
                margin: EdgeInsets.only(top: 25, bottom: 30),
                child: Text(
                    AppLocalizations.of(context).translate('unhealthyDiet'),
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          ],
        );
      }
    } else if (question['group'] == 'tobacco') {
      print('tobacco');
      print(tobaccoTitleAdded);
      if (!tobaccoTitleAdded) {
        tobaccoTitleAdded = true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            Container(
                margin: EdgeInsets.only(top: 25, bottom: 30),
                child: Text(
                    AppLocalizations.of(context).translate('tobaccoUse'),
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          ],
        );
      }
    } else if (question['type'] == 'physical-activity-high') {
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
            child: Text('$title',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PatientTopbar(),
                SizedBox(
                  height: 30,
                ),
                Container(
                    // alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Text(
                        //   AppLocalizations.of(context).translate('tobaccoUse'),
                        //   style: TextStyle(
                        //       fontSize: 20, fontWeight: FontWeight.w500),
                        // ),
                        Text(
                          AppLocalizations.of(context)
                              .translate('wasCounsellingProvided'),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(bottom: 35, top: 20),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: kBorderLighter))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...counsellingQuestions['items'].map((question) {
                                if (checkCounsellingQuestions(question))
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      addCounsellingGroupTitle(question),
                                      Container(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getQuestionText(context, question),
                                            style: TextStyle(
                                                fontSize: 18, height: 1.7),
                                          ),
                                          Container(
                                              width: 240,
                                              child: Row(
                                                children: <Widget>[
                                                  ...question['options']
                                                      .map(
                                                        (option) => Expanded(
                                                            child: Container(
                                                          height: 25,
                                                          width: 100,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 20,
                                                                  left: 0),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: counsellingAnswers[counsellingQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)]
                                                                      ? Color(
                                                                          0xFF01579B)
                                                                      : Colors
                                                                          .black),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              color: counsellingAnswers[counsellingQuestions['items'].indexOf(
                                                                          question)] ==
                                                                      question['options']
                                                                          [question['options'].indexOf(option)]
                                                                  ? Color(0xFFE1F5FE)
                                                                  : null),
                                                          child: FlatButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                dietTitleAdded = false;
                                                                tobaccoTitleAdded = false;
                                                                counsellingAnswers[counsellingQuestions['items'].indexOf(question)] = question['options'][question['options'].indexOf(option)];
                                                                // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                              });
                                                            },
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            child: Text(
                                                              getOptionText(
                                                                  context,
                                                                  question,
                                                                  option),
                                                              style: TextStyle(
                                                                  color: counsellingAnswers[counsellingQuestions['items'].indexOf(
                                                                              question)] ==
                                                                          question['options']
                                                                              [
                                                                              question['options'].indexOf(option)]
                                                                      ? kPrimaryColor
                                                                      : null),
                                                            ),
                                                          ),
                                                        )),
                                                      )
                                                      .toList()
                                                ],
                                              )),
                                        ],
                                      )),
                                      SizedBox(
                                        height: 20,
                                      )
                                    ],
                                  );
                                else
                                  return Container();
                              }).toList(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 20),
                                  Container(
                                      child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)
                                            .translate('referralRequired'),
                                        style: TextStyle(
                                            fontSize: 18,
                                            height: 1.7,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                          width: 240,
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                  child: Container(
                                                height: 25,
                                                width: 100,
                                                margin: EdgeInsets.only(
                                                    right: 20, left: 0),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: (isReferralRequired !=
                                                                    null &&
                                                                isReferralRequired)
                                                            ? Color(0xFF01579B)
                                                            : Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                    color: (isReferralRequired !=
                                                                null &&
                                                            isReferralRequired)
                                                        ? Color(0xFFE1F5FE)
                                                        : null),
                                                child: FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      dietTitleAdded = false;
                                                      tobaccoTitleAdded = false;
                                                      isReferralRequired = true;
                                                    });
                                                  },
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate('yes'),
                                                    style: TextStyle(
                                                        color: (isReferralRequired !=
                                                                    null &&
                                                                isReferralRequired)
                                                            ? kPrimaryColor
                                                            : null),
                                                  ),
                                                ),
                                              )),
                                              Expanded(
                                                  child: Container(
                                                height: 25,
                                                width: 100,
                                                margin: EdgeInsets.only(
                                                    right: 20, left: 0),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: (isReferralRequired ==
                                                                    null ||
                                                                isReferralRequired)
                                                            ? Colors.black
                                                            : Color(
                                                                0xFF01579B)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                    color: (isReferralRequired ==
                                                                null ||
                                                            isReferralRequired)
                                                        ? null
                                                        : Color(0xFFE1F5FE)),
                                                child: FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      dietTitleAdded = false;
                                                      tobaccoTitleAdded = false;
                                                      isReferralRequired = false;
                                                    });
                                                  },
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate('NO'),
                                                    style: TextStyle(
                                                        color: (isReferralRequired ==
                                                                    null ||
                                                                isReferralRequired)
                                                            ? null
                                                            : kPrimaryColor),
                                                  ),
                                                ),
                                              )),
                                            ],
                                          )),
                                    ],
                                  )),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )),
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
      return titleWidget(
          AppLocalizations.of(context).translate('unhealthyDiet'));
    } else if (question['type'] == 'physical-activity-high') {
      return titleWidget(
          AppLocalizations.of(context).translate('physicalActivity'));
    } else if (question['type'] == 'alcohol-status') {
      return titleWidget(AppLocalizations.of(context).translate('alcohol'));
    }

    return Container();
  }

  Widget titleWidget(title) {
    return Container(
        margin: EdgeInsets.only(top: 25, bottom: 30),
        child: Text('$title',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PatientTopbar(),
                SizedBox(
                  height: 30,
                ),
                Container(
                  // alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: Text(
                    AppLocalizations.of(context).translate('riskFactors'),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
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
                                  bottom: BorderSide(color: kBorderLighter))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...riskQuestions['items'].map((question) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    addRiskGroupTitle(question),
                                    Container(
                                        child: Text(
                                      getQuestionText(context, question),
                                      style:
                                          TextStyle(fontSize: 18, height: 1.7),
                                    )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Row(
                                          children: <Widget>[
                                            ...question['options']
                                                .map(
                                                  (option) => Expanded(
                                                      child: Container(
                                                    height: 40,
                                                    margin: EdgeInsets.only(
                                                        right: 20, left: 0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: riskAnswers[riskQuestions['items'].indexOf(question)] ==
                                                                    question['options']
                                                                        [
                                                                        question['options']
                                                                            .indexOf(
                                                                                option)]
                                                                ? Color(
                                                                    0xFF01579B)
                                                                : Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        color: riskAnswers[riskQuestions['items'].indexOf(question)] ==
                                                                question['options']
                                                                    [question['options'].indexOf(option)]
                                                            ? Color(0xFFE1F5FE)
                                                            : null),
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          riskAnswers[riskQuestions[
                                                                      'items']
                                                                  .indexOf(
                                                                      question)] =
                                                              question[
                                                                  'options'][question[
                                                                      'options']
                                                                  .indexOf(
                                                                      option)];
                                                          // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                        });
                                                      },
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      child: Text(
                                                        getOptionText(context,
                                                            question, option),
                                                        style: TextStyle(
                                                            color: riskAnswers[riskQuestions[
                                                                            'items']
                                                                        .indexOf(
                                                                            question)] ==
                                                                    question[
                                                                        'options'][question[
                                                                            'options']
                                                                        .indexOf(
                                                                            option)]
                                                                ? kPrimaryColor
                                                                : null),
                                                      ),
                                                    ),
                                                  )),
                                                )
                                                .toList()
                                          ],
                                        )),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                );
                              }).toList()
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class InitialCounselling extends StatefulWidget {
  _EditIncompleteEncounterChwScreenState parent;
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
              SizedBox(
                height: 30,
              ),
              Container(
                // alignment: Alignment.center,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                child: Text(
                  AppLocalizations.of(context).translate("requiredDevice"),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(bottom: 35, top: 20),
                        decoration: BoxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: ExpandableNotifier(
                                  child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: kBorderLighter)),
                                  child: Column(
                                    children: <Widget>[
                                      ScrollOnExpand(
                                        scrollOnExpand: true,
                                        scrollOnCollapse: false,
                                        child: ExpandablePanel(
                                          theme: const ExpandableThemeData(
                                            headerAlignment:
                                                ExpandablePanelHeaderAlignment
                                                    .center,
                                            tapBodyToCollapse: true,
                                          ),
                                          header: Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          'smokingCessation'),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ),
                                          expanded: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Checkbox(
                                                    activeColor: kPrimaryColor,
                                                    value: false,
                                                    onChanged: (value) {},
                                                  ),
                                                  Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              "harmSmoking"),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18)),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Checkbox(
                                                    activeColor: kPrimaryColor,
                                                    value: true,
                                                    onChanged: (value) {},
                                                  ),
                                                  Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              "stopSmoking"),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18)),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          "givenPatient"),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18)),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .5,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                          child: Container(
                                                        height: 40,
                                                        margin: EdgeInsets.only(
                                                            right: 20, left: 0),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color:
                                                                    kPrimaryColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                            color: Color(
                                                                0xFFE1F5FE)),
                                                        child: FlatButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                            });
                                                          },
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "yes"),
                                                            style: TextStyle(
                                                                color:
                                                                    kPrimaryColor),
                                                          ),
                                                        ),
                                                      )),
                                                      Expanded(
                                                          child: Container(
                                                        height: 40,
                                                        margin: EdgeInsets.only(
                                                            right: 20, left: 0),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                            color: null),
                                                        child: FlatButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              // _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                                            });
                                                          },
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "no"),
                                                            style: TextStyle(
                                                                color: null),
                                                          ),
                                                        ),
                                                      )),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          builder: (_, collapsed, expanded) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Expandable(
                                                collapsed: collapsed,
                                                expanded: expanded,
                                                theme:
                                                    const ExpandableThemeData(
                                                        crossFadePoint: 0),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: ExpandableNotifier(
                                  child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: kBorderLighter)),
                                  child: Column(
                                    children: <Widget>[
                                      ScrollOnExpand(
                                        scrollOnExpand: true,
                                        scrollOnCollapse: false,
                                        child: ExpandablePanel(
                                          theme: const ExpandableThemeData(
                                            headerAlignment:
                                                ExpandablePanelHeaderAlignment
                                                    .center,
                                            tapBodyToCollapse: true,
                                          ),
                                          header: Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate("diet"),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ),
                                          expanded: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          builder: (_, collapsed, expanded) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Expandable(
                                                collapsed: collapsed,
                                                expanded: expanded,
                                                theme:
                                                    const ExpandableThemeData(
                                                        crossFadePoint: 0),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: ExpandableNotifier(
                                  child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: kBorderLighter)),
                                  child: Column(
                                    children: <Widget>[
                                      ScrollOnExpand(
                                        scrollOnExpand: true,
                                        scrollOnCollapse: false,
                                        child: ExpandablePanel(
                                          theme: const ExpandableThemeData(
                                            headerAlignment:
                                                ExpandablePanelHeaderAlignment
                                                    .center,
                                            tapBodyToCollapse: true,
                                          ),
                                          header: Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          "physicalActivity"),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ),
                                          expanded: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          builder: (_, collapsed, expanded) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Expandable(
                                                collapsed: collapsed,
                                                expanded: expanded,
                                                theme:
                                                    const ExpandableThemeData(
                                                        crossFadePoint: 0),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: ExpandableNotifier(
                                  child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: kBorderLighter)),
                                  child: Column(
                                    children: <Widget>[
                                      ScrollOnExpand(
                                        scrollOnExpand: true,
                                        scrollOnCollapse: false,
                                        child: ExpandablePanel(
                                          theme: const ExpandableThemeData(
                                            headerAlignment:
                                                ExpandablePanelHeaderAlignment
                                                    .center,
                                            tapBodyToCollapse: true,
                                          ),
                                          header: Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          "medicationAdherence"),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ),
                                          expanded: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          builder: (_, collapsed, expanded) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Expandable(
                                                collapsed: collapsed,
                                                expanded: expanded,
                                                theme:
                                                    const ExpandableThemeData(
                                                        crossFadePoint: 0),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: ExpandableNotifier(
                                  child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: kBorderLighter)),
                                  child: Column(
                                    children: <Widget>[
                                      ScrollOnExpand(
                                        scrollOnExpand: true,
                                        scrollOnCollapse: false,
                                        child: ExpandablePanel(
                                          theme: const ExpandableThemeData(
                                            headerAlignment:
                                                ExpandablePanelHeaderAlignment
                                                    .center,
                                            tapBodyToCollapse: true,
                                          ),
                                          header: Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate("alcohol"),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ),
                                          expanded: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          builder: (_, collapsed, expanded) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Expandable(
                                                collapsed: collapsed,
                                                expanded: expanded,
                                                theme:
                                                    const ExpandableThemeData(
                                                        crossFadePoint: 0),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: FlatButton(
                                        onPressed: () async {
                                          print("hello");

                                          widget.parent.setLoader(true);

                                          var patient = Patient().getPatient();

                                          print(patient['data']['age']);
                                          // return;
                                          // var response = await AssessmentController().createOnlyAssessment('new patient questionnaire', '', '');

                                          widget.parent.setLoader(false);
                                          print('successss');
                                          return;

                                          if (patient['data']['age'] != null &&
                                              patient['data']['age'] > 40) {
                                            var data = {
                                              'meta': {
                                                'patient_id': Patient()
                                                    .getPatient()['id'],
                                                "collected_by":
                                                    Auth().getAuth()['uid'],
                                                "status": "pending"
                                              },
                                              'body': {},
                                              'referred_from':
                                                  'new questionnaire'
                                            };
                                            widget.parent.goToHome(true, data);

                                            return;
                                          }

                                    widget.parent.goToHome(false, null);

                                          print('response');
                                          // print(response);
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'completeQuestionnaire')
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ));
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
              SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate("patientTemperature"),
                  style: TextStyle(fontSize: 21),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: PrimaryTextField(
                  hintText:
                      AppLocalizations.of(context).translate('tempReading'),
                  controller: _temperatureController,
                  topPaadding: 10,
                  bottomPadding: 10,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  widget.parent.nextStep();
                },
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,
                  child: Text(
                      AppLocalizations.of(context)
                          .translate('skipDeviceUnavailable'),
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              )
            ],
          ),
        ));
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
              SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate("whatPressure"),
                  style: TextStyle(fontSize: 21),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 170),
                width: 300,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
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
                    Text(AppLocalizations.of(context).translate("leftArm"),
                        style: TextStyle(color: Colors.black)),
                    SizedBox(
                      width: 30,
                    ),
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
                    Text(AppLocalizations.of(context).translate("leftArm"),
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 170),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: PrimaryTextField(
                        hintText:
                            AppLocalizations.of(context).translate('systolic'),
                        controller: _systolicController,
                        topPaadding: 10,
                        bottomPadding: 10,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '/',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: PrimaryTextField(
                        hintText:
                            AppLocalizations.of(context).translate('diastolic'),
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
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  widget.parent.nextStep();
                },
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,
                  child: Text(
                      AppLocalizations.of(context)
                          .translate('skipDeviceUnavailable'),
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              )
            ],
          ),
        ));
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
              SizedBox(
                height: 30,
              ),
              Container(
                  padding: EdgeInsets.only(bottom: 35, top: 20),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: kBorderLighter))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                          // child: Text(_questions['items'][0]['question'],
                          child: Text(
                            firstQuestionText,
                            style: TextStyle(
                                fontSize: 18,
                                height: 1.7,
                                fontWeight: FontWeight.w500),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                          width: MediaQuery.of(context).size.width * .5,
                          child: Row(
                            children: <Widget>[
                              ...firstQuestionOptions
                                  .map(
                                    (option) => Expanded(
                                        child: Container(
                                      height: 40,
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                          // border: Border.all(width: 1, color:  Color(0xFF01579B)),
                                          border: Border.all(
                                              width: 1,
                                              color: firstAnswer == option
                                                  ? Color(0xFF01579B)
                                                  : Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          color: firstAnswer == option
                                              ? Color(0xFFE1F5FE)
                                              : null
                                          // color: Color(0xFFE1F5FE)
                                          ),
                                      child: FlatButton(
                                        onPressed: () {
                                          setState(() {
                                            firstAnswer = option;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        child: Text(
                                          option.toUpperCase(),
                                          style: TextStyle(
                                              color: firstAnswer == option
                                                  ? kPrimaryColor
                                                  : null),
                                          // style: TextStyle(color: kPrimaryColor),
                                        ),
                                      ),
                                    )),
                                  )
                                  .toList()
                            ],
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                          // child: Text(_questions['items'][0]['question'],
                          child: Text(
                            secondQuestionText,
                            style: TextStyle(
                                fontSize: 18,
                                height: 1.7,
                                fontWeight: FontWeight.w500),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                          width: MediaQuery.of(context).size.width * .5,
                          child: Row(
                            children: <Widget>[
                              ...secondQuestionOptions
                                  .map(
                                    (option) => Expanded(
                                        child: Container(
                                      height: 40,
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                          // border: Border.all(width: 1, color:  Color(0xFF01579B)),
                                          border: Border.all(
                                              width: 1,
                                              color: secondAnswer == option
                                                  ? Color(0xFF01579B)
                                                  : Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          color: secondAnswer == option
                                              ? Color(0xFFE1F5FE)
                                              : null
                                          // color: Color(0xFFE1F5FE)
                                          ),
                                      child: FlatButton(
                                        onPressed: () {
                                          setState(() {
                                            secondAnswer = option;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        child: Text(
                                          option.toUpperCase(),
                                          style: TextStyle(
                                              color: secondAnswer == option
                                                  ? kPrimaryColor
                                                  : null),
                                          // style: TextStyle(color: kPrimaryColor),
                                        ),
                                      ),
                                    )),
                                  )
                                  .toList()
                            ],
                          )),
                    ],
                  )),
            ],
          ),
        ));
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
              SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate("bloodGlucoseLevel"),
                  style: TextStyle(fontSize: 21),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 80),
                width: 300,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
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
                    Text(AppLocalizations.of(context).translate('fasting'),
                        style: TextStyle(color: Colors.black)),
                    SizedBox(
                      width: 30,
                    ),
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
                    Text(AppLocalizations.of(context).translate('random'),
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 80),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: PrimaryTextField(
                        hintText: 'Fasting Glucose',
                        controller: _glucoseController,
                        topPaadding: 10,
                        bottomPadding: 10,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
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
                    SizedBox(
                      width: 20,
                    ),
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
                  hint: Text(
                    AppLocalizations.of(context).translate("selectDevice"),
                    style: TextStyle(fontSize: 20, color: kTextGrey),
                  ),
                  decoration: InputDecoration(
                    fillColor: kSecondaryTextField,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    border: UnderlineInputBorder(
                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    )),
                  ),
                  items: [
                    ...devices
                        .map((item) => DropdownMenuItem(
                            child: Text(item['name']),
                            value: devices.indexOf(item)))
                        .toList(),
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
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  widget.parent.nextStep();
                },
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,
                  child: Text(
                      AppLocalizations.of(context)
                          .translate('skipDeviceUnavailable'),
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              )
            ],
          ),
        ));
  }
}
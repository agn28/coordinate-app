import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/screens/patients/ncd/followup_patient_summary_screen.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/unwell/medical_recomendation_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../custom-classes/custom_stepper.dart';

// var medicalHistoryQuestions = {};
// var medicalHistoryAnswers = [];
var medicationQuestions = {};
var medicationAnswers = [];
var dynamicMedicationTitles = [];
var dynamicMedicationQuestions = {};
var dynamicMedicationAnswers = [];
// var riskQuestions = {};
// var riskAnswers = [];
// var relativeQuestions = {};
// var relativeAnswers = [];
// var personalQuestions = {};

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

class EditIncompleteShortFollowupScreen extends StatefulWidget {
  static const path = '/editIncompleteShortFollowup';
  @override
  _EditIncompleteShortFollowupScreenState createState() =>
      _EditIncompleteShortFollowupScreenState();
}

class _EditIncompleteShortFollowupScreenState extends State<EditIncompleteShortFollowupScreen> {
  int _currentStep = 0;
  String nextText = 'NEXT';
  bool nextHide = false;
  var encounter;
  var observations = [];

  @override
  void initState() {
    super.initState();
    print("Edit incomplete short Followup");
    _checkAuth();
    clearForm();
    isLoading = false;
    prepareQuestions();
    prepareAnswers();
    getMedications();
    getIncompleteFollowup();

    print(Language().getLanguage());
    nextText = (Language().getLanguage() == 'Bengali') ? 'পরবর্তী' : 'NEXT';
  }

  getIncompleteFollowup() async {
    print("getIncompleteFollowup");

    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }

    setState(() {
      isLoading = true;
    });
    var patientId = Patient().getPatient()['id'];
    var data = await AssessmentController().getIncompleteEncounterWithObservation(patientId, key:'type', value:'follow up visit (center)');
    setState(() {
      isLoading = false;
    });

    if (data == null) {
      return;
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
      return;
    } else if (data['error'] != null && data['error']) {
      return;
    }

    setState(() {
      encounter = data['data']['assessment'];
      print("encounter: $encounter");
      observations = data['data']['observations'];
      print("observations: $observations");
    });

    print("observations: $observations");

    populatePreviousAnswers();
  }

  populatePreviousAnswers() {
    print("testest");
    observations.forEach((obs) {
      print('obs $obs');
      if (obs['body']['type'] == 'survey') {
        print('into survey');
        var obsData = obs['body']['data'];
        if (obsData['name'] == 'dynamic_medication') {
          print('into dynamic_medication');
          var keys = obsData.keys.toList();
          print(keys);
          keys.forEach((key) {
            if (obsData[key] != '') {
              print('into keys');
              if(dynamicMedicationQuestions.isNotEmpty)
              {
                var matchedMhq = dynamicMedicationQuestions['items'].where((mhq) => mhq['key'] == key);
                if (matchedMhq.isNotEmpty) {
                  matchedMhq = matchedMhq.first;
                  setState(() {
                    print("medication: ${obsData[key]}");
                    dynamicMedicationAnswers[dynamicMedicationQuestions['items'].indexOf(matchedMhq)] = obsData[key];
                    print("medicationAnswers");
                    //print(medicationAnswers[medicationQuestions['items'].indexOf(matchedMhq)]);
                  });
                }
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
          if (obsData['name'] == 'waist' && obsData['value'] != '') {
            print('into waist');
            var waistText = obsData['value'];
            waistEditingController.text = '${obsData['value']}';
            print(waistText);
          }
          if (obsData['name'] == 'hip' && obsData['value'] != '') {
            print('into hip');
            var hipText = obsData['value'];
            hipEditingController.text = '${obsData['value']}';
            print(hipText);
          }
        }
      }
      if (obs['body']['type'] == 'blood_test') {
        print('into blood test');
        var obsData = obs['body']['data'];
        if (obsData.isNotEmpty) {
          print(obsData['name']);
          if (obsData['name'] == 'creatinine' && obsData['value'] != '') {
            print('into creatinine');
            var creatinineText = obsData['value'];
            creatinineController.text = '${obsData['value']}';
            selectedCreatinineUnit = obsData['unit'];
            print(creatinineText);
          }
          if (obsData['name'] == 'a1c' && obsData['value'] != '') {
            print('into a1c');
            var hba1cText = obsData['value'];
            hba1cController.text = '${obsData['value']}';
            selectedHba1cUnit = obsData['unit'];
            print(hba1cText);
          }
          if (obsData['name'] == 'total_cholesterol' &&
              obsData['value'] != '') {
            print('into total_cholesterol');
            var totalCholesterolText = obsData['value'];
            cholesterolController.text = '${obsData['value']}';
            selectedCholesterolUnit = obsData['unit'];
            print(totalCholesterolText);
          }
          if (obsData['name'] == 'potassium' && obsData['value'] != '') {
            print('into potassium');
            var potassiumText = obsData['value'];
            potassiumController.text = '${obsData['value']}';
            selectedPotassiumUnit = obsData['unit'];
            print(potassiumText);
          }
          if (obsData['name'] == 'ldl' && obsData['value'] != '') {
            print('into ldl');
            var ldlText = obsData['value'];
            ldlController.text = '${obsData['value']}';
            selectedLdlUnit = obsData['unit'];
            print(ldlText);
          }
          if (obsData['name'] == 'blood_sugar' && obsData['type'] == null && obsData['value'] != '') {
            print('into blood_sugar');
            var bloodSugarText = obsData['value'];
            randomBloodController.text = '${obsData['value']}';
            selectedRandomBloodUnit = obsData['unit'];
            print(bloodSugarText);
          }
          if ((obsData['name'] == 'blood_glucose' || obsData['name'] == 'blood_sugar') && (obsData['type'] != null && obsData['type'] == 'fasting') && obsData['value'] != '') {
            print('into blood_glucose');
            var bloodGlucoseText = obsData['value'];
            fastingBloodController.text = '${obsData['value']}';
            selectedFastingBloodUnit = obsData['unit'];
            print(bloodGlucoseText);
          }
          if (obsData['name'] == 'hdl' && obsData['value'] != '') {
            print('into hdl');
            var hdlText = obsData['value'];
            hdlController.text = '${obsData['value']}';
            selectedHdlUnit = obsData['unit'];
            print(hdlText);
          }
          if (obsData['name'] == 'ketones' && obsData['value'] != '') {
            print('into ketones');
            var ketonesText = obsData['value'];
            ketonesController.text = '${obsData['value']}';
            selectedKetonesUnit = obsData['unit'];
            print(ketonesText);
          }
          if (obsData['name'] == 'protein' && obsData['value'] != '') {
            print('into protein');
            var proteinText = obsData['value'];
            proteinController.text = '${obsData['value']}';
            selectedProteinUnit = obsData['unit'];
            print(proteinText);
          }
          if (obsData['name'] == 'sodium' && obsData['value'] != '') {
            print('into sodium');
            var sodiumText = obsData['value'];
            sodiumController.text = '${obsData['value']}';
            selectedSodiumUnit = obsData['unit'];
            print(sodiumText);
          }
          if (obsData['name'] == 'blood_glucose' && obsData['value'] != '') {
            print('into blood_glucose');
            var bloodGlucoseText = obsData['value'];
            fastingBloodController.text = '${obsData['value']}';
            selectedFastingBloodUnit = obsData['unit'];
            print(bloodGlucoseText);
          }
          if (obsData['name'] == 'triglycerides' && obsData['value'] != '') {
            print('into triglycerides');
            var triglyceridesText = obsData['value'];
            tgController.text = '${obsData['value']}';
            selectedTgUnit = obsData['unit'];
            print(triglyceridesText);
          }
          if (obsData['name'] == '2habf' && obsData['value'] != '') {
            print('into 2habf');
            var habfText = obsData['value'];
            habfController.text = '${obsData['value']}';
            selectedHabfUnit = obsData['unit'];
            print(habfText);
          }
        }
      }
    });
  }
  getMedications() async {
    print("getMedications");
    dynamicMedicationQuestions = {};

    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }

    // setState(() {
    //   isLoading = true;
    // });
    var patientId = Patient().getPatient()['id'];
    var data = await PatientController().getMedicationsByPatient(patientId);
    // setState(() {
    //   isLoading = false;
    // });

    if (data == null) {
      return;
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
      return;
    } else if (data['error'] != null && data['error']) {
      return;
    } else if (data['data'] != null) {
      var q = await prepareDynamicMedicationQuestions(data['data']);
      print('q $q');
      setState(() {
        dynamicMedicationQuestions = q;
        print("medication: $dynamicMedicationQuestions");
      });

    }
  }

  prepareDynamicMedicationQuestions(medications) { 
    var prepareQuestion = [];
    dynamicMedicationTitles = [];
    dynamicMedicationAnswers = [];
    for(var item in medications) {
      dynamicMedicationTitles.add(item['body']['title']);
      prepareQuestion.add({
        'question': 'Are you taking ${item['body']['title']} regularly?',
        'question_bn': 'আপনি কি নিয়মিত ${item['body']['title']} খাচ্ছেন?',
        'options': ['yes', 'no'],
        'options_bn': ['হ্যা', 'না'],
        'key': '${item['body']['title']}'
      });
      dynamicMedicationAnswers.add('');
    }
    dynamicMedicationQuestions['items'] = prepareQuestion;
    print(dynamicMedicationTitles);  
    print(dynamicMedicationQuestions["items"]);  
    return dynamicMedicationQuestions;
  }

  prepareQuestions() {
    // medicalHistoryQuestions = Questionnaire().questions['new_patient']['medical_history'];
    medicationQuestions = Questionnaire().questions['new_patient']['medication'];
    // riskQuestions = Questionnaire().questions['new_patient']['risk_factors'];
    // relativeQuestions = Questionnaire().questions['new_patient']['relative_problems'];
  }

  prepareAnswers() {
    // medicalHistoryAnswers = [];
    medicationAnswers = [];
    // riskAnswers = [];
    // relativeAnswers = [];
    // medicalHistoryQuestions['items'].forEach((qtn) {
    //   medicalHistoryAnswers.add('');
    // });
    medicationQuestions['items'].forEach((qtn) {
      medicationAnswers.add('');
    });
    // riskQuestions['items'].forEach((qtn) {
    //   riskAnswers.add('');
    // });
    // relativeQuestions['items'].forEach((qtn) {
    //   relativeAnswers.add('');
    // });
  }

  clearForm() {
    systolicEditingController.text = '';
    diastolicEditingController.text = '';
    pulseRateEditingController.text = '';
    heightEditingController.text = '';
    weightEditingController.text = '';
    waistEditingController.text = '';
    hipEditingController.text = '';

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

    selectedRandomBloodUnit = 'mmol/L';
    selectedFastingBloodUnit = 'mmol/L';
    selectedHabfUnit = 'mmol/L';
    selectedHba1cUnit = 'mmol/L';
    selectedCholesterolUnit = 'mmol/L';
    selectedLdlUnit = 'mmol/L';
    selectedHdlUnit = 'mmol/L';
    selectedTgUnit = 'mmol/L';
    selectedCreatinineUnit = 'mmol/L';
    selectedSodiumUnit = 'mmol/L';
    selectedPotassiumUnit = 'mmol/L';
    selectedKetonesUnit = 'mmol/L';
    selectedProteinUnit = 'mmol/L';
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
      Navigator.of(context).pushNamed(
        '/home',
      );
    }
  }

  createObservations() {
    print('_currentStep $_currentStep');
    if (diastolicEditingController.text != '' &&
        systolicEditingController.text != '' &&
        pulseRateEditingController.text != '') {
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
      print('weightEditingController.text');
      print(weightEditingController.text);
      BodyMeasurement()
          .addItem('weight', weightEditingController.text, 'kg', '', '');
    }
    if (waistEditingController.text != '') {
      BodyMeasurement()
          .addItem('waist', waistEditingController.text, 'cm', '', '');
    }
    if (hipEditingController.text != '') {
      BodyMeasurement().addItem('hip', hipEditingController.text, 'cm', '', '');
    }

    BodyMeasurement().addBmItem();
    print('BodyMeasurement().bmItems ${BodyMeasurement().bmItems}');

    if (randomBloodController.text != '') {
      BloodTest().addItem('blood_sugar', randomBloodController.text,
          selectedRandomBloodUnit, '', '');
    }
    if (fastingBloodController.text != '') {
      BloodTest().addItem('blood_glucose', fastingBloodController.text,
          selectedFastingBloodUnit, '', '');
    }
    if (habfController.text != '') {
      BloodTest()
          .addItem('2habf', habfController.text, selectedHabfUnit, '', '');
    }
    if (hba1cController.text != '') {
      BloodTest()
          .addItem('a1c', hba1cController.text, selectedHba1cUnit, '', '');
    }

    if (cholesterolController.text != '') {
      BloodTest().addItem('total_cholesterol', cholesterolController.text,
          selectedCholesterolUnit, '', '');
    }

    if (ldlController.text != '') {
      BloodTest().addItem('ldl', ldlController.text, selectedLdlUnit, '', '');
    }
    if (hdlController.text != '') {
      BloodTest().addItem('hdl', hdlController.text, selectedHdlUnit, '', '');
    }
    if (tgController.text != '') {
      BloodTest()
          .addItem('triglycerides', tgController.text, selectedTgUnit, '', '');
    }
    if (creatinineController.text != '') {
      BloodTest().addItem('creatinine', creatinineController.text,
          selectedCreatinineUnit, '', '');
    }
    if (sodiumController.text != '') {
      BloodTest()
          .addItem('sodium', sodiumController.text, selectedSodiumUnit, '', '');
    }
    if (potassiumController.text != '') {
      BloodTest().addItem(
          'potassium', potassiumController.text, selectedPotassiumUnit, '', '');
    }
    if (ketonesController.text != '') {
      BloodTest().addItem(
          'ketones', ketonesController.text, selectedKetonesUnit, '', '');
    }
    if (proteinController.text != '') {
      BloodTest().addItem(
          'protein', proteinController.text, selectedProteinUnit, '', '');
    }

    BloodTest().addBtItem();
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
        title: Text(
            AppLocalizations.of(context).translate('editIncompleteFollowup')),
      ),
      body: !isLoading
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
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
                  child: _currentStep != 0
                      ? FlatButton(
                          onPressed: () {
                            setState(() {
                              nextHide = false;
                              _currentStep = _currentStep - 1;
                              nextText = AppLocalizations.of(context)
                                  .translate('next');
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.chevron_left),
                              Text(
                                  AppLocalizations.of(context)
                                      .translate('back'),
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        )
                      : Text('')),
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
                          child: Icon(
                            Icons.lens,
                            size: 15,
                            color: _currentStep == index
                                ? kPrimaryColor
                                : kStepperDot,
                          ));
                    },
                  ),
                ),
              ),
              Expanded(
                  child: _currentStep < _mySteps().length || nextHide
                      ? FlatButton(
                          onPressed: () async {
                            setState(() {
                              print(_currentStep);
                              
                              if (_currentStep == 1) {
                                print('hello');
                                createObservations();
                                AssessmentController().createAssessmentWithObservationsLocal(context, 'follow up visit (center)', 'follow-up', '', 'incomplete', '', followupType: 'short');
                                _completeStep();
                                return;
                              }
                              if (_currentStep == 0) {
                                if(dynamicMedicationTitles.isNotEmpty) {
                                  Questionnaire().addNewDynamicMedicationNcd('dynamic_medication', dynamicMedicationTitles, dynamicMedicationAnswers);
                                  AssessmentController().createAssessmentWithObservationsLocal(context, 'follow up visit (center)', 'follow-up', '', 'incomplete', '', followupType: 'short');
                                }
                                // print(Questionnaire().qnItems);
                                nextText = (Language().getLanguage() == 'Bengali') ? 'সম্পন্ন করুন' : 'COMPLETE';
                              }
                              if (_currentStep < 2) {
                                // If the form is valid, display a Snackbar.
                                _currentStep = _currentStep + 1;
                              }
                            });
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
                      : Container()),
            ],
          )),
    );
  }

  missingDataAlert() async {
    var response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: new Text(
              AppLocalizations.of(context).translate("incompleteNcd"),
              style: TextStyle(fontSize: 22),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              Container(  
                margin: EdgeInsets.all(20),  
                child:FlatButton(
                  child: new Text(AppLocalizations.of(context).translate("back"),
                      style: TextStyle(fontSize: 20),),
                  color: kPrimaryColor,  
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
              Container(  
                margin: EdgeInsets.all(20),  
                child:FlatButton(
                  child: new Text(
                      AppLocalizations.of(context).translate("continue"),
                      style: TextStyle(fontSize: 20),),
                  color: kPrimaryColor,  
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            ],
          );
        });
    print("NoYes : $response");
    return response;
  }

  Future _completeStep() async {
    print('before missing popup');

    var hasMissingData = checkMissingData();
    var hasOptionalMissingData = checkOptionalMissingData();

    if (hasMissingData) {
      var continueMissing = await missingDataAlert();
      if (!continueMissing) {
        return;
      }
    }

    // setLoader(true);

    var patient = Patient().getPatient();

    print(patient['data']['age']);
    var dataStatus = hasMissingData ? 'incomplete' : hasOptionalMissingData ? 'partial' : 'complete';
    var encounterData = {
      'context': context,
      'dataStatus': dataStatus,
      'encounter': encounter,
      'observations': observations
    };
    print('dataStatus $dataStatus');
    // return;
    Navigator.of(context).pushNamed(FollowupPatientSummaryScreen.path, arguments: {'prevScreen' : 'followup', 'encounterData': encounterData ,});
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [
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
        content: Measurements(),
        isActive: _currentStep >= 2,
      ),
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

  if (randomBloodController.text == '' &&
      fastingBloodController.text == '' &&
      habfController.text == '' &&
      hba1cController.text == '') {
    print('blood sugar missing');
    return true;
  }

  return false;
}
checkOptionalMissingData() {
  if (heightEditingController.text == '' ||
    weightEditingController.text == '' ||
    waistEditingController.text == ''||
    hipEditingController.text == '') {
    print('body measurement optional missing');
    return true;
  }

  if (randomBloodController.text == '' ||
      fastingBloodController.text == '' ||
      habfController.text == '' ||
      hba1cController.text == '') {
    print('blood sugar optinal missing');
    return true;
  }

  if (cholesterolController.text == '' ||
    ldlController.text == '' ||
    hdlController.text == '' ||
    tgController.text == '') {
    print('lipid profile optinal missing');
    return true;
  }

  if (creatinineController.text == '' ||
    sodiumController.text == '' ||
    potassiumController.text == '' ||
    ketonesController.text == '' ||
    proteinController.text == '') {
    print('additional optinal missing');
    return true;
  }

  return false;
}

class Medication extends StatefulWidget {
  @override
  _MedicationState createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {
  bool showLastMedicationQuestion = false;
  bool isEmpty = true;

  // checkMedicalHistoryAnswers(medicationQuestion) {
  //   // if (medicationQuestions['items'].length -1 == medicationQuestions['items'].indexOf(medicationQuestion)) {
  //   //   if (showLastMedicationQuestion) {
  //   //     return true;
  //   //   }

  //   // }
  //   // return true;

  //   // check if any medical histroy answer is yes. then return true if medication question is aspirin, or lower fat
  //   if (medicationQuestion['type'] == 'heart' || medicationQuestion['type'] == 'heart_bp_diabetes') {
  //     var medicalHistoryasYes = medicalHistoryAnswers.where((item) => item == 'yes');
  //     if (medicalHistoryasYes.isNotEmpty) {
  //       return true;
  //     }
  //   }
    
  //   if (medicationQuestion['type'].contains('medication')) {
  //     var mainType =
  //         medicationQuestion['type'].replaceAll('_regular_medication', '');
  //     print('mainType ' + mainType);
  //     var matchedMedicationQuestion = medicationQuestions['items']
  //         .where((item) => item['type'] == mainType)
  //         .first;
  //     print("matchedMedicationQuestion: $matchedMedicationQuestion");
  //     var medicationAnswer = medicationAnswers[
  //         medicationQuestions['items'].indexOf(matchedMedicationQuestion)];
  //     print("medicationAnswer: $medicationAnswer");
  //     if (medicationAnswer == 'yes') {
  //       return true;
  //     }

  //     return false;
  //   }

  //   var matchedQuestion;
  //   bool matchedHBD = false;
  //   medicalHistoryQuestions['items'].forEach((item) {
  //     if (item['type'] != null && item['type'] == medicationQuestion['type']) {
  //       matchedQuestion = item;
  //     } else if (medicationQuestion['type'] == 'heart_bp_diabetes') {
  //       if (item['type'] == 'stroke' ||
  //           item['type'] == 'heart' ||
  //           item['type'] == 'blood_pressure' ||
  //           item['type'] == 'diabetes') {
  //         var answer = medicalHistoryAnswers[
  //             medicalHistoryQuestions['items'].indexOf(item)];
  //         if (answer == 'yes') {
  //           matchedHBD = true;
  //           // return true;
  //         }
  //       }
  //     }
  //   });

  //   if (matchedHBD) {
  //     return true;
  //   }

  //   if (matchedQuestion != null) {
  //     // print(matchedQuestion.first);
  //     var answer = medicalHistoryAnswers[
  //         medicalHistoryQuestions['items'].indexOf(matchedQuestion)];
  //     if (answer == 'yes') {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

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
                              if(dynamicMedicationQuestions['items'] != null) 
                              ...dynamicMedicationQuestions['items'].map((question) {
                                // if (checkMedicalHistoryAnswers(question)) {
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
                                                ...question['options'].map(
                                                      (option) => Expanded(
                                                          child: Container(
                                                        height: 40,
                                                        margin: EdgeInsets.only(
                                                            right: 20, left: 0),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(width: 1,
                                                              color: dynamicMedicationQuestions[dynamicMedicationQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFF01579B) : Colors.black),
                                                            borderRadius:BorderRadius.circular(3),
                                                            color: dynamicMedicationAnswers[dynamicMedicationQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFFE1F5FE): null),
                                                        child: FlatButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              print(
                                                                  dynamicMedicationAnswers);
                                                              dynamicMedicationAnswers[
                                                                  dynamicMedicationQuestions[
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
                                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          child: Text(getOptionText(context, question, option),
                                                            style: TextStyle(color: dynamicMedicationAnswers[dynamicMedicationQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? kPrimaryColor: null),
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
var systolicEditingController = TextEditingController();
var pulseRateEditingController = TextEditingController();
var diastolicEditingController = TextEditingController();
var commentsEditingController = TextEditingController();

var heightEditingController = TextEditingController();
var weightEditingController = TextEditingController();
var waistEditingController = TextEditingController();
var hipEditingController = TextEditingController();
var bmiEditingController = TextEditingController();


//Blood Test
var selectedRandomBloodUnit = 'mmol/L';
var randomBloodController = TextEditingController();
var selectedFastingBloodUnit = 'mmol/L';
var fastingBloodController = TextEditingController();
var selectedHabfUnit = 'mmol/L';
var habfController = TextEditingController();
var selectedHba1cUnit = 'mmol/L';
var hba1cController = TextEditingController();
var selectedCholesterolUnit = 'mmol/L';
var cholesterolController = TextEditingController();
var selectedLdlUnit = 'mmol/L';
var ldlController = TextEditingController();
var selectedHdlUnit = 'mmol/L';
var hdlController = TextEditingController();
var selectedTgUnit = 'mmol/L';
var tgController = TextEditingController();
var selectedCreatinineUnit = 'mmol/L';
var creatinineController = TextEditingController();
var selectedSodiumUnit = 'mmol/L';
var sodiumController = TextEditingController();
var selectedPotassiumUnit = 'mmol/L';
var potassiumController = TextEditingController();
var selectedKetonesUnit = 'mmol/L';
var ketonesController = TextEditingController();
var selectedProteinUnit = 'mmol/L';
var proteinController = TextEditingController();

class Measurements extends StatefulWidget {
  @override
  _MeasurementsState createState() => _MeasurementsState();
}

class _MeasurementsState extends State<Measurements> {
  calculateBmi() {
    if (heightEditingController.text != '' && weightEditingController.text != '') {
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
                  height: 200,
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
                                            onChanged: (value) {},
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                          onChanged: (value) {},
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
                                  ))
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),SizedBox(
                  height: 24,
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
                        height: 230,
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
                                    width: 20,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: heightEditingController,
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
                                    width: 18,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: weightEditingController,
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
                                          .translate("waist"),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )),
                                  SizedBox(
                                    width: 35,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: waistEditingController,
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
                                              .translate("hip") +
                                          " ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )),
                                  SizedBox(
                                    width: 47,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: hipEditingController,
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
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  AppLocalizations.of(context).translate('bloodSugar'),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 24,
                ),
                Container(
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('randomBloodSugar'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: randomBloodController,
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
                                  Row(
                                    children: <Widget>[
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
                                      Text("mg/dL",
                                          style:
                                              TextStyle(color: Colors.black)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('fastingBloodSugar'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: fastingBloodController,
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
                                  Row(
                                    children: <Widget>[
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
                                      Text("mg/dL",
                                          style:
                                              TextStyle(color: Colors.black)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('2HABF'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 113,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: habfController,
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
                                  Row(
                                    children: <Widget>[
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
                                      Text("mg/dL",
                                          style:
                                              TextStyle(color: Colors.black)),
                                      SizedBox(
                                        width: 20,
                                      ),
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
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('hba1c'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 117,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: hba1cController,
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
                                  Row(
                                    children: <Widget>[
                                      Radio(
                                        activeColor: kPrimaryColor,
                                        value: 'mmol/L',
                                        groupValue: selectedHba1cUnit,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedHba1cUnit = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "mmol/L",
                                      ),
                                      Radio(
                                        activeColor: kPrimaryColor,
                                        value: 'mg/dL',
                                        groupValue: selectedHba1cUnit,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedHba1cUnit = value;
                                          });
                                        },
                                      ),
                                      Text("mg/dL",
                                          style:
                                              TextStyle(color: Colors.black)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
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
                              width: 35,
                            ),
                            Expanded(
                              child: Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.text,
                                  controller: commentsEditingController,
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('lipidProfile'),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 0.5, color: Colors.grey.shade400),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('totalCholesterol'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: cholesterolController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: 'mmol/L',
                                              groupValue:
                                                  selectedCholesterolUnit,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedCholesterolUnit =
                                                      value;
                                                });
                                              },
                                            ),
                                            Text(
                                              "mmol/L",
                                            ),
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: 'mg/dL',
                                              groupValue:
                                                  selectedCholesterolUnit,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedCholesterolUnit =
                                                      value;
                                                });
                                              },
                                            ),
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('ldl'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 117,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: ldlController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
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
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('hdl'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 115,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: hdlController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
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
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('triglycerides'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 55,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: tgController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
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
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
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
                SizedBox(
                  height: 32,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('additional'),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 0.5, color: Colors.grey.shade400),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('creatinine'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 35,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: creatinineController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: 'mmol/L',
                                              groupValue:
                                                  selectedCreatinineUnit,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedCreatinineUnit =
                                                      value;
                                                });
                                              },
                                            ),
                                            Text(
                                              "mmol/L",
                                            ),
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: 'mg/dL',
                                              groupValue:
                                                  selectedCreatinineUnit,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedCreatinineUnit =
                                                      value;
                                                });
                                              },
                                            ),
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('sodium'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: sodiumController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
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
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('potassium'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 28,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: potassiumController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
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
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('ketones'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 45,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: ketonesController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
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
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('protein'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        SizedBox(
                                          width: 45,
                                        ),
                                        Container(
                                          width: 80,
                                          height: 40,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: proteinController,
                                            onChanged: (value) {},
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
                                        Row(
                                          children: <Widget>[
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
                                            Text("mg/dL",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            SizedBox(
                                              width: 20,
                                            ),
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
          )),
    );
  }
}

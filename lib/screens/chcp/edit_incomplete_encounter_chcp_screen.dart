import 'dart:convert';

import 'package:basic_utils/basic_utils.dart' as basic_utils;
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/controllers/referral_controller.dart';
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'package:nhealth/screens/chcp/followup_patient_chcp_summary_screen.dart';
import 'package:nhealth/screens/chw/followup/edit_followup_screen.dart';
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
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

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
bool hasChwEncounter = false;
bool hasIncompleteChcpEncounter = false;

var _questions = {};
var medicalHistoryQuestions = {};
var medicalHistoryAnswers = [];
var medicationQuestions = {};
var medicationAnswers = [];
var riskQuestions = {};
var relativeQuestions = {};
var counsellingQuestions = {};
// var personalQuestions = {};
var riskAnswers = [];
var relativeAnswers = [];
var counsellingAnswers = [];
var answers = [];

int _firstQuestionOption = 1;
int _secondQuestionOption = 1;
int _thirdQuestionOption = 1;
int _fourthQuestionOption = 1;
bool isLoading = false;


var dueCarePlans = [];
var completedCarePlans = [];
var upcomingCarePlans = [];
var referrals = [];
var pendingReferral;
var encounterData;

var selectedReferralRole;
var selectedReason;
var selectedtype;
var clinicNameController = TextEditingController();

var clinicTypes = [];
var _patient;

bool refer = false;


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
  return basic_utils.StringUtils.capitalize(option);
}


class EditIncompleteEncounterChcpScreen extends StatefulWidget {
  static const path = '/editIncompleteEncounterChcp';
  @override
  _EditIncompleteEncounterChcpScreenState createState() => _EditIncompleteEncounterChcpScreenState();
}

class _EditIncompleteEncounterChcpScreenState extends State<EditIncompleteEncounterChcpScreen> {
  final syncController = Get.put(SyncController());
  int _currentStep = 0;

  String nextText = 'NEXT';
  bool nextHide = false;
  var encounter;
  var observations = [];
  var referral;

  @override
  void initState() {
    super.initState();
    Helpers().clearObservationItems();
    print("Edit incomplete Chcp");
    _patient = Patient().getPatient();
    _checkAuth();
    clearForm();
    isLoading = false;
    hasChwEncounter = false;
    hasIncompleteChcpEncounter = false;

    print(Language().getLanguage());
    nextText = (Language().getLanguage() == 'Bengali') ? 'পরবর্তী' : 'NEXT';

    prepareQuestions();
    prepareAnswers();

    // getCenters();

    getLanguage();

    if(_patient['data']['chcp_encounter_status'] != null && _patient['data']['chcp_encounter_status'] == 'incomplete') {
      hasIncompleteChcpEncounter = true;
    } else {
      hasIncompleteChcpEncounter = false;
    }
    getIncompleteAssessmentLocal();

    _getAuthData();
  }

  getCenters() async {
    // setState(() {
    //   isLoading = true;
    // });
    var centerData = await PatientController().getCenter();
    // setState(() {
    //   isLoading = false;
    // });

    print("CenterData: $centerData");

    if (centerData['error'] != null && !centerData['error']) {
      clinicTypes = centerData['data'];
      for(var center in clinicTypes) {
        if(isNotNull(_patient['data']['center']) && center['id'] == _patient['data']['center']['id']) {
          print('selectedCenter $center');
          setState(() {
            selectedtype = center;
          });
        }
      }
    }
    print("center: $clinicTypes");
  }

  // getIncompleteAssessment() async {
  //   print("getIncompleteAssessment");

  //   if (Auth().isExpired()) {
  //     Auth().logout();
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
  //   }

  //   setState(() {
  //     isLoading = true;
  //   });
  //   var patientId = Patient().getPatient()['id'];
  //   print('patientId $patientId');
  //   var data = await AssessmentController().getIncompleteEncounterWithObservation(patientId);
  //   if(data != null && data.isNotEmpty && !data['error']) {
  //     if(data['data']['assessment']['body']['type'] == 'community clinic assessment') {
  //       hasChwEncounter = true;
  //     }
  //   }
  //   print('hasChwEncounter $hasChwEncounter');
  //   setState(() {
  //     isLoading = false;
  //   });

  //   if (data == null) {
  //     return;
  //   } else if (data['message'] == 'Unauthorized') {
  //     Auth().logout();
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
  //     return;
  //   } else if (data['error'] != null && data['error']) {
  //     return;
  //   }

  //   setState(() {
  //     encounter = data['data']['assessment'];
  //     print("encounter: $encounter");
  //     observations = data['data']['observations'];
  //     print("observations: $observations");
  //   });

  //   // for (var key in obs) {
  //   //   print(key);
  //   // }

  //   // var keys = obs.keys();
  //   print("observations: $observations");

  //   populatePreviousAnswers();
  // }

  getIncompleteAssessmentLocal() async {
    // encounter = await AssessmentController().getAssessmentsByPatientWithLocalStatus('incomplete', assessmentType: 'community clinic assessment');

    var patientId = Patient().getPatient()['id'];
    encounter = await AssessmentRepositoryLocal().getIncompleteAssessmentsByPatient(patientId);
    //check type of encounter
    if(encounter.isNotEmpty) {
      var lastEncounter = encounter.last;
      print("lastEncounter: $lastEncounter");
      var parseData = jsonDecode(lastEncounter['data']);
      if(parseData['body']['type'] == 'new questionnaire' || (parseData['body']['type'] == 'community clinic assessment' && parseData['local_status'] == 'incomplete')) {
        encounter = {
          'id': lastEncounter['id'],
          'body': parseData['body'],
          'meta': parseData['meta'],
        };
        observations = await AssessmentController().getObservationsByAssessment(encounter);
        referral = await ReferralController().getReferralByAssessment(encounter['id']);
      }
    }
    print("encounter: $encounter");
    print("observations: $observations");
    print("referral: $referral");

    populatePreviousAnswers();
    populateReferral();
  }

  populateReferral() async {
    var centerData = await PatientController().getCenter();

    if (centerData['error'] != null && !centerData['error']) {
      clinicTypes = centerData['data'];
      for(var center in clinicTypes) {
        if(isNotNull(referral['body']) && isNotNull(referral['body']['location']) && isNotNull(referral['body']['location']['clinic_type']) && center['id'] == referral['body']['location']['clinic_type']['id']) {
          print('selectedCenter $center');
          setState(() {
            selectedtype = center;
          });
        }
      }
    }
    if(isNotNull(referral['body'])) {
      print('referralbody $referral');
      setState(() {
        clinicNameController.text = referral['body']['location']['clinic_name'];
        selectedReason = referral['body']['reason'];
      });
    }
  }

  populatePreviousAnswers() {
    print("testest");
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
        } else if (obsData['name'] == 'relative_problems') {
          print('into relative problems');
          var keys = obsData.keys.toList();
          print(keys);
          keys.forEach((key) {
            if (obsData[key] != '') {
              print('into keys');
              var matchedMhq =
                  relativeQuestions['items'].where((mhq) => mhq['key'] == key);
              if (matchedMhq.isNotEmpty) {
                matchedMhq = matchedMhq.first;
                setState(() {
                  relativeAnswers[relativeQuestions['items']
                      .indexOf(matchedMhq)] = obsData[key];
                });
              }
            }
            if (key == 'religion') {
              selectedReligion = obsData[key];
            }
            if (key == 'occupation') {
              occupationController.text = '${obsData[key]}';
            }
            if (key == 'ethnicity') {
              selectedEthnicity = obsData[key];
            }
            if (key == 'monthly_income') {
              incomeController.text = '${obsData[key]}';
            }
            if (key == 'blood_group') {
              selectedBloodGroup = obsData[key];
            }
            if (key == 'education') {
              educationController.text = '${obsData[key]}';
            }
            if (key == 'tribe') {
              isTribe = obsData[key];
            }
          });
        } else if (obsData['name'] == 'counselling_provided') {
          print('counselling provided');
          var keys = obsData.keys.toList();
          print(keys);
          keys.forEach((key) {
            if (obsData[key] != '') {
              print('into keys');
              var matchedPc = counsellingQuestions['items'].where((pc) => pc['key'] == key);
              if (matchedPc.isNotEmpty) {
                matchedPc = matchedPc.first;
                setState(() {
                  print("counselling provied: ${obsData[key]}");
                 
                  counsellingAnswers[counsellingQuestions['items']
                      .indexOf(matchedPc)] = obsData[key];
                  print("counsellingAnswers");
                  
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
          print('systolicText: $systolicText');
          print('diastolicText: $diastolicText');
          print('pulseRateText: $pulseRateText');
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

          if (obsData['name'] == 'bmi' && obsData['value'] != '') {
            print('into bmi');
            var bmiText = obsData['value'];
            bmiEditingController.text = '${obsData['value']}';
            print('bmiText: $bmiText');
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
          if (obsData['name'] == 'total_cholesterol' && obsData['value'] != '') {
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
    relativeAnswers = [];
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
    waistEditingController.text = '';
    hipEditingController.text = '';
    bmiEditingController.text = '';

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

    occupationController.text = '';
    incomeController.text = '';
    educationController.text = '';
    selectedReligion = null;
    selectedEthnicity = null;
    selectedBloodGroup = null;
    isTribe = null;

    selectedReferralRole = null;
    selectedReason = null;
    selectedtype = null;
    clinicNameController.text = '';
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
        '/chcpHome',
      );
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
    if (diastolicEditingController.text != '' && systolicEditingController.text != '' && pulseRateEditingController.text != '') {
    BloodPressure().addItem('left', int.parse(systolicEditingController.text), int.parse(diastolicEditingController.text), int.parse(pulseRateEditingController.text), null);
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
      BodyMeasurement().addItem('height', heightEditingController.text, 'cm', '', '');
    }
    if (weightEditingController.text != '') {
      print('weightEditingController.text');
      print(weightEditingController.text);
      BodyMeasurement().addItem('weight', weightEditingController.text, 'kg', '', '');
    }
    if (waistEditingController.text != '') {
      BodyMeasurement().addItem('waist', waistEditingController.text, 'cm', '', '');
    }
    if (hipEditingController.text != '') {
      BodyMeasurement().addItem('hip', hipEditingController.text, 'cm', '', '');
    }
    if (bmiEditingController.text != '') {
      BodyMeasurement().addItem('bmi', bmiEditingController.text, 'bmi', '', '');
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
  }

  final scrollController = ScrollController();

  void jumpToEnd(){
    final endPosition = scrollController.position.maxScrollExtent;
    print('end position: $endPosition');
    scrollController.jumpTo(endPosition);
  }

  void jumpToStart(){
    final startPosition = scrollController.position.minScrollExtent;
    print('start position: $startPosition');
    scrollController.jumpTo(startPosition);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
          onPressed: (){
            _currentStep != 0 ?
            setState(() {
              nextHide = false;
              _currentStep = _currentStep - 1;
              if( _currentStep == 2){
                jumpToStart();
              }
              nextText = AppLocalizations.of(context).translate('next');
            }) :
            setState(() {
              Navigator.pop(context);
            });
          },
        child: Icon(Icons.arrow_back, color: Colors.white,)
        ),
        title: Text(AppLocalizations.of(context).translate('editIncompleteEncounter')),
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
                    _currentStep > 0 ? _currentStep = _currentStep - 1:null;
                    print('currentStep: $_currentStep');
                    if( _currentStep == 2){
                      jumpToStart();
                    }
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
                  controller: scrollController,
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
                    
                    print('_currentStep $_currentStep');

                    if (_currentStep == 0) {
                      Questionnaire().addNewMedicalHistoryNcd('medical_history', medicalHistoryAnswers);
                      AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                    }

                    if (_currentStep == 1) {
                      Questionnaire().addNewMedicationNcd('medication', medicationAnswers);
                      AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                    }

                    if (_currentStep == 2) {
                      Questionnaire().addNewRiskFactorsNcd('risk_factors', riskAnswers);
                      AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                    }

                    if (_currentStep == 3) {
                      if(diastolicEditingController.text == '' ||
                        systolicEditingController.text == '' ||
                        pulseRateEditingController.text == '' ||
                        heightEditingController.text == '' ||
                        weightEditingController.text == ''||
                        waistEditingController.text == ''||
                        hipEditingController.text == '') 
                      {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              content: new Text(AppLocalizations.of(context).translate("missingData"), style: TextStyle(fontSize: 22),),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                Container(  
                                  margin: EdgeInsets.all(20),  
                                  child: FlatButton(
                                    child: new Text(AppLocalizations.of(context).translate("back"), style: TextStyle(fontSize: 20),),
                                    color: kPrimaryColor,  
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ),
                                Container(  
                                  margin: EdgeInsets.all(20),  
                                  child: FlatButton(
                                    child: new Text(AppLocalizations.of(context).translate("continue"), style: TextStyle(fontSize: 20),),
                                    color: kPrimaryColor,  
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      
                                      createObservations();
                                      
                                      AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                                      setState(() {
                                        _currentStep = _currentStep + 1;
                                      });
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        );
                      } else {
                        createObservations();
                        
                        AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                        setState(() {
                          _currentStep = _currentStep + 1;
                        });
                        return;
                      }
                      return;
                    }

                    if (_currentStep == 9) {
                      // await AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                      _completeRefer();
                      return;
                    }

                    if (_currentStep == 8) {
                      setState(() {
                        _currentStep = _currentStep + 1;
                        nextText = (Language().getLanguage() == 'Bengali') ? 'সম্পন্ন করুন' : 'COMPLETE';
                      });
                      _completeStep();
                      return;
                    }

                    if (_currentStep == 7) {
                      Questionnaire().addNewCounselling('counselling_provided', counsellingAnswers);
                      
                      AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                      setState(() {
                        _currentStep = _currentStep + 1;
                      });
                      return;
                    }
                    if (_currentStep == 6) {
                      jumpToEnd();
                      setState(() {
                        _currentStep = _currentStep + 1;
                      });
                      return;
                    }

                    if (_currentStep == 5) {
                      var relativeAdditionalData = {
                        'religion': selectedReligion,
                        'occupation': occupationController.text,
                        'ethnicity': selectedEthnicity,
                        'monthly_income': incomeController.text,
                        'blood_group': selectedBloodGroup,
                        'education': educationController.text,
                        'tribe': isTribe
                      };
                      print('relativeAdditionalData $relativeAdditionalData');
                      Questionnaire().addNewPersonalHistory('relative_problems', relativeAnswers, relativeAdditionalData);
                      AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                      setState(() {
                        _currentStep = _currentStep + 1;
                      });
                      return;
                    }
                    if (_currentStep == 4) {
                      print('hello');
                      if (randomBloodController.text == '' ||
                        fastingBloodController.text == '' ||
                        habfController.text == '' ||
                        hba1cController.text == '' ||
                        cholesterolController.text == '' ||
                        ldlController.text == '' ||
                        hdlController.text == '' ||
                        tgController.text == '' ||
                        creatinineController.text == '' ||
                        sodiumController.text == '' ||
                        potassiumController.text == '' ||
                        ketonesController.text == '' ||
                        proteinController.text == '')
                      {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              content: new Text(AppLocalizations.of(context).translate("missingData"), style: TextStyle(fontSize: 22),),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                Container(  
                                  margin: EdgeInsets.all(20),  
                                  child:FlatButton(
                                    child: new Text(AppLocalizations.of(context).translate("back"), style: TextStyle(fontSize: 20),),
                                    color: kPrimaryColor,  
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ),
                                Container(  
                                  margin: EdgeInsets.all(20),  
                                  child: FlatButton(
                                    child: new Text(AppLocalizations.of(context).translate("continue"), style: TextStyle(fontSize: 20),),
                                    color: kPrimaryColor,  
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      createObservations();
                                      AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                                      setState(() {
                                        _currentStep = _currentStep + 1;
                                      });
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        );
                      } else {
                        createObservations();
                        AssessmentController().createAssessmentWithObservationsLocal(context, 'community clinic assessment', 'chcp', '', 'incomplete', '');
                        setState(() {
                          _currentStep = _currentStep + 1;
                        });
                        return;
                      }
                      return;
                    }
                    if (_currentStep < 3) {
                      setState(() {
                        _currentStep = _currentStep + 1;
                      });
                    }
                  // });
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
          content: new Text(AppLocalizations.of(context).translate("incompleteNcd"), style: TextStyle(fontSize: 22),),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            Container(  
              margin: EdgeInsets.all(20),  
              child:FlatButton(
                child: new Text(AppLocalizations.of(context).translate("back"), style: TextStyle(fontSize: 20),),
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
                child: new Text(AppLocalizations.of(context).translate("continue"), style: TextStyle(fontSize: 20),),
                color: kPrimaryColor,  
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
        );
      }
    );
    print("NoYes : $response");
    return response;
  }

  var role = '';
  _getAuthData() async {
    var data = await Auth().getStorageAuth();

    print('role');
    print(data['role']);
    setState(() {
      role = data['role'];
    });
  }

  Future _completeRefer() async{
    var referralData = referral;
    if(isNotNull(referralData['body'])) {
      referralData['body']['reason'] = selectedReason;
      referralData['body']['location']['clinic_type'] = selectedtype;
      referralData['body']['location']['clinic_name'] = clinicNameController.text;
      print('referralData: $referralData');
    } else if (refer) {
      var referralType;
      if(role == 'chw')
      {
        referralType = 'community';
      } else if(role == 'nurse'){
        referralType = 'center';
      }  else if(role == 'chcp'){
        referralType = 'chcp';
      } else{
        referralType = '';
      }

      referralData = {
        'meta': {
          'patient_id': Patient().getPatient()['id'],
          "collected_by": Auth().getAuth()['uid'],
          "status": "pending",
          "created_at": DateTime.now().toString()
        },
        'body': {
          'reason': selectedReason,
          'type' : referralType,
          'location' : {
            'clinic_type' : selectedtype,
            'clinic_name' : clinicNameController.text,
          },
        },
        'referred_from': 'community clinic',
      };
    }
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text(
            AppLocalizations.of(context).translate("wantToCompleteVisit"),
            style: TextStyle(fontSize: 22),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
             Container(  
              margin: EdgeInsets.all(20),  
              child: FlatButton(
                child: new Text(
                    AppLocalizations.of(context).translate("NO"),
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
              child: FlatButton(
                child: new Text(AppLocalizations.of(context).translate("yes"),
                    style: TextStyle(fontSize: 20),),
                color: kPrimaryColor,  
                textColor: Colors.white,
                onPressed: () async {
                  // Navigator.of(context).pop(false);
                  isNotNull(referralData['body']) && refer ? await AssessmentController().createReferralByAssessmentLocal('community clinic assessment', referralData) : '';
                  _patient['data']['chcp_encounter_status'] = encounterData['dataStatus'];
                  _patient['data']['chcp_encounter_type'] = 'community clinic assessment';
                  Navigator.of(context).pushNamed(FollowupPatientChcpSummaryScreen.path, arguments: {'prevScreen' : 'encounter', 'encounterData': encounterData ,});
                },
              ),
            ),
          ],
        );
    });

  }

  Future _completeStep() async {
    print('before missing popup');

    var hasMissingData = checkMissingData();
    var hasOptionalMissingData = checkOptionalMissingData();

    // if (hasMissingData) {
    //   var continueMissing = await missingDataAlert();
    //   if (!continueMissing) {
    //     return;
    //   }
    // }

    // setLoader(true);

    var patient = Patient().getPatient();

    print(patient['data']['age']);
    var dataStatus = hasMissingData ? 'incomplete' : hasOptionalMissingData ? 'partial' : 'complete';
    // if (nextVisitDate != '') {
    //   encounter['body']['next_visit_date'] = nextVisitDate;
    // }
    print('dataStatus: $dataStatus');
    print('encounter: $encounter');
    if(hasIncompleteChcpEncounter) {
      encounterData = {
        'context': context,
        'dataStatus': 'incomplete',
        'encounter': encounter,
        'observations': observations
      };
    } else {
      encounterData = {
        'context': context,
        'dataStatus': 'incomplete',
      };
    }
    
    // var response = await AssessmentController().updateAssessmentWithObservations(status, encounter, observations);
    // var response = await AssessmentController().createOnlyAssessmentWithStatus('ncd center assessment', 'ncd', '', 'incomplete');
    // !hasMissingData ? Patient().setPatientReviewRequiredTrue() : null;
    // setLoader(false);

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

    // if (isReferralRequired) {
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
  
    // Navigator.of(context).pushNamed(PatientSummeryChcpScreen.path, arguments: {'prevScreen' : 'encounter', 'encounterData': encounterData ,});
    // Navigator.of(context).pushNamed(FollowupPatientSummaryScreen.path, arguments: 'encounter');
    // Navigator.of(context).pushNamed('/ncdPatientSummary');
    // goToHome(false, null);
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
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: Measurements(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: BloodTests(),
        isActive: _currentStep >= 2,
      ),

      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: History(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: ChcpPatientRecordsScreen(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: RecommendedCounsellingChcp(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: MedicationsDispense(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
        content: CreateRefer(),
        isActive: _currentStep >= 2,
      ),
  

      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: Followup(parent: this),
      //   isActive: _currentStep >= 2,
      // ),

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



  if (heightEditingController.text == '' || weightEditingController.text == '') {
    print('body measurement missing');
    return true;
  }

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
      print('mainType ' + mainType);
      var matchedMedicationQuestion = medicationQuestions['items']
          .where((item) => item['type'] == mainType)
          .first;
      print("matchedMedicationQuestion: $matchedMedicationQuestion");
      var medicationAnswer = medicationAnswers[
          medicationQuestions['items'].indexOf(matchedMedicationQuestion)];
      print("medicationAnswer: $medicationAnswer");
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
var waistEditingController = TextEditingController();
var hipEditingController = TextEditingController();
var bmiEditingController = TextEditingController();
var bloodSugerEditingController = TextEditingController();

class _MeasurementsState extends State<Measurements> {
  calculateBmi() {
    if (heightEditingController.text != '' && weightEditingController.text != '') {
      var height = double.parse(heightEditingController.text) / 100;
      var weight = double.parse(weightEditingController.text);

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
                        height: 280,
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
                                        contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red, width: 0.0)
                                        ), 
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16,),
                                  Text(AppLocalizations.of(context).translate("cm"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context).translate("weight") + "*", style: TextStyle(color: Colors.black, fontSize: 16,)),
                                  SizedBox(width: 18,),
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
                                        contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red, width: 0.0)
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16,),
                                  Text(AppLocalizations.of(context).translate("kg"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context).translate("waist"), style: TextStyle(color: Colors.black, fontSize: 16,)),
                                  SizedBox(width: 35,),
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
                                        contentPadding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red, width: 0.0)
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16,),
                                  Text(AppLocalizations.of(context).translate("cm"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context).translate("hip") + " ", style: TextStyle(color: Colors.black, fontSize: 16,)),
                                  SizedBox(width: 47,),
                                  Container(
                                    width: 80,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: hipEditingController,
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

                                  SizedBox(width: 16,),
                                  Text(AppLocalizations.of(context).translate("cm"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
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
                                    width: 48,
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
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}


class BloodTests extends StatefulWidget {

  @override
  _BloodTestsState createState() => _BloodTestsState();
}

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

class _BloodTestsState extends State<BloodTests> {
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
                                    Text("mg/dL", style: TextStyle(color: Colors.black)),
                                    

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
                                    Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                    Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                SizedBox(width: 115,),
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
                                          Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                          Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                          Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                          Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                          Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                          Text("mg/dL", style: TextStyle(color: Colors.black)),
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
                                          Text("mg/dL", style: TextStyle(color: Colors.black)),
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
      ),
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
var personalQuestions = {
  'religion' :
    {
      'options': ['Islam', 'Hindu', 'Cristianity', 'Others'],
      'options_bn': ['ইসলাম', 'হিন্দু', 'খ্রিস্টান', 'অন্যান্য']
    },
    'ethnicity' :
    {
      'options': ['Bengali', 'Others'],
      'options_bn': ['বাংলাদেশী', 'অন্যান্য'],
    },
    'blood_group' : {
      'options': ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', "Don't know"],
      'options_bn': ['এবি+', 'এবি-', 'এ+', 'এ-', 'বি+', 'বি-', 'ও+', 'ও-', "জানি না"],
    }
};
var religions = personalQuestions['religion']['options'];
var selectedReligion = null;
var ethnicity = personalQuestions['ethnicity']['options'];
var selectedEthnicity = null;
var bloodGroups = personalQuestions['blood_group']['options'];
var selectedBloodGroup = null;
var isTribe = null;

getDropdownOptionText(context, list, value) {
  var locale = Localizations.localeOf(context);

  if (locale == Locale('bn', 'BN')) {

    if (list['options_bn'] != null) {
      var matchedIndex = list['options'].indexOf(value);
      print('matchedIndex $matchedIndex');
      print(list['options_bn'][matchedIndex]);
      return list['options_bn'][matchedIndex];
    }
    return basic_utils.StringUtils.capitalize(value);
  }
  return basic_utils.StringUtils.capitalize(value);
}

class _HistoryState extends State<History> {
  @override
   void initState() {
    super.initState();
   }
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
                  AppLocalizations.of(context).translate('familyHistory'),
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
                                          .translate('religion'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 85,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    color: kSecondaryTextField,
                                    child: DropdownButton(
                                      items: religions.map((value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(getDropdownOptionText(context, personalQuestions['religion'], value)),
                                        );
                                      }).toList(),
                                      value: selectedReligion,
                                      onChanged: (newValue) {
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
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('occupation'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 60,
                                  ),
                                  Container(
                                    width: 110,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      controller: occupationController,
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
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('ethnicity'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 80,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    color: kSecondaryTextField,
                                    child: DropdownButton<String>(
                                      items: ethnicity.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(getDropdownOptionText(context, personalQuestions['ethnicity'], value)),
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
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('monthlyIncome'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 27,
                                  ),
                                  Container(
                                    width: 110,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: incomeController,
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
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context).translate('bloodGroup'),style: TextStyle(color: Colors.black, fontSize: 16)),
                                  SizedBox(width: 53,),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    color: kSecondaryTextField,
                                    child: DropdownButton<String>(
                                      items: bloodGroups.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(getDropdownOptionText(context, personalQuestions['blood_group'], value)),
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
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('educationYear'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 18,
                                  ),
                                  Container(
                                    width: 110,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: educationController,
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
                            SizedBox(height: 16),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate('tribe'),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(
                                    width: 110,
                                  ),
                                  Container(
                                      width: 200,
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
                                                    color: (isTribe != null &&
                                                            isTribe)
                                                        ? Color(0xFF01579B)
                                                        : Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color:
                                                    (isTribe != null && isTribe)
                                                        ? Color(0xFFE1F5FE)
                                                        : null),
                                            child: FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  isTribe = true;
                                                });
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .translate('yes'),
                                                style: TextStyle(
                                                    color: (isTribe != null &&
                                                            isTribe)
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
                                                    color: (isTribe == null ||
                                                            isTribe)
                                                        ? Colors.black
                                                        : Color(0xFF01579B)),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color:
                                                    (isTribe == null || isTribe)
                                                        ? null
                                                        : Color(0xFFE1F5FE)),
                                            child: FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  isTribe = false;
                                                });
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .translate('NO'),
                                                style: TextStyle(
                                                    color: (isTribe == null ||
                                                            isTribe)
                                                        ? null
                                                        : kPrimaryColor),
                                              ),
                                            ),
                                          )),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)
                            .translate('relativeHistory'),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      Container(
                          padding: EdgeInsets.only(bottom: 35, top: 20),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: kBorderLighter))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...relativeQuestions['items'].map((question) {
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
                                                            color: relativeAnswers[relativeQuestions['items'].indexOf(question)] ==
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
                                                        color: relativeAnswers[relativeQuestions['items'].indexOf(question)] ==
                                                                question['options']
                                                                    [question['options'].indexOf(option)]
                                                            ? Color(0xFFE1F5FE)
                                                            : null),
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          relativeAnswers[
                                                              relativeQuestions[
                                                                      'items']
                                                                  .indexOf(
                                                                      question)] = question[
                                                                  'options'][
                                                              question[
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
                                                            color: relativeAnswers[relativeQuestions[
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


class ChcpPatientRecordsScreen extends StatefulWidget {
  var checkInState = false;
  var prevScreen = '';

  // ChcpPatientRecordsScreen({this.prevScreen, this.encounterData});
  @override
  _ChcpPatientRecordsState createState() => _ChcpPatientRecordsState();
}

class _ChcpPatientRecordsState extends State<ChcpPatientRecordsScreen> {
  // var _patient;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  var lastAssessment;
  String lastEncounterType = '';
  String lastEncounterDate = '';
  String nextVisitDateChw = '';
  String nextVisitPlaceChw = '';
  String nextVisitDateCc = '';
  String nextVisitPlaceCc = '';
  String lastCarePlanDate = '';
  var medications = [];
  var smokingAnswer = '';
  var smokelessTobaccoAnswer = '';

  @override
  void initState() {
    super.initState();
    // _patient = Patient().getPatient();

    print('prevScreen ${widget.prevScreen}');
    getRiskQuestionAnswer();
    getLastAssessment();

  }

  getRiskQuestionAnswer(){
    // print('getRiskQuestionAnswer');
    var riskQuestions = Questionnaire().questions['new_patient']['risk_factors'];
    // print('riskQuestions $riskQuestions');
    riskQuestions['items'].forEach((item) {
       print('risk factor: ${item} \n');
      if(item['type'] == 'smoking'){
       print('riskAnswers: ${riskAnswers} \n');
        smokingAnswer = riskAnswers[riskQuestions['items'].indexOf(item)];
        // riskAnswers[0]
        print('riskAnswers: answer: $smokingAnswer');
        print('SMOKING $smokingAnswer');
      }
      if(item['type'] == 'smokeless-tobacco'){
        smokelessTobaccoAnswer = riskAnswers[riskQuestions['items'].indexOf(item)];
        print('riskAnswers: smokelessTobaccoAnswer: $smokelessTobaccoAnswer');
        print('SMOKEless tobacco $smokelessTobaccoAnswer');
      }
    });

  }
  getDate(date) {
     if (date.runtimeType == String && date != null && date != '') {
      return DateFormat("MMMM d, y").format(DateTime.parse(date)).toString();
    } else if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);

      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  getLastAssessment() async {
    // setState(() {
    //   isLoading = true;
    // });
    lastAssessment = await AssessmentController().getLastAssessmentByPatient();

    print('lastAssessment1 $lastAssessment');
    if(lastAssessment != null && lastAssessment.isNotEmpty) {
      if(lastAssessment['data']['body']['follow_up_info'] != null && lastAssessment['data']['body']['follow_up_info'].isNotEmpty){
        var followUpInfoChw = lastAssessment['data']['body']['follow_up_info'].where((info)=> info['type'] == 'chw');
        if(followUpInfoChw.isNotEmpty) {
          followUpInfoChw = followUpInfoChw.first;
        }
        var followUpInfoCc= lastAssessment['data']['body']['follow_up_info'].where((info)=> info['type'] == 'cc');
        if(followUpInfoCc.isNotEmpty) {
          followUpInfoCc = followUpInfoCc.first;
        }
        setState(() {
          nextVisitDateChw = (followUpInfoChw['date'] != null && followUpInfoChw['date'].isNotEmpty) ? getDate(followUpInfoChw['date']) : '' ;
          nextVisitPlaceChw = (followUpInfoChw['place'] != null && followUpInfoChw['place'].isNotEmpty) ? (followUpInfoChw['place']) : '' ;
          nextVisitDateCc = (followUpInfoCc['date'] != null && followUpInfoCc['date'].isNotEmpty) ? getDate(followUpInfoCc['date']) : '' ;
          nextVisitPlaceCc = (followUpInfoCc['place'] != null && followUpInfoCc['place'].isNotEmpty) ? (followUpInfoCc['place']) : '' ;
        });
      }

      setState(() {
        lastEncounterType = lastAssessment['data']['body']['type'];
        lastEncounterDate = getDate(lastAssessment['data']['meta']['created_at']);
        print('lastEncounterDate ${lastEncounterDate}');
      });
    }
    // setState(() {
    //   isLoading = false;
    // });
    
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      if(widget.prevScreen == 'followup') {
          print('WillPopScope if');
          Navigator.of(context).pushNamed( '/chwNavigation', arguments: 1);
          return true;
        } else {
          print('WillPopScope else');
          Navigator.pop(context);
          return true;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        // appBar: new AppBar(
        //   title: new Text(AppLocalizations.of(context).translate('patientSummary'), style: TextStyle(color: Colors.white, fontSize: 20),),
        //   backgroundColor: kPrimaryColor,
        //   elevation: 0.0,
        //   iconTheme: IconThemeData(color: Colors.white),
        //   actions: <Widget>[

        //   ],
        // ),
        body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Column(                
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: kBorderLighter),
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),    
                      
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 20, top: 15),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(AppLocalizations.of(context).translate('age')+":", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  // padding: EdgeInsets.symmetric(vertical: 9),
                                  // child: Text('dummy age', style: TextStyle(fontSize: 17,)),
                                  // Text(Helpers().getPatientAgeAndGender(Patient().getPatient()),)
                                  child: 
                                  Text(
                                    Helpers().getPatientAge(Patient().getPatient()) != '' &&
                                    Helpers().getPatientAge(Patient().getPatient()) != null
                                    ? Helpers().getPatientAge(Patient().getPatient())
                                    : 'N/A',
                                  style: TextStyle(fontSize: 17,)
                                  )
                                ),
                              ],
                            ),
                          ),

                          // report != null && report['body']['result']['assessments']['cvd'] != null ?
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                              decoration: BoxDecoration(
                                border: Border(
                                  // top: BorderSide(color: kBorderLighter)
                                )
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context).translate('gender')+":", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                      SizedBox(width: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                Helpers().getPatientGender(Patient().getPatient()) != '' && 
                                                Helpers().getPatientGender(Patient().getPatient()) != null
                                                  ? Helpers().getPatientGender(Patient().getPatient())
                                                  : 'N/A',
                                                style: TextStyle(fontSize: 17,)),
                                            ]
                                          ),
                                        ]
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 20,),

                                ],
                              ),
                            ), 
                            // : Container(),

                          // report != null && report['body']['result']['assessments']['lifestyle'] != null && report['body']['result']['assessments']['lifestyle']['components']['smoking'] != null ?
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(AppLocalizations.of(context).translate('smoking') + ":", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                    SizedBox(width: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(smokingAnswer != ''
                                              ? smokingAnswer
                                              : 'N/A',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            )
                                          ]
                                        ),
                                      ]
                                    )
                                  ],
                                ),

                                SizedBox(height: 20,),

                              ],
                            ),
                          ), 
                          // : Container(),


                          // report != null && report['body']['result']['assessments']['body_composition'] != null && report['body']['result']['assessments']['body_composition']['components']['bmi'] != null ?
                          Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context).translate('smokelessTobacco') + ":", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                      SizedBox(width: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(smokelessTobaccoAnswer != ''
                                                ? smokelessTobaccoAnswer
                                                : 'N/A',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  // color: ColorUtils.statusColor[report['body']['result']['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black
                                                ),
                                              ),
                                            ]
                                          ),
                                        ]
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 20,),

                                ],
                              ),
                            ),
                            // : Container(),


                          // report != null && report['body']['result']['assessments']['lifestyle'] != null && report['body']['result']['assessments']['lifestyle']['components']['physical_activity'] != null ?
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context).translate('bmi') + ":", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                      SizedBox(width: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(bmiEditingController.text != '' 
                                                  ? "${bmiEditingController.text}"
                                                  :"N/A",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ]
                                          ),
                                        ]
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 20,),

                                ],
                              ),
                            ),
                            // : Container(),


                          // report != null && report['body']['result']['assessments']['cholesterol'] != null && report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context).translate('bp') + ":", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                      SizedBox(width: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                systolicEditingController.text != '' && diastolicEditingController.text != ''
                                                ? systolicEditingController.text + '/' + diastolicEditingController.text
                                                : 'N/A',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ]
                                          ),
                                        ]
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 20,),

                                ],
                              ),
                            ),
                          ],
                        ),
                    ),

                    Container(
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //     top: BorderSide(width: 4, color: kBorderLighter)
                      //   ),
                      // ),
                      padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Column(
                        children: <Widget>[

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: kBorderLighter),
                            ),
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context).translate('ncdCenterVisit'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                SizedBox(height: 15,),
                                nextVisitDateChw == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitDateChw') +  ': $nextVisitDateChw', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                nextVisitPlaceChw == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitPlaceChw') +  ': $nextVisitPlaceChw', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                nextVisitDateCc == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitDateCc') +  ': $nextVisitDateCc', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                nextVisitPlaceCc == '' 
                                ? Container()
                                : Column(children:[
                                  Text(AppLocalizations.of(context).translate('nextVisitPlaceCc') +  ': $nextVisitPlaceCc', style: TextStyle(fontSize: 17,)),
                                  SizedBox(height: 10,),
                                  ]),
                                Text(AppLocalizations.of(context).translate('lastVisitDate') +  ': $lastEncounterDate', style: TextStyle(fontSize: 17,))
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: kBorderLighter),
                            ),
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context).translate('lastEncounter')+'${(lastEncounterType)}', style: TextStyle(fontSize: 17,)),
                                SizedBox(height: 10,),
                                Text(AppLocalizations.of(context).translate('lastEncounterDate')+  ': $lastEncounterDate', style: TextStyle(fontSize: 17,)),
                              ],
                            ),
                          ),

                        ],
                      )
                    ),
                    SizedBox(height: 15,),
                  ], 
                  
                ),
                isLoading ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Color(0x90FFFFFF),
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
                  ),
                ) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class FloatingButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const FloatingButton({this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      width: 300,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            Icon(Icons.add),
            SizedBox(width: 10,),
            Text(text, style: TextStyle(fontSize: 17),)
          ],
        ),
      )
    );
  }
}


class RecommendedCounsellingChcp extends StatefulWidget {
  @override
  _RecommendedCounsellingChcpState createState() => _RecommendedCounsellingChcpState();
}

// var isReferralRequired = null;
bool dietTitleAdded = false;
bool tobaccoTitleAdded = false;
var dietCurrentCount = 0;
var tobaccoCurrentCount = 0;

class _RecommendedCounsellingChcpState extends State<RecommendedCounsellingChcp> {

  bool activityTitleAdded = false;

  @override
  initState() {
    super.initState();
    dietTitleAdded = false;
    tobaccoTitleAdded = false;
    // isReferralRequired = null;
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
      if (riskAnswers[9] == 'no' && riskAnswers[10] == 'no') {
        return true;
      }
      return false;
    }

    if (counsellingQuestion['type'] == 'salt') {
      if (riskAnswers[4] == 'yes' || riskAnswers[5] == 'yes') {
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
    var totalUnhealthyDiet = counsellingQuestions['items'].where((item) => (item['group'] == 'unhealthy-diet') && checkCounsellingQuestions(item)).toList().length;
    var totalTobacco = counsellingQuestions['items'].where((item) => (item['group'] == 'tobacco') && checkCounsellingQuestions(item)).toList().length;

    if (question['group'] == 'unhealthy-diet') {
      dietCurrentCount++;
      if(dietCurrentCount == 1) 
      {
        dietTitleAdded = true;
        if(dietCurrentCount%totalUnhealthyDiet == 0) 
        {
          dietCurrentCount = 0;
        }
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
      if(dietCurrentCount%totalUnhealthyDiet == 0) 
      {
        dietCurrentCount = 0;
      }
    } else if (question['group'] == 'tobacco') {
      tobaccoCurrentCount++;
      if(tobaccoCurrentCount == 1) 
      {
        tobaccoTitleAdded = true;
        if(tobaccoCurrentCount%totalTobacco == 0)
        {
          tobaccoCurrentCount = 0;
        }
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
      if(tobaccoCurrentCount%totalTobacco == 0)
      {
        tobaccoCurrentCount = 0;
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
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: <Widget>[
                              //     SizedBox(height: 20),
                              //     Container(
                              //         child: Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Text(
                              //           AppLocalizations.of(context)
                              //               .translate('referralRequired'),
                              //           style: TextStyle(
                              //               fontSize: 18,
                              //               height: 1.7,
                              //               fontWeight: FontWeight.w500),
                              //         ),
                              //         Container(
                              //             width: 240,
                              //             child: Row(
                              //               children: <Widget>[
                              //                 Expanded(
                              //                     child: Container(
                              //                   height: 25,
                              //                   width: 100,
                              //                   margin: EdgeInsets.only(
                              //                       right: 20, left: 0),
                              //                   decoration: BoxDecoration(
                              //                       border: Border.all(
                              //                           width: 1,
                              //                           color: (isReferralRequired !=
                              //                                       null &&
                              //                                   isReferralRequired)
                              //                               ? Color(0xFF01579B)
                              //                               : Colors.black),
                              //                       borderRadius:
                              //                           BorderRadius.circular(
                              //                               3),
                              //                       color: (isReferralRequired !=
                              //                                   null &&
                              //                               isReferralRequired)
                              //                           ? Color(0xFFE1F5FE)
                              //                           : null),
                              //                   child: FlatButton(
                              //                     onPressed: () {
                              //                       setState(() {
                              //                         dietTitleAdded = false;
                              //                         tobaccoTitleAdded = false;
                              //                         isReferralRequired = true;
                              //                       });
                              //                     },
                              //                     materialTapTargetSize:
                              //                         MaterialTapTargetSize
                              //                             .shrinkWrap,
                              //                     child: Text(
                              //                       AppLocalizations.of(context)
                              //                           .translate('yes'),
                              //                       style: TextStyle(
                              //                           color: (isReferralRequired !=
                              //                                       null &&
                              //                                   isReferralRequired)
                              //                               ? kPrimaryColor
                              //                               : null),
                              //                     ),
                              //                   ),
                              //                 )),
                              //                 Expanded(
                              //                     child: Container(
                              //                   height: 25,
                              //                   width: 100,
                              //                   margin: EdgeInsets.only(
                              //                       right: 20, left: 0),
                              //                   decoration: BoxDecoration(
                              //                       border: Border.all(
                              //                           width: 1,
                              //                           color: (isReferralRequired ==
                              //                                       null ||
                              //                                   isReferralRequired)
                              //                               ? Colors.black
                              //                               : Color(
                              //                                   0xFF01579B)),
                              //                       borderRadius:
                              //                           BorderRadius.circular(
                              //                               3),
                              //                       color: (isReferralRequired ==
                              //                                   null ||
                              //                               isReferralRequired)
                              //                           ? null
                              //                           : Color(0xFFE1F5FE)),
                              //                   child: FlatButton(
                              //                     onPressed: () {
                              //                       setState(() {
                              //                         dietTitleAdded = false;
                              //                         tobaccoTitleAdded = false;
                              //                         isReferralRequired = false;
                              //                       });
                              //                     },
                              //                     materialTapTargetSize:
                              //                         MaterialTapTargetSize
                              //                             .shrinkWrap,
                              //                     child: Text(
                              //                       AppLocalizations.of(context)
                              //                           .translate('NO'),
                              //                       style: TextStyle(
                              //                           color: (isReferralRequired ==
                              //                                       null ||
                              //                                   isReferralRequired)
                              //                               ? null
                              //                               : kPrimaryColor),
                              //                     ),
                              //                   ),
                              //                 )),
                              //               ],
                              //             )),
                              //       ],
                              //     )),
                              //     SizedBox(
                              //       height: 20,
                              //     )
                              //   ],
                              // ),
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

class MedicationsDispense extends StatefulWidget {
  @override
  _MedicationsDispenseState createState() => _MedicationsDispenseState();
}

var dispenseEditingController = TextEditingController();
// var stringListReturnedFromApiCall = ["first", "second", "third", "fourth", "..."];
  // This list of controllers can be used to set and get the text from/to the TextFields
  Map<String,TextEditingController> textEditingControllers = {};
  var textFields = <TextField>[];

class _MedicationsDispenseState extends State<MedicationsDispense> {
  bool isEmpty = true;

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
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('medication'),
                              style: TextStyle(
                              color: Colors.black,
                              fontSize: 34,
                              fontWeight: FontWeight.w500),
                            ),
                          ],  
                        ),                       

                      ),
                      // SizedBox(height: 24),

                      // Container(
                      //     child: Text(
                      //         'Serial Name    Dose Unit    Frequancy    Duration',
                      //         style: TextStyle(
                      //         color: Colors.black,
                      //         fontSize: 18,
                      //         // fontWeight: FontWeight.w500
                      //         ),
                      //       ),
                      // ),
                      SizedBox(height: 24),
                      if(dynamicMedications != null)
                      ...dynamicMedications.map((item) {
                        isEmpty = false;
                        return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                item['medInfo'],
                                style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Text(AppLocalizations.of(context).translate('dispense'),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      )),
                                  SizedBox(
                                    width: 28,
                                  ),
                                  Container(
                                    width: 120,
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: textEditingControllers[item['medId']],
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
                                  FlatButton(
                                    color: Colors.blue[800],
                                    textColor: Colors.white, 
                                    onPressed: () async {
                                      print('id ${item['medId']}');
                                      var response = await PatientController().dispenseMedicationByPatient(item['medId'], textEditingControllers[item['medId']].text);
                                      print('response $response');
                                      if(!response['error']) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(AppLocalizations.of(context).translate('dataSaved')),
                                          backgroundColor: kPrimaryGreenColor,
                                        ));
                                        return;
                                      }
                                      {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(AppLocalizations.of(context).translate('somethingWrong')),
                                          backgroundColor: kPrimaryRedColor,
                                        ));
                                      }
                                      // Navigator.of(context).pop();
                                      // if (response == 'success') {
                                      // // Navigator.of(context).pop();
                                      // } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                                    },
                                    child: Text(AppLocalizations.of(context).translate('submit')),
                                  )
                                ],
                              ),
                              ),
                              SizedBox(height: 24),
                          ],
                        ),
                      );
                      }).toList(),
                      isEmpty ? Container(child: Text(AppLocalizations.of(context).translate('noMedication'), style: TextStyle(fontSize: 16),),): Container()
                      ],
                    ),
                  ),
                ]
              ),
          ),
      ),

    );
  }

}

class CreateRefer extends StatefulWidget {

  @override
  _CreateReferState createState() => _CreateReferState();
}

class _CreateReferState extends State<CreateRefer> {

  var role = '';
  var referralReasonOptions = {
  'options': ['Urgent medical attempt required', 'NCD screening required'],
  'options_bn': ['তাৎক্ষণিক মেডিকেল প্রচেষ্টা প্রয়োজন', 'এনসিডি স্ক্রিনিং প্রয়োজন']
  };
  List referralReasons;

  var referralToRolesOptions = {
    'options': ['Chcp', 'Chw'],
    'options_bn': ['chcp', 'chw']
  };
  List referralToRoles;


  @override
  void initState() {
    super.initState();
    print(Language().getLanguage());
    referralReasons = referralReasonOptions['options']; 
    referralToRoles = referralToRolesOptions['options'];
    print('encounterData $encounterData');
  }


  @override
  Widget build(BuildContext context) {
    return Container(
       child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // PatientTopbar(),
                    SizedBox(height: 30,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            // padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(AppLocalizations.of(context).translate("referralRequired"), style: TextStyle(fontSize: 20),)
                          ),
                          SizedBox(width: 30,),
                          Container(
                            height: 25,
                            width: 100,
                            margin:
                                EdgeInsets.only(right: 20,left: 0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color:  Colors.black),
                                borderRadius: BorderRadius.circular(3),
                          ),
                            child: FlatButton(
                              onPressed: () { 
                                setState(() {
                                  refer = true;
                                });
                              },
                              color: refer ? Color(0xFFE1F5FE) : Colors.white,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Text(
                                AppLocalizations.of(context).translate('yes'),
                              ),
                            ),
                          ),

                          SizedBox(width: 20,),
                          Container(
                            height: 25,
                            width: 100,
                            margin:
                                EdgeInsets.only(right: 20,left: 0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color:  Colors.black),
                                borderRadius: BorderRadius.circular(3),
                          ),
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  refer = false;
                                }); 
                              },
                              color: !refer ? Color(0xFFE1F5FE) : Colors.white,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Text(
                                AppLocalizations.of(context).translate('NO'),
                              ),
                            ),
                          ),
                        ],)
                    ),
                    SizedBox(height: 50,),
                    refer == true
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(AppLocalizations.of(context).translate("reasonForReferral"), style: TextStyle(fontSize: 20),)
                        ),
                        SizedBox(height: 10,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          color: kSecondaryTextField,
                          child: DropdownButtonFormField(
                            hint: Text(AppLocalizations.of(context).translate('selectAReason'), style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                              ...referralReasons.map((item) =>
                                DropdownMenuItem(
                                  child: Text(getDropdownOptionText(context, referralReasonOptions, item)),
                                  value: item
                                )
                              ).toList(),
                            ],
                            value: selectedReason,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                selectedReason = value;
                              });
                            },
                          ),
                        ),


                        SizedBox(height: 30,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(AppLocalizations.of(context).translate("referralLocation"), style: TextStyle(fontSize: 20),)
                        ),
                        SizedBox(height: 10,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          color: kSecondaryTextField,
                          child: DropdownButtonFormField(
                            hint: Text(AppLocalizations.of(context).translate("clinicType"), style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                              ...clinicTypes.map((item) =>
                                DropdownMenuItem(
                                  child: Text(getName(context, item)),
                                  value: item
                                )
                              ).toList(),
                            ],
                            value: selectedtype,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                selectedtype = value;
                                print('selectedtype $selectedtype');
                              });
                            },
                          ),
                        ),

                        SizedBox(height: 20,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          color: kSecondaryTextField,
                          child: TextField(
                            controller: clinicNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 10, right: 10),
                              hintText: AppLocalizations.of(context).translate("clinicName"),
                              hintStyle: TextStyle(fontSize: 18)
                            ),
                          )
                        ),
                        SizedBox(height: 50,),
                      ],
                    )
                    : Container(),
                    ],
                  ),
                ),   
          ],
        ),
      ),
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
  _EditIncompleteEncounterChcpScreenState parent;
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
                                          // var response = await AssessmentController().createOnlyAssessment('follow up visit (center)', '', '');

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

var firstQuestionText =
    'Are you having any pain or discomfort or pressure or heaviness in your chest?';
var secondQuestionText =
    'Are you having any difficulty in talking, or any weakness or numbness of arms, legs or face?';
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

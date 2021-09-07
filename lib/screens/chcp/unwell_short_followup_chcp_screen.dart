import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/followup/well_followup_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';
import 'package:nhealth/screens/chw/unwell/create_referral_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_visit_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

import 'followup_visit_chcp_screen.dart';
import 'full_assessment_chcp_screen.dart';

final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _causesFormKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final _temperatureController = TextEditingController();
final _systolicController = TextEditingController();
final _diastolicController = TextEditingController();
final _pulseController = TextEditingController();
final _glucoseController = TextEditingController();
final _deviceController = TextEditingController();
List causes = ['Fever', 'Shortness of breath', 'Feeling faint', 'Stomach discomfort', 'Vision', 'Smell', 'Mental Health', 'Other'];
// List issues = ['Vision', 'Smell', 'Mental Health', 'Other'];
List selectedCauses = [];
List selectedIssues = [];
final otherIssuesController = TextEditingController();
String selectedArm = 'left';
String selectedGlucoseType = 'fasting';
String selectedGlucoseUnit = 'mg/dL';

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

class UnwellShortFollowupChcpScreen extends StatefulWidget {
  static const path = '/unWellShortFollowupChcpScreen';
  @override
  _UnwellShortFollowupChcpScreen createState() => _UnwellShortFollowupChcpScreen();
}

class _UnwellShortFollowupChcpScreen extends State<UnwellShortFollowupChcpScreen> {

  int _currentStep = 0;

  String nextText = 'Ok to Proceed';

  @override
  void initState() {
    super.initState();
    print('unwell short followup chcp');
    nextText = (Language().getLanguage() == 'Bengali') ? 'এগিয়ে যান' : 'Ok to Proceed';
    _checkAuth();
    clearForm();
  }

  nextStep() {
    setState(() {
      if (_currentStep == 0) {
        _currentStep = _currentStep + 1;
        nextText = 'COMPLETE';
      } else if (_currentStep == 1) {
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

    if (firstAnswer == 'yes' || secondAnswer == 'yes') {
      var data = {
        'meta': {
          'patient_id': Patient().getPatient()['id'],
          "collected_by": Auth().getAuth()['uid'],
          "status": "pending"
        },
        'body': {}
      };
      Navigator.of(context).pushNamed('/medicalRecommendation', arguments: data);
      return;
    }

    Navigator.of(context).pushNamed('/chwPatientSummary');

    // if (temp > 39 || glucose > 250 || systolic > 160 || diastolic > 100 || firstAnswer == 'yes' || secondAnswer == 'yes') {
    //   // var response = FollowupController().create(data);
    //   // print(response);
    //   // if (response['error'] != null && !response['error'])
    //     Navigator.of(context).pushReplacementNamed('/medicalRecommendation', arguments: data);
    // } else {
    //   // var response = FollowupController().create(data);
    //   // print(response);
    //   // if (response['error'] != null && !response['error'])
    //    Navigator.of(context).pushReplacementNamed('/chwContinue');
    // }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _causesFormKey,
      appBar: AppBar(
        leading: FlatButton(
          onPressed: (){
            // _currentStep != 0 ?
            // setState(() {
            //   _currentStep = _currentStep - 1;
            //   nextText = AppLocalizations.of(context).translate('next');
            // }) :
            setState(() {
              Navigator.pop(context);
            });
          },
        child: Icon(Icons.arrow_back, color: Colors.white,)
        ),
        title: Text(AppLocalizations.of(context).translate('followUp')),
      ),
      body: GestureDetector(
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
      ),
      bottomNavigationBar: Container(
        color: kBottomNavigationGrey,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _currentStep == 0 ? FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/chcpHome');
                  // setState(() {
                    // _currentStep = _currentStep - 1;
                    // nextText = AppLocalizations.of(context).translate('next');
                    // var data = {
                    //   'meta': {
                    //     'patient_id': Patient().getPatient()['id'],
                    //     "collected_by": Auth().getAuth()['uid'],
                    //     "status": "pending"
                    //   },
                    //   'body': {}
                    // };
                  //   Navigator.of(context).pushNamed(CreateReferralScreen.path, arguments: data);
                  //   return;
                  // });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Icon(Icons.chevron_left),
                    Text(AppLocalizations.of(context).translate("unableToProceed"), style: TextStyle(fontSize: 20)),
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
              child: _currentStep < _mySteps().length ? FlatButton(
                onPressed: () {
                  setState(() {
                    print('_currentStep $_currentStep');
                    if (_currentStep == 1) {
                    }
                    if (_currentStep == 0) {
                    //  nextText = 'COMPLETE';
                      // nextText = (Language().getLanguage() == 'Bengali') ? 'সম্পন্ন করুন' : 'Ok to Proceed';
                      // checkData();
                      // Navigator.of(context).pushNamed(WellFollowupScreen.path);
                      // Navigator.of(context).pushNamed(FullAssessmentChcpScreen.path);
                      Navigator.of(context).pushNamed(FollowupVisitChcpScreen.path);
                    }
                    // if (_currentStep < 1) {

                    //     // If the form is valid, display a Snackbar.
                    //     _currentStep = _currentStep + 1;
                    // }
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(nextText, style: TextStyle(fontSize: 20)),
                    // Icon(Icons.chevron_right)
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
        title: Text(AppLocalizations.of(context).translate("causes"), textAlign: TextAlign.center,),
        content: UnwellCauses(),
        isActive: _currentStep >= 0,
      ),
      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: Temperature(parent: this),
      //   isActive: _currentStep >= 1,
      // ),
      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: BloodPressure(parent: this),
      //   isActive: _currentStep >= 2,
      // ),

      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: Glucose(parent: this),
      //   isActive: _currentStep >= 4,
      // ),
      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate("permission"), textAlign: TextAlign.center,),
      //   content: AcuteIssues(parent: this),
      //   isActive: _currentStep >= 1,
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

class UnwellCauses extends StatefulWidget {
  @override
  _UnwellCausesState createState() => _UnwellCausesState();
}

class _UnwellCausesState extends State<UnwellCauses> {

  var selectedReason = 0;
  DateTime selectedDate = DateTime.now();
  bool isOtherIssue = false;

  checkCause(value, item) {
    if (value) {
      selectedCauses.add(item);
    } else {
      selectedCauses.remove(item);
    }
  }
  checkIssue(value, item) {
    if (value) {
      selectedIssues.add(item);
    } else {
      selectedIssues.remove(item);
    }
  }

  //bool checkBoxValue = false;
 bool _checkboxListTile = false;
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _causesFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context).translate('unwellCause'), style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),

            Container(
              color: kSecondaryTextField,
              margin: EdgeInsets.symmetric(horizontal: 100),
              child: DropdownButtonFormField(
                hint: Text(AppLocalizations.of(context).translate("selectAReason"), style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                  ...causes.map((item) =>
                    DropdownMenuItem(
                      child: Text(item),
                      value: causes.indexOf(item)
                    )
                  ).toList(),
                ],
                value: selectedReason,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                    print('selectedReason $selectedReason');
                  });
                },
              ),
            ),
            SizedBox(height: 20,),
            //  ...causes.map((item) {
            //     return Container(
            //       alignment: Alignment.centerLeft,
            //       width: double.infinity,
            //         margin: EdgeInsets.only(left: 30, right: 30, bottom: 15),
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(3),
            //           border: Border.all(color: selectedCauses.contains(item) ? kPrimaryColor : kBorderGrey)
            //         ),
            //       child: CheckboxListTile(
            //         controlAffinity: ListTileControlAffinity.leading,
            //         contentPadding: EdgeInsets.only(left: 5),
            //         title: Text(item, style: TextStyle(fontSize: 17, ),),
            //         value: selectedCauses.contains(item),
            //         onChanged: (value) {
            //           setState(() {
            //             checkCause(value, item);
            //           });
            //         },
            //       ),
            //     );
            //  }).toList(),

            // ...causes.map((item) {
            //   return Container(
            //     width: double.infinity,
            //     margin: EdgeInsets.only(left: 30, right: 30, bottom: 15),
            //     height: 50,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(3),
            //       border: Border.all(color: selectedCauses.contains(item) ? kPrimaryColor : kBorderGrey)
            //     ),
            //     child: Row(
            //       children: <Widget>[
            //         Checkbox(
            //           activeColor: kPrimaryColor,
            //           value: selectedCauses.contains(item),
            //           onChanged: (value) {
            //             setState(() {
            //               //checkBoxValue = value;
            //               print("value : $value");
            //               // widget.form = value;
            //               checkCause(value, item);
            //             });
            //           },
            //         ),
            //         Text(item, style: TextStyle(fontSize: 17, ),)
            //       ],
            //     ),
            //   );
            // }).toList(),
            // SizedBox(height: 20,),
            // Container(
            //   margin: EdgeInsets.only(left: 30),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: <Widget>[
            //       Text(AppLocalizations.of(context).translate('issuesWith'), style: TextStyle(fontSize: 17),),
            //       SizedBox(height: 20,),
            //       Wrap(
            //         direction: Axis.horizontal,
            //         children: <Widget>[
            //           ...issues.map((item) {
            //             return Container(
            //               width: MediaQuery.of(context).size.width / 2 - 45,
            //               margin: EdgeInsets.only(bottom: 15, right: 15),
            //               //height: 50,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(3),
            //                 border: Border.all(color: selectedIssues.contains(item) ? kPrimaryColor : kBorderGrey)
            //               ),

            //               child: CheckboxListTile(
            //                 controlAffinity: ListTileControlAffinity.leading,
            //                 contentPadding: EdgeInsets.only(left: 5),
            //                 title: Text(item, style: TextStyle(fontSize: 17, ),),
            //                 value: selectedCauses.contains(item),
            //                 onChanged: (value) {
            //                   setState(() {
            //                     checkCause(value, item);
            //                   });
            //                 },
            //               ),
            //             );
            //           }).toList(),
            //         ],
            //       ),
            //       SizedBox(height: 20,),
            //       selectedIssues.contains('Other') ? Container(
            //         child: TextField(
            //           keyboardType: TextInputType.multiline,
            //           maxLines: 3,
            //           style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
            //           decoration: InputDecoration(
            //             contentPadding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 20, right: 20),
            //             filled: true,
            //             fillColor: kSecondaryTextField,
            //             border: new UnderlineInputBorder(
            //               borderSide: new BorderSide(color: Colors.white),
            //               borderRadius: BorderRadius.only(
            //                 topLeft: Radius.circular(4),
            //                 topRight: Radius.circular(4),
            //               )
            //             ),

            //             hintText: 'Describe other issues',
            //             hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
            //           ),
            //         ),
            //       ) : Container(),
            //     ],
            //   ),
            // ),
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
              child: Text(AppLocalizations.of(context).translate("whatIsPatientTem"), style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: PrimaryTextField(
                hintText: AppLocalizations.of(context).translate('tempReading'),
                controller: _temperatureController,
                type: TextInputType.number,
                topPaadding: 8,
                bottomPadding: 8,
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
                  Text(AppLocalizations.of(context).translate("rightArm"), style: TextStyle(color: Colors.black)),
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
                      type: TextInputType.number,
                      topPaadding: 8,
                      bottomPadding: 8,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text('/', style: TextStyle(fontSize: 20),),
                  SizedBox(width: 10,),
                  Expanded(
                    child: PrimaryTextField(
                      hintText: AppLocalizations.of(context).translate('diastolic'),
                      controller: _diastolicController,
                      type: TextInputType.number,
                      topPaadding: 8,
                      bottomPadding: 8,
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
                type: TextInputType.number,
                topPaadding: 8,
                bottomPadding: 8,
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

var followupQuestions = {};
var followupAnswers = [];
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
// var firstQuestion = {
//   'question': 'Are you having any pain or discomfort or pressure or heaviness in your chest?',
//   'question_bn': 'আপনার কি কখনও স্ট্রোক হয়েছে?',
//   'options': ['yes', 'no'],
//   'options_bn': ['হ্যা', 'না']
// };
// var secondQuestion = {
//   'question': 'Are you having any difficulty in talking, or any weakness or numbness of arms, legs or face?',
//   'question_bn': 'আপনার কি কখনও স্ট্রোক হয়েছে?',
//   'options': ['yes', 'no'],
//   'options_bn': ['হ্যা', 'না']
// };
var firstAnswer = null;
var secondAnswer = null;

class _AcuteIssuesState extends State<AcuteIssues> {

  List devices = [];
  var selectedDevice = 0;

  @override
  initState() {
    super.initState();
    firstAnswer = null;
    secondAnswer = null;
    devices = Device().getDevices();
    prepareQuestions();
    prepareAnswers();
  }
  prepareQuestions() {
    followupQuestions = Questionnaire().questions['unwell_followup'];
  }
  prepareAnswers() {
    followupAnswers = [];
    followupQuestions['items'].forEach((qtn) {
      followupAnswers.add('');
    });
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
                children: [
                  ...followupQuestions['items'].map((question) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                        // child: Text(_questions['items'][0]['question'],
                        child: Text(getQuestionText(context, question),
                          style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                        )
                      ),
                      SizedBox(height: 20,),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                        width: MediaQuery.of(context).size.width * .5,
                        child: Row(
                          children: <Widget>[
                            ...question['options'].map((option) => 
                              Expanded(
                                child: Container(
                                  height: 40,
                                  margin: EdgeInsets.only(right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    // border: Border.all(width: 1, color:  Color(0xFF01579B)),
                                    border: Border.all(width: 1, color: followupAnswers[followupQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFF01579B) : Colors.black),
                                    borderRadius: BorderRadius.circular(3),
                                    color: followupAnswers[followupQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? Color(0xFFE1F5FE) : null
                                    // color: Color(0xFFE1F5FE) 
                                  ),
                                  child: FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        // firstAnswer = option;
                                        followupAnswers[followupQuestions['items'].indexOf(question)] = question['options'][question['options'].indexOf(option)];
                                      });
                                    },
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    child: Text(getOptionText(context, question, option),
                                      style: TextStyle(color: followupAnswers[followupQuestions['items'].indexOf(question)] == question['options'][question['options'].indexOf(option)] ? kPrimaryColor : null),
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
                    ],
                  );
                 }).toList() 

              //     SizedBox(height: 30,),
              //     Container(
              //       margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              //       // child: Text(_questions['items'][0]['question'],
              //       child: Text(getQuestionText(context, secondQuestion),
              //         style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
              //       )
              //     ),
              //     SizedBox(height: 20,),
              //     Container(
              //       margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
              //       width: MediaQuery.of(context).size.width * .5,
              //       child: Row(
              //         children: <Widget>[
              //           ...secondQuestionOptions.map((option) => 
              //             Expanded(
              //               child: Container(
              //                 height: 40,
              //                 margin: EdgeInsets.only(right: 10, left: 10),
              //                 decoration: BoxDecoration(
              //                   // border: Border.all(width: 1, color:  Color(0xFF01579B)),
              //                   border: Border.all(width: 1, color: (secondAnswer != null && secondAnswer == option) ? Color(0xFF01579B) : Colors.black),
              //                   borderRadius: BorderRadius.circular(3),
              //                   color: (secondAnswer != null && secondAnswer == option) ? Color(0xFFE1F5FE) : null
              //                   // color: Color(0xFFE1F5FE) 
              //                 ),
              //                 child: FlatButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       secondAnswer = option;
              //                     });
              //                   },
              //                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //                   child: Text(option.toUpperCase(),
              //                     style: TextStyle(color: (secondAnswer != null && secondAnswer == option) ? kPrimaryColor : null),
              //                     // style: TextStyle(color: kPrimaryColor),
              //                   ),
              //                 ),
              //               )
              //             ),
              //           ).toList()
              //         ],
              //       )
              //     ),



              // // Row(
              // //   mainAxisAlignment: MainAxisAlignment.end,
              // //   children: <Widget>[
              // //     Container(
              // //       width: 200,
              // //       margin: EdgeInsets.symmetric(horizontal: 30),
              // //       height: 50,
              // //       decoration: BoxDecoration(
              // //         color: kPrimaryColor,
              // //         borderRadius: BorderRadius.circular(3)
              // //       ),
              // //       child: FlatButton(
              // //         onPressed: () async {
              // //           if (firstAnswer == 'yes' || secondAnswer == 'yes') {
              // //             var data = {
              // //               'meta': {
              // //                 'patient_id': Patient().getPatient()['id'],
              // //                 "collected_by": Auth().getAuth()['uid'],
              // //                 "status": "pending"
              // //               },
              // //               'body': {}
              // //             };
              // //             Navigator.of(context).pushNamed('/medicalRecommendation', arguments: data);
              // //             return;
              // //           }

              // //           Navigator.of(context).pushNamed(FollowupVisitScreen.path);
                        
              // //         },
              // //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              // //         child: Text(AppLocalizations.of(context).translate('next'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
              // //       ),
              // //     ),
              // //   ],
              // // ),

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
                      type: TextInputType.number,
                      topPaadding: 8,
                      bottomPadding: 8,
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

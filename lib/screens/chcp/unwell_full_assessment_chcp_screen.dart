import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'full_assessment_chcp_screen.dart';

final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _causesFormKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final _temperatureController = TextEditingController();
final _systolicController = TextEditingController();
final _diastolicController = TextEditingController();
final _pulseController = TextEditingController();
final _glucoseController = TextEditingController();
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

class UnwellFullAssessmentChcpScreen extends StatefulWidget {
  static const path = '/unWellFullAssessmentChcpScreen';
  @override
  _UnwellFullAssessmentChcpScreen createState() => _UnwellFullAssessmentChcpScreen();
}

class _UnwellFullAssessmentChcpScreen extends State<UnwellFullAssessmentChcpScreen> {
  int _currentStep = 0;
  String nextText = 'Ok to Proceed';

  @override
  void initState() {
    super.initState();
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _causesFormKey,
      appBar: AppBar(
        leading: FlatButton(
          onPressed: (){
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
                    if (_currentStep == 1) {
                    }
                    if (_currentStep == 0) {
                      Navigator.of(context).pushNamed(FullAssessmentChcpScreen.path);
                    }
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
                  });
                },
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      )
    );
  }
}

var firstAnswer = null;
var secondAnswer = null;

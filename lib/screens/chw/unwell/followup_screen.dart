import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
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


class ChwFollowupScreen extends StatefulWidget {
  @override
  _ChwFollowupState createState() => _ChwFollowupState();
}

class _ChwFollowupState extends State<ChwFollowupScreen> {
  
  int _currentStep = 0;

  String nextText = 'NEXT';

  @override
  void initState() {
    super.initState();
    _checkAuth();
    clearForm();
  }

  nextStep() {
    setState(() {
      if (_currentStep == 2) {
        _currentStep = _currentStep + 1;
        nextText = 'COMPLETE';
      } else if (_currentStep == 3) {
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
        'patient_id': Patient().getPatient()['uuid']
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

    if (temp > 39 || glucose > 250 || systolic > 160 || diastolic > 100) {
      var response = FollowupController().create(data);
      // print(response);
      // if (response['error'] != null && !response['error'])
        Navigator.of(context).pushReplacementNamed('/medicalRecommendation');
    } else {
      var response = FollowupController().create(data);
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
              child: _currentStep != 0 ? FlatButton(
                onPressed: () {
                  
                  setState(() {
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
              child: _currentStep < _mySteps().length ? FlatButton(
                onPressed: () {
                  setState(() {
                    print(_currentStep);
                    if (nextText =='COMPLETE') {
                      checkData();
                    }
                    if (_currentStep == 2) {
                      print(_currentStep);
                     nextText = 'COMPLETE';
                    }
                    if (_currentStep < 3) {
                     
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
        content: UnwellCauses(),
        isActive: _currentStep >= 0,
      ),
      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: Temperature(parent: this),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: BloodPressure(parent: this),
        isActive: _currentStep >= 2,
      ),

      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: Glucose(parent: this),
        isActive: _currentStep >= 4,
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
        key: _patientFormKey,
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
            ...causes.map((item) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 30, right: 30, bottom: 15),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: selectedCauses.contains(item) ? kPrimaryColor : kBorderGrey)
                ),
                child: FlatButton(
                  onPressed: () async {

                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        activeColor: kPrimaryColor,
                        value: selectedCauses.contains(item),
                        onChanged: (value) {
                          setState(() {
                            // widget.form = value;
                            checkCause(value, item);
                          });
                        },
                      ),
                      Text(item, style: TextStyle(fontSize: 17, ),)
                    ],
                  )
                ),
              );
            }).toList(),

            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('issuesWith'), style: TextStyle(fontSize: 17),),
                  SizedBox(height: 20,),
                  Wrap(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      ...issues.map((item) {
                        return Container(
                          padding: EdgeInsets.only(right: 20),
                          margin: EdgeInsets.only(right: 20,  bottom: 15),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: selectedIssues.contains(item) ? kPrimaryColor : kBorderGrey)
                          ),
                          child: GestureDetector(
                            onTap: () async {

                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Checkbox(
                                  activeColor: kPrimaryColor,
                                  value: selectedIssues.contains(item),
                                  onChanged: (value) {
                                    setState(() {
                                      // widget.form = value;
                                      checkIssue(value, item);
                                    });
                                  },
                                ),
                                Text(item, style: TextStyle(fontSize: 17, ),)
                              ],
                            )
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 20,),
                  selectedIssues.contains('Other') ? Container(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
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
                      
                        hintText: 'Describe other issues',
                        hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                      ),
                    ),
                  ) : Container(),
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

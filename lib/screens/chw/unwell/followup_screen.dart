import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import '../../../custom-classes/custom_stepper.dart';

final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _causesFormKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final _temperatureController = TextEditingController();
final _systolicController = TextEditingController();
final _diastolicController = TextEditingController();
final _pulseController = TextEditingController();
final _glucoseController = TextEditingController();


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
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } 
  }

  checkData() {
    int temp = 0;
    int systolic = 0;
    int diastolic = 0;
    int glucose = 0;
    if (_temperatureController.text != '') {
      print('temp');
      temp = int.parse(_temperatureController.text);
    }
    if (_systolicController.text != '') {
      print('systolic');
      // print(_systolicController.text);
      systolic = int.parse(_systolicController.text);
    }
    if (_diastolicController.text != '') {
      print('diastolic');
      diastolic = int.parse(_diastolicController.text);
    }
    if (_glucoseController.text != '') {
      print('glucose');
      glucose = int.parse(_glucoseController.text);
    }

    if (temp > 39 || glucose > 250 || systolic > 160 || diastolic > 100) {
      Navigator.of(context).pushNamed('/medicalRecommendation');
    } else {
      Navigator.of(context).pushNamed('/chwSeverity');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Followup'),
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
        content: Temperature(),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: BloodPressure(),
        isActive: _currentStep >= 2,
      ),

      CustomStep(
        title: Text('Permission', textAlign: TextAlign.center,),
        content: Glucose(),
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
              child: Text('What is causing you to be unwell ?', style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 30),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: kPrimaryColor)
              ),
              child: FlatButton(
                onPressed: () async {

                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: true,
                      onChanged: (value) {
                        setState(() {
                          // widget.form = value;
                        });
                      },
                    ),
                    Text('Fever', style: TextStyle(fontSize: 17, ),)
                  ],
                )
              ),
            ),
            SizedBox(height: 15,),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 30),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: kTextGrey)
              ),
              child: FlatButton(
                onPressed: () async {

                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: false,
                      onChanged: (value) {
                        setState(() {
                          // widget.form = value;
                        });
                      },
                    ),
                    Text('Shortness of breath', style: TextStyle(fontSize: 17, ),)
                  ],
                )
              ),
            ),
            SizedBox(height: 15,),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 30),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: kTextGrey)
              ),
              child: FlatButton(
                onPressed: () async {

                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: false,
                      onChanged: (value) {
                        setState(() {
                          // widget.form = value;
                        });
                      },
                    ),
                    Text('Feeling faint', style: TextStyle(fontSize: 17, ),)
                  ],
                )
              ),
            ),
            SizedBox(height: 15,),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 30),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: kTextGrey)
              ),
              child: FlatButton(
                onPressed: () async {

                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: kPrimaryColor,
                      value: false,
                      onChanged: (value) {
                        setState(() {
                          // widget.form = value;
                        });
                      },
                    ),
                    Text('Stomach discomfort', style: TextStyle(fontSize: 17, ),)
                  ],
                )
              ),
            ),

            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Issues with', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 20,),
                  Wrap(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Container(
                      padding: EdgeInsets.only(right: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: kPrimaryColor)
                        ),
                        child: GestureDetector(
                          onTap: () async {

                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                activeColor: kPrimaryColor,
                                value: true,
                                onChanged: (value) {
                                  setState(() {
                                    // widget.form = value;
                                  });
                                },
                              ),
                              Text('Vision', style: TextStyle(fontSize: 17, ),)
                            ],
                          )
                        ),
                      ),
                      SizedBox(width: 20,),
                      Container(
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.only(bottom: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: kTextGrey)
                        ),
                        child: GestureDetector(
                          onTap: () async {

                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                activeColor: kPrimaryColor,
                                value: false,
                                onChanged: (value) {
                                  setState(() {
                                    // widget.form = value;
                                  });
                                },
                              ),
                              Text('Smell', style: TextStyle(fontSize: 17, ),)
                            ],
                          )
                        ),
                      ),
                      SizedBox(width: 20,),
                      Container(
                      padding: EdgeInsets.only(right: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: kTextGrey)
                        ),
                        child: GestureDetector(
                          onTap: () async {

                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                activeColor: kPrimaryColor,
                                value: false,
                                onChanged: (value) {
                                  setState(() {
                                    // widget.form = value;
                                  });
                                },
                              ),
                              Text('Mental Health', style: TextStyle(fontSize: 17, ),)
                            ],
                          )
                        ),
                      ),
                      SizedBox(width: 20,),
                      Container(
                      padding: EdgeInsets.only(right: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: kTextGrey)
                        ),
                        child: GestureDetector(
                          onTap: () async {

                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                activeColor: kPrimaryColor,
                                value: false,
                                onChanged: (value) {
                                  setState(() {
                                    // widget.form = value;
                                  });
                                },
                              ),
                              Text('Other', style: TextStyle(fontSize: 17, ),)
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Container(
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
              child: Text('Can I take your temerature ?', style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: PrimaryTextField(
                hintText: 'Temperature readings (celsius)',
                controller: _temperatureController,
                topPaadding: 10,
                bottomPadding: 10,
              ),
            ),
            SizedBox(height: 10,),
            Container(
              // margin: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              child: Text('SKIP (DEVICE UNAVAILABLE)', style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500,)),
            )

          ],
        ),
      )
    );
  }
}

class BloodPressure extends StatefulWidget {

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
              child: Text('Can I take your BLood Pressure & Heart Rate ?', style: TextStyle(fontSize: 21),),
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
                    groupValue: 'left',
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                    },
                  ),
                  Text('Left Arm', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 30,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'right',
                    groupValue: 'left',
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
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
                      hintText: 'Systolic',
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
                      hintText: 'Diastolic',
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
            Container(
              // margin: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              child: Text('SKIP (DEVICE UNAVAILABLE)', style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500,)),
            )

          ],
        ),
      )
    );
  }
}


class Glucose extends StatefulWidget {

  @override
  _GlucoseState createState() => _GlucoseState();
}

class _GlucoseState extends State<Glucose> {
  
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
              child: Text('Can I take your Blood Pressure & Heart Rate ?', style: TextStyle(fontSize: 21),),
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
                    groupValue: 'fasting',
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                    },
                  ),
                  Text('Fasting', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 30,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'random',
                    groupValue: 'fasting',
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                    },
                  ),
                  Text('Random', style: TextStyle(color: Colors.black)),
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
                    groupValue: 'mg/dL',
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                    },
                  ),
                  Text('mg/dL', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 20,),
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 'mmol/L',
                    groupValue: 'mg/dL',
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                    },
                  ),
                  Text('mmol/L', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 100),
              alignment: Alignment.center,
              child: PrimaryTextField(
                hintText: 'Select a device',
                topPaadding: 10,
                bottomPadding: 10,
              ),
            ),
            SizedBox(height: 10,),
            Container(
              // margin: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              child: Text('SKIP (DEVICE UNAVAILABLE)', style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500,)),
            )

          ],
        ),
      )
    );
  }
}




class PatientTopbar extends StatelessWidget {
  const PatientTopbar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
      color: Colors.white,
        boxShadow: [BoxShadow(
          blurRadius: .5,
          color: Colors.black38,
          offset: Offset(0.0, 1.0)
        )]
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image.asset(
                      'assets/images/avatar.png',
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
                  SizedBox(width: 15,),
                  Text('Nurul Begum', style: TextStyle(fontSize: 18))
                ],
              ),
            ),
          ),
          Expanded(
            child: Text('31Y Female', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
          ),
          Expanded(
            child: Text('PID: N-121933421', style: TextStyle(fontSize: 18))
          )
        ],
      ),
    );
  }
}

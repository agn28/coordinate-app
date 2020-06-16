import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaires_screen.dart';

int selectedOption = -1;
var _questions = {};
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

int _secondQuestionOption = 1;
int _firstQuestionOption = 1;
int _thirdQuestionOption = 1;
int _fourthQuestionOption = 1;
int _fifthQuestionOption = 1;
int _sixthQuestionOption = 1;
int _eightsQuestionOption = 1;
final _seventhQuestionController = TextEditingController();

class MedicalHistoryScreen extends CupertinoPageRoute {
  final EncounnterStepsState parent;

  MedicalHistoryScreen({this.parent})
      : super(builder: (BuildContext context) => new MedicalHistory(parent: parent));

}

class MedicalHistory extends StatefulWidget {
  final EncounnterStepsState parent;
  MedicalHistory({this.parent});
  @override
  _MedicalHistoryState createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
 int _currentStep = 0; 

 @override
 void initState() {
    super.initState();
    setState(() {
      _questions = Questionnaire().questions['medical_history'];
      _secondQuestionOption = 1;
      _firstQuestionOption = 1;
      _thirdQuestionOption = 1;
      _fourthQuestionOption = 1;
      _fifthQuestionOption = 1;
      _sixthQuestionOption = 1;
      _eightsQuestionOption = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Questionnaire', style: TextStyle(color: kPrimaryColor)),
        backgroundColor: Colors.white,
        elevation: 0.0,
        bottomOpacity: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),

      body: CustomStepper(
        physics: ClampingScrollPhysics(),
        type: CustomStepperType.horizontal,
        isHeader: false,
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
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.chevron_left),
                    Text('BACK', style: TextStyle(fontSize: 20)),
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
              child: _currentStep < _mySteps().length - 1 ? FlatButton(
                onPressed: () {
                  setState(() {
                    _currentStep = _currentStep + 1;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('NEXT', style: TextStyle(fontSize: 20)),
                    Icon(Icons.chevron_right)
                  ],
                ),
              ) : FlatButton(
                onPressed: () async {
                  var answers = [];
                  answers.add(_questions['items'][0]['options'][_firstQuestionOption]);
                  answers.add(_questions['items'][1]['options'][_secondQuestionOption]);
                  answers.add(_questions['items'][2]['options'][_thirdQuestionOption]);
                  answers.add(_questions['items'][3]['options'][_fourthQuestionOption]);
                  answers.add(_questions['items'][4]['options'][_fifthQuestionOption]);
                  answers.add(_questions['items'][5]['options'][_sixthQuestionOption]);
                  answers.add(_seventhQuestionController.text);
                  answers.add(_questions['items'][7]['options'][_eightsQuestionOption]);
                  answers.add(_selectedAllergies);
                  var result = Questionnaire().addMedicalHistory('medical_history', answers);
                  if (result == 'success') {
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Data saved successfully!'),
                        backgroundColor: Color(0xFF4cAF50),
                      )
                    );
                    this.widget.parent.setState(() {
                      this.widget.parent.setStatus();
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.of(context).pop();
                  } else {
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(result.toString()),
                        backgroundColor: kPrimaryRedColor,
                      )
                    );
                  }
                },
                child: Text('COMPLETE', style: TextStyle(fontSize: 20, color: kPrimaryColor))
              )
            ),
          ],
        )
      ),
    );
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [
      CustomStep(
        title: Text('Photo'),
        content: FirstQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: SecondQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: ThirdQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: FourthQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: FifthQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: SixthQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: SeventhQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: EighthQuestion(),
        isActive: _currentStep >= 2,
      ),
    ];

    return _steps;
  }
  
}

class FirstQuestion extends StatefulWidget {
  const FirstQuestion({
    Key key,
  }) : super(key: key);

  @override
  _FirstQuestionState createState() => _FirstQuestionState();
}

class _FirstQuestionState extends State<FirstQuestion> {

  

  _changeOption(value) {
    setState(() {
      _firstQuestionOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              height: 90,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF4F4F4),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.error_outline, color: Color(0x87000000), size: 40,),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Text('Do you have a history of (or has ever been told they have) (select all that apply)', style: TextStyle(fontSize: 19),),
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][0]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  ..._questions['items'][0]['options'].map((option) => 
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: _firstQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                          borderRadius: BorderRadius.circular(3),
                          color: _firstQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _changeOption(_questions['items'][0]['options'].indexOf(option));
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(option.toUpperCase(),
                            style: TextStyle(color: _firstQuestionOption == _questions['items'][0]['options'].indexOf(option) ? kPrimaryColor : null),
                          ),
                        ),
                      )
                    ),
                  ).toList()
                ],
              )
            ),
          ],
        ),
    );
  }
 }


class SecondQuestion extends StatefulWidget {
  const SecondQuestion({
    Key key,
  }) : super(key: key);

  @override
  _SecondQuestionState createState() => _SecondQuestionState();
}

class _SecondQuestionState extends State<SecondQuestion> {
  
    _changeOption(value) {
      setState(() {
        _secondQuestionOption = value;
      });
    }
    
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][1]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  ..._questions['items'][0]['options'].map((option) => 
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: _secondQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                          borderRadius: BorderRadius.circular(3),
                          color: _secondQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _changeOption(_questions['items'][0]['options'].indexOf(option));
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(option.toUpperCase(),
                            style: TextStyle(color: _secondQuestionOption == _questions['items'][0]['options'].indexOf(option) ? kPrimaryColor : null),
                          ),
                        ),
                      )
                    ),
                  ).toList()
                ],
              )
            ),
          ],
        ),
    );
  }
 }


class ThirdQuestion extends StatefulWidget {

  @override
  _ThirdQuestionState createState() => _ThirdQuestionState();
}

class _ThirdQuestionState extends State<ThirdQuestion> {
  
    _changeOption(value) {
      setState(() {
        _thirdQuestionOption = value;
      });
    }
    
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][2]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  ..._questions['items'][2]['options'].map((option) => 
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: _thirdQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                          borderRadius: BorderRadius.circular(3),
                          color: _thirdQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _changeOption(_questions['items'][2]['options'].indexOf(option));
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(option.toUpperCase(),
                            style: TextStyle(color: _thirdQuestionOption == _questions['items'][0]['options'].indexOf(option) ? kPrimaryColor : null),
                          ),
                        ),
                      )
                    ),
                  ).toList()
                ],
              )
            ),
          ],
        ),
    );
  }
}


class FourthQuestion extends StatefulWidget {

  @override
  _FourthQuestionState createState() => _FourthQuestionState();
}

class _FourthQuestionState extends State<FourthQuestion> {
  
    _changeOption(value) {
      setState(() {
        _fourthQuestionOption = value;
      });
    }
    
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][3]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  ..._questions['items'][3]['options'].map((option) => 
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: _fourthQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                          borderRadius: BorderRadius.circular(3),
                          color: _fourthQuestionOption == _questions['items'][3]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _changeOption(_questions['items'][3]['options'].indexOf(option));
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(option.toUpperCase(),
                            style: TextStyle(color: _fourthQuestionOption == _questions['items'][0]['options'].indexOf(option) ? kPrimaryColor : null),
                          ),
                        ),
                      )
                    ),
                  ).toList()
                ],
              )
            ),
          ],
        ),
    );
  }
}


class FifthQuestion extends StatefulWidget {

  @override
  _FifthQuestionState createState() => _FifthQuestionState();
}

class _FifthQuestionState extends State<FifthQuestion> {
  
    _changeOption(value) {
      setState(() {
        _fifthQuestionOption = value;
      });
    }
    
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][4]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  ..._questions['items'][4]['options'].map((option) => 
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: _fifthQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                          borderRadius: BorderRadius.circular(3),
                          color: _fifthQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _changeOption(_questions['items'][4]['options'].indexOf(option));
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(option.toUpperCase(),
                            style: TextStyle(color: _fifthQuestionOption == _questions['items'][0]['options'].indexOf(option) ? kPrimaryColor : null),
                          ),
                        ),
                      )
                    ),
                  ).toList()
                ],
              )
            ),
          ],
        ),
    );
  }
}


class SixthQuestion extends StatefulWidget {

  @override
  _SixthQuestionState createState() => _SixthQuestionState();
}

class _SixthQuestionState extends State<SixthQuestion> {
  
    _changeOption(value) {
      setState(() {
        _sixthQuestionOption = value;
      });
    }
    
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][5]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  ..._questions['items'][4]['options'].map((option) => 
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: _sixthQuestionOption == _questions['items'][5]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                          borderRadius: BorderRadius.circular(3),
                          color: _sixthQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _changeOption(_questions['items'][5]['options'].indexOf(option));
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(option.toUpperCase(),
                            style: TextStyle(color: _sixthQuestionOption == _questions['items'][5]['options'].indexOf(option) ? kPrimaryColor : null),
                          ),
                        ),
                      )
                    ),
                  ).toList()
                ],
              )
            ),
          ],
        ),
    );
  }
}


class SeventhQuestion extends StatefulWidget {

  @override
  _SeventhQuestionState createState() => _SeventhQuestionState();
}

class _SeventhQuestionState extends State<SeventhQuestion> {
  
    _changeOption(value) {
      setState(() {
        _firstQuestionOption = value;
      });
    }
    
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][6]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              width: 250,
              child: PrimaryTextField(
                topPaadding: 15,
                bottomPadding: 15,
                hintText: 'Write your problem',
                controller: _seventhQuestionController,
              )
            ),
          ],
        ),
    );
  }
}


class EighthQuestion extends StatefulWidget {

  @override
  _EighthQuestionState createState() => _EighthQuestionState();
}

var selectedDiseases = [];
var _selectedAllergies = [];
class _EighthQuestionState extends State<EighthQuestion> {
  List allMedications = [];
  List _medications = [];
  var _checkValue = {};
  


  @override
  void initState() {
    super.initState();
    _preparedata();
    _selectedAllergies = [];
  }

  List _allDiseases = ['lupus', 'diabetes', 'bronchitis', 'hypertension', 'cancer', 'Ciliac', 'Scleroderma', 'Abulia', 'Agraphia', 'Chorea', 'Coma' ];
    _changeOption(value) {
      setState(() {
        _eightsQuestionOption = value;
      });
    }

  _preparedata() async {
    var data = await DefaultAssetBundle.of(context).loadString('assets/allergies.json');
    setState(() {
      allMedications = json.decode(data);
      _medications = allMedications;
    });
    _preapareCheckboxValue();
  }
  _preapareCheckboxValue() {
    _medications.forEach((item) {
      selectedDiseases.indexOf(item) == -1 ? _checkValue[item] = false : _checkValue[item] = true;
    });

  }

  _updateCheckBox(value, index) {
    // if (value == true && _selectedItem.length == 3) {
    //   return Toast.show("You cannot select more than three diseases", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    // }

    setState(() {
      value ? _selectedAllergies.add(_medications[index]) : _selectedAllergies.removeAt(_selectedAllergies.indexOf(_medications[index]));
      _checkValue[_medications[index]] = value;
    });

  }
    
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Medical History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][7]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  ..._questions['items'][7]['options'].map((option) => 
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: _eightsQuestionOption == _questions['items'][7]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                          borderRadius: BorderRadius.circular(3),
                          color: _eightsQuestionOption == _questions['items'][7]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _changeOption(_questions['items'][7]['options'].indexOf(option));
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(option.toUpperCase(),
                            style: TextStyle(color: _eightsQuestionOption == _questions['items'][7]['options'].indexOf(option) ? kPrimaryColor : null),
                          ),
                        ),
                      )
                    ),
                  ).toList()
                ],
              )
            ),

            _eightsQuestionOption == 0 ? Container(
              width: double.infinity,
              height: 520.0,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Form(
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 10,),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Select Allergies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),

                    SizedBox(height: 10,),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        // direction: Axis.horizontal,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        
                        children: <Widget>[
                          ..._selectedAllergies.map((item) => 
                            Container(
                              margin: EdgeInsets.only(right: 10, bottom: 10),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Wrap(
                                children: <Widget>[
                                  Text(item, style: TextStyle(color: Colors.white),),
                                  SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _checkValue[item] = false;
                                        _selectedAllergies.removeAt(_selectedAllergies.indexOf(item));
                                      });
                                    },
                                    child: Icon(Icons.close, size: 15, color: Colors.white,),
                                  ),
                                ],
                              )
                            ),
                          ).toList()
                        ],
                      )
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          
                          TextField(
                            
                            style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                            onChanged: (value) => {
                              setState(() {
                                _medications = allMedications
                                  .where((item) => item
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                                  .toList();
                              })
                            },
                            decoration: InputDecoration(
                              counterText: ' ',
                              contentPadding: EdgeInsets.only(top: 14, bottom: 14,),
                              prefixIcon: Icon(Icons.search),
                              filled: true,
                              fillColor: kSecondaryTextField,
                              border: new UnderlineInputBorder(
                                borderSide: new BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                )
                              ),
                              hintText: 'Search',
                              hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                            )
                          )
                        ],
                      )
                    ),

                    Container(
                      height: 340,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _medications.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10,),
                                Checkbox(
                                  activeColor: kPrimaryColor,
                                  value: _checkValue[_medications[index]],
                                  onChanged: (value) {
                                    _updateCheckBox(value, index);
                                  },
                                ),
                                Text(StringUtils.capitalize(_medications[index]), style: TextStyle(fontSize: 17),)
                              ],
                            )
                          );
                        },
                      )
                    ),
                    
                  ],
                )
              ),
            ) : Container(),
  
          ],
        ),
    );
  }
}

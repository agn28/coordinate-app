import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaires_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

int selectedOption = - 1;
var _questions = {};
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

int _firstQuestionOption = 1;
int _secondQuestionOption = 1;
int _thirdQuestionOption = 1;
int _fourthQuestionOption = 1;

class DietScreen extends CupertinoPageRoute {
  final EncounnterStepsState parent;

  DietScreen({this.parent})
      : super(builder: (BuildContext context) => new Diet(parent: parent));

}

class Diet extends StatefulWidget {
  final EncounnterStepsState parent;
  Diet({this.parent});
  @override
  _DietState createState() => _DietState();
}

class _DietState extends State<Diet> {
 int _currentStep = 0; 

 @override
 void initState() {
    super.initState();
    setState(() {
      _questions = Questionnaire().questions['diet'];
      _firstQuestionOption = 1;
      _secondQuestionOption = 1;
      _thirdQuestionOption = 1;
      _fourthQuestionOption = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Diet', style: TextStyle(color: kPrimaryColor)),
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
                  var result = Questionnaire().addDiet('diet', answers);
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
    ];

    return _steps;
  }
  
}

class FirstQuestion extends StatefulWidget {

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
              child: Text('Diet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
                    child: Text('Now I am going to ask you some questions about your diet.', style: TextStyle(fontSize: 19),),
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
                          child: Text(StringUtils.capitalize(option),
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

  @override
  _SecondQuestionState createState() => _SecondQuestionState();
}

class _SecondQuestionState extends State<SecondQuestion> {
  
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
              child: Text('Diet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][1]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Column(
                children: <Widget>[
                  ..._questions['items'][1]['options'].map((option) => 
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: kPrimaryColor,
                          value: _questions['items'][1]['options'].indexOf(option),
                          groupValue: _secondQuestionOption,
                          onChanged: (val) {
                            setState(() {
                              _secondQuestionOption = val;
                            });
                          },
                        ),
                        Text(StringUtils.capitalize(option), style: TextStyle(color: Colors.black, fontSize: 18)),
                      ],
                    ),
                  ).toList(),
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
      selectedOption = value;
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
              child: Text('Diet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][2]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Column(
                children: <Widget>[
                  ..._questions['items'][2]['options'].map((option) => 
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: kPrimaryColor,
                          value: _questions['items'][2]['options'].indexOf(option),
                          groupValue: _thirdQuestionOption,
                          onChanged: (val) {
                            setState(() {
                              _thirdQuestionOption = val;
                            });
                          },
                        ),
                        Text(StringUtils.capitalize(option), style: TextStyle(color: Colors.black, fontSize: 18)),
                      ],
                    ),
                  ).toList(),
                ],
              )
            ),
          ],
        ),
    );
  }
 }


 class FourthQuestion extends StatefulWidget {
  const FourthQuestion({
    Key key,
  }) : super(key: key);

  

  @override
  _FourthQuestionState createState() => _FourthQuestionState();
}
class _FourthQuestionState extends State<FourthQuestion> {

  _changeOption(value) {
    setState(() {
      selectedOption = value;
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
              child: Text('Diet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][3]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Column(
                children: <Widget>[
                  ..._questions['items'][3]['options'].map((option) => 
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: kPrimaryColor,
                          value: _questions['items'][3]['options'].indexOf(option),
                          groupValue: _fourthQuestionOption,
                          onChanged: (val) {
                            setState(() {
                              _fourthQuestionOption = val;
                            });
                          },
                        ),
                        Text(StringUtils.capitalize(option), style: TextStyle(color: Colors.black, fontSize: 18)),
                      ],
                    ),
                  ).toList(),
                ],
              )
            ),
          ],
        ),
    );
  }
 }

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaires_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

int selectedOption = -1;
var _questions = {};
int _secondQuestionOption = 0;
int _firstQuestionOption = 0;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class TobaccoScreen extends CupertinoPageRoute {
  
  var parent;
  TobaccoScreen({this.parent})
      : super(builder: (BuildContext context) => new Tobacco(parent: parent,));

}

class Tobacco extends StatefulWidget {
  EncounnterStepsState parent;
  Tobacco({this.parent});
  @override
  _TobaccoState createState() => _TobaccoState();
}

class _TobaccoState extends State<Tobacco> {
 int _currentStep = 0; 

 @override
 void initState() {
    super.initState();
    setState(() {
      _questions = Questionnaire().questions['tobacco'];
      _firstQuestionOption = -1;
      _secondQuestionOption = -1;
    });
  }

  _changeOption(value) {
    setState(() {
      _firstQuestionOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Tobacco', style: TextStyle(color: kPrimaryColor)),
        backgroundColor: Colors.white,
        elevation: 0.0,
        bottomOpacity: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),

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
                    child: Text(AppLocalizations.of(context).translate('questionsAboutTobacco'), style: TextStyle(fontSize: 19),),
                  )
                ],
              )
            ),

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
                    margin: EdgeInsets.symmetric( horizontal: 30),
                    child: Text(_questions['items'][0]['question'],
                      style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500,),
                    )
                  ),
                  SizedBox(height: 40,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                    width: MediaQuery.of(context).size.width * .5,
                    
                    child: Row(
                      children: <Widget>[
                        ..._questions['items'][0]['options'].map((option) => 
                          Expanded(
                            child: Container(
                              height: 40,
                              margin: EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: _firstQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                                borderRadius: BorderRadius.circular(3),
                                color: _firstQuestionOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _firstQuestionOption = _questions['items'][0]['options'].indexOf(option);
                                  });
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
              )
            ),

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
                    child: Text(_questions['items'][1]['question'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 30,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                    width: MediaQuery.of(context).size.width * .5,
                    child: Row(
                      children: <Widget>[
                        ..._questions['items'][1]['options'].map((option) => 
                          Expanded(
                            child: Container(
                              height: 40,
                              margin: EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: _secondQuestionOption == _questions['items'][1]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                                borderRadius: BorderRadius.circular(3),
                                color: _secondQuestionOption == _questions['items'][1]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _secondQuestionOption = _questions['items'][1]['options'].indexOf(option);
                                  });
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(StringUtils.capitalize(option),
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
              )
            ),


            SizedBox(height: 60,),

              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black54),
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                        ),
                      )
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            var answers = [];
                            if (_firstQuestionOption == -1 && _secondQuestionOption == -1) {
                              Toast.show('No answer given', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                              return;
                            }
                            answers.add(_questions['items'][0]['options'][_firstQuestionOption]);
                            answers.add(_questions['items'][1]['options'][_secondQuestionOption]);
                            var result = Questionnaire().addTobacco('tobacco', answers);
                            if (result == 'success') {
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text('Data saved successfully!'),
                                  backgroundColor: Color(0xFF4cAF50),
                                )
                              );
                              this.widget.parent.setState(() {
                                this.widget.parent.setStatus('Tobacco');
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
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(AppLocalizations.of(context).translate('save'), style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                        ),
                      )
                    )
                  ],
                ),
              ),

            
          ],
        ),
    ),

    );
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [
      CustomStep(
        title: Text(AppLocalizations.of(context).translate('photo')),
        content: FirstQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate('thumbprint')),
        content: SecondQuestion(),
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
              child: Text(AppLocalizations.of(context).translate('tobacco'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
                    child: Text(AppLocalizations.of(context).translate('questionsAboutTobacco'), style: TextStyle(fontSize: 19),),
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][0]['question'],
                style: TextStyle(fontSize: 18),
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
              child: Text(AppLocalizations.of(context).translate('tobacco'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
                    child: Text('Integer non leo mattis nulla efficitur pharetra. In tortor purus, rutrum sit amet sollicitudin ac.', style: TextStyle(fontSize: 19),),
                  )
                ],
              )
            ),
            
          ],
        ),
    );
  }
 }

class ThirdQuestion extends StatefulWidget {
  const ThirdQuestion({
    Key key,
  }) : super(key: key);

  

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
              child: Text(AppLocalizations.of(context).translate('tobacco'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
                    child: Text('Integer non leo mattis nulla efficitur pharetra. In tortor purus, rutrum sit amet sollicitudin ac.', style: TextStyle(fontSize: 19),),
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ut elit nec mauris hendrerit vestibulum.',
                style: TextStyle(fontSize: 18),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 120),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleOption(value: 0),
                      CircleOption(value: 1),
                      CircleOption(value: 2),
                      CircleOption(value: 3),
                    ],
                  ),
                  SizedBox(height: 25,),
                  Row(
                    children: <Widget>[
                      CircleOption(value: 4),
                      CircleOption(value: 5),
                      CircleOption(value: 6),
                      CircleOption(value: 7),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
 }

class CircleOption extends StatefulWidget {
  int value;

  CircleOption({this.value});

  @override
  _CircleOptionState createState() => _CircleOptionState();
}

class _CircleOptionState extends State<CircleOption> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: .5)
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedOption = widget.value;
            });
          },
          child: CircleAvatar(
            backgroundColor: selectedOption == widget.value ? Color(0xFFE1F5FE) : Colors.transparent,
            child: Text(widget.value.toString(), style: TextStyle(color: Colors.black),),
          ),
        )
      ),
    );
  }
}

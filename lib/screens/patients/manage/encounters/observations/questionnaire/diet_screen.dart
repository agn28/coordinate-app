import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/app_localizations.dart';
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
  var parent;

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
                    child: Text('Now I am going to ask you some questions about your diet.', style: TextStyle(fontSize: 19),),
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
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                    child: Text(_questions['items'][0]['question'],
                      style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 30,),
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
              padding: EdgeInsets.only(bottom: 20, top: 20),
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
                      style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 17),
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
              )
            ),

            Container(
              padding: EdgeInsets.only(bottom: 20, top: 20),
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
                    child: Text(_questions['items'][2]['question'],
                      style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 17),
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
              )
            ),

            Container(
              padding: EdgeInsets.only(bottom: 20, top: 20),
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
                    child: Text(_questions['items'][3]['question'],
                      style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 17),
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
                              this.widget.parent.setStatus('Diet');
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
  
}

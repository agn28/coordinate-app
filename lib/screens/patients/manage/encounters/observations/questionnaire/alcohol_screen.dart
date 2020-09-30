import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaires_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

int selectedOption = -1;

var _questions = {};

int _secondQuestionOption = 0;
int _selectedOption = 1;
final daysController = TextEditingController();
final unitsController = TextEditingController();
final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class AlcoholScreen extends CupertinoPageRoute {
  var parent;
  AlcoholScreen({this.parent})
      : super(builder: (BuildContext context) => new Alcohol(parent: parent));

}

class Alcohol extends StatefulWidget {
  final EncounnterStepsState parent;
  Alcohol({this.parent});
  @override
  _AlcoholState createState() => _AlcoholState();
}

class _AlcoholState extends State<Alcohol> {
 int _currentStep = 0; 

 @override
 void initState() {
    super.initState();
    setState(() {
      _questions = Questionnaire().questions['alcohol'];
      _selectedOption = 1;
      _secondQuestionOption = 0;
      daysController.text = '';
      unitsController.text = '';
    });
  }

  _changeOption(value) {
    setState(() {
      _selectedOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("alcohol"), style: TextStyle(color: kPrimaryColor)),
        backgroundColor: Colors.white,
        elevation: 0.0,
        bottomOpacity: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),

      body: Container(
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
                    child: Text(AppLocalizations.of(context).translate("questionsAboutalcohol"), style: TextStyle(fontSize: 19),),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    )
                  ),
                  SizedBox(height: 30,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                    width: MediaQuery.of(context).size.width * .5,
                    child: Row(
                      children: <Widget>[
                        ..._questions['items'][0]['options'].map((option) => 
                          Expanded(
                            child: Container(
                              height: 40,
                              margin: EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: _selectedOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFF01579B) : Colors.black),
                                borderRadius: BorderRadius.circular(3),
                                color: _selectedOption == _questions['items'][0]['options'].indexOf(option) ? Color(0xFFE1F5FE) : null
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  _changeOption(_questions['items'][0]['options'].indexOf(option));
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(StringUtils.capitalize(option),
                                  style: TextStyle(color: _selectedOption == _questions['items'][0]['options'].indexOf(option) ? kPrimaryColor : null),
                                ),
                              ),
                            )
                          ),
                        ).toList()
                      ],
                    )
                  ),
                  SizedBox(height: 30,),

                  _selectedOption == 0 ? 
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Text(_questions['items'][1]['question'],
                            style: TextStyle(fontSize: 18),
                          )
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                          width: 200,
                          child: PrimaryTextField(
                            topPaadding: 8,
                            bottomPadding: 8,
                            hintText: 'Number of days',
                            validation: true,
                            type: TextInputType.number,
                            controller: daysController,
                          )
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Text(_questions['items'][2]['question'],
                            style: TextStyle(fontSize: 18),
                          )
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                          width: 200,
                          child: PrimaryTextField(
                            topPaadding: 8,
                            bottomPadding: 8,
                            hintText: 'Number of units',
                            validation: true,
                            type: TextInputType.number,
                            controller: unitsController,
                          )
                        ),
                      ],
                    ),
                  ) : Container(),
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
                          var result = '';
                          var answers = [];
                          if (_selectedOption == 0) {
                            if (_formKey.currentState.validate()) {
                              answers.add(_questions['items'][0]['options'][_selectedOption]);
                              answers.add(daysController.text);
                              answers.add(unitsController.text);
                              result = Questionnaire().addAlcohol('alcohol', answers);
                            }
                          } else {
                            answers.add(_questions['items'][0]['options'][_selectedOption]);
                            result = Questionnaire().addAlcohol('alcohol', answers);
                          }

                          if (result == 'success') {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).translate("dataSaved")),
                                backgroundColor: Color(0xFF4cAF50),
                              )
                            );
                            this.widget.parent.setState(() {
                              this.widget.parent.setStatus('Alcohol');
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

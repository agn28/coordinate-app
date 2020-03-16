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
int _secondQuestionOption = 0;
int _selectedOption = 1;
List allMedications = [];
final problemController = TextEditingController();
final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class CurrentMedicationScreen extends CupertinoPageRoute {
  final EncounnterStepsState parent;
  CurrentMedicationScreen({this.parent})
      : super(builder: (BuildContext context) => new CurrentMedication(parent: parent));

}

class CurrentMedication extends StatefulWidget {
  final EncounnterStepsState parent;
  CurrentMedication({this.parent});
  @override
  _CurrentMedicationState createState() => _CurrentMedicationState();
}

class _CurrentMedicationState extends State<CurrentMedication> {
 int _currentStep = 0; 

 @override
 void initState() {
    super.initState();
    setState(() {
      _questions = Questionnaire().questions['current_medication'];
      _selectedOption = 1;
    });
    getMedications();
  }

  getMedications() async {
    var data = await DefaultAssetBundle.of(context).loadString('assets/medications.json');
    setState(() {
      allMedications = json.decode(data);
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
                  answers.add(_selectedItem);
                  answers.add(_questions['items'][1]['options'][_secondQuestionOption]);
                  answers.add(problemController.text);
                  var result = Questionnaire().addCurrentMedication('current_medication', answers);
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
        title: Text('Photo'),
        content: SecondQuestion(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Photo'),
        content: ThirdQuestion(),
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
      _selectedOption = value;
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
              child: Text('Current Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][0]['question'],
                style: TextStyle(fontSize: 18, height: 1.7),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: MedicationList()
            ),
            SizedBox(height: 10,),
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
              child: Text('Current Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
              child: Text('Current Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text(_questions['items'][2]['question'],
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
                controller: problemController,
              )
            ),
          ],
        ),
    );
  }
 }



 class MedicationList extends StatefulWidget {


  @override
  _MedicationListState createState() => _MedicationListState();
}

var selectedDiseases = [];
final lastVisitDateController = TextEditingController();
var _selectedItem = [];
class _MedicationListState extends State<MedicationList> {

  List _allDiseases = ['lupus', 'diabetes', 'bronchitis', 'hypertension', 'cancer', 'Ciliac', 'Scleroderma', 'Abulia', 'Agraphia', 'Chorea', 'Coma' ];
  List _medications = [];
  var _checkValue = {};

  @override
  void initState() {
    super.initState();
    _preparedata();
    
  }

  _preparedata() async {
    var data = await DefaultAssetBundle.of(context).loadString('assets/medications.json');
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
      value ? _selectedItem.add(_medications[index]) : _selectedItem.removeAt(_selectedItem.indexOf(_medications[index]));
      _checkValue[_medications[index]] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 520.0,
      color: Color(0x07000000),
      padding: EdgeInsets.all(10),
      child: Form(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 10,),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Select Medications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                ],
              ),
            ),

            SizedBox(height: 10,),
            Container(
              alignment: Alignment.centerLeft,
              child: Row(
                // direction: Axis.horizontal,
                // crossAxisAlignment: CrossAxisAlignment.start,
                
                children: <Widget>[
                  ..._selectedItem.map((item) => 
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(
                        color: kTableBorderGrey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(item),
                          SizedBox(width: 5,),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _checkValue[item] = false;
                                _selectedItem.removeAt(_selectedItem.indexOf(item));
                              });
                            },
                            child: Icon(Icons.close, size: 15,),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';

class QuestionnaireScreen extends CupertinoPageRoute {
  QuestionnaireScreen()
      : super(builder: (BuildContext context) => new Questionnaire());

}

class Questionnaire extends StatefulWidget {
 
  @override
  _QuestionnaireState createState() => _QuestionnaireState();
}

class _QuestionnaireState extends State<Questionnaire> {
 int _currentStep = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: () {},
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
        isActive: _currentStep >= 3,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: ThirdQuestion(),
        isActive: _currentStep >= 3,
      )
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getPatientDetails(),
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
              child: Text('Tobacco', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
                    child: Text('Now I am going to ask you some questions about tobacco use.', style: TextStyle(fontSize: 19),),
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Text('Do you currently smoke any tobacco products daily, such as cigarettes, cigars or pipes?',
                style: TextStyle(fontSize: 18),
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(3)
                      ),
                      child: FlatButton(
                        onPressed: () {},
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text('YES',),
                      ),
                    )
                  ),
                  SizedBox(width: 30,),
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(3)
                      ),
                      child: FlatButton(
                        onPressed: () {},
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text('No'),
                      ),
                    )
                  )
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getPatientDetails(),
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
              child: Text('Tobacco', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Radio(
                        activeColor: kPrimaryColor,
                        value: 1,
                        groupValue: 1,
                        onChanged: (val) {},
                      ),
                      Text("Never", style: TextStyle(color: Colors.black, fontSize: 18)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        activeColor: kPrimaryColor,
                        value: 2,
                        groupValue: 1,
                        onChanged: (val) {},
                      ),
                      Text("Past (12 months back)", style: TextStyle(color: Colors.black, fontSize: 18)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        activeColor: kPrimaryColor,
                        value: 3,
                        groupValue: 1,
                        onChanged: (val) {},
                      ),
                      Text("Current (within 12 months)", style: TextStyle(color: Colors.black, fontSize: 18)),
                    ],
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getPatientDetails(),
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
              child: Text('Tobacco', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
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
                      CircleOption(value: '0'),
                      CircleOption(value: '1'),
                      CircleOption(value: '2'),
                      CircleOption(value: '3'),
                    ],
                  ),
                  SizedBox(height: 25,),
                  Row(
                    children: <Widget>[
                      CircleOption(value: '4'),
                      CircleOption(value: '5'),
                      CircleOption(value: '6'),
                      CircleOption(value: '7'),
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

class CircleOption extends StatelessWidget {
  String value;

  CircleOption({this.value});

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
        child: CircleAvatar(
        backgroundColor: Colors.transparent,
          child: Text(value, style: TextStyle(color: Colors.black),),
        )
      ),
    );
  }
}

_getPatientDetails() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        bottom: BorderSide(width: 2, color: Colors.black26)
      )
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Row(
              children: <Widget>[
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: kLightPrimaryColor,
                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.perm_identity),
                ),
                SizedBox(width: 15,),
                Text('Jahanara', style: TextStyle(fontSize: 18))
              ],
            ),
          ),
        ),
        Expanded(
          child: Text('31Y Female', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
        ),
        Expanded(
          child: Text('PID: N-1216657773', style: TextStyle(fontSize: 18))
        )
      ],
    ),
  );
}




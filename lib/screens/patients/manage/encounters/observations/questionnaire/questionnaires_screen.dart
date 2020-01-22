import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/new_observation_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/tobacco_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class QuestionnairesScreen extends CupertinoPageRoute {
  QuestionnairesScreen()
      : super(builder: (BuildContext context) => new Questionnaires());

}

class Questionnaires extends StatefulWidget {

  @override
  _QuestionnairesState createState() => _QuestionnairesState();
}

class _QuestionnairesState extends State<Questionnaires> {

  @override
  void initState() {
    super.initState();
  }

  _getStatus(type) {
    return BodyMeasurement().hasItem(type) ? 'Complete' : 'Incomplete';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Body Measurements', style: TextStyle(color: kPrimaryColor),),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 17, horizontal: 10),
              decoration: BoxDecoration(
              color: Colors.white,
                boxShadow: [BoxShadow(
                  blurRadius: 20.0,
                  color: Colors.black,
                  offset: Offset(0.0, 1.0)
                )]
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
                          Text('Jahanara Begum', style: TextStyle(fontSize: 18))
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
            ),

            Container(
              height: 90,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 40),
              decoration: BoxDecoration(
                color: Color(0xFFF9F9F9),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Complete All Components', style: TextStyle(fontSize: 22),)
            ),
            
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_pressure.png'),
                    text: Text('Tobacco', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getStatus('tobacco'),
                    onTap: () {
                      Navigator.of(context).push(TobaccoScreen());
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_test.png'),
                    text: Text('Alcohol', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getStatus('alcohol'),
                    onTap: () {},
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: Text('Diet', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getStatus('diet'),
                    onTap: () {},
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: Text('Current Medication', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getStatus('current medication'),
                    onTap: () {},
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: Text('Medical History', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getStatus('medical history'),
                    onTap: () {},
                  ),
                ],
              )
            ),

            SizedBox(height: 30,),

            SizedBox(height: 30,),
          ],
        ),
      ),

      
      bottomNavigationBar: Container(
        height: 120,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: .5, color: Color(0xFF50000000))
          )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FlatButton(
                  onPressed: () {},
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Cancel', style: TextStyle(fontSize: 19, color: kPrimaryColor, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
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
                    var result = BodyMeasurement().addBmItem();
                    if (result == 'success') {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text('Data saved successfully!'),
                          backgroundColor: Color(0xFF4cAF50),
                        )
                      );
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
                  child: Text('Save Assessment', style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                ),
              )
            )
          ],
        )
      )
    );
  }
}

class EncounnterSteps extends StatefulWidget {
   EncounnterSteps({this.text, this.onTap, this.icon, this.status});

   final Text text;
   final Function onTap;
   final Image icon;
   final String status;

  @override
  _EncounnterStepsState createState() => _EncounnterStepsState();
}

class _EncounnterStepsState extends State<EncounnterSteps> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.onTap,
      child: Container(
        // padding: EdgeInsets.only(left: 20, right: 20),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: .5, color: Color(0x40000000))
          )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: widget.icon,
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: widget.text,
              )
            ),
            Expanded(
              flex: 2,
              child: Text(widget.status, style: TextStyle(color: widget.status == 'Complete' ? kPrimaryGreenColor : kPrimaryRedColor, fontSize: 18, fontWeight: FontWeight.w500),),
            ),
            
            Expanded(
              flex: 1,
              child: Container(
                child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 50,),
              ),
            )
          ],
        )
      )
    );
  }
}



class AddDialogue extends StatefulWidget {
  String title;
  String inputText;

  AddDialogue({this.title, inputText});

  @override
  _AddDialogueState createState() => _AddDialogueState();
}

class _AddDialogueState extends State<AddDialogue> {

   int selectedUnit;
   final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

   final valueController = TextEditingController();
   final deviceController = TextEditingController();
   final commentController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedUnit = 1;
  }

  _addItem() {
    String unit = _getUnit();
    BodyMeasurement().addItem(widget.title, valueController.text, unit, commentController != null ? commentController.text : "", deviceController.text);
    _EncounnterStepsState().initState();
  }

  _getUnit() {
    if (widget.title == 'Weight') {
      return selectedUnit == 1 ? 'kg' : 'pound';
    }
    return selectedUnit == 1 ? 'cm' : 'inch';
  }

  _clearDialogForm() {
    valueController.clear();
    deviceController.clear();
    commentController.clear();
    selectedUnit = 1;
  }

  changeArm(val) {
    setState(() {
      selectedUnit = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30),
        height: 460.0,
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Add ' + widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
              Container(
                // margin: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: <Widget>[
                    // SizedBox(width: 20,),
                    Container(
                      width: 150,
                      child: PrimaryTextField(
                        hintText: widget.title,
                        topPaadding: 15,
                        bottomPadding: 15,
                        validation: true,
                        type: TextInputType.number,
                        controller: valueController,
                      ),
                    ),
                    Radio(
                      activeColor: kPrimaryColor,
                      value: 1,
                      groupValue: selectedUnit,
                      onChanged: (val) {
                        changeArm(val);
                      },
                    ),
                    Text(widget.title == 'Weight' ? 'kg' : 'cm', style: TextStyle(color: Colors.black)),

                    Radio(
                      activeColor: kPrimaryColor,
                      value: 2,
                      groupValue: selectedUnit,
                      onChanged: (val) {
                        changeArm(val);
                      },
                    ),
                    Text(
                      widget.title == 'Weight' ? 'pound' : 'inch',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: double.infinity,
                child: PrimaryTextField(
                  hintText: 'Select device',
                  topPaadding: 15,
                  bottomPadding: 15,
                  controller: deviceController,
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: double.infinity,
                child: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 20.0,),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  controller: commentController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 15.0, bottom: 25.0, left: 10, right: 10),
                    filled: true,
                    fillColor: kSecondaryTextField,
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      )
                    ),
                  
                    hintText: 'Comments/Notes',
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                  ),
                )
              ),

              Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('UNABLE TO PERFORM', style: TextStyle(color: kPrimaryColor, fontSize: 18),)
                          ),
                        ),
                        SizedBox(width: 30,),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('CANCEL', style: TextStyle(color: kPrimaryColor, fontSize: 18),)
                        ),
                        SizedBox(width: 30,),
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState.validate()) {
                              Navigator.of(context).pop();
                              _addItem();
                              _clearDialogForm();
                            }
                          },
                          child: Text('ADD', style: TextStyle(color: kPrimaryColor, fontSize: 18))
                        ),
                      ],
                    )
                  )
                ],
              )
            ],
          ),
        )
      )
      
    );
  }
}

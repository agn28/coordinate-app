import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import '../../../../../../models/blood_test.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
bool isOther = false;
final otherReasonController = TextEditingController();

class BloodTestScreen extends CupertinoPageRoute {
  BloodTestScreen()
      : super(builder: (BuildContext context) => new BloodTests());
}

class BloodTests extends StatefulWidget {

  @override
  _BloodTestsState createState() => _BloodTestsState();
}

class _BloodTestsState extends State<BloodTests> {

  goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('bloodTests'), style: TextStyle(color: kPrimaryColor),),
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
                          Text(Helpers().getPatientName(Patient().getPatient()), style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(Helpers().getPatientAgeAndGender(Patient().getPatient()), style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
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
              child: Text(AppLocalizations.of(context).translate('enterBloodTest'), style: TextStyle(fontSize: 18),)
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
              child: Text(AppLocalizations.of(context).translate('lipidProfile'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),)
            ),
            
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_test_common.png'),
                    text: AppLocalizations.of(context).translate('totalCholesterol'),
                    name: 'total_cholesterol'
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_test_common.png'),
                    text: AppLocalizations.of(context).translate('hdl'),
                    name: 'hdl'
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_test_common.png'),
                    text: AppLocalizations.of(context).translate('triglycerides'),
                    name: 'tg'
                  ),
                ],
              )
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
              child: Text(AppLocalizations.of(context).translate('blood'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),)
            ),

            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_glucose.png'),
                    text: AppLocalizations.of(context).translate('fastingBloodGlucose'),
                    name: 'blood_glucose'
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_glucose.png'),
                    text: AppLocalizations.of(context).translate('randomBloodSugar'),
                    name: 'blood_sugar'
                  ),
                ],
              )
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
              child: Text(AppLocalizations.of(context).translate('others'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),)
            ),

            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/hba1c.png'),
                    text: AppLocalizations.of(context).translate('hba1c'),
                    name: 'a1c'
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/ogtt.png'),
                    text: AppLocalizations.of(context).translate('hogtt'),
                    name: '2h_ogtt'
                  ),
                ],
              )
            ),

            SizedBox(height: 30,),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 100,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 2, color: Color(0xFF20000000))
          )
        ),
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return SkipAlert(parent: this);
                      },
                    );
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(AppLocalizations.of(context).translate('unablePerform'), style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
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
                    var result = BloodTest().addBtItem();
                    if (result == 'success') {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).translate('dataSaved')),
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
                  child: Text(AppLocalizations.of(context).translate('save'), style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
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
   EncounnterSteps({this.text, this.icon, this.name});

   final String text;
   final Image icon;
   final String name;

  @override
  _EncounnterStepsState createState() => _EncounnterStepsState();
}

class _EncounnterStepsState extends State<EncounnterSteps> {
  String status = 'Incomplete';

  @override
  void initState() {
    super.initState();
    setStatus();
  }

  setStatus() {
    status = BloodTest().hasItem(widget.name) ? 'Complete' : 'Incomplete';
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddTestsDialogue(
              parent: this,
              title: widget.text,
              name: widget.name
            );
          } 
        );
      },
      child: Container(
        // padding: EdgeInsets.only(left: 20, right: 20),
        width: double.infinity,
        height: 90,
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
                child: Text(widget.text, style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
              )
            ),
            Expanded(
              flex: 2,
              child: Text(status, style: TextStyle(color: status == 'Complete' ? kPrimaryGreenColor  : kPrimaryRedColor, fontSize: 18, fontWeight: FontWeight.bold),),
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



class AddTestsDialogue extends StatefulWidget {
  
  final String title;
  final String name;
  _EncounnterStepsState parent;

  AddTestsDialogue({this.parent, this.title, this.name});

  @override
  _AddTestsDialogueState createState() => _AddTestsDialogueState();
}

class _AddTestsDialogueState extends State<AddTestsDialogue> {

  String selectedUnit;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final valueController = TextEditingController();
  final deviceController = TextEditingController();
  final commentController = TextEditingController();

  List devices = ['D-23429', 'B-94857'];
  int selectedDevice = 0;

  _addItem(){
    BloodTest().addItem(widget.name, valueController.text, selectedUnit, commentController.text, devices[selectedDevice]);
    this.widget.parent.setState(() {
      this.widget.parent.setStatus();
    });
  }
  _clearDialogForm() {
    valueController.clear();
    deviceController.clear();
    commentController.clear();
  }

  @override
  void initState() {
    super.initState();
    selectedUnit = 'mg/dL';
  }

  _changeUnit(val) {
    setState(() {
      selectedUnit = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 30, left: 30, right: 30),
          height: 500.0,
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Set ${widget.title}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                SizedBox(height: 20,),
                Container(
                  // margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: <Widget>[
                      // SizedBox(width: 20,),
                      Container(
                        width: 200,
                        child: PrimaryTextField(
                          hintText: widget.title,
                          topPaadding: 15,
                          bottomPadding: 15,
                          controller: valueController,
                          validation: true,
                          type: TextInputType.number
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 20, left: 10),
                        child: Row(
                          children: <Widget>[
                            Radio(
                              activeColor: kPrimaryColor,
                              value: 'mg/dL',
                              groupValue: selectedUnit,
                              onChanged: (val) {
                                _changeUnit(val);
                              },
                            ),
                            Text("mg/dL", style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
                            Radio(
                              activeColor: kPrimaryColor,
                              value: 'mmol/L',
                              groupValue: selectedUnit,
                              onChanged: (val) {
                                _changeUnit(val);
                              },
                            ),
                            Text(
                              "mmol/L",
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  color: kSecondaryTextField,
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
                          child: Text(item),
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
                SizedBox(height: 40,),
                Container(
                  width: double.infinity,
                  child: TextFormField(
                    style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
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
                              child: Text('UNABLE TO PERFORM', style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500),)
                            ),
                          ),
                          SizedBox(width: 30,),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('CANCEL', style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500),)
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
                            child: Text('ADD', style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500))
                          ),
                        ],
                      )
                    )
                  ],
                )
              ],
            ),
          )
        ),
      )
      
    );
  }
}

class SkipAlert extends StatefulWidget {
  _BloodTestsState parent;
  SkipAlert({this.parent});

  @override
  _SkipAlertState createState() => _SkipAlertState();
}

class _SkipAlertState extends State<SkipAlert> {

  final GlobalKey<FormState> _skipForm = new GlobalKey<FormState>();

  String selectedReason = 'patient refused';
  bool isOther = false;
  final skipReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isOther = false;
    selectedReason = 'patient refused';
  }

  changeReason(val) {
    setState(() {
      if (val == 'others') 
        isOther = true;
      else
        isOther = false;
      selectedReason = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30),
        color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppLocalizations.of(context).translate('reasonSkipping'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
                // margin: EdgeInsets.symmetric(horizontal: 30),
              Row(
                children: <Widget>[
                  // SizedBox(width: 20,),
                  Radio(
                    activeColor: kPrimaryColor,
                    value: 'patient refused',
                    groupValue: selectedReason,
                    onChanged: (val) {
                      changeReason(val);
                    },
                  ),
                  Text(AppLocalizations.of(context).translate('patientRefused'), style: TextStyle(color: Colors.black)),
                ],
              ),
              Row(
                children: <Widget>[
                  // SizedBox(width: 20,),
                  Radio(
                    activeColor: kPrimaryColor,
                    value: 'patient unable',
                    groupValue: selectedReason,
                    onChanged: (val) {
                      changeReason(val);
                    },
                  ),
                  Text(AppLocalizations.of(context).translate('patientUnable'), style: TextStyle(color: Colors.black)),
                ],
              ),
              Row(
                children: <Widget>[
                  // SizedBox(width: 20,),
                  Radio(
                    activeColor: kPrimaryColor,
                    value: 'instrument error',
                    groupValue: selectedReason,
                    onChanged: (val) {
                      changeReason(val);
                    },
                  ),
                  Text(AppLocalizations.of(context).translate('instrumentError'), style: TextStyle(color: Colors.black)),
                ],
              ),
              Row(
                children: <Widget>[
                  // SizedBox(width: 20,),
                  Radio(
                    activeColor: kPrimaryColor,
                    value: 'instrument unavailable',
                    groupValue: selectedReason,
                    onChanged: (val) {
                      changeReason(val);
                    },
                  ),
                  Text(AppLocalizations.of(context).translate('instrumentUnavailable'), style: TextStyle(color: Colors.black)),
                ],
              ),
              Row(
                children: <Widget>[
                  // SizedBox(width: 20,),
                  Radio(
                    activeColor: kPrimaryColor,
                    value: 'others',
                    groupValue: selectedReason,
                    onChanged: (val) {
                      changeReason(val);
                    },
                  ),
                  Text(AppLocalizations.of(context).translate('others'), style: TextStyle(color: Colors.black)),
                ],
              ),

              isOther ? Container(
                margin: EdgeInsets.only(top: 10),
                child: Form(
                  key: _skipForm,
                  child: PrimaryTextField(
                    hintText: 'Other reason',
                    controller: otherReasonController,
                    topPaadding: 15,
                    bottomPadding: 15,
                  ),
                ),
              ) : Container(),
              SizedBox(height: 10,),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 18),)
                        ),
                        SizedBox(width: 30,),
                        GestureDetector(
                          onTap: () async {
                            var reason = selectedReason;
                            if (reason == 'others') {
                              if (_skipForm.currentState.validate()) {
                                reason = skipReasonController.text;
                                var response = BloodTest().addSkip(reason);
                                BloodTest().addBtItem();

                                if (response == 'success') {
                                  Navigator.of(context).pop();
                                  await Future.delayed(const Duration(seconds: 1));
                                  widget.parent.goBack();
                                } 
                              }
                            } else {
                              var response = BloodTest().addSkip(reason);
                                BloodTest().addBtItem();

                              if (response == 'success') {
                                Navigator.pop(context);
                                await Future.delayed(const Duration(seconds: 1));
                                widget.parent.goBack();
                              } 
                            }
                          },
                          child: Text(AppLocalizations.of(context).translate('add'), style: TextStyle(color: kPrimaryColor, fontSize: 18))
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



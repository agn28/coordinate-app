import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/app_localizations.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class MeasurementsScreen extends CupertinoPageRoute {
  final parent;
  MeasurementsScreen({this.parent})
      : super(builder: (BuildContext context) => new Measurements(parent: parent));

}

class Measurements extends StatefulWidget {
  final parent;
  Measurements({this.parent});

  @override
  MeasurementsState createState() => MeasurementsState();
}

class MeasurementsState extends State<Measurements> {

  bool avatarExists = false;
  var authUser;

  @override
  void initState() {
    super.initState();
    _checkAvatar();
    getAuth();
  }

  _checkAvatar() async {
    var data = await File(Patient().getPatient()['data']['avatar']).exists();
    setState(() {
      avatarExists = data;
    });
  }

  getAuth() async {
    var data = await Auth().getStorageAuth();
    setState(() {
      authUser = data;
    });
  }

  goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('bodyMeasurements'), style: TextStyle(color: kPrimaryColor),),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),
      body: SingleChildScrollView(
        child: authUser != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
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
              child: Text(AppLocalizations.of(context).translate('completeComponents'), style: TextStyle(fontSize: 22),)
            ),
            
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/height.png'),
                    text: AppLocalizations.of(context).translate('height'),
                    name: 'height'
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/weight.png'),
                    text: AppLocalizations.of(context).translate('weight'),
                    name: 'weight'
                  ),

                  authUser['role'] != 'chw' ? 
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/hip.png'),
                    text: AppLocalizations.of(context).translate('waist'),
                    name: 'waist'
                  ) : Container(),

                  authUser['role'] != 'chw' ?
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/hip.png'),
                    text: AppLocalizations.of(context).translate('hip'),
                    name: 'hip'
                  ) : Container(),
                ],
              )
            ),

            SizedBox(height: 30,),

            SizedBox(height: 30,),
          ],
        ) : Container(),
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
                  border: Border.all(width: 1, color: Colors.black54),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FlatButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SkipAlert(parent: this);
                      },
                    );
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(AppLocalizations.of(context).translate('unablePerform'), style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                ),
              ),
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
                    widget.parent.setState((){});
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
  EncounnterStepsState createState() => EncounnterStepsState();
}

class EncounnterStepsState extends State<EncounnterSteps> {
  String status = 'Incomplete';
  
  @override
  void initState() {
    super.initState();
    setStatus();
  }

  setStatus() {
    status = BodyMeasurement().hasItem(widget.name) ? 'Complete' : 'Incomplete';
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddDialogue(
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
                child: Text(widget.text, style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
              )
            ),
            Expanded(
              flex: 2,
              child: Text(AppLocalizations.of(context).translate(status), style: TextStyle(color: status == 'Complete' ? kPrimaryGreenColor : kPrimaryRedColor, fontSize: 18, fontWeight: FontWeight.bold),),
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
  EncounnterStepsState parent;
  String title;
  String name;

  AddDialogue({this.parent, this.title, this.name});

  List devices = [];
  int selectedDevice;

  @override
  _AddDialogueState createState() => _AddDialogueState();
}

class _AddDialogueState extends State<AddDialogue> {

   String selectedUnit;
   final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

   final valueController = TextEditingController();
   final deviceController = TextEditingController();
   final commentController = TextEditingController();

   _getItem() {
    var item = BodyMeasurement().getItem(widget.name);
    if (item.isNotEmpty) {
      setState(() {
        valueController.text = item['value'].toString();
        commentController.text = item['comment'];
        selectedUnit = item['unit'];
      });
    }

  }

  @override
  void initState() {
    super.initState();
    selectedUnit = widget.name == 'weight' ? 'kg' : 'cm';
    devices = Device().getDevices();
    print(devices);
    _getItem();
  }

  _addItem() {
    BodyMeasurement().addItem(widget.name, valueController.text, selectedUnit, commentController != null ? commentController.text : "", devices[selectedDevice]['id']);
    this.widget.parent.setState(() => {
      this.widget.parent.setStatus(),
    });
  }

  _clearDialogForm() {
    valueController.clear();
    deviceController.clear();
    commentController.clear();
    selectedUnit = 'cm';
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
                Text(widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                SizedBox(height: 20,),
                Container(
                  // margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // SizedBox(width: 20,),
                      Container(
                        width: 150,
                        child: PrimaryTextField(
                          hintText: widget.title,
                          topPaadding: 8,
                          bottomPadding: 8,
                          validation: true,
                          type: TextInputType.number,
                          controller: valueController,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 20, left: 10),
                        child: widget.name == 'weight' ?
                        Row(
                          children: <Widget>[
                            Radio(
                              activeColor: kPrimaryColor,
                              value: 'kg',
                              groupValue: selectedUnit,
                              onChanged: (val) {
                                _changeUnit(val);
                              },
                            ),
                            Text('kg', style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
                            Radio(
                              activeColor: kPrimaryColor,
                              value: 'pound',
                              groupValue: selectedUnit,
                              onChanged: (val) {
                                _changeUnit(val);
                              },
                            ),
                            Text('pound',),
                          ],
                        ) :
                        Row(
                          children: <Widget>[
                            Radio(
                              activeColor: kPrimaryColor,
                              value: 'cm',
                              groupValue: selectedUnit,
                              onChanged: (val) {
                                _changeUnit(val);
                              },
                            ),
                            Text('cm', style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
                            Radio(
                              activeColor: kPrimaryColor,
                              value: 'inch',
                              groupValue: selectedUnit,
                              onChanged: (val) {
                                _changeUnit(val);
                              },
                            ),
                            Text('inch',),
                          ],
                        )
                      ),
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
                          child: Text(item['name']),
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
                SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  child: TextField(
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

                      hintText: AppLocalizations.of(context).translate('comment'),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500),)
                          ),
                          SizedBox(width: 50,),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState.validate()) {
                                Navigator.of(context).pop();
                                _addItem();
                                _clearDialogForm();
                              }
                            },
                            child: Text(AppLocalizations.of(context).translate('add'), style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500))
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
  MeasurementsState parent;
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
                    controller: skipReasonController,
                    topPaadding: 8,
                    bottomPadding: 8,
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
                                var response = BodyMeasurement().addSkip(reason);
                                BodyMeasurement().addBmItem();

                                if (response == 'success') {
                                  Navigator.of(context).pop();
                                  await Future.delayed(const Duration(seconds: 1));
                                  widget.parent.goBack();
                                } 
                              }
                            } else {
                              var response = BodyMeasurement().addSkip(reason);
                                BodyMeasurement().addBmItem();

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


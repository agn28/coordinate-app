import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

String selectedArm = 'left';
double systolic;
double diastolic;
double pulse;
final systolicController = TextEditingController();
final diastolicController = TextEditingController();
final pulseController = TextEditingController();
final commentController = TextEditingController();
final deviceController = TextEditingController();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
int selectedDevice = 0;
List devices = [];
List rightArmReason = [
  'left arm is missing',
  'participants hand is broken into pieces',
  'other'
];
final otherReasonController = TextEditingController();
String selectedRightArmReason = rightArmReason[0];

class AddBloodPressureScreen extends CupertinoPageRoute {
  final parent;

  AddBloodPressureScreen({this.parent})
      : super(builder: (BuildContext context) => new AddBloodPressure(parent: parent));

}

class AddBloodPressure extends StatefulWidget {
  final parent;

  AddBloodPressure({this.parent});

  @override
  _AddBloodPressureState createState() => _AddBloodPressureState();
}

class _AddBloodPressureState extends State<AddBloodPressure> {
  List bpItems = BloodPressure().items;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var _patient;
  var _bloodPressures;
  bool avatarExists = false;

  goBack() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    selectedArm = 'left';
    devices = Device().getDevices();
    _checkAvatar();
    getBloodPressures();
  }

  _checkAvatar() async {
    var data = await File(Patient().getPatient()['data']['avatar']).exists();
    setState(() {
      avatarExists = data;
    });

  }

  getBloodPressures() {
    setState(() {
      if (BloodPressure().items.length > 0 && BloodPressure().items[0]['skip'] != null && BloodPressure().items[0]['skip'] == true ) {
        _bloodPressures = [];
      } else {
        _bloodPressures = BloodPressure().items;
      }
      
    });
  }

  _clearDialogForm() {
    systolicController.clear();
    diastolicController.clear();
    pulseController.clear();
    selectedArm = 'left';
    selectedRightArmReason = rightArmReason[0];
  }
  String _getSerial(serial) {
    return (serial + 1).toString();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomPadding: true,
      //Migrate Projects
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('bloodPressure'), style: TextStyle(color: kLightBlack),),
        backgroundColor: Colors.white,
        elevation: 0,
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
              padding: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Color(0xFFF4F4F4),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text(AppLocalizations.of(context).translate('twoBloodPressure'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),)
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 20, right: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Container(
                    width: double.infinity,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(AppLocalizations.of(context).translate('no'))
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context).translate('arm'))
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context).translate('systolic'))
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context).translate('diastolic'))
                        ),
                        DataColumn(
                          label: Text(AppLocalizations.of(context).translate('pulseRate'))
                        )
                      ],
                      rows: _bloodPressures.map<DataRow>((bp) => DataRow(
                        cells: [
                          DataCell(Text(_getSerial(_bloodPressures.indexOf(bp)))),
                          DataCell(Text("${bp['arm'][0].toUpperCase()}${bp['arm'].substring(1)}")),
                          DataCell(Text(bp['systolic'].toInt().toString())),
                          DataCell(Text(bp['diastolic'].toInt().toString())),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(bp['pulse_rate'].toInt().toString()),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: kPrimaryColor,
                                    onPressed: () {
                                      BloodPressure().removeItem(_bloodPressures.indexOf(bp));
                                      getBloodPressures();
                                    },
                                  ),
                                )
                              ],
                            )
                          ),
                        ]
                      )).toList(),

                      sortColumnIndex: 0,
                      sortAscending: true,
                    ),
                  ),
                  SizedBox(height: 50,),

                  BloodPressure().items.length > 0 ? Container(
                    color: kWarningColor,
                    height: 80,
                    margin: EdgeInsets.only(bottom: 30),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Icon(Icons.error_outline),
                        ),
                        Expanded(
                          flex: 7,
                          child: Text(AppLocalizations.of(context).translate('measurementAdded')),
                        )
                      ],
                    )
                  ) : Container(),
                  
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(width: 2, color: kPrimaryColor)
                    ),
                    child: FlatButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  elevation: 0.0,
                                  backgroundColor: Colors.transparent,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(top:30),
                                          color: Colors.white,
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.only(left: 25),
                                                  child: Text(AppLocalizations.of(context).translate('bpMeasurement'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                                ),
                                                SizedBox(height: 20,),
                                                Container(
                                                  // margin: EdgeInsets.symmetric(horizontal: 30),
                                                  padding: EdgeInsets.only(left: 10),
                                                  child: Row(
                                                    children: <Widget>[
                                                      // SizedBox(width: 20,),
                                                      Radio(
                                                        activeColor: kPrimaryColor,
                                                        value: 'left',
                                                        groupValue: selectedArm,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            selectedArm = val;
                                                          });
                                                        },
                                                      ),
                                                      Text(AppLocalizations.of(context).translate('leftArm'), style: TextStyle(fontSize: 15),),

                                                      Radio(
                                                        activeColor: kPrimaryColor,
                                                        value: 'right',
                                                        groupValue: selectedArm,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            selectedArm = val;
                                                          });
                                                        },
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(context).translate('rightArm'),
                                                        style: TextStyle(fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 20,),
                                                selectedArm == 'right' ? Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Container(
                                                            padding: EdgeInsets.only(left: 25),
                                                            child: Text(AppLocalizations.of(context).translate('usingRightArm'), style: TextStyle(fontSize: 19),),
                                                          ),
                                                          SizedBox(height: 10,),
                                                          ...rightArmReason.map((item) {
                                                            return Row(
                                                              children: <Widget>[
                                                                SizedBox(width: 10,),
                                                                Radio(
                                                                  activeColor: kPrimaryColor,
                                                                  value: item,
                                                                  groupValue: selectedRightArmReason,
                                                                  onChanged: (val) {
                                                                    setState(() {
                                                                      selectedRightArmReason = val;
                                                                    });
                                                                  },
                                                                ),
                                                                Text(
                                                                  StringUtils.capitalize(item),
                                                                  style: TextStyle(fontSize: 15),
                                                                ),
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ],
                                                      ),
                                                    ),


                                                    selectedRightArmReason == 'other' ? Column(
                                                      children: <Widget>[
                                                        Container(
                                                          padding: EdgeInsets.only(left: 25, right: 25),
                                                          child: TextField(
                                                            
                                                            keyboardType: TextInputType.multiline,
                                                            maxLines: 2,
                                                            style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                                                            controller: otherReasonController,

                                                            decoration: InputDecoration(
                                                              contentPadding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 20, right: 20),
                                                              filled: true,
                                                              fillColor: kSecondaryTextField,
                                                              border: new UnderlineInputBorder(
                                                                borderSide: new BorderSide(color: Colors.white),
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(4),
                                                                  topRight: Radius.circular(4),
                                                                )
                                                              ),
                                                            
                                                              hintText: AppLocalizations.of(context).translate('stateReason'),
                                                              hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                                                            ),
                                                          )
                                                        ),
                                                        
                                                      ],
                                                    ) : Container(),
                                                    SizedBox(height: 15,),
                                                    Divider(),
                                                    SizedBox(height: 15,),
                                                  ],
                                                ) : Container(),
                                                Container(
                                                  padding: EdgeInsets.only(left: 25),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 2,
                                                        child: PrimaryTextField(
                                                          hintText: AppLocalizations.of(context).translate('systolic'),
                                                          topPaadding: 12,
                                                          bottomPadding: 12,
                                                          controller: systolicController,
                                                          name:AppLocalizations.of(context).translate('systolic'),
                                                          validation: true,
                                                          type: TextInputType.number
                                                        ),
                                                      ),
                                                      SizedBox(width: 20,),
                                                      Container(
                                                        alignment: Alignment.center,
                                                        child: Text('/', style: TextStyle(fontSize: 20, height: 0),),
                                                      ),
                                                      SizedBox(width: 20,),
                                                      Expanded(
                                                        flex: 2,
                                                        child: PrimaryTextField(
                                                          hintText: AppLocalizations.of(context).translate('diastolic'),
                                                          topPaadding: 12,
                                                          bottomPadding: 12,
                                                          controller: diastolicController,
                                                          name:AppLocalizations.of(context).translate('diastolic'),
                                                          validation: true,
                                                          type: TextInputType.number
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(''),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                Container(
                                                  padding: EdgeInsets.only(left: 25),
                                                  width: 175,
                                                  child: PrimaryTextField(
                                                    hintText: AppLocalizations.of(context).translate('pulseRate'),
                                                    topPaadding: 12,
                                                    bottomPadding: 12,
                                                    controller: pulseController,
                                                    name:AppLocalizations.of(context).translate('pulseRate'),
                                                    validation: true,
                                                    type: TextInputType.number
                                                  ),
                                                ),

                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Container(
                                                      alignment: Alignment.bottomRight,
                                                      margin: EdgeInsets.only(top: 20),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: <Widget>[
                                                          FlatButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                              _clearDialogForm();
                                                            },
                                                            child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500),)
                                                          ),
                                                          SizedBox(width: 20,),
                                                          FlatButton(
                                                            onPressed: () {
                                                              if (_formKey.currentState.validate()) {
                                                                Navigator.of(context).pop();
                                                                var reason = selectedRightArmReason == 'other' ? otherReasonController.text : selectedRightArmReason;
                                                                setState(() {
                                                                  BloodPressure().addItem(selectedArm, int.parse(systolicController.text), int.parse(diastolicController.text), int.parse(pulseController.text), reason);
                                                                });
                                                                getBloodPressures();
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
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  
                                );
                              },
                            );
                          },
                        );
                      },
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(AppLocalizations.of(context).translate('addBpMeasurement'), style: TextStyle(fontSize: 16, color: kPrimaryColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                    ),
                  ),

                  SizedBox(height: 100,),

                  Container(
                    // margin: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
                      style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                      controller: commentController,

                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 20, right: 20),
                        filled: true,
                        fillColor: kSecondaryTextField,
                        border: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          )
                        ),
                      
                        hintText: AppLocalizations.of(context).translate('comments'),
                        hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                      ),
                    )
                  ),

                  SizedBox(height: 30,),

                  Container(
                    color: kSecondaryTextField,
                    child: DropdownButtonFormField(
                      hint: Text(AppLocalizations.of(context).translate('selectDevice'), style: TextStyle(fontSize: 20, color: kTextGrey),),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kSecondaryTextField,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
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

                  // PrimaryTextField(
                  //   hintText: 'Select a device',
                  //   controller: deviceController,
                  // ),

                  SizedBox(height: 50,),
                  
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 90,
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
                    var formData = _prepareFormData();
                    var result = BloodPressure().addBloodPressure(formData);
                    widget.parent.setState((){});
                    if (result.toString() == 'success') {
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

_prepareFormData() {
  return {
    'items': _AddBloodPressureState().bpItems,
    'comment': commentController.text,
    'patient_id': Patient().getPatient()['id'],
    'device': devices[selectedDevice]['id'],
    'performed_by': 'Md. Feroj Bepari',
  };
}


class SkipAlert extends StatefulWidget {
  _AddBloodPressureState parent;
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
                    hintText: AppLocalizations.of(context).translate("OtherReason"),
                    controller: skipReasonController,
                    topPaadding: 8,
                    bottomPadding: 8,
                    validation: true,
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
                                var response = BloodPressure().addSkip(reason);
                                var formData = _prepareFormData();
                                BloodPressure().addBloodPressure(formData);

                                if (response == 'success') {
                                  Navigator.of(context).pop();
                                  await Future.delayed(const Duration(seconds: 1));
                                  widget.parent.goBack();
                                } 
                              }
                            } else {
                              var response = BloodPressure().addSkip(reason);
                              var formData = _prepareFormData();
                              BloodPressure().addBloodPressure(formData);

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

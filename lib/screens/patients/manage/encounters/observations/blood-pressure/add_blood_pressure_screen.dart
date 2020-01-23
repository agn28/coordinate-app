import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

int selectedArm = 0;
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
List devices = ['D-23429', 'B-94857'];

enum Arms {
  LeftArm,
  RughtArm
}

class AddBloodPressureScreen extends CupertinoPageRoute {
  AddBloodPressureScreen()
      : super(builder: (BuildContext context) => new AddBloodPressure());

}

class AddBloodPressure extends StatefulWidget {
  
  @override
  _AddBloodPressureState createState() => _AddBloodPressureState();
}

class _AddBloodPressureState extends State<AddBloodPressure> {
  List<BloodPressureItem> bpItems = BloodPressure().items;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var _patient;

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    selectedArm = 0;
  }

  _changeArm(int val) {
    setState(() {
      selectedArm = val;
    });
  }

  _clearDialogForm() {
    systolicController.clear();
    diastolicController.clear();
    pulseController.clear();
    selectedArm = 0;
  }
  String _getSerial(serial) {
    return (serial + 1).toString();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Blood Pressure', style: TextStyle(color: kLightBlack),),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
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
                    flex: 4,
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
                          Text(Patient().getPatient()['data']['name'], style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('${Patient().getPatient()['data']['age']}Y ${Patient().getPatient()['data']['gender'].toUpperCase()}', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
                  ),
                  Expanded(
                    flex: 3,
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
                color: Color(0xFFF4F4F4),
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Text('Take 3 Blood Pressure measurements, each 1 min apart', style: TextStyle(fontSize: 19),)
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
                          label: Text("NO")
                        ),
                        DataColumn(
                          label: Text("ARM")
                        ),
                        DataColumn(
                          label: Text("SYSTOLIC")
                        ),
                        DataColumn(
                          label: Text("DIASTOLIC")
                        ),
                        DataColumn(
                          label: Text("PULSE")
                        )
                      ],
                      rows: BloodPressure().items.map((bp) => DataRow(
                        cells: [
                          DataCell(Text(_getSerial(BloodPressure().items.indexOf(bp)))),
                          DataCell(Text("${bp.arm[0].toUpperCase()}${bp.arm.substring(1)}")),
                          DataCell(Text(bp.systolic.toString())),
                          DataCell(Text(bp.diastolic.toString())),
                          DataCell(Text(bp.pulse.toString()))
                        ]
                      )).toList(),

                      sortColumnIndex: 0,
                      sortAscending: true,
                    ),
                  ),
                  SizedBox(height: 30,),

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
                          child: Text("Measurement added. Participant must rest for one or two minutes before taking the next BP measurement."),
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
                                      Text('Add BP Measurement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                      SizedBox(height: 20,),
                                      Container(
                                        // margin: EdgeInsets.symmetric(horizontal: 30),
                                        child: Row(
                                          children: <Widget>[
                                            // SizedBox(width: 20,),
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: 0,
                                              groupValue: selectedArm,
                                              onChanged: (val) {
                                                _changeArm(val);
                                              },
                                            ),
                                            Text("Left Arm", style: TextStyle(color: Colors.black)),

                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: 1,
                                              groupValue: selectedArm,
                                              onChanged: (val) {
                                                _changeArm(val);
                                              },
                                            ),
                                            Text(
                                              "Right Arm",
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: PrimaryTextField(
                                              hintText: 'Systolic',
                                              controller: systolicController,
                                              name:'Systolic',
                                              validation: true,
                                              type: TextInputType.number
                                            ),
                                          ),
                                          SizedBox(width: 20,),
                                          Text('/', style: TextStyle(fontSize: 20),),
                                          SizedBox(width: 20,),
                                          Expanded(
                                            flex: 2,
                                            child: PrimaryTextField(
                                              hintText: 'Diastolic',
                                              controller: diastolicController,
                                              name:'Diastolic',
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
                                      SizedBox(height: 10,),
                                      Container(
                                        width: 140,
                                        child: PrimaryTextField(
                                          hintText: 'Pulse Rate',
                                          controller: pulseController,
                                          name:'Pulse Rate',
                                          validation: true,
                                          type: TextInputType.number
                                        ),
                                      ),

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            margin: EdgeInsets.only(top: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _clearDialogForm();
                                                  },
                                                  child: Text('CANCEL', style: TextStyle(color: kPrimaryColor, fontSize: 18),)
                                                ),
                                                SizedBox(width: 30,),
                                                FlatButton(
                                                  onPressed: () {
                                                    if (_formKey.currentState.validate()) {
                                                      Navigator.of(context).pop();
                                                      setState(() {
                                                        BloodPressure().addItem(selectedArm == 0 ? 'left' : 'right' , double.parse(systolicController.text), double.parse(diastolicController.text), double.parse(pulseController.text));
                                                      });
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
                                  )
                                ),
                              )
                              
                            );
                          },
                        );
                      },
                      padding: EdgeInsets.symmetric(vertical: 17),
                      child: Text('+ ADD A BP MEASUREMENT', style: TextStyle(fontSize: 16, color: kPrimaryColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                    ),
                  ),

                  SizedBox(height: 35,),

                  Container(
                    // margin: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
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
                      
                        hintText: 'Comments/Notes (optional)',
                        hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                      ),
                    )
                  ),

                  SizedBox(height: 30,),

                  Container(
                    color: kSecondaryTextField,
                    child: DropdownButtonFormField(
                      hint: Text('Select Device', style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FlatButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return SkipAlert();
                      },
                    );
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('UNABLE TO PERFORM', style: TextStyle(fontSize: 16, color: kPrimaryColor, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
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
                    print('hello');
                    var formData = _prepareFormData();
                    var result = BloodPressure().addBloodPressure(formData);
                    if (result.toString() == 'success') {
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
                  child: Text('SAVE', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
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
    'patient_id': Patient().getPatient()['uuid'],
    'device': devices[selectedDevice],
    'performed_by': 'Md. Feroj Bepari',
  };
}


class SkipAlert extends StatefulWidget {
  SkipAlert();

  @override
  _SkipAlertState createState() => _SkipAlertState();
}

class _SkipAlertState extends State<SkipAlert> {

  int selectedReason;

  @override
  void initState() {
    super.initState();
    selectedReason = 0;
  }

  changeArm(int val) {
    
    setState(() {
      selectedReason = val;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Reason for Skipping', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
            SizedBox(height: 20,),
              // margin: EdgeInsets.symmetric(horizontal: 30),
            Row(
              children: <Widget>[
                // SizedBox(width: 20,),
                Radio(
                  activeColor: kPrimaryColor,
                  value: 0,
                  groupValue: selectedReason,
                  onChanged: (val) {
                    changeArm(val);
                  },
                ),
                Text("Patient Refused", style: TextStyle(color: Colors.black)),
              ],
            ),
            Row(
              children: <Widget>[
                // SizedBox(width: 20,),
                Radio(
                  activeColor: kPrimaryColor,
                  value: 1,
                  groupValue: selectedReason,
                  onChanged: (val) {
                    changeArm(val);
                  },
                ),
                Text("Patient Unable", style: TextStyle(color: Colors.black)),
              ],
            ),
            Row(
              children: <Widget>[
                // SizedBox(width: 20,),
                Radio(
                  activeColor: kPrimaryColor,
                  value: 2,
                  groupValue: selectedReason,
                  onChanged: (val) {
                    changeArm(val);
                  },
                ),
                Text("Instrument Error", style: TextStyle(color: Colors.black)),
              ],
            ),
            Row(
              children: <Widget>[
                // SizedBox(width: 20,),
                Radio(
                  activeColor: kPrimaryColor,
                  value: 3,
                  groupValue: selectedReason,
                  onChanged: (val) {
                    changeArm(val);
                  },
                ),
                Text("Instrument Unavailable", style: TextStyle(color: Colors.black)),
              ],
            ),
            Row(
              children: <Widget>[
                // SizedBox(width: 20,),
                Radio(
                  activeColor: kPrimaryColor,
                  value: 4,
                  groupValue: selectedReason,
                  onChanged: (val) {
                    changeArm(val);
                  },
                ),
                Text("Other", style: TextStyle(color: Colors.black)),
              ],
            ),
            SizedBox(height: 30,),

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
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
                        child: Text('CANCEL', style: TextStyle(color: kPrimaryColor, fontSize: 18),)
                      ),
                      SizedBox(width: 30,),
                      GestureDetector(
                        onTap: () {},
                        child: Text('ADD', style: TextStyle(color: kPrimaryColor, fontSize: 18))
                      ),
                    ],
                  )
                )
              ],
            )
          ],
        )
      )
      
    );
  }
}

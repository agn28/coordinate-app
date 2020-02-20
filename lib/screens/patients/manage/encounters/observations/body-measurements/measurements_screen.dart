import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class MeasurementsScreen extends CupertinoPageRoute {
  MeasurementsScreen()
      : super(builder: (BuildContext context) => new Measurements());

}

class Measurements extends StatefulWidget {

  @override
  MeasurementsState createState() => MeasurementsState();
}

class MeasurementsState extends State<Measurements> {

  @override
  void initState() {
    super.initState();
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
              child: Text('Complete All Components', style: TextStyle(fontSize: 22),)
            ),
            
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/height.png'),
                    text: 'Height',
                    name: 'height'
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/weight.png'),
                    text: 'Weight',
                    name: 'weight'
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/hip.png'),
                    text: 'Waist/Hip',
                    name: 'waist/hip'
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
                  border: Border.all(width: 1, color: Colors.black54),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FlatButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SkipAlert();
                      },
                    );
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('UNABLE TO PERFORM', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
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
              child: Text(status, style: TextStyle(color: status == 'Complete' ? kPrimaryGreenColor : kPrimaryRedColor, fontSize: 18, fontWeight: FontWeight.bold),),
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

  List devices = ['D-23429', 'B-94857'];
  int selectedDevice;

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
    super.initState();
    selectedUnit = 1;
  }

  _addItem() {
    String unit = _getUnit();
    BodyMeasurement().addItem(widget.name, valueController.text, unit, commentController != null ? commentController.text : "", devices[selectedDevice]);
    this.widget.parent.setState(() => {
      this.widget.parent.setStatus(),
    });
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
                Text('Add ' + widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
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
                          topPaadding: 15,
                          bottomPadding: 15,
                          validation: true,
                          type: TextInputType.number,
                          controller: valueController,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 20, left: 10),
                        child: Row(
                          children: <Widget>[
                            Radio(
                              activeColor: kPrimaryColor,
                              value: 1,
                              groupValue: selectedUnit,
                              onChanged: (val) {
                                changeArm(val);
                              },
                            ),
                            Text(widget.title == 'Weight' ? 'kg' : 'cm', style: TextStyle(color: Colors.black)),
                            SizedBox(width: 20,),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('CANCEL', style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.w500),)
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

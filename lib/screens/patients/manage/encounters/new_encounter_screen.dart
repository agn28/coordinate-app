import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-test/blood_test_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/body-measurements/measurements_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/questionnaire/questionnaires_screen.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class NewEncounterScreen extends CupertinoPageRoute {
  NewEncounterScreen()
      : super(builder: (BuildContext context) => new NewEncounter());

}

class NewEncounter extends StatefulWidget {

  @override
  _NewEncounterState createState() => _NewEncounterState();
}

class _NewEncounterState extends State<NewEncounter> {
  String selectedType = 'In-clinic Screening';
  final commentController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
  }

  _getBpStatus() {
    return BloodPressure().bpItems.length > 0 ? 'Complete' : 'Incomplete';
  }

  _getBmStatus() {
    return BodyMeasurement().bmItems.length >= 3 ? 'Complete' : 'Incomplete';
  }

  _getBtStatus() {
    return BloodTest().btItems.length >= 7 ? 'Complete' : 'Incomplete';
  }

  _changeType(value) {
    setState(() {
      selectedType = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create a New Assessment', style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
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
                          Text(Patient().getPatient()['data']['name'], style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text('${Patient().getPatient()['data']['age']}Y ${Patient().getPatient()['data']['gender'].toUpperCase()}', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
                  ),
                  Expanded(
                    child: Text('PID: N-121933421', style: TextStyle(fontSize: 18))
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
              child: Text('Complete all the sections that are applicable', style: TextStyle(fontSize: 22),)
            ),
            
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_pressure.png'),
                    text: Text('Blood Pressure', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getBpStatus(),
                    onTap: () => Navigator.of(context).push(AddBloodPressureScreen()),
                  ),
                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/body_measurements.png'),
                    text: Text('Body Measurements', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getBmStatus(),
                    onTap: () => Navigator.of(context).push(MeasurementsScreen()),
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_test.png'),
                    text: Text('Blood Test', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: _getBtStatus(),
                    onTap: () => Navigator.of(context).push(BloodTestScreen()),
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: Text('Questionnaire', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: 'Incomplete',
                    onTap: () => Navigator.of(context).push(QuestionnairesScreen()),
                  ),
                ],
              )
            ),

            SizedBox(height: 30,),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                style: TextStyle(color: Colors.white, fontSize: 20.0,),
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
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: <Widget>[
                  Text('Encounter Type', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                  SizedBox(width: 20,),
                  Radio(
                    value: 'In-clinic Screening',
                    groupValue: selectedType,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      _changeType(value);
                    },
                  ),
                  Text("In-clininc Screening", style: TextStyle(color: Colors.black)),

                  Radio(
                    value: 'Home Visit',
                    activeColor: kPrimaryColor,
                    groupValue: selectedType,
                    onChanged: (value) {
                      _changeType(value);
                    },
                  ),
                  Text(
                    "Home Visit",
                  ),
                ],
              ),
            ),

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
                  onPressed: () {
                    var result = AssessmentController().create(selectedType, commentController.text);

                    if (result == 'success') {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text('Data saved successfully!'),
                          backgroundColor: Color(0xFF4cAF50),
                        )
                      );
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

class EncounnterSteps extends StatelessWidget {
   EncounnterSteps({this.text, this.onTap, this.icon, this.status});

   final Text text;
   final Function onTap;
   final Image icon;
   final String status;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onTap,
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
              child: icon,
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: text,
              )
            ),
            Expanded(
              flex: 2,
              child: Text(status, style: TextStyle(
                color: status == 'Incomplete' ? kPrimaryRedColor : kPrimaryGreenColor,
                fontSize: 18,
                fontWeight: FontWeight.w500),),
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

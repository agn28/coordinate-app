import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/blood-pressure/add_blood_pressure_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/new_observation_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';


class MeasurementsScreen extends CupertinoPageRoute {
  MeasurementsScreen()
      : super(builder: (BuildContext context) => new Measurements());

}

class Measurements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    text: Text('Height', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: 'Incomplete',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AaddHeightDialogue();
                        } 
                      );
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/blood_test.png'),
                    text: Text('Weight', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: 'Incomplete',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AaddHeightDialogue();
                        } 
                      );
                    },
                  ),

                  EncounnterSteps(
                    icon: Image.asset('assets/images/icons/questionnaire.png'),
                    text: Text('Waist/Hip', style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w500),),
                    status: 'Incomplete',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AaddHeightDialogue();
                        } 
                      );
                    },
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
                  onPressed: () {},
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
              child: Text(status, style: TextStyle(color: kPrimaryRedColor, fontSize: 18, fontWeight: FontWeight.w500),),
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



class AaddHeightDialogue extends StatefulWidget {
  AaddHeightDialogue();

  @override
  _AddHeightDialogueState createState() => _AddHeightDialogueState();
}

class _AddHeightDialogueState extends State<AaddHeightDialogue> {

   String selectedHeightUnit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedHeightUnit = 'cm';
  }

  changeArm(val) {
    setState(() {
      selectedHeightUnit = val;
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
            Text('Add BP Measurement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
            SizedBox(height: 20,),
            Container(
              // margin: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: <Widget>[
                  // SizedBox(width: 20,),
                  Container(
                    width: 150,
                    child: PrimaryTextField(
                      hintText: 'Height',
                      topPaadding: 15,
                      bottomPadding: 15,
                    ),
                  ),
                  Radio(
                    activeColor: kPrimaryColor,
                    value: 'cm',
                    groupValue: selectedHeightUnit,
                    onChanged: (val) {
                      changeArm(val);
                    },
                  ),
                  Text("cm", style: TextStyle(color: Colors.black)),

                  Radio(
                    activeColor: kPrimaryColor,
                    value: 'inch',
                    groupValue: selectedHeightUnit,
                    onChanged: (val) {
                      changeArm(val);
                    },
                  ),
                  Text(
                    "inch",
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,),
            Container(
              width: double.infinity,
              child: PrimaryTextField(
                hintText: 'Select device',
                topPaadding: 15,
                bottomPadding: 15,
              ),
            ),
            SizedBox(height: 30,),
            Container(
              width: double.infinity,
              child: TextField(
                style: TextStyle(color: Colors.white, fontSize: 20.0,),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
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


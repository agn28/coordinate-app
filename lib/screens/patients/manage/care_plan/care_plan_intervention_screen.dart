import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/widgets/primary_button_widget.dart';

class CarePlanInterventionScreen extends CupertinoPageRoute {
  var carePlan;
  CarePlanInterventionScreen({this.carePlan})
      : super(builder: (BuildContext context) => CarePlanIntervention(carePlan: carePlan));

}

class CarePlanIntervention extends StatefulWidget {
  var carePlan;
  CarePlanIntervention({this.carePlan});
  @override
  _CarePlanInterventionState createState() => _CarePlanInterventionState();
}

class _CarePlanInterventionState extends State<CarePlanIntervention> {

  bool smoking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Intervention', style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.black38)
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
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 17),
              decoration: BoxDecoration(
                
              ),
              child: Row(
                children: <Widget>[
                  Checkbox(
                    activeColor: kPrimaryColor,
                    value: smoking,
                    onChanged: (value) {
                      setState(() {
                        smoking = value;
                      });
                    },
                  ),
                  Text('Smoking cessation advise provided to patient', style: TextStyle(fontSize: 16),)
                ],
              ),
            ),
            
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                style: TextStyle(color: Colors.white, fontSize: 20.0,),

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
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: PrimaryButton(
                onTap: () async {
                  var result = await CarePlanController().update(widget.carePlan);
                  Navigator.of(context).pop();
                },
                text: Text('MARK AS COMPLETE', style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ),
          ],
        ),
      ),
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';

class EncounterDetailsScreen extends CupertinoPageRoute {
  final assessment;
  EncounterDetailsScreen(this.assessment)
      : super(builder: (BuildContext context) => new EncounterDetails(assessment));

}

class EncounterDetails extends StatefulWidget {
  final assessment;
  EncounterDetails(this.assessment);

  @override
  _EncounterDetailsState createState() => _EncounterDetailsState();
}

class _EncounterDetailsState extends State<EncounterDetails> {
  @override
  void initState() {
    // TODO: implement initState
    _getObservations();
    super.initState();
  }

  _getObservations() {
    AssessmentController().getObservationsByAssessment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Assessment Details', style: TextStyle(color: Colors.white),),
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
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 30),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: .5, color: Colors.black38)
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Text('Jan 5, 2019', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                        ),
                        Expanded(
                          child: Text('In-Clinic', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                        ),
                        Expanded(
                          child: Text('')
                        )
                      ],
                    )
                  )
                ],
              )
            ),

            SizedBox(height: 30,),
            
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Observation', style: TextStyle(fontSize: 20, ),),
                  // SizedBox(height: 20,),
                  Text('Blood Pressure', style: TextStyle(fontSize: 35, height: 1.7),),
                  Row(
                    children: <Widget>[
                      Text('Average Reading: ', style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(' 139/78 mmHg', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Recorded By: ', style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(' Malay Islam', style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(' on Jan 5 2019 at 15:50', style: TextStyle(fontSize: 20, height: 2),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Measured Using: ', style: TextStyle(fontSize: 20, height: 2),),
                      Text(' M43KS23', style: TextStyle(fontSize: 20, height: 2),),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30,),

            Row(
              children: <Widget>[
                Expanded(
                  child: Divider()
                )
              ],
            ),

            SizedBox(height: 30,), 

            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Observation', style: TextStyle(fontSize: 20, ),),
                  // SizedBox(height: 20,),
                  Text('Fasting Blood Glucose', style: TextStyle(fontSize: 35, height: 1.7),),
                  Row(
                    children: <Widget>[
                      Text('Reading: ', style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(' 74 mg/dL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Recorded By: ', style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(' Malay Islam', style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(' on Jan 5 2019 at 15:50', style: TextStyle(fontSize: 20, height: 2),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Measured Using: ', style: TextStyle(fontSize: 20, height: 2),),
                      Text(' M43KS23', style: TextStyle(fontSize: 20, height: 2),),
                    ],
                  ),
                ],
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/models/patient.dart';
import 'package:basic_utils/basic_utils.dart';

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
  var _patient;
  var _observations;
  var _bloodPressures = [];
  var _bloodTests;
   List<Widget> observationItems = List<Widget>();

  @override
  void initState() {
    super.initState();
    _getObservations();
    _patient = Patient().getPatient();
  }

  _getObservations() async {
    _observations =  await AssessmentController().getObservationsByAssessment(widget.assessment);
    _getItem();

   setState(() {
    _bloodPressures =  _observations.where((item) => item['data']['type'] == 'blood_pressure').toList();
    _bloodTests =  _observations.where((item) => item['data']['type'] == 'blood_test').toList();
   });
  }

  _getAverageBp() {
    double systolic = 0.0;
    double diastolic = 0;
    double pulseRate = 0;

    _bloodPressures.forEach((item) => {
      systolic = systolic + item['data']['data']['systolic'],
      diastolic = diastolic + item['data']['data']['diastolic'],
      pulseRate = pulseRate + item['data']['data']['pulse_rate'],
    
    });

    double avgSystolic = systolic/_bloodPressures.length;
    double avgDiastolic = diastolic/_bloodPressures.length;
    return '${avgDiastolic.toStringAsFixed(0)} / ${avgSystolic.toStringAsFixed(0)}';
  }

  _getBpPerformedBy() {
    return _bloodPressures.length > 0 ? _bloodPressures[0]['meta']['performed_by'] : '';
  }

  _getDevice() {
    return _bloodPressures.length > 0 && _bloodPressures[0]['meta']['device_id'] != null ? _bloodPressures[0]['meta']['device_id'] : '';
  }

  _getType(type) {
    return StringUtils.capitalize(type.replaceAll('_', ' '));
  }

  _getItem() {
    _observations.forEach((item) => {
      if (item['data']['type'] != 'blood_pressure') {
        setState(() {
          observationItems.add(
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Observation', style: TextStyle(fontSize: 20, ),),
                      Text(_getType(item['data']['data']['type']), style: TextStyle(fontSize: 35, height: 1.7),),
                      Row(
                        children: <Widget>[
                          Text('Reading: ', style: TextStyle(fontSize: 20, height: 1.6),),
                          Text(' ${item['data']['data']['value']} ${item['data']['data']['unit']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Recorded By: ', style: TextStyle(fontSize: 20, height: 1.6),),
                          Text(' ${item['meta']['performed_by']}', style: TextStyle(fontSize: 20, height: 1.6),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Measured Using: ', style: TextStyle(fontSize: 20, height: 2),),
                          Text(' ${item['meta']['device_id']}', style: TextStyle(fontSize: 20, height: 2),),
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
              ],
            )
          );
        })
      }
      
    });
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
                          Text(_patient['data']['name'], style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text('${_patient["data"]["age"]}Y ${_patient["data"]["gender"].toUpperCase()}', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
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
            
            _bloodPressures.length > 0 ? Container(
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
                      Text(_getAverageBp(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Recorded By: ', style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(_getBpPerformedBy(), style: TextStyle(fontSize: 20, height: 1.6),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Measured Using: ', style: TextStyle(fontSize: 20, height: 2),),
                      Text(_getDevice(), style: TextStyle(fontSize: 20, height: 2),),
                    ],
                  ),
                ],
              ),
            ) : Container(),

            SizedBox(height: 30,),

            Row(
              children: <Widget>[
                Expanded(
                  child: Divider()
                )
              ],
            ),

            SizedBox(height: 30,), 
            Column(children: observationItems),

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

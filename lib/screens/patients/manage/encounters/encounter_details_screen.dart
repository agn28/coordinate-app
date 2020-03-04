import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/patient.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:nhealth/screens/patients/manage/encounters/new_encounter_screen.dart';

class EncounterDetailsScreen extends CupertinoPageRoute {
  final assessment;

  EncounterDetailsScreen(this.assessment)
      : super(builder: (BuildContext context) => new EncounterDetails(assessment));

}

class EncounterDetails extends StatefulWidget {
  final assessment;
  EncounterDetails(this.assessment);

  @override
  EncounterDetailsState createState() => EncounterDetailsState();
}

class EncounterDetailsState extends State<EncounterDetails> {
  var _patient;
  var _observations;
  var _bloodPressures = [];
  var _bloodTests = [];
   List<Widget> observationItems = List<Widget>();

  @override
  void initState() {
    super.initState();
    getObservations();
    _patient = Patient().getPatient();
  }

  /// Get all observations by assessment
  getObservations() async {
    _observations =  await AssessmentController().getObservationsByAssessment(widget.assessment);
    _getItem();

   setState(() {
    _bloodPressures =  _observations.where((item) => item['body']['type'] == 'blood_pressure').toList();
    _bloodTests =  _observations.where((item) => item['body']['type'] == 'blood_test').toList();
   });
  }

  /// Calculate average Blood Pressure
  _getAverageBp() {
    int systolic = 0;
    int diastolic = 0;

    _bloodPressures.forEach((item) {
      print(item['body']['data']['systolic']);
      systolic = systolic + item['body']['data']['systolic'];
      diastolic = diastolic + item['body']['data']['diastolic'];
    });

    double avgSystolic = systolic/_bloodPressures.length;
    double avgDiastolic = diastolic/_bloodPressures.length;
    return '${avgDiastolic.toStringAsFixed(0)} / ${avgSystolic.toStringAsFixed(0)}';
  }

  /// Get observation's performed by
  _getBpPerformedBy() {
    return _bloodPressures.length > 0 && _bloodPressures[0]['meta']['performed_by'] != null ? _bloodPressures[0]['meta']['performed_by'] : '';
  }

  /// Get the device id of an observation
  _getDevice() {
    return _bloodPressures.length > 0 && _bloodPressures[0]['meta']['device_id'] != null ? _bloodPressures[0]['meta']['device_id'] : '';
  }

  /// Convert [type] to upper case and remove the '_'
  _getType(obs) {
    if (obs['type'] == 'blood_test' && BloodTest().getMap()[obs['data']['name']] != null) {
      return BloodTest().getMap()[obs['data']['name']];
    }
    return StringUtils.capitalize(obs['data']['name'].replaceAll('_', ' '));
  }

  /// Populate observation widgets form observations list.
  _getItem() {
    observationItems = [];
    _observations.forEach((item) {
      if (item['body']['type'] != 'blood_pressure' && item['body']['type'] != 'survey') {
        setState(() {
          observationItems.add(
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('observation'), style: TextStyle(fontSize: 20, ),),
                      Text(_getType(item['body']), style: TextStyle(fontSize: 35, height: 1.7),),
                      Row(
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate('reading'), style: TextStyle(fontSize: 20, height: 1.6),),
                          Text(' ${item['body']['data']['value']} ${item['body']['data']['unit']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate('recordedBy'), style: TextStyle(fontSize: 20, height: 1.6),),
                          Text(' ${item['meta']['performed_by'] ?? ''} ', style: TextStyle(fontSize: 20, height: 1.6),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate('measuredUsing'), style: TextStyle(fontSize: 20, height: 2),),
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
        });
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('assessmentDetails'), style: TextStyle(color: Colors.white),),
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
                          Text(Helpers().getPatientName(_patient), style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(Helpers().getPatientAgeAndGender(_patient), style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text('PID: N-1216657773', style: TextStyle(fontSize: 18))
                      ],
                    )
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
                          child: Text(Helpers().convertDate(widget.assessment['data']['assessment_date']), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                        ),
                        Expanded(
                          child: Text(StringUtils.capitalize(widget.assessment['data']['type']), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              AssessmentController().edit(widget.assessment, _observations);
                              Navigator.of(context).push(NewEncounterScreen(encounterDetailsState: this));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Icon(Icons.edit, color: kPrimaryColor,),
                                SizedBox(width: 10),
                                Text('Edit Encounter', style: TextStyle(color: kPrimaryColor))
                              ],
                            ),
                          )
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
                  Text(AppLocalizations.of(context).translate('observation'), style: TextStyle(fontSize: 20, ),),
                  // SizedBox(height: 20,),
                  Text(AppLocalizations.of(context).translate('bloodPressure'), style: TextStyle(fontSize: 35, height: 1.7),),
                  Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('averageReading'), style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(_getAverageBp(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('recordedBy'), style: TextStyle(fontSize: 20, height: 1.6),),
                      Text(_getBpPerformedBy(), style: TextStyle(fontSize: 20, height: 1.6),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('measuredUsing'), style: TextStyle(fontSize: 20, height: 2),),
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

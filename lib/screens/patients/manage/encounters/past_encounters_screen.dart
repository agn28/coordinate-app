import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/encounter_details_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

class PastEncountersScreen extends CupertinoPageRoute {
  var encounters;
  PastEncountersScreen({this.encounters})
      : super(builder: (BuildContext context) => new PastEncounters(encounters: encounters));

}


class PastEncounters extends StatefulWidget {
  var encounters;
  PastEncounters({this.encounters});

  @override
  _PastEncountersState createState() => _PastEncountersState();
}

class _PastEncountersState extends State<PastEncounters> {

  var _patient;
  var _encounters;
  bool isLoading = true;
  List<Widget> list = List<Widget>();

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
  }

  _getData() async {
    _checkAuth();

    // _encounters = await AssessmentController().getAllAssessmentsByPatient();
    _encounters = await AssessmentController().getLiveAllAssessmentsByPatient();
    print(_encounters);

    setState(() {
      isLoading = false;
    });
    // _assessments = await AssessmentController().getAllAssessmentsByPatient();
    _encounters.forEach((encounter) => {
      setState(() => {
        list.add(
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: .5, color: Colors.black38)
              )
            ),
            child: FlatButton(
              onPressed: () => Navigator.of(context).push(EncounterDetailsScreen(encounter)),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Text(Helpers().convertDate(encounter['data']['assessment_date']), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                        ),
                        Expanded(
                          child: Text(StringUtils.capitalize(encounter['data']['type']), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                          )
                        )
                      ],
                    )
                  )
                ],
              )
            )
          ),
        )
      })
    });
  }

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('pastAssessments'), style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                PatientTopbar(),

                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .5, color: Colors.black38)
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: Text(AppLocalizations.of(context).translate('dateEncounter'), style: TextStyle(fontSize: 17),),
                            ),
                            Expanded(
                              child: Text(AppLocalizations.of(context).translate('type'), style: TextStyle(fontSize: 17,),),
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

                Column(children: list),

              ],
            ),
          ),
          isLoading ? Container(
              height: double.infinity,
              width: double.infinity,
              color: Color(0x20FFFFFF),
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),backgroundColor: Color(0x30FFFFFF),)
              ),
            ) : Container(),
        ],
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

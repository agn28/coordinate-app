import 'package:basic_utils/basic_utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/chw/new_patient_questionnairs/new_patient_questionnaire_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';


class NewQuestionnaireAcuteScreen extends StatefulWidget {
  static const path = '/newQuestionnaireAcuteScreen';
  NewQuestionnaireAcuteScreen({this.parent});
  final parent;

  @override
  _NewQuestionnaireAcuteScreenState createState() => _NewQuestionnaireAcuteScreenState();
}

var firstQuestionText = 'Are you having any pain or discomfort or pressure or heaviness in your chest?';
var secondQuestionText = 'Are you having any difficulty in talking, or any weakness or numbness of arms, legs or face?';
var firstQuestionOptions = ['yes', 'no'];
var secondQuestionOptions = ['yes', 'no'];

var firstAnswer = 'no';
var secondAnswer = 'no';

class _NewQuestionnaireAcuteScreenState extends State<NewQuestionnaireAcuteScreen> {

  List devices = [];

  

  var selectedDevice = 0;

  @override
  initState() {
    super.initState();
    firstAnswer = 'no';
    secondAnswer = 'no';

    devices = Device().getDevices();
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('newPatientQuestionnaire'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PatientTopbar(),
              SizedBox(height: 30,),
              Container(
                padding: EdgeInsets.only(bottom: 35, top: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: kBorderLighter)
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                      // child: Text(_questions['items'][0]['question'],
                      child: Text(firstQuestionText,
                        style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                      )
                    ),
                    SizedBox(height: 20,),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                      width: MediaQuery.of(context).size.width * .5,
                      child: Row(
                        children: <Widget>[
                          ...firstQuestionOptions.map((option) => 
                            Expanded(
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.only(right: 10, left: 10),
                                decoration: BoxDecoration(
                                  // border: Border.all(width: 1, color:  Color(0xFF01579B)),
                                  border: Border.all(width: 1, color: firstAnswer == option ? Color(0xFF01579B) : Colors.black),
                                  borderRadius: BorderRadius.circular(3),
                                  color: firstAnswer == option ? Color(0xFFE1F5FE) : null
                                  // color: Color(0xFFE1F5FE) 
                                ),
                                child: FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      firstAnswer = option;
                                    });
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: Text(option.toUpperCase(),
                                    style: TextStyle(color: firstAnswer == option ? kPrimaryColor : null),
                                    // style: TextStyle(color: kPrimaryColor),
                                  ),
                                ),
                              )
                            ),
                          ).toList()
                        ],
                      )
                    ),

                    SizedBox(height: 30,),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                      // child: Text(_questions['items'][0]['question'],
                      child: Text(secondQuestionText,
                        style: TextStyle(fontSize: 18, height: 1.7, fontWeight: FontWeight.w500),
                      )
                    ),
                    SizedBox(height: 20,),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                      width: MediaQuery.of(context).size.width * .5,
                      child: Row(
                        children: <Widget>[
                          ...secondQuestionOptions.map((option) => 
                            Expanded(
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.only(right: 10, left: 10),
                                decoration: BoxDecoration(
                                  // border: Border.all(width: 1, color:  Color(0xFF01579B)),
                                  border: Border.all(width: 1, color: secondAnswer == option ? Color(0xFF01579B) : Colors.black),
                                  borderRadius: BorderRadius.circular(3),
                                  color: secondAnswer == option ? Color(0xFFE1F5FE) : null
                                  // color: Color(0xFFE1F5FE) 
                                ),
                                child: FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      secondAnswer = option;
                                    });
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: Text(option.toUpperCase(),
                                    style: TextStyle(color: secondAnswer == option ? kPrimaryColor : null),
                                    // style: TextStyle(color: kPrimaryColor),
                                  ),
                                ),
                              )
                            ),
                          ).toList()
                        ],
                      )
                    ),

                  ],
                )
              ),
              SizedBox(height: 100,),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 200,
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    height: 50,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child: FlatButton(
                      onPressed: () async {
                        if (firstAnswer == 'yes' || secondAnswer == 'yes') {
                          var data = {
                            'meta': {
                              'patient_id': Patient().getPatient()['uuid'],
                              "collected_by": Auth().getAuth()['uid'],
                              "status": "pending"
                            },
                            'body': {}
                          };
                          Navigator.of(context).pushNamed('/medicalRecommendation', arguments: data);
                          return;
                        }

                        Navigator.of(context).pushNamed(NewPatientQuestionnaireScreen.path);
                        
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text(AppLocalizations.of(context).translate('next'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      )
  
    );
    
  }
}


import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/health_report_success_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';


class CreateHealthReportScreen extends CupertinoPageRoute {
  CreateHealthReportScreen()
      : super(builder: (BuildContext context) => new CreateHealthReport());

}

class CreateHealthReport extends StatefulWidget {
  @override
  _CreateHealthReportState createState() => _CreateHealthReportState();
}

class _CreateHealthReportState extends State<CreateHealthReport> {

  var reports;
  bool isLoading = false;
  bool confirmLoading = false;
  bool reviewLoading = false;
  bool canEdit = false;
  final commentsController = TextEditingController();
  var medications = [];
  var conditions = [];
  bool avatarExists = false;
  @override
  void initState() {
    super.initState();
    _checkAvatar();
    getReports();
  }

  _checkAvatar() async {
    var data = await File(Patient().getPatient()['data']['avatar']).exists();
    setState(() {
      avatarExists = data;
    });
  }

  getReports() async {
    isLoading = true;
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
    var data = await HealthReportController().getReport();

    if (data == null) {
      return Toast.show('Server Error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }
    if (data['error'] != null && data['error']) {
      if (data['message'] == 'No matching documents.') {
        return Toast.show('No Assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
      }
      return Toast.show('Server Error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }
    var fetchedSurveys = await ObservationController().getLiveSurveysByPatient();

    if(fetchedSurveys.isNotEmpty) {
      fetchedSurveys.forEach((item) {
        if (item['data']['name'] == 'medical_history') {
          item['data'].keys.toList().forEach((key) {
            if (item['data'][key] == 'yes') {
              setState(() {
                var text = key.replaceAll('_', ' ');
                conditions.add(text[0].toUpperCase() + text.substring(1));
              });
            }
          });
        }
        if (item['data']['name'] == 'current_medication' && item['data']['medications'].isNotEmpty) {
          setState(() {
            medications = item['data']['medications'];
          });
        }
      });
    }

    if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        isLoading = false;
        reports = data;
      });
    }

  }

  checkIfAllGreen() {
    // print(reports);
    // reports['assessments']['lifestyle']['components']['smoking']['tfl'] = 'GREEN';
    // reports['assessments']['lifestyle']['components']['alcohol']['tfl'] = 'GREEN';
    // reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['tfl'] = 'GREEN';
    // reports['assessments']['lifestyle']['components']['physical_activity']['tfl'] = 'GREEN';
    // reports['assessments']['body_composition']['components']['bmi']['tfl'] = 'GREEN';
    // reports['assessments']['blood_pressure']['tfl'] = 'GREEN';
    // reports['assessments']['diabetes']['tfl'] = 'GREEN';
    // reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] = 'GREEN';
    // reports['assessments']['cvd']['tfl'] = 'GREEN';

    var tobacco = reports['assessments']['lifestyle']['components']['smoking'] != null ? reports['assessments']['lifestyle']['components']['smoking']['tfl'] == 'GREEN' || reports['assessments']['lifestyle']['components']['smoking']['tfl'] == 'BLUE' : false;
    var alcohol = reports['assessments']['lifestyle']['components']['alcohol'] != null ? reports['assessments']['lifestyle']['components']['alcohol']['tfl'] == 'GREEN' || reports['assessments']['lifestyle']['components']['alcohol']['tfl'] == 'BLUE' : false;
    var fruits = reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable'] != null ? reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['tfl'] == 'GREEN' || reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['tfl'] == 'BLUE' : false;
    var physicalActivity = reports['assessments']['lifestyle']['components']['physical_activity'] != null ? reports['assessments']['lifestyle']['components']['physical_activity']['tfl'] == 'GREEN' || reports['assessments']['lifestyle']['components']['physical_activity']['tfl'] == 'BLUE' : false;
    var bmi = reports['assessments']['body_composition']['components']['bmi'] != null ? reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'GREEN' || reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'BLUE' : false;
    var bloodPressure = reports['assessments']['blood_pressure']!= null ? reports['assessments']['blood_pressure']['tfl'] == 'GREEN' || reports['assessments']['blood_pressure']['tfl'] == 'BLUE' : false;
    var diabetes = reports['assessments']['diabetes'] != null ? reports['assessments']['diabetes']['tfl'] == 'GREEN' || reports['assessments']['diabetes']['tfl'] == 'BLUE' : false;
    var cholesterol = reports['assessments']['cholesterol']['components']['total_cholesterol'] != null ? reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'GREEN' || reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'BLUE' : false;
    var cvd = reports['assessments']['cvd'] != null ? reports['assessments']['cvd']['tfl'] == 'GREEN' || reports['assessments']['cvd']['tfl'] == 'BLUE' : false;

    if (tobacco && alcohol && fruits && physicalActivity && bmi && bloodPressure && diabetes && cholesterol && cvd) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('newHealthAssessment'), style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: isLoading ? NeverScrollableScrollPhysics() : null,
        child: Stack(
          children: <Widget>[
            reports != null ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PatientTopbar(),

                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('existingConditions'), style: TextStyle(fontSize: 24)),
                                canEdit ?  IconButton(
                                  icon: Icon(Icons.edit, color: kPrimaryColor,),
                                  onPressed: () {}
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 15,),
                            ...conditions.map((item) {
                              return Text(item, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5));
                            }).toList(),

                          ],
                        )
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Current Medications', style: TextStyle(fontSize: 24)),
                                canEdit ?  IconButton(
                                  icon: Icon(Icons.edit, color: kPrimaryColor,),
                                  onPressed: () {}
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 15,),
                            ...medications.map((item) {
                              return Text(item, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5));
                            }).toList()
                          ],
                        )
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .5, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Lifestyle', style: TextStyle(fontSize: 24)),
                            SizedBox(height: 25,),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  reports['assessments']['lifestyle']['components']['smoking'] != null ?
                                  Expanded(
                                    child:
                                    Container(
                                      height: 230,
                                      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                                      decoration: BoxDecoration(
                                        color: kBackgroundGrey
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Image.asset('assets/images/icons/icon_smoker.png', ),
                                              ),
                                              canEdit ? GestureDetector(
                                                child: Icon(Icons.edit, color: kPrimaryColor,),
                                                onTap: () {}
                                              ) : Container(),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Text('Tobacco Use', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['smoking']['eval']}',
                                            style: TextStyle(
                                              color: ColorUtils.statusColor[reports['assessments']['lifestyle']['components']['smoking']['tfl']] ?? Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['smoking']['message']}', style: TextStyle(fontSize: 14, height: 1.3),)
                                        ],
                                      ),
                                    ),
                                  ) : Container(),
                                  SizedBox(width: 20,),
                                  reports['assessments']['lifestyle']['components']['alcohol'] != null ?
                                  Expanded(
                                    child:
                                    Container(
                                      // height: 220,
                                      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                                      decoration: BoxDecoration(
                                        color: kBackgroundGrey
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Image.asset('assets/images/icons/icon_alcohol.png', ),
                                              ),
                                              canEdit ? GestureDetector(
                                                child: Icon(Icons.edit, color: kPrimaryColor,),
                                                onTap: () {}
                                              ) : Container(),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Text('Alcohol Consumption', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['alcohol']['eval']}',
                                            style: TextStyle(
                                              color: ColorUtils.statusColor[reports['assessments']['lifestyle']['components']['alcohol']['tfl']] ?? Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['alcohol']['message']}', style: TextStyle(fontSize: 14, height: 1.3),)
                                        ],
                                      ),
                                    ),
                                  ) : Container(),
                                ],
                              ),
                            ),
                            SizedBox(height: 20,),
                            reports['assessments']['lifestyle']['components']['diet'] != null && reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable'] != null ?
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      // height: 210,
                                      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 20),
                                      decoration: BoxDecoration(
                                        color: kBackgroundGrey
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Image.asset('assets/images/icons/icon_fruits.png', ),
                                              ),
                                              canEdit ? GestureDetector(
                                                child: Icon(Icons.edit, color: kPrimaryColor,),
                                                onTap: () {}
                                              ) : Container(),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Text('Fruits and vegetables intake', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['eval']}',
                                            style: TextStyle(
                                              color: ColorUtils.statusColor[reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['tfl']] ?? Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['message']}', style: TextStyle(fontSize: 14,),)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15,),
                                  reports['assessments']['lifestyle']['components']['physical_activity'] != null ? 
                                  Expanded(
                                    child: Container(
                                      height: 210,
                                      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                                      decoration: BoxDecoration(
                                        color: kBackgroundGrey
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Image.asset('assets/images/icons/icon_physical-activity.png', ),
                                              ),
                                              canEdit ? GestureDetector(
                                                child: Icon(Icons.edit, color: kPrimaryColor,),
                                                onTap: () {}
                                              ) : Container(),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Text('Physical Activity', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['physical_activity']['eval']}',
                                            style: TextStyle(
                                              color: ColorUtils.statusColor[reports['assessments']['lifestyle']['components']['physical_activity']['tfl']] ?? Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Text('${reports['assessments']['lifestyle']['components']['physical_activity']['message']}', style: TextStyle(fontSize: 14,),)
                                        ],
                                      ),
                                    ),
                                  ) : Container(),
                                ],
                              ),
                            ) :
                            Container(),
                          ],
                        )
                      ),



                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(AppLocalizations.of(context).translate('bodyComposition'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                            SizedBox(height: 30,),

                            reports['assessments']['body_composition']['components']['hip_circ'] != null ?
                            Container(
                              // alignment: Alignment.topCenter,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              margin: EdgeInsets.only(top: 25),
                              decoration: BoxDecoration(
                                color: kBackgroundGrey,
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context).translate('hipCircumference'), style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                                      canEdit ? GestureDetector(
                                        child: Icon(Icons.edit, color: kPrimaryColor,),
                                        onTap: () {}
                                      ) : Container(),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(top: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('${reports['assessments']['body_composition']['components']['hip_circ']['value']} ${reports['assessments']['body_composition']['components']['hip_circ']['eval']}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: ColorUtils.statusColor[reports['assessments']['body_composition']['components']['hip_circ']['tfl']] ?? Colors.black
                                                ),
                                              ),
                                              SizedBox(height: 15,),
                                              Text('${reports['assessments']['body_composition']['components']['hip_circ']['target']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: kTextGrey
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    color: kPrimaryGreenColor,
                                                    height: 14,
                                                    width: 57,
                                                  ),
                                                  reports['assessments']['body_composition']['components']['hip_circ']['tfl'] == 'GREEN' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                                  ) :
                                                  Container()
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    color: kPrimaryAmberColor,
                                                    height: 14,
                                                    width: 57,
                                                  ),
                                                  reports['assessments']['body_composition']['components']['hip_circ']['tfl'] == 'AMBER' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                                  ) :
                                                  Container()
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    color: kPrimaryRedColor,
                                                    height: 14,
                                                    width: 57,
                                                  ),
                                                  reports['assessments']['body_composition']['components']['hip_circ']['tfl'] == 'RED' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                                  ) :
                                                  Container()
                                                ],
                                              ),

                                            ],
                                          ),
                                        )
                                      )
                                    ],
                                  ),

                                ],
                              ),
                            ) :
                            Container(),

                            reports['assessments']['body_composition']['components']['bmi'] != null ?
                            Container(
                              // alignment: Alignment.topCenter,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              margin: EdgeInsets.only(top: 25),
                              decoration: BoxDecoration(
                                color: kBackgroundGrey,
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('BMI', style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                                      canEdit ? GestureDetector(
                                        child: Icon(Icons.edit, color: kPrimaryColor,),
                                        onTap: () {}
                                      ) : Container(),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(top: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('${reports['assessments']['body_composition']['components']['bmi']['value']} ${reports['assessments']['body_composition']['components']['bmi']['eval']}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: ColorUtils.statusColor[reports['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black,

                                                ),
                                              ),
                                              SizedBox(height: 15,),
                                              Text('${reports['assessments']['body_composition']['components']['bmi']['target']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: kTextGrey
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    color: kPrimaryBlueColor,
                                                    height: 14,
                                                    width: 40,
                                                  ),
                                                  reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'BLUE' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryBlueColor,),
                                                  ) :
                                                  Container(),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    color: kGreenColor,
                                                    height: 14,
                                                    width: 40,
                                                  ),
                                                  reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'GREEN' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kGreenColor,),
                                                  ) :
                                                  Container(),
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    color: kPrimaryAmberColor,
                                                    height: 14,
                                                    width: 40,
                                                  ),
                                                  reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'AMBER' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                                  ) :
                                                  Container(),
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    color: kRedColor,
                                                    height: 14,
                                                    width: 40,
                                                    margin: EdgeInsets.only(right: 10),
                                                  ),
                                                  reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'RED' ||  reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'DEEP-RED' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kRedColor,),
                                                  ) :
                                                  Container(),
                                                ],
                                              ),

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    color: kPrimaryDeepRedColor,
                                                    height: 14,
                                                    width: 40,
                                                  ),
                                                  reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'DEEP-RED' ?
                                                  Container(
                                                    child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryDeepRedColor,),
                                                  ) :
                                                  Container(),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                ],
                              ),
                            ) :
                            Container(),

                            SizedBox(height: 30,),

                            Container(

                              child: Text(AppLocalizations.of(context).translate('weightReduction'), style: TextStyle(fontSize: 18,),),
                            )

                          ],
                        )
                      ),

                      reports['assessments']['blood_pressure'] != null ?
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Blood Pressure', style: TextStyle(fontSize: 24)),
                                canEdit ? GestureDetector(
                                  child: Icon(Icons.edit, color: kPrimaryColor,),
                                  onTap: () {}
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 20,),

                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${reports['assessments']['blood_pressure']['value']}   ${reports['assessments']['blood_pressure']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[reports['assessments']['blood_pressure']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${reports['assessments']['blood_pressure']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
                                  ]
                                ),
                                SizedBox(width: 30,),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryBlueColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['blood_pressure']['tfl'] == 'BLUE' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryBlueColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kGreenColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['blood_pressure']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kGreenColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryAmberColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['blood_pressure']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kRedColor,
                                            height: 14,
                                            width: 40,
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          reports['assessments']['blood_pressure']['tfl'] == 'RED' ||  reports['assessments']['blood_pressure']['tfl'] == 'DEEP-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryDeepRedColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['blood_pressure']['tfl'] == 'DEEP-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryDeepRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25,),

                            Text("${reports['assessments']['blood_pressure']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),

                          ],
                        )
                      ) :
                      Container(),

                      reports['assessments']['diabetes'] != null ?
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Diabetes', style: TextStyle(fontSize: 24)),
                                canEdit ? GestureDetector(
                                  child: Icon(Icons.edit, color: kPrimaryColor,),
                                  onTap: () {}
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 20,),

                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${reports['assessments']['diabetes']['value']}   ${reports['assessments']['diabetes']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[reports['assessments']['diabetes']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${reports['assessments']['diabetes']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
                                  ]
                                ),
                                SizedBox(width: 30,),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryBlueColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['diabetes']['tfl'] == 'BLUE' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryBlueColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kGreenColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['diabetes']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kGreenColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryAmberColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['diabetes']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kRedColor,
                                            height: 14,
                                            width: 40,
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          reports['assessments']['diabetes']['tfl'] == 'RED' ||  reports['assessments']['blood_pressure']['tfl'] == 'DEEP-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryDeepRedColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['diabetes']['tfl'] == 'DEEP-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryDeepRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              
                              ],
                            ),
                            SizedBox(height: 25,),

                            Text("${reports['assessments']['diabetes']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),

                          ],
                        )
                      ) :
                      Container(),

                      reports['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Cholesterol', style: TextStyle(fontSize: 24)),
                                canEdit ? GestureDetector(
                                  child: Icon(Icons.edit, color: kPrimaryColor,),
                                  onTap: () {}
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 20,),

                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${reports['assessments']['cholesterol']['components']['total_cholesterol']['value']}   ${reports['assessments']['cholesterol']['components']['total_cholesterol']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${reports['assessments']['cholesterol']['components']['total_cholesterol']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
                                  ]
                                ),
                                SizedBox(width: 30,),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryBlueColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'BLUE' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryBlueColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kGreenColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kGreenColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryAmberColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kRedColor,
                                            height: 14,
                                            width: 40,
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'RED' ||  reports['assessments']['blood_pressure']['tfl'] == 'DEEP-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryDeepRedColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'DEEP-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryDeepRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              
                              ],
                            ),
                            SizedBox(height: 25,),

                            Text("${reports['assessments']['cholesterol']['components']['total_cholesterol']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),

                          ],
                        )
                      ) :
                      Container(),

                      reports['assessments']['cvd'] != null ?
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Cardiovascular Risk', style: TextStyle(fontSize: 24)),
                                canEdit ? GestureDetector(
                                  child: Icon(Icons.edit, color: kPrimaryColor,),
                                  onTap: () {}
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 20,),

                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${reports['assessments']['cvd']['value']}   ${reports['assessments']['cvd']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[reports['assessments']['cvd']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${reports['assessments']['cvd']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
                                  ]
                                ),
                                SizedBox(width: 30,),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryBlueColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cvd']['tfl'] == 'BLUE' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryBlueColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kGreenColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cvd']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kGreenColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryAmberColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cvd']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kRedColor,
                                            height: 14,
                                            width: 40,
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          reports['assessments']['cvd']['tfl'] == 'RED' ||  reports['assessments']['blood_pressure']['tfl'] == 'DEEP-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            color: kPrimaryDeepRedColor,
                                            height: 14,
                                            width: 40,
                                          ),
                                          reports['assessments']['cvd']['tfl'] == 'DEEP-RED' || reports['assessments']['cvd']['tfl'] == 'DARK-RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryDeepRedColor,),
                                          ) :
                                          Container(),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              
                              ],
                            ),
                            SizedBox(height: 25,),

                            Text("${reports['assessments']['cvd']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),

                          ],
                        )
                      ) :
                      Container(),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(AppLocalizations.of(context).translate('referralRequired'), style: TextStyle(fontSize: 24, color: kPrimaryRedColor)),
                            SizedBox(height: 20,),
                            Text(AppLocalizations.of(context).translate('generateReferral'), style: TextStyle(fontSize: 20, height: 1.4),),
                            SizedBox(height: 20,),

                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: kBorderGrey),
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: FlatButton(
                                onPressed: () {},
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.add, color: kPrimaryColor, size: 30,),
                                    SizedBox(width: 20,),
                                    Text(AppLocalizations.of(context).translate('generateReferralTitle'), style: TextStyle(fontSize: 18, color: kPrimaryColor),)
                                  ],
                                )
                              ),
                            ),

                          ],
                        )
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: .6, color: kBorderLighter)
                          )
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                          controller: commentsController,
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

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                          )
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: kBorderGrey),
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(fontSize: 14),)
                            ),
                          ),

                          SizedBox(height: 20,),

                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: checkIfAllGreen() ? Color(0x60000000) : Color(0xFF00838F),
                              borderRadius: BorderRadius.circular(3)
                            ),
                            child: FlatButton(
                              onPressed: checkIfAllGreen() ? null : () async {
                                setState(() {
                                  confirmLoading = true;
                                });
                                var response = await HealthReportController().confirmAssessment(reports, commentsController.text);
                                if (response == 'success') {
                                  setState(() {
                                    confirmLoading = false;
                                  });
                                  Navigator.of(context).push(HealthReportSuccessScreen());
                                } else {
                                  setState(() {
                                    confirmLoading = false;
                                  });
                                  Toast.show('Invalid data', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                                }
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: confirmLoading ? CircularProgressIndicator() : Text('CONFIRM ASSESSMENT', style: TextStyle(fontSize: 14, color: Colors.white),),
                            ),
                          ),

                          SizedBox(height: 20,),

                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(3)
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                setState(() {
                                  reviewLoading = true;
                                });
                                var response = await HealthReportController().sendForReview(reports, commentsController.text);
                                if (response == 'success') {
                                  setState(() {
                                    reviewLoading = false;
                                  });
                                  Navigator.of(context).push(HealthReportSuccessScreen());
                                } else {
                                  setState(() {
                                    reviewLoading = false;
                                  });
                                  Toast.show('Invalid data', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                                }
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: reviewLoading ? CircularProgressIndicator() : Text('SEND FOR DOCTOR REVIEW', style: TextStyle(fontSize: 14, color: Colors.white),)
                            ),
                          ),
                        ],
                      )
                    ),


                  ],
                )
              ),

              SizedBox(height: 30,),

            ],
          ) : Container(),
            isLoading ? Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Color(0x90FFFFFF),
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
              ),
            ) : Container(),
          ],
        )),

    );
  }
}

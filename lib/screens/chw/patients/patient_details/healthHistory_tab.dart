import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/controllers/worklist_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';
import 'package:nhealth/screens/work-list/work_list_details.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';



class HealthHistoryTab extends StatefulWidget {
  HealthHistoryTab({this.reports});

  var reports;

  @override
  _HealthHistoryState createState() => _HealthHistoryState();
}

class _HealthHistoryState extends State<HealthHistoryTab> {
  bool isLoading = false;
  bool confirmLoading = false;
  bool reviewLoading = false;

  bool canEdit = false;
  final commentsController = TextEditingController();
  var medications = [];
  var conditions = [];
  bool avatarExists = false;

  @override
  initState() {
    super.initState();

    // getReports();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          !isLoading ? Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(width: .5, color: kBorderLighter)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Lifestyle', style: TextStyle(fontSize: 22)),
                SizedBox(height: 25,),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      widget.reports['assessments']['lifestyle']['components']['smoking'] != null ?
                      Expanded(
                        child:
                        Container(
                          height: 220,
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
                              Text('${widget.reports['assessments']['lifestyle']['components']['smoking']['eval']}',
                                style: TextStyle(
                                  color: ColorUtils.statusColor[widget.reports['assessments']['lifestyle']['components']['smoking']['tfl']] ?? Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 20,),
                              Text('${widget.reports['assessments']['lifestyle']['components']['smoking']['message']}', style: TextStyle(fontSize: 14, height: 1.3),)
                            ],
                          ),
                        ),
                      ) : Container(),
                      SizedBox(width: 20,),
                      widget.reports['assessments']['lifestyle']['components']['alcohol'] != null ?
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
                              Text('${widget.reports['assessments']['lifestyle']['components']['alcohol']['eval']}',
                                style: TextStyle(
                                  color: ColorUtils.statusColor[widget.reports['assessments']['lifestyle']['components']['alcohol']['tfl']] ?? Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 20,),
                              Text('${widget.reports['assessments']['lifestyle']['components']['alcohol']['message']}', style: TextStyle(fontSize: 14, height: 1.3),)
                            ],
                          ),
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                widget.reports['assessments']['lifestyle']['components']['diet'] != null && widget.reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable'] != null ?
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text('${widget.reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['eval']}',
                                style: TextStyle(
                                  color: ColorUtils.statusColor[widget.reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['tfl']] ?? Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 20,),
                              Text('${widget.reports['assessments']['lifestyle']['components']['diet']['components']['fruit_vegetable']['message']}', style: TextStyle(fontSize: 14,),)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      widget.reports['assessments']['lifestyle']['components']['physical_activity'] != null ? 
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
                              Text('${widget.reports['assessments']['lifestyle']['components']['physical_activity']['eval']}',
                                style: TextStyle(
                                  color: ColorUtils.statusColor[widget.reports['assessments']['lifestyle']['components']['physical_activity']['tfl']] ?? Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 20,),
                              Text('${widget.reports['assessments']['lifestyle']['components']['physical_activity']['message']}', style: TextStyle(fontSize: 14,),)
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
          )
        
          : Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: Color(0x90FFFFFF),
            child: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
            ),
          ),
        ],
      ),
    );
  }
}

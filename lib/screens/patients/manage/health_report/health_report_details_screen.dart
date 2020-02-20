import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/health_report_repository.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/health_report_success_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';


class HealthReportDetailsScreen extends CupertinoPageRoute {
  var reports;
  HealthReportDetailsScreen({this.reports})
      : super(builder: (BuildContext context) => new HealthReportDetails(reports: reports));

}

class HealthReportDetails extends StatefulWidget {
  var reports;
  HealthReportDetails({this.reports});
  @override
  _HealthReportDetailsState createState() => _HealthReportDetailsState();
}

class _HealthReportDetailsState extends State<HealthReportDetails> {

  // var reports;
  bool isLoading = false;
  bool canEdit = false;
  final commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // getReports();
    print('reports');
    print(widget.reports);
  }

  getReports() async {
    isLoading = true;
    var data = await HealthReportController().getReport();
    
    // if (data['message'] == 'Unauthorized') {
    //   Auth().logout();
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    // } else {
    //   setState(() {
    //     isLoading = false;
    //     reports = data;
    //   });
    // }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create a New Health Assessment', style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: isLoading ? NeverScrollableScrollPhysics() : null,
        child: Stack(
          children: <Widget>[
            widget.reports != null ? Column(
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
                                Text('Existing Conditions', style: TextStyle(fontSize: 24)),
                                canEdit ?  IconButton(
                                  icon: Icon(Icons.edit, color: kPrimaryColor,),
                                  onPressed: () {}
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 15,),
                            Text('Diabetes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),

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
                            Text('Metfornin 50mg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
                                  widget.reports['assessments']['lifestyle']['components']['smoking'] != null ?
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
                                  ),
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
                            Text('Body Composition', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                            SizedBox(height: 30,),

                            widget.reports['assessments']['body_composition']['components']['body_fat'] != null ?
                            Container(
                              // alignment: Alignment.topCenter,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                                      Text('Fat', style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
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
                                              Text('${widget.reports['assessments']['body_composition']['components']['body_fat']['value']} ${widget.reports['assessments']['body_composition']['components']['body_fat']['eval']}',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: ColorUtils.statusColor[widget.reports['assessments']['body_composition']['components']['body_fat']['tfl']],
                                                  ),
                                                ),
                                              SizedBox(height: 15,),
                                              Text('${widget.reports['assessments']['body_composition']['components']['body_fat']['target']}',
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
                                                  widget.reports['assessments']['body_composition']['components']['body_fat']['tfl'] == 'GREEN' ? 
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
                                                  widget.reports['assessments']['body_composition']['components']['body_fat']['tfl'] == 'AMBER' ? 
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
                                                  widget.reports['assessments']['body_composition']['components']['body_fat']['tfl'] == 'RED' ? 
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

                            widget.reports['assessments']['body_composition']['components']['hip_circ'] != null ? 
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
                                      Text('Hip Circumference', style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
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
                                              Text('${widget.reports['assessments']['body_composition']['components']['hip_circ']['value']} ${widget.reports['assessments']['body_composition']['components']['hip_circ']['eval']}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: ColorUtils.statusColor[widget.reports['assessments']['body_composition']['components']['hip_circ']['tfl']] ?? Colors.black
                                                ),
                                              ),
                                              SizedBox(height: 15,),
                                              Text('${widget.reports['assessments']['body_composition']['components']['hip_circ']['target']}',
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
                                                  widget.reports['assessments']['body_composition']['components']['hip_circ']['tfl'] == 'GREEN' ? 
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
                                                  widget.reports['assessments']['body_composition']['components']['hip_circ']['tfl'] == 'AMBER' ? 
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
                                                  widget.reports['assessments']['body_composition']['components']['hip_circ']['tfl'] == 'RED' ? 
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

                            widget.reports['assessments']['body_composition']['components']['bmi'] != null ? 
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
                                              Text('${widget.reports['assessments']['body_composition']['components']['bmi']['value']} ${widget.reports['assessments']['body_composition']['components']['bmi']['eval']}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: ColorUtils.statusColor[widget.reports['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black,

                                                ),
                                              ),
                                              SizedBox(height: 15,),
                                              Text('${widget.reports['assessments']['body_composition']['components']['bmi']['target']}',
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
                                                  widget.reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'GREEN' ? 
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
                                                  widget.reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'AMBER' ? 
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
                                                  widget.reports['assessments']['body_composition']['components']['bmi']['tfl'] == 'RED' ? 
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

                            SizedBox(height: 30,),

                            Container(
                              
                              child: Text('Weight reduction', style: TextStyle(fontSize: 18,),),
                            )

                          ],
                        )
                      ),

                      widget.reports['assessments']['blood_pressure'] != null ?
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
                                    Text('${widget.reports['assessments']['blood_pressure']['value']}   ${widget.reports['assessments']['blood_pressure']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[widget.reports['assessments']['blood_pressure']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${widget.reports['assessments']['blood_pressure']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                            color: kPrimaryGreenColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['blood_pressure']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
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
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['blood_pressure']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) : 
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kPrimaryRedColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['blood_pressure']['tfl'] == 'RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
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

                            Text("${widget.reports['assessments']['blood_pressure']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),
                            
                          ],
                        )
                      ) : 
                      Container(),

                      widget.reports['assessments']['diabetes'] != null ?
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
                                    Text('${widget.reports['assessments']['diabetes']['value']}   ${widget.reports['assessments']['diabetes']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[widget.reports['assessments']['diabetes']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${widget.reports['assessments']['diabetes']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                            color: kPrimaryGreenColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['diabetes']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
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
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['diabetes']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) : 
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kPrimaryRedColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['diabetes']['tfl'] == 'RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
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

                            Text("${widget.reports['assessments']['diabetes']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),
                            
                          ],
                        )
                      ) : 
                      Container(),

                      widget.reports['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
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
                                    Text('${widget.reports['assessments']['cholesterol']['components']['total_cholesterol']['value']}   ${widget.reports['assessments']['cholesterol']['components']['total_cholesterol']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[widget.reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${widget.reports['assessments']['diabetes']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                            color: kPrimaryGreenColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
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
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) : 
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kPrimaryRedColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
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

                            Text("${widget.reports['assessments']['cholesterol']['components']['total_cholesterol']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),
                            
                          ],
                        )
                      ) : 
                      Container(),

                      widget.reports['assessments']['cvd'] != null ?
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
                                    Text('${widget.reports['assessments']['cvd']['value']}   ${widget.reports['assessments']['cvd']['eval']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ColorUtils.statusColor[widget.reports['assessments']['cvd']['tfl']] ?? Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Text('${widget.reports['assessments']['cvd']['target']}', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                            color: kPrimaryGreenColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['cvd']['tfl'] == 'GREEN' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
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
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['cvd']['tfl'] == 'AMBER' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryAmberColor,),
                                          ) : 
                                          Container(),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            color: kPrimaryRedColor,
                                            height: 14,
                                            width: 57,
                                          ),
                                          widget.reports['assessments']['cvd']['tfl'] == 'RED' ?
                                          Container(
                                            child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
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

                            Text("${widget.reports['assessments']['cvd']['message']}", style: TextStyle(fontSize: 18, height: 1.5),),
                            
                          ],
                        )
                      ) : 
                      Container(),
                  
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
        )
      )
    
    );

    
  }
}

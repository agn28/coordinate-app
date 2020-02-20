import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_medication_screen.dart';

class CarePlanDetailsScreen extends CupertinoPageRoute {
  var carePlans;
  CarePlanDetailsScreen({this.carePlans})
      : super(builder: (BuildContext context) => CarePlanDetails(carePlans: carePlans));
}

class CarePlanDetails extends StatefulWidget {
  var carePlans;
  CarePlanDetails({this.carePlans});
  @override
  _CarePlanDetailsState createState() => _CarePlanDetailsState();
}

class _CarePlanDetailsState extends State<CarePlanDetails> {
  var reports;
  bool isLoading = false;
  bool canEdit = false;
  final commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getReports();
  }

  getReports() async {
    isLoading = true;
    var data = await HealthReportController().getLastReport();
    
    if (data['error'] == true) {
      setState(() {
        isLoading = false;
      });
      Toast.show('No Health assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        isLoading = false;
        reports = data['data'];
      });
    }
    print('sadljaslkd');
    // print(result'body']['assessments']);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Care Plan', style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            widget.carePlans != null && !isLoading ?
            Column(
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
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: <Widget>[
                      Text('Generated on Jan 5, 2019', style: TextStyle(fontSize: 16),),
                      SizedBox(width: 60,),
                      Text('Last modified on Jan 10, 2019', style: TextStyle(fontSize: 16),)
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: kBorderLight)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Summary', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                      SizedBox(height: 20,),
                      reports != null ?
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Fat', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['body_fat']['value']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['body_fat']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                             ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['body_fat']['eval']}', 
                                              style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['body_fat']['tfl']] ?? Colors.black, 
                                                fontWeight: FontWeight.w500
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 35,),

                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Tobacco Use', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['lifestyle']['components']['smoking']['eval']}', 
                                              style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['lifestyle']['components']['smoking']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 35,),

                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Physical Activity', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['lifestyle']['components']['physical_activity']['eval']}', 
                                              style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['lifestyle']['components']['physical_activity']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            )
                                            
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 35,),

                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Fasting Blood Sugar', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['diabetes']['value']}',
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['diabetes']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['diabetes']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['diabetes']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('BMI', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['bmi']['value']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['bmi']['eval']}', 
                                            style: TextStyle(
                                              fontSize: 14, 
                                              color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 35,),

                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Alcohol Consumption', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['lifestyle']['components']['alcohol']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['lifestyle']['components']['alcohol']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 35,),

                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Blood Pressure', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['blood_pressure']['value']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['blood_pressure']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['blood_pressure']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['blood_pressure']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 35,),

                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Total Cholesterol', style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['value']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                ],
                              ),
                            )
                          ],
                        ),
                      ) : Container(),
                    ],
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: kBorderLight)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Interventions', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                      SizedBox(height: 20,),

                      ...widget.carePlans.map<Widget>((item) => 
                        Interventions(carePlan: item),
                      ).toList(),
                      SizedBox(height: 25,),

                      // Container(
                      //   padding: EdgeInsets.symmetric(vertical: 25),
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     color: kBackgroundGrey,
                      //     borderRadius: BorderRadius.circular(3)                     
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: <Widget>[
                      //       Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 25,),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             Text('Goal', style: TextStyle(color: kTextGrey),),
                      //             SizedBox(height: 10,),
                      //             Text('Decrease cholesterol levels', style: TextStyle(fontSize: 19),),
                      //           ],
                      //         )
                      //       ),
                      //       SizedBox(height: 30,),
                      //       Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 25,),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             Text('Intervention', style: TextStyle(color: kTextGrey),),
                      //             SizedBox(height: 10,),
                      //             Text('Counselling about reduced salt intake', style: TextStyle(fontSize: 19),),
                      //           ],
                      //         )
                      //       ),

                      //       SizedBox(height: 30,),
                      //       Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 25,),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             Text('When', style: TextStyle(color: kTextGrey),),
                      //             SizedBox(height: 10,),
                      //             Text('Within 1 month of recommendation of goal', style: TextStyle(fontSize: 19),),
                      //           ],
                      //         )
                      //       ),
                      //       SizedBox(height: 20,),
                      //       Divider(),
                      //       SizedBox(height: 15,),
                      //       GestureDetector(
                      //         onTap: () {
                      //           Navigator.of(context).push(CarePlanInterventionScreen());
                      //         },
                      //         child: Container(
                      //           padding: EdgeInsets.symmetric(horizontal: 25,),
                      //           child: Row(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //             children: <Widget>[
                      //               Text('Pending', style: TextStyle(color: kPrimaryRedColor, fontSize: 19),),
                      //               Icon(Icons.arrow_forward, color: kPrimaryColor,)
                      //             ],
                      //           )
                      //         ),
                      //       ),
                      //     ],
                      //   )
                      // ),
                    
                    ]
                  )
                ),

                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     border: Border(
                //       bottom: BorderSide(color: kBorderLight)
                //     )
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       Text('Medications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                //       SizedBox(height: 20,),
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.of(context).push(CarePlanMedicationScreen());
                //         },
                //         child: Container(
                //           padding: EdgeInsets.symmetric(horizontal: 25,),
                //           height: 70,
                //           decoration: BoxDecoration(
                //             color: kBackgroundGrey
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: <Widget>[
                //               Text('Napa 12 mg', style: TextStyle(fontSize: 19),),
                //               Icon(Icons.arrow_forward, color: kPrimaryColor,)
                //             ],
                //           )
                //         ),
                //       ),
                //       SizedBox(height: 20,),
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.of(context).push(CarePlanMedicationScreen());
                //         },
                //         child: Container(
                //           padding: EdgeInsets.symmetric(horizontal: 25,),
                //           height: 70,
                //           decoration: BoxDecoration(
                //             color: kBackgroundGrey
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: <Widget>[
                //               Text('Metfornim 50 mg', style: TextStyle(fontSize: 19),),
                //               Icon(Icons.arrow_forward, color: kPrimaryColor,)
                //             ],
                //           )
                //         ),
                //       ),
                //     ]
                //   )
                // ),

                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     border: Border(
                //       bottom: BorderSide(color: kBorderLight)
                //     )
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       Text('Followup', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                //       SizedBox(height: 20,),
                //       Text('After 3 months', style: TextStyle(fontSize: 19),)
                //     ]
                //   )
                // ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: double.infinity,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child: FlatButton(
                      onPressed: () {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text('GENERATE PATIENT CARD', style: TextStyle(fontSize: 15, color: Colors.white),)
                    ),
                  ),
                )
                
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
        ),
      ),
    );
  }
}

class Interventions extends StatefulWidget {
  var carePlan;
  Interventions({this.carePlan});

  @override
  InterventionsState createState() => InterventionsState();
}

class InterventionsState extends State<Interventions> {
  var status;

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  getStatus() {
    setState(() {
      status = widget.carePlan['body']['status'];
      print(status);
    });
  }

  setStatus() {
    setState(() {
      status = 'completed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25),
      margin: EdgeInsets.only(bottom: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kBackgroundGrey,
        borderRadius: BorderRadius.circular(3)                     
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.carePlan['body']['goal'] != null ?
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Goal', style: TextStyle(color: kTextGrey),),
                SizedBox(height: 10,),
                Text(widget.carePlan['body']['goal']['title'], style: TextStyle(fontSize: 19),),
              ],
            )
          ) : Container(),
          SizedBox(height: 30,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Intervention', style: TextStyle(color: kTextGrey),),
                SizedBox(height: 10,),
                Text(widget.carePlan['body']['title'], style: TextStyle(fontSize: 19),),
              ],
            )
          ),

          // SizedBox(height: 30,),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 25,),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Text('When', style: TextStyle(color: kTextGrey),),
          //       SizedBox(height: 10,),
          //       Text('Within 1 month of recommendation of goal', style: TextStyle(fontSize: 19),),
          //     ],
          //   )
          // ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: () {
              if (widget.carePlan['body']['status'] == null) {
                Navigator.of(context).push(CarePlanInterventionScreen(carePlan: widget.carePlan, parent: this));
              }
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                // color: Colors.red,
                border: Border(
                  top: BorderSide(color: kBorderLighter)
                )
              ),
              padding: EdgeInsets.symmetric(horizontal: 25,),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('${status != null ? status[0].toUpperCase() + status.substring(1) : 'Pending'}', style: TextStyle(color: status != null ? kPrimaryGreenColor : kPrimaryRedColor, fontSize: 19, height: .5),),
                  Icon(Icons.arrow_forward, color: kPrimaryColor,)
                ],
              )
            ),
          ),
        ],
      )
    );
  }
}

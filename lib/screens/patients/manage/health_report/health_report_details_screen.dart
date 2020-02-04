import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/health_report/health_report_success_screen.dart';

class HealthReportDetailsScreen extends CupertinoPageRoute {
  HealthReportDetailsScreen()
      : super(builder: (BuildContext context) => new HealthReportDetail());

}

class HealthReportDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Health Assessment', style: TextStyle(color: Colors.white),),
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
                          Text(Patient().getPatient()['data']['name'], style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text('${Patient().getPatient()['data']['age']}Y ${Patient().getPatient()['data']['gender'].toUpperCase()}', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
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
                        Text('Existing Conditions', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 25,),
                        Text('Diabetes', style: TextStyle(fontSize: 18)),

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Current Medications', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 25,),
                        Text('Metfornin 50mg', style: TextStyle(fontSize: 18)),

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Lifestyle', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 25,),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: kPrimaryRedColor,
                                      radius: 30,
                                      child: Image.asset('assets/images/icons/smoker.png', )
                                    ),
                                    SizedBox(height: 7,),
                                    Text('Smoker', style: TextStyle(fontSize: 18, height: 1.4),),
                                    Text('Yes', style: TextStyle(fontSize: 18, color: kPrimaryRedColor, height: 2),),
                                  ],
                                )
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: kPrimaryYellowColor,
                                      radius: 30,
                                      child: Image.asset('assets/images/icons/alcohol.png', )
                                    ),
                                    SizedBox(height: 7,),
                                    Text('Alcohol \n Consumption', style: TextStyle(fontSize: 18, height: 1.4), textAlign: TextAlign.center,),
                                    Text('Medium', style: TextStyle(fontSize: 18, color: kPrimaryYellowColor, height: 2),),
                                  ],
                                )
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: kPrimaryGreenColor,
                                      radius: 30,
                                      child: Image.asset('assets/images/icons/fruit.png', )
                                    ),
                                    SizedBox(height: 7,),
                                    Text('Fruit Consumption', style: TextStyle(fontSize: 18, height: 1.4),),
                                    Text('Hight', style: TextStyle(fontSize: 18, color: kPrimaryGreenColor, height: 2),),
                                  ],
                                )
                              ),
                            ],
                          )
                        ),

                        SizedBox(height: 30,),

                        Container(
                          alignment: Alignment.topCenter,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: kPrimaryGreenColor,
                                      radius: 30,
                                      child: Image.asset('assets/images/icons/vegetables.png', )
                                    ),
                                    SizedBox(height: 7,),
                                    Text('Vegetable \n Consumption', style: TextStyle(fontSize: 18, height: 1.4), textAlign: TextAlign.center,),
                                    Text('High', style: TextStyle(fontSize: 18, color: kPrimaryGreenColor, height: 2),),
                                  ],
                                )
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: kPrimaryRedColor,
                                      radius: 30,
                                      child: Image.asset('assets/images/icons/activity.png', )
                                    ),
                                    SizedBox(height: 7,),
                                    Text('Physical Activity', style: TextStyle(fontSize: 18, height: 1.4), textAlign: TextAlign.center,),
                                    Text('Low Activity', style: TextStyle(fontSize: 18, color: kPrimaryRedColor, height: 2),),
                                  ],
                                )
                              ),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          )
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 30),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Stop Smoking', style: TextStyle(fontSize: 18, height: 1.5),),
                              Text('Reduce alcohol consumption', style: TextStyle(fontSize: 18, height: 1.5),),
                              Text('Eat more fruits', style: TextStyle(fontSize: 18, height: 1.5),),
                              Text('Aim for regular exercise, 30 minutes a day', style: TextStyle(fontSize: 18, height: 1.5),),
                            ],
                          ),
                        )

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Body Composition', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 20,),

                        Container(
                          // alignment: Alignment.topCenter,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('BMI', style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w500),),
                                    Text('31.5  Overweight', style: TextStyle(fontSize: 18, height: 1.8, color: kPrimaryRedColor),),
                                    Text('18.5 to 24.9', style: TextStyle(fontSize: 18, color: kTextGrey, height: 1.6),),
                                    SizedBox(height: 20,),
                                    Row(
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
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              color: kPrimaryYellowColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryYellowColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: kPrimaryRedColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            Container(
                                              child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                            )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                )
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Hip/Waist Ratio', style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w500),),
                                    Text('1.29  Borderline', style: TextStyle(fontSize: 18, height: 1.8, color: kPrimaryRedColor),),
                                    Text('0.5 - 24.9', style: TextStyle(fontSize: 18, color: kTextGrey, height: 1.6),),
                                    SizedBox(height: 20,),
                                    Row(
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
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              color: kPrimaryYellowColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            Container(
                                              child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryYellowColor,),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: kPrimaryRedColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                            // )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                )
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20,),

                        Container(
                          // alignment: Alignment.topCenter,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Fat', style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w500),),
                                    Text('5% High', style: TextStyle(fontSize: 18, height: 1.8, color: kPrimaryRedColor),),
                                    Text('18.5 to 24.9', style: TextStyle(fontSize: 18, color: kTextGrey, height: 1.6),),
                                    SizedBox(height: 20,),
                                    Row(
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
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              color: kPrimaryYellowColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryYellowColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: kPrimaryRedColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            Container(
                                              child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                            )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                )
                              ),

                              Expanded(
                                child: Column()
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          margin: EdgeInsets.only(top: 30),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Eat a balanced diet', style: TextStyle(fontSize: 18,),),
                            ],
                          ),
                        )

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Blood Pressure', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 20,),

                        Container(
                          // alignment: Alignment.topCenter,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('110/180  Normal', style: TextStyle(fontSize: 18, height: 1.8, color: kPrimaryGreenColor),),
                                    Text('130/180', style: TextStyle(fontSize: 18, color: kTextGrey, height: 1.6),),
                                    SizedBox(height: 20,),
                                    Row(
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
                                            Container(
                                              child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              color: kPrimaryYellowColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryYellowColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: kPrimaryRedColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                            // )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                )
                              ),

                              Expanded(
                                child: Column()
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          margin: EdgeInsets.only(top: 30),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Since you're on medications, your BP needs to be controlled", style: TextStyle(fontSize: 18,),),
                            ],
                          ),
                        )

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Diabetes', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 20,),

                        Container(
                          // alignment: Alignment.topCenter,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Blood Sugar', style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w500),),
                                    Text('5.9 Pre-diabetes', style: TextStyle(fontSize: 18, height: 1.8, color: kPrimaryYellowColor),),
                                    Text('5.2 to 5.5', style: TextStyle(fontSize: 18, color: kTextGrey, height: 1.6),),
                                    SizedBox(height: 20,),
                                    Row(
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
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              color: kPrimaryYellowColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            Container(
                                              child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryYellowColor,),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: kPrimaryRedColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                            // )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                )
                              ),

                              Expanded(
                                child: Column()
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          margin: EdgeInsets.only(top: 30),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("You're at a risk of developing diabetes Manage your sugar intake", style: TextStyle(fontSize: 18,),),
                            ],
                          ),
                        )

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Cholesterol', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 20,),

                        Container(
                          // alignment: Alignment.topCenter,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Total Cholesterol', style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w500),),
                                    Text('55 mmol/L', style: TextStyle(fontSize: 18, height: 1.8, color: kPrimaryRedColor),),
                                    Text('18.5 t 24.9', style: TextStyle(fontSize: 18, color: kTextGrey, height: 1.6),),
                                    SizedBox(height: 20,),
                                    Row(
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
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              color: kPrimaryYellowColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            Container(
                                              child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryYellowColor,),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: kPrimaryRedColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                            // )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                )
                              ),

                              Expanded(
                                child: Column()
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          margin: EdgeInsets.only(top: 30),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Look at guidelines for recommendations. Treat based on CVD risk rules.", style: TextStyle(fontSize: 18,),),
                            ],
                          ),
                        )

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Cardiovascular Risk', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 20,),

                        Container(
                          // alignment: Alignment.topCenter,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Your 10 years risk', style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w500),),
                                    Text('20% Low', style: TextStyle(fontSize: 18, height: 1.8, color: kPrimaryRedColor),),
                                    Text('20-30%', style: TextStyle(fontSize: 18, color: kTextGrey, height: 1.6),),
                                    SizedBox(height: 20,),
                                    Row(
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
                                            Container(
                                              child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              color: kPrimaryYellowColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryYellowColor,),
                                            // )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: kPrimaryRedColor,
                                              height: 14,
                                              width: 57,
                                            ),
                                            // Container(
                                            //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryRedColor,),
                                            // )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                )
                              ),

                              Expanded(
                                child: Column()
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          margin: EdgeInsets.only(top: 30),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("This means that over the next 10 years, your risk of having a heart attack or stroke is approximately 10%, putting you in the low risk population", style: TextStyle(fontSize: 18, height: 1.5),),
                            ],
                          ),
                        )

                      ],
                    )
                  ),
                
                ],
              )
            ),
            
            SizedBox(height: 30,),

          ],
        ),
      ),
    );
  }
}

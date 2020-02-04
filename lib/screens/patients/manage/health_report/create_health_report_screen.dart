import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/health_report/health_report_success_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';


class CreateHealthReportScreen extends CupertinoPageRoute {
  CreateHealthReportScreen()
      : super(builder: (BuildContext context) => new CreateHealthReport());

}

class CreateHealthReport extends StatelessWidget {
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
                            IconButton(
                              icon: Icon(Icons.edit, color: kPrimaryColor,),
                              onPressed: () {}
                            ),
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
                            IconButton(
                              icon: Icon(Icons.edit, color: kPrimaryColor,),
                              onPressed: () {}
                            ),
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
                            children: <Widget>[
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
                                            child: Image.asset('assets/images/icons/icon_smoker.png', ),
                                          ),
                                          GestureDetector(
                                            child: Icon(Icons.edit, color: kPrimaryColor,),
                                            onTap: () {}
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Text('Tobacco Use', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Smoker', style: TextStyle(color: kPrimaryRedColor, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Quite Tobacco Use', style: TextStyle(fontSize: 14,),)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
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
                                            child: Image.asset('assets/images/icons/icon_alcohol.png', ),
                                          ),
                                          GestureDetector(
                                            child: Icon(Icons.edit, color: kPrimaryColor,),
                                            onTap: () {}
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Text('Alcohol Consumption', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Moderate', style: TextStyle(color: kPrimaryOrangeColor, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Quite Alcohol Consumption', style: TextStyle(fontSize: 14,),)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          child: Row(
                            children: <Widget>[
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
                                            child: Image.asset('assets/images/icons/icon_fruits.png', ),
                                          ),
                                          GestureDetector(
                                            child: Icon(Icons.edit, color: kPrimaryColor,),
                                            onTap: () {}
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Text('Fruits and vegetables intake', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Adequate', style: TextStyle(color: kPrimaryGreenColor, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Maintain current status', style: TextStyle(fontSize: 14,),)
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
                                          GestureDetector(
                                            child: Icon(Icons.edit, color: kPrimaryColor,),
                                            onTap: () {}
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Text('Physical Activity', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Inadequate', style: TextStyle(color: kPrimaryOrangeColor, fontSize: 19, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      Text('Increase physical activity', style: TextStyle(fontSize: 14,),)
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                        bottom: BorderSide(width: 1, color: kBorderLighter)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Body Composition', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                        SizedBox(height: 30,),

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
                                  GestureDetector(
                                      onTap: () {},
                                      child: Icon(Icons.edit, color: kPrimaryColor,),
                                    )
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
                                          Text('5% High', style: TextStyle(fontSize: 18, color: kPrimaryRedColor),),
                                          SizedBox(height: 15,),
                                          Text('18.5 to 24.9', style: TextStyle(fontSize: 14, color: kTextGrey),)
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
                                              // Container(
                                              //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                              // )
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(right: 10),
                                                color: kPrimaryOrangeColor,
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
                                    )
                                  )
                                ],
                              ),
                              
                            ],
                          ),
                        ),

                        SizedBox(height: 25,),
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
                                  Text('Hip Circumference', style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                                  GestureDetector(
                                      onTap: () {},
                                      child: Icon(Icons.edit, color: kPrimaryColor,),
                                    )
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
                                          Text('99 cm Borderline', style: TextStyle(fontSize: 18, color: kPrimaryOrangeColor),),
                                          SizedBox(height: 15,),
                                          Text('80 cm - 100 cm', style: TextStyle(fontSize: 14, color: kTextGrey),)
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
                                              // Container(
                                              //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                              // )
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(right: 10),
                                                color: kPrimaryOrangeColor,
                                                height: 14,
                                                width: 57,
                                              ),
                                              Container(
                                                child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryOrangeColor,),
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
                                    )
                                  )
                                ],
                              ),
                              
                            ],
                          ),
                        ),

                        SizedBox(height: 25,),
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
                                  Text('BMI', style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                                  GestureDetector(
                                      onTap: () {},
                                      child: Icon(Icons.edit, color: kPrimaryColor,),
                                    )
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
                                          Text('31.4 Overweight', style: TextStyle(fontSize: 18, color: kPrimaryRedColor),),
                                          SizedBox(height: 15,),
                                          Text('18.5 to 24.9', style: TextStyle(fontSize: 14, color: kTextGrey),)
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
                                              // Container(
                                              //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                              // )
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(right: 10),
                                                color: kPrimaryOrangeColor,
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
                                    )
                                  )
                                ],
                              ),
                              
                            ],
                          ),
                        ),

                        SizedBox(height: 30,),

                        Container(
                          
                          child: Text('Weight reduction', style: TextStyle(fontSize: 18,),),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Blood Pressure', style: TextStyle(fontSize: 24)),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.edit, color: kPrimaryColor)
                            )
                          ],
                        ),
                        SizedBox(height: 20,),

                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('140/95 mmHg   Hypertensive', style: TextStyle(fontSize: 18, color: kPrimaryOrangeColor),),
                                SizedBox(height: 15,),
                                Text('< 130/180 mmHg', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                      // Container(
                                      //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                      // )
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryOrangeColor,
                                        height: 14,
                                        width: 57,
                                      ),
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryOrangeColor,),
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
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),

                        Text("Since you're on medications, your BP needs to be controlled", style: TextStyle(fontSize: 18,),),
                        
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Diabetes', style: TextStyle(fontSize: 24)),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.edit, color: kPrimaryColor)
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Text('Fasting Blood Sugar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                        SizedBox(height: 15,),

                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('120 mg/dL   Pre-diabetes', style: TextStyle(fontSize: 18, color: kPrimaryOrangeColor),),
                                SizedBox(height: 15,),
                                Text('< 100 mg/dL', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                      // Container(
                                      //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                      // )
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryOrangeColor,
                                        height: 14,
                                        width: 57,
                                      ),
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryOrangeColor,),
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
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),

                        Text("Improve glycemic control", style: TextStyle(fontSize: 18,),),
                        
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Cholesterol', style: TextStyle(fontSize: 24)),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.edit, color: kPrimaryColor)
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Text('Total Cholesterol', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                        SizedBox(height: 15,),

                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('250 mg/dL   High', style: TextStyle(fontSize: 18, color: kPrimaryRedColor),),
                                SizedBox(height: 15,),
                                Text('< 100 mg/dL', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                      // Container(
                                      //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                      // )
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryOrangeColor,
                                        height: 14,
                                        width: 57,
                                      ),
                                      // Container(
                                      //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryOrangeColor,),
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
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),

                        Text("Look at guidelines for recommendations. Treat based on CVD risk rules", style: TextStyle(fontSize: 18,),),
                        
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Cardiovascular Risk', style: TextStyle(fontSize: 24)),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.edit, color: kPrimaryColor)
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Text('Your 10 years risk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                        SizedBox(height: 15,),

                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('10% to 20%   Low', style: TextStyle(fontSize: 18, color: kPrimaryGreenColor),),
                                SizedBox(height: 15,),
                                Text('< 100 mg/dL', style: TextStyle(fontSize: 14, color: kTextGrey,),)
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
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryGreenColor,),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryOrangeColor,
                                        height: 14,
                                        width: 57,
                                      ),
                                      // Container(
                                      //   child: Icon(Icons.arrow_drop_up, size: 40, color: kPrimaryOrangeColor,),
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
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),

                        Text("Maintain current lifestyle", style: TextStyle(fontSize: 18,),),
                        
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
                        Text('Referral Required', style: TextStyle(fontSize: 24, color: kPrimaryRedColor)),
                        SizedBox(height: 20,),
                        Text('Generate a referral before submitting.', style: TextStyle(fontSize: 20, height: 1.4),),
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
                                Text('Generate Referral', style: TextStyle(fontSize: 18, color: kPrimaryColor),)
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
                      style: TextStyle(color: Colors.white, fontSize: 20.0,),

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
                            child: Text('CANCEL', style: TextStyle(fontSize: 14),)
                          ),
                        ),

                        SizedBox(height: 20,),

                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFF00838F),
                            borderRadius: BorderRadius.circular(3)
                          ),
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).push(HealthReportSuccessScreen());
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            child: Text('CONFIRM ASSESSMENT', style: TextStyle(fontSize: 14, color: Colors.white),)
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
                            onPressed: () {},
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            child: Text('SEND FOR DOCTOR REVIEW', style: TextStyle(fontSize: 14, color: Colors.white),)
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
        ),
      ),
    );
  }
}

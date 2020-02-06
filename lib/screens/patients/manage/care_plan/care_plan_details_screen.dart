import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_medication_screen.dart';

class CarePlanDetailsScreen extends CupertinoPageRoute {
  CarePlanDetailsScreen()
      : super(builder: (BuildContext context) => CarePlanDetails());
}

class CarePlanDetails extends StatelessWidget {
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
                                        Text('5%', style: TextStyle(fontSize: 14, color: kPrimaryRedColor, fontWeight: FontWeight.w500),),
                                        SizedBox(width: 40,),
                                        Text('High', style: TextStyle(fontSize: 14, color: kPrimaryRedColor, fontWeight: FontWeight.w500),)
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
                                        Text('Smoker', style: TextStyle(fontSize: 14, color: kPrimaryRedColor, fontWeight: FontWeight.w500),),
                                        
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
                                        Text('Inadequate', style: TextStyle(fontSize: 14, color: kPrimaryOrangeColor, fontWeight: FontWeight.w500),),
                                        
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
                                        Text('120 mg/dL', style: TextStyle(fontSize: 14, color: kPrimaryOrangeColor, fontWeight: FontWeight.w500),),
                                        SizedBox(width: 40,),
                                        Text('Pre-diabetes', style: TextStyle(fontSize: 14, color: kPrimaryOrangeColor, fontWeight: FontWeight.w500),)
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
                                        Text('31.4', style: TextStyle(fontSize: 14, color: kPrimaryRedColor, fontWeight: FontWeight.w500),),
                                        SizedBox(width: 40,),
                                        Text('Overweight', style: TextStyle(fontSize: 14, color: kPrimaryRedColor, fontWeight: FontWeight.w500),)
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
                                        Text('Moderate', style: TextStyle(fontSize: 14, color: kPrimaryOrangeColor, fontWeight: FontWeight.w500),),
                                        
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
                                        Text('140/95 mmHg', style: TextStyle(fontSize: 14, color: kPrimaryOrangeColor, fontWeight: FontWeight.w500),),
                                        SizedBox(width: 40,),
                                        Text('Hypertensive', style: TextStyle(fontSize: 14, color: kPrimaryOrangeColor, fontWeight: FontWeight.w500),)
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
                                        Text('250 mg/dL', style: TextStyle(fontSize: 14, color: kPrimaryRedColor, fontWeight: FontWeight.w500),),
                                        SizedBox(width: 40,),
                                        Text('High', style: TextStyle(fontSize: 14, color: kPrimaryRedColor, fontWeight: FontWeight.w500),)
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
                  ),
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

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kBackgroundGrey,
                      borderRadius: BorderRadius.circular(3)                     
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Goal', style: TextStyle(color: kTextGrey),),
                              SizedBox(height: 10,),
                              Text('Improve blood pressure control', style: TextStyle(fontSize: 19),),
                            ],
                          )
                        ),
                        SizedBox(height: 30,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Intervention', style: TextStyle(color: kTextGrey),),
                              SizedBox(height: 10,),
                              Text('Counselling about reduced salt intake', style: TextStyle(fontSize: 19),),
                            ],
                          )
                        ),

                        SizedBox(height: 30,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('When', style: TextStyle(color: kTextGrey),),
                              SizedBox(height: 10,),
                              Text('Within 1 month of recommendation of goal', style: TextStyle(fontSize: 19),),
                            ],
                          )
                        ),
                        SizedBox(height: 20,),
                        Divider(),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(CarePlanInterventionScreen());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 25,),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Completed on Jan 10 2019', style: TextStyle(color: kPrimaryGreenColor, fontSize: 19),),
                                Icon(Icons.arrow_forward, color: kPrimaryColor,)
                              ],
                            )
                          ),
                        ),
                      ],
                    )
                  ),

                  SizedBox(height: 25,),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kBackgroundGrey,
                      borderRadius: BorderRadius.circular(3)                     
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Goal', style: TextStyle(color: kTextGrey),),
                              SizedBox(height: 10,),
                              Text('Decrease cholesterol levels', style: TextStyle(fontSize: 19),),
                            ],
                          )
                        ),
                        SizedBox(height: 30,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Intervention', style: TextStyle(color: kTextGrey),),
                              SizedBox(height: 10,),
                              Text('Counselling about reduced salt intake', style: TextStyle(fontSize: 19),),
                            ],
                          )
                        ),

                        SizedBox(height: 30,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('When', style: TextStyle(color: kTextGrey),),
                              SizedBox(height: 10,),
                              Text('Within 1 month of recommendation of goal', style: TextStyle(fontSize: 19),),
                            ],
                          )
                        ),
                        SizedBox(height: 20,),
                        Divider(),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(CarePlanInterventionScreen());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 25,),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Pending', style: TextStyle(color: kPrimaryRedColor, fontSize: 19),),
                                Icon(Icons.arrow_forward, color: kPrimaryColor,)
                              ],
                            )
                          ),
                        ),
                      ],
                    )
                  ),
                ]
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
                  Text('Medications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                  SizedBox(height: 20,),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(CarePlanMedicationScreen());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 25,),
                      height: 70,
                      decoration: BoxDecoration(
                        color: kBackgroundGrey
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Napa 12 mg', style: TextStyle(fontSize: 19),),
                          Icon(Icons.arrow_forward, color: kPrimaryColor,)
                        ],
                      )
                    ),
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(CarePlanMedicationScreen());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 25,),
                      height: 70,
                      decoration: BoxDecoration(
                        color: kBackgroundGrey
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Metfornim 50 mg', style: TextStyle(fontSize: 19),),
                          Icon(Icons.arrow_forward, color: kPrimaryColor,)
                        ],
                      )
                    ),
                  ),
                ]
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
                  Text('Followup', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                  SizedBox(height: 20,),
                  Text('After 3 months', style: TextStyle(fontSize: 19),)
                ]
              )
            ),

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
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_generate_screen.dart';
import 'package:nhealth/widgets/primary_button_widget.dart';

class CarePlanListScreen extends CupertinoPageRoute {
  CarePlanListScreen()
      : super(builder: (BuildContext context) => new CarePlanList());
}

class CarePlanList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Health Report', style: TextStyle(color: Colors.white),),
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
                          Text('Jahanara Begum', style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text('31Y Female', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
                  ),
                  Expanded(
                    child: Text('PID: N-1216657773', style: TextStyle(fontSize: 18))
                  )
                ],
              ),
            ),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 40),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: .5, color: Color(0x50000000))
                )
              ),
              child: Row(
                children: <Widget>[
                  Text('Generaated on Jan 5, 2019', style: TextStyle(fontSize: 16),),
                  SizedBox(width: 60,),
                  Text('Last modified on Jan 10, 2019', style: TextStyle(fontSize: 16),)
                ],
              ),
            ),
            
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
                          child: Text('Action', style: TextStyle(fontSize: 17),),
                        ),
                        Expanded(
                          child: Text('Status', style: TextStyle(fontSize: 17,),),
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
            
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: .5, color: Colors.black38)
                )
              ),
              child: FlatButton(
                onPressed: () => Navigator.of(context).push(CarePlanGenerateScreen()),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text(AppLocalizations.of(context).translate('dietAdvise'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                          ),
                          Expanded(
                            child: Text(AppLocalizations.of(context).translate('completedOn') + ' Jan 10 2019', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kPrimaryGreenColor),),
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

            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: .5, color: Colors.black38)
                )
              ),
              child: FlatButton(
                onPressed: () => Navigator.of(context).push(CarePlanGenerateScreen()),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text(AppLocalizations.of(context).translate('smokingAdvise'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                          ),
                          Expanded(
                            child: Text(AppLocalizations.of(context).translate('pending'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400, color: kPrimaryRedColor),),
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

            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: .5, color: Colors.black38)
                )
              ),
              child: FlatButton(
                onPressed: () => Navigator.of(context).push(CarePlanGenerateScreen()),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text('3 month follow-up', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                          ),
                          Expanded(
                            child: Text('Pending', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400, color: kPrimaryRedColor),),
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

            SizedBox(height: 30,),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: PrimaryButton(
                onTap: () {},
                text: Text('GENERATE PATIENT CARD', style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ),
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

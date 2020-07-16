import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/health_report/health_report_details_screen.dart';

class PastHealthReportScreen extends CupertinoPageRoute {
  PastHealthReportScreen()
      : super(builder: (BuildContext context) => new PastHealthReport());

}

class PastHealthReport extends StatefulWidget {

  @override
  _PastHealthReportState createState() => _PastHealthReportState();
}

class _PastHealthReportState extends State<PastHealthReport> {

  var reports = [];
  var fetchedReports = [];
  bool isLoading = false;
  List<Widget> list = List<Widget>();
  bool avatarExists = false;

  @override
  void initState() {
    super.initState();
    _getAssessments();
    _checkAvatar();
  }

  _checkAvatar() async {
    var data = await File(Patient().getPatient()['data']['avatar']).exists();
    setState(() {
      avatarExists = data;
    });
  }

  _getAssessments() async {
    setState(() {
      isLoading = true;
    });
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
    var response = await HealthReportController().getReports();

    if (response['error']) {
      if (response['message'] == 'No matching documents.') {
        return Toast.show('No Assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
      }
      return Toast.show('Server Error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }
    

    if(response != null && response['message'] == 'Unauthorized') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }

    reports = response['data'];

    if (reports != null) {
      reports.forEach((item){
        setState(() {
          var date = '';
          if(item['report_date'] != null && item['report_date']['_seconds'] != null) {
            var parseddate = DateTime.fromMillisecondsSinceEpoch(item['report_date']['_seconds'] * 1000);
            date = DateFormat('MMMM d, yyyy').format(parseddate);
          }
          list.add(
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: .5, color: Colors.black38)
                )
              ),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).push(HealthReportDetailsScreen(reports: item['result']));
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text(date, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                          ),
                          Expanded(
                            child: Text('', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
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
          );
        });
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('pastHealthAssessments'), style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
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
                              Patient().getPatient()['data']['avatar'] == null || !avatarExists ? 
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: kLightPrimaryColor,
                                  shape: BoxShape.circle
                                ),
                                child: Icon(Icons.perm_identity),
                              ) :
                              CircleAvatar(
                                radius: 17,
                                backgroundImage: FileImage(File(Patient().getPatient()['data']['avatar'])),
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
                              child: Text(reports == null ? 'No data found' : 'Date', style: TextStyle(fontSize: 17),),
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

                SizedBox(height: 30,),

              ],
            ),
            
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

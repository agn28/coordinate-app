import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'chcp_feeling_screen.dart';
import 'new_visit/new_visit_chcp_feeling_screen.dart';


class ChcpPatientSummaryScreen extends StatefulWidget {
  var checkInState = false;
  ChcpPatientSummaryScreen({this.checkInState});
  @override
  _ChcpPatientSummaryScreenState createState() => _ChcpPatientSummaryScreenState();
}

class _ChcpPatientSummaryScreenState extends State<ChcpPatientSummaryScreen> {
  var _patient;
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  bool avatarExists = false;
  var lastAssessment;
  var nextVisitDate = '';
  String lastEncounterType = '';
  String lastEncounterDate = '';
  String incompleteEncounterDate = '';
  var encounter;
  bool hasIncompleteAssessment = false;

  @override
  void initState() {
    super.initState();

    _patient = Patient().getPatient();
    
    _checkAvatar();
    _checkAuth();
    
    getIncompleteAssessment();
    getLastAssessment();
  }

  getIncompleteAssessment() async {
    var patientId = Patient().getPatient()['id'];
    encounter = await AssessmentController().getIncompleteAssessmentsByPatient(patientId);

    if(encounter.isNotEmpty && (encounter.last['data']['type'] == 'new questionnaire' || (encounter.last['data']['type'] == 'community clinic assessment' && encounter.last['local_status'] == 'incomplete'))) {

      setState(() {
        hasIncompleteAssessment = true;
        incompleteEncounterDate = DateFormat("MMMM d, y").format(DateTime.parse(encounter.last['meta']['created_at']));
        isLoading = false;
      });
    } else {

      setState(() {
        hasIncompleteAssessment = false;
        isLoading = false;
      });
    }
  }

  getDate(date) {
    if (date.runtimeType == String && date != null && date != '') {
      try{
        return DateFormat("MMMM d, y").format(DateTime.parse(date)).toString();
      } on FormatException {
        return 'invalid data format';
      } 
    } else if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);

      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  getLastAssessment() async {
    lastAssessment = await AssessmentController().getLastAssessmentByPatient();
    if(lastAssessment != null && lastAssessment.isNotEmpty) {
      setState(() {
        nextVisitDate = lastAssessment['data']['body']['next_visit_date'] != null && lastAssessment['data']['body']['next_visit_date'] != '' ? DateFormat("MMMM d, y").format(DateTime.parse(lastAssessment['data']['body']['next_visit_date'])):'';
        lastEncounterType = lastAssessment['data']['body']['type'];
        lastEncounterDate = getDate(lastAssessment['data']['meta']['created_at']);
      });
    }
    
  }

  _checkAvatar() async {
    avatarExists = await File(Patient().getPatient()['data']['avatar']).exists();
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('patientSummary'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[

        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: kBorderLighter)
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Patient().getPatient()['data']['avatar'] == '' ? 
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30.0),
                                      child: Image.asset(
                                        'assets/images/avatar.png',
                                        height: 70.0,
                                        width: 70.0,
                                      ),
                                    ) :
                                    CircleAvatar(
                                      radius: 30,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30.0),
                                        child: Image.network(
                                          Patient().getPatient()['data']['avatar'],
                                          height: 70.0,
                                          width: 70.0,
                                          errorBuilder: (BuildContext context,
                                              Object exception, StackTrace stackTrace) {
                                            return Image.asset(
                                              'assets/images/avatar.png',
                                              height: 70.0,
                                              width: 70.0,
                                            );
                                          },
                                        ),
                                      ),
                                      backgroundImage: AssetImage('assets/images/avatar.png'),
                                    ),

                                    SizedBox(width: 20,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(Helpers().getPatientName(_patient), style: TextStyle( fontSize: 19, fontWeight: FontWeight.w600),),
                                        SizedBox(height: 7,),
                                        Row(
                                          children: <Widget>[
                                            Text(Helpers().getPatientAgeAndGender(_patient), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                      ],
                                    ),
                                    SizedBox(width: 100,),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/chwPatientDetails');
                                },
                                child: Container(
                                  child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 35,)
                                ),
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  
                  hasIncompleteAssessment ?
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context).translate('incompleteEncounterDate')+': $incompleteEncounterDate', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                            SizedBox(height: 15,),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(ChcpFeelingScreen.path);
                                },
                                color: kPrimaryColor,
                                child: Text(AppLocalizations.of(context).translate("completePrevEncounter"), style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            SizedBox(width: 20),
                          ]
                        ),
                      ],
                    )
                  ) : Container(),
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: kBorderLighter),
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).translate('lastEncounter')+'${(lastEncounterType)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        SizedBox(height: 15,),
                        Text(AppLocalizations.of(context).translate('lastEncounterDate')+'$lastEncounterDate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 4, color: kBorderLighter)
                      ),
                    ),
                    padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[

                            ],
                          ),
                        ),
                        widget.checkInState != null && widget.checkInState ? Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                          height: 50,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(3)
                          ),
                          child: FlatButton(
                            onPressed: () async {
                              showDialog(
                                context: _scaffoldKey.currentContext,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      width: double.infinity,
                                      height: 160.0,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            width: 350,
                                            alignment: Alignment.center,
                                            child: Text(AppLocalizations.of(context).translate('medicalIssueInVisit'), style: TextStyle(
                                            fontSize: 22
                                          ), textAlign: TextAlign.center,),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: kPrimaryRedColor,
                                                    borderRadius: BorderRadius.circular(3)
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.of(context).pushNamed('/reportMedicalIssues');
                                                    },
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    child: Text(AppLocalizations.of(context).translate("yes"), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: kPrimaryGreenColor,
                                                    borderRadius: BorderRadius.circular(3)
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      var result = '';
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      await Future.delayed(const Duration(seconds: 5));
                                                      result = await AssessmentController().create('visit', 'follow-up', '');
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Navigator.of(_scaffoldKey.currentContext).pushNamed('/chwNavigation');
                                                    },
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    child: Text(AppLocalizations.of(context).translate("NO"), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            child: Text(AppLocalizations.of(context).translate('completeVisit'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                          ),
                        ) : Container(),
                      ],
                    )
                  ),
                  SizedBox(height: 15,),
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
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context){
              return Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 50,
                    right: 0,
                    child: AlertDialog(
                      contentPadding: EdgeInsets.all(0),
                      elevation: 0,
                      content: Container(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            hasIncompleteAssessment ?
                            FloatingButton(text: AppLocalizations.of(context).translate('updateLastEncounter'), onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(ChcpFeelingScreen.path);
                            }, ) : Container(),
                            FloatingButton(
                              text: AppLocalizations.of(context).translate('newVisit'), 
                              onPressed: () {
                                Navigator.of(context).pushNamed(NewVisitChcpFeelingScreen.path);
                              },
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  )
                ],
              );
            }
          );
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: kPrimaryColor,
            boxShadow: [
              new BoxShadow(
                offset: Offset(0.0, 1.0),
                color: Color(0xFF000000),
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Center(
            child: Icon(Icons.add, color: Colors.white,),
          ),
        ),
      ),
    );
  }
}

class FloatingButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const FloatingButton({this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      width: 300,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            Icon(Icons.add),
            SizedBox(width: 10,),
            Text(text, style: TextStyle(fontSize: 17),)
          ],
        ),
      )
    );
  }
}
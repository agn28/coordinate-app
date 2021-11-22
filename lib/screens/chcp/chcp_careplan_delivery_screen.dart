import 'dart:io';
// import 'package:basic_utils/basic_utils.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import 'package:expandable/expandable.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/user_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/counselling_framwork_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/couselling_confirmation_screen.dart';

import 'chcp_counselling_confirmation_screen.dart';

var dueCarePlans = [];
var cpUpdateCount = 0;
var completedCarePlans = [];
var upcomingCarePlans = [];
var referrals = [];
var pendingReferral;

class ChcpCareplanDeliveryScreen extends StatefulWidget {
  var checkInState = false;
  static const String path = '/chcpCareplanDelivery';
  ChcpCareplanDeliveryScreen({this.checkInState});
  @override
  _ChcpCareplanDeliveryScreenState createState() => _ChcpCareplanDeliveryScreenState();
}

class _ChcpCareplanDeliveryScreenState extends State<ChcpCareplanDeliveryScreen> {
  var _patient;
  bool isLoading = false;
  var carePlans = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  bool avatarExists = false;
  var encounters = [];
  String lastEncounterdDate = '';
  String lastAssessmentdDate = '';
  String lastCarePlanDate = '';
  var conditions = [];
  var medications = [];
  var allergies = [];
  var users = [];
  var report;
  var bmi;
  var cholesterol;
  var bp;
  var cvd;
  int interventionIndex = 0;
  bool actionsActive = false;
  bool carePlansEmpty = false;
  var dueDate = '';

  @override
  void initState() {
    super.initState();

    _patient = Patient().getPatient();
    dueCarePlans = [];
    cpUpdateCount = 0;
    completedCarePlans = [];
    upcomingCarePlans = [];
    conditions = [];
    referrals = [];
    pendingReferral = null;
    carePlansEmpty = false;

    
    _checkAvatar();
    _checkAuth();
    _getCarePlan();
    
  }

  getStatus(item) {
    var status = 'completed';
    item['items'].forEach( (goal) {
      if (goal['meta']['status'] == 'pending') {
        setState(() {
          status = 'pending';
        });
      }
    });

    return status;
  }

  getCount(item) {
    var count = 0;

    item['items'].forEach( (goal) {
      setState(() {
        count += 1;
      });
    });
    

    return count.toString();
  }


  getUser(uid) {
    var user = users.where((user) => user['uid'] == uid);
    if (user.isNotEmpty) {
      return user.first['name'];
    }

    return '';
  }

  getCompletedDate(goal) {
    var data = '';
    DateTime date;
    // print(goal['items']);
    goal['items'].forEach((item) {
      // print(item['body']['activityDuration']['end']);
      DateFormat format = new DateFormat("E LLL d y");
      var endDate;
      try {
        endDate = format.parse(item['body']['activityDuration']['end']);
      } catch(err) {
        endDate = DateTime.parse(item['body']['activityDuration']['end']);
      }
      // print(endDate);
      date = endDate;
      if (date != null) {
        date  = endDate;
      } else {
        if (endDate.isBefore(date)) {
          date = endDate;
        }
      }
      
    });
    if (date != null) {
      var test = DateFormat('MMMM d, y').format(date);
      data = 'Complete By ' + test;
    }
    return data;
  }


  getDueCounts() {
    var goalCount = 0;
    var actionCount = 0;
    carePlans.forEach((item) {
      if(item['meta']['status'] == 'pending') {
        goalCount = goalCount + 1;
        if (item['body']['components'] != null) {
          actionCount = actionCount + item['body']['components'].length;
        }
      }
    });

    return "$goalCount goals & $actionCount actions";
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

  _getCarePlan() async {
    var data = await CarePlanController().getCarePlan();
    if (data != null) {
      // print( data['data']);
      // DateTime.parse(localAuth['expirationTime']).add(DateTime.now().timeZoneOffset).add(Duration(hours: 12)).isBefore(DateTime.now())
      setState(() {
        carePlans = data;
      });

      carePlans.forEach( (item) {

        DateFormat format = new DateFormat("E LLL d y");
        
        var todayDate = DateTime.now();

        var endDate;
        var startDate;

        try {
          endDate = format.parse(item['body']['activityDuration']['end']);
          startDate = format.parse(item['body']['activityDuration']['start']);
        } catch(err) {

          DateFormat newFormat = new DateFormat("yyyy-MM-dd");
          endDate = DateTime.parse(item['body']['activityDuration']['end']);
          startDate = DateTime.parse(item['body']['activityDuration']['start']);
          // startDate = DateTime.parse(item['body']['activityDuration']['start']);
          
        }


        // check due careplans
        if (item['body']['category'] != null && item['body']['category'] != 'investigation') {
          if (item['meta']['status'] == 'pending') {
            if (todayDate.isAfter(startDate) && todayDate.isBefore(endDate)) {
              if(item['body']['goal'] != null){
              var existedCp = dueCarePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);

              // print(item['body']['activityDuration']['start']);

              if (existedCp.isEmpty) {
                var items = [];
                items.add(item);
                setState(() {
                  dueCarePlans.add({
                    'items': items,
                    'title': item['body']['goal']['title'],
                    'id': item['body']['goal']['id']
                  });
                });
                
              } else {
                setState(() {
                  dueCarePlans[dueCarePlans.indexOf(existedCp.first)]['items'].add(item);
                });
                
              }
              cpUpdateCount = dueCarePlans.length;
              }

            } else if (todayDate.isBefore(startDate)) {
              var existedCp = upcomingCarePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);
              // print(existedCp);
              // print(item['body']['activityDuration']['start']);

              if (existedCp.isEmpty) {
                var items = [];
                items.add(item);
                upcomingCarePlans.add({
                  'items': items,
                  'title': item['body']['goal']['title'],
                  'id': item['body']['goal']['id']
                });
              } else {
                upcomingCarePlans[upcomingCarePlans.indexOf(existedCp.first)]['items'].add(item);

              }
            }
          } else {
            var existedCp = completedCarePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);
            // print(existedCp);
            // print(item['body']['activityDuration']['start']);

            if (existedCp.isEmpty) {
              var items = [];
              items.add(item);
              completedCarePlans.add({
                'items': items,
                'title': item['body']['goal']['title'],
                'id': item['body']['goal']['id']
              });
            } else {
              completedCarePlans[completedCarePlans.indexOf(existedCp.first)]['items'].add(item);

            }
          }
        }

        
        
        // var existedCp = carePlans.where( (cp) => cp['id'] == item['body']['goal']['id']);
        // // print(existedCp);
        // // print(item['body']['activityDuration']['start']);
        

        // if (existedCp.isEmpty) {
        //   var items = [];
        //   items.add(item);
        //   carePlans.add({
        //     'items': items,
        //     'title': item['body']['goal']['title'],
        //     'id': item['body']['goal']['id']
        //   });
        // } else {
        //   carePlans[carePlans.indexOf(existedCp.first)]['items'].add(item);

        // }
      });

      // setState(() {
      //   carePlans = data['data'];
      //   isLoading = false;
      // });
    }
  }

  convertDateFromSeconds(date) {
    if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);

      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  getTitle(encounter) {
    var screening_type =  encounter['data']['screening_type'];
    if (screening_type != null && screening_type != '') {
      if (screening_type == 'ncd') {
        screening_type = screening_type.toUpperCase() + ' ';
      } else {
        screening_type = screening_type[0].toUpperCase() + screening_type.substring(1) + ' ';
      }
      
      return screening_type + 'Encounter: ' + encounter['data']['type'][0].toUpperCase() + encounter['data']['type'].substring(1);
    }
    
    return 'Encounter: ' + encounter['data']['type'][0].toUpperCase() + encounter['data']['type'].substring(1);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('deliverCarePlan'), style: TextStyle(color: Colors.white, fontSize: 20),),
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
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 4, color: kBorderLighter)
                      ),
                    ),
                    padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: Column(
                      children: <Widget>[
                        
                        dueCarePlans.length > 0 ?
                        CareplanAction(checkInState: false, carePlans: dueCarePlans, text: AppLocalizations.of(context).translate('dueToday'))
                        : Container(
                          child: Text(AppLocalizations.of(context).translate('noConfirmedCarePlan'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                        ),
                        // upcomingCarePlans.length > 0 ? CareplanAction(checkInState: widget.checkInState, carePlans: upcomingCarePlans, text: AppLocalizations.of(context).translate('upComing')) : Container(),
                        // completedCarePlans.length> 0 ? CareplanAction(checkInState: widget.checkInState, carePlans: completedCarePlans, text: AppLocalizations.of(context).translate('complete')) : Container(),

                        // SizedBox(height: 20,),


                        //previous patient history steps
                      dueCarePlans.length > 0 ?
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            if(cpUpdateCount > 0) {
                              //Navigator.of(context).pushNamed('/chwPatientSummary');
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    content: new Text(AppLocalizations.of(context).translate("carePlanActionsNotCompleted"), style: TextStyle(fontSize: 22),),
                                    actions: <Widget>[
                                      // usually buttons at the bottom of the dialog
                                      Container(  
                                        margin: EdgeInsets.all(20),  
                                        child:FlatButton(
                                          child: new Text(AppLocalizations.of(context).translate("back"), style: TextStyle(fontSize: 20),),
                                          color: kPrimaryColor,  
                                          textColor: Colors.white,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                      Container(  
                                        margin: EdgeInsets.all(20),  
                                        child:FlatButton(
                                          child: new Text(AppLocalizations.of(context).translate("continue"), style: TextStyle(fontSize: 20),),
                                          color: kPrimaryColor,  
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            // Navigator.of(context).pop();
                                            var result;
                                            setState(() {
                                              isLoading = true;
                                            });
                                            result = await AssessmentController().createOnlyAssessment(context, 'Care Plan Delivery', 'care-plan-delivered', '', 'complete', '');

                                            setState(() {
                                              isLoading = false;
                                            });
                                            Navigator.of(_scaffoldKey.currentContext).pushNamed('/chcpHome');
                                            
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              );
                            }
                            else {
                              var result;
                              setState(() {
                                isLoading = true;
                              });
                              result = await AssessmentController().createOnlyAssessment(context, 'Care Plan Delivery', 'care-plan-delivered', '', 'complete', '');

                              setState(() {
                                isLoading = false;
                              });
                              Navigator.of(_scaffoldKey.currentContext).pushNamed('/chcpHome');
                            
                              }
                            },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(AppLocalizations.of(context).translate('completeVisit'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                        ),
                      ): Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child: FlatButton(
                          onPressed: () async {
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: Text(AppLocalizations.of(context).translate('checkCarePlan'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                        ),
                      ),
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
              // Container(
              //   height: 300,
              //   width: double.infinity,
              //   color: Colors.black12,
              // )
            ],
          ),
        ),
      ),
      // floatingActionButton: GestureDetector(
      //   onTap: () {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context){
      //         return Stack(
      //           children: <Widget>[
      //             Positioned(
      //               bottom: 50,
      //               right: 0,
      //               child: AlertDialog(
      //                 contentPadding: EdgeInsets.all(0),
      //                 elevation: 0,
      //                 content: Container(
      //                   alignment: Alignment.bottomRight,
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.end,
      //                     children: <Widget>[
      //                       FloatingButton(text: AppLocalizations.of(context).translate('followUp'), onPressed: () {
      //                         // Navigator.of(context).pop();
      //                         // Navigator.of(context).pushNamed('/patientFeeling', arguments: {'communityClinic': true});
      //                       }, ),

      //                       FloatingButton(text: AppLocalizations.of(context).translate('newCommunityVisit'), onPressed: () {
      //                         Navigator.of(context).pop();
      //                         Navigator.of(context).pushNamed('/patientFeeling');
      //                       },),
      //                     ],
      //                   ),
      //                 ),
      //                 backgroundColor: Colors.transparent,
      //               ),
      //             )
      //           ],
      //         );
      //       }
      //     );
      //   },
      //   // icon: Icon(Icons.add),
      //   // label: null,
      //   // backgroundColor: kPrimaryColor,
      //   child: Container(
      //     height: 50,
      //     width: 50,
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(50),
      //       color: kPrimaryColor,
      //       boxShadow: [
      //         new BoxShadow(
      //           offset: Offset(0.0, 1.0),
      //           color: Color(0xFF000000),
      //           blurRadius: 2.0,
      //         ),
      //       ],
      //     ),
      //     child: Center(
      //       child: Icon(Icons.add, color: Colors.white,),
      //     ),
      //   ),
      // ),

      
      // floatingActionButton: widget.checkInState == null ? FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.of(context).pushNamed('/verifyPatient');
      //   },
      //   icon: Icon(Icons.add),
      //   label: Text(AppLocalizations.of(context).translate('newCommunityVisit')),
      //   backgroundColor: kPrimaryColor,
      // ) : Container(),
    );
  }
}

class GoalItem extends StatefulWidget {
  final item;
  GoalItem({ this.item });

  @override
  _GoalItemState createState() => _GoalItemState();
}

class _GoalItemState extends State<GoalItem> {
  var status = 'pending';

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  getStatus() {
    status = 'completed';
    widget.item['items'].forEach( (goal) {
      if (goal['meta']['status'] == 'pending') {
        setState(() {
          status = 'pending';
        });
      }
    });
  }
  setStatus(completedItem) {

    // set all the actions as completed
    // setState(() {
    //   dueCarePlans.remove(completedItem);
    //   var data = completedItem;
    //   data['items'].forEach( (goal) {
    //     completedItem['items'][completedItem['items'].indexOf(goal)]['meta']['status'] = 'completed';
    //   });
    //   completedCarePlans.add(completedItem);
    //   // status = 'completed';
    // });
  }
  getCount() {
    var count = 0;
    if (status == 'pending') {
      widget.item['items'].forEach( (goal) {
        if (goal['meta']['status'] == 'pending') {
          setState(() {
            count += 1;
          });
        }
      });
    } else {
      widget.item['items'].forEach( (goal) {
        setState(() {
          count += 1;
        });
      });
    }

    return count.toString();
  }
  
  getCompletedDate(goal) {
    var data = '';
    DateTime date;
    goal['items'].forEach((item) {
      // print(item['body']['activityDuration']['end']);
      DateFormat format = new DateFormat("E LLL d y");
      var endDate;
        try {
          endDate = format.parse(item['body']['activityDuration']['end']);
        } catch(err) {
          endDate = DateTime.parse(item['body']['activityDuration']['end']);
        }
      // print(endDate);
      date = endDate;
      if (date != null) {
        date  = endDate;
      } else {
        if (endDate.isBefore(date)) {
          date = endDate;
        }
      }
      
    });
    if (date != null) {
      var test = DateFormat('MMMM d, y').format(date);
      data = 'Complete By ' + test;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      padding: EdgeInsets.only(bottom: 0, top: 15, left: 15,),
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(.03),
        border: Border(
          // bottom: BorderSide(color: kBorderLighter)
        )
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                // bottom: BorderSide(color: kBorderLighter)
              )
            ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.item['title'], style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
              status != 'completed' ? Text(getCompletedDate(widget.item), style: TextStyle(fontSize: 15, color: kBorderLight)) : Container(),
              Container(
                child: Row(
                  children: <Widget>[
                    // Container(
                    //   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor),
                    //     borderRadius: BorderRadius.circular(3)
                    //   ),
                    //   child: Row(
                    //     children: <Widget>[
                    //       // Text('${report['body']['result']['actions'].length} Actions  ', style: TextStyle(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor, fontWeight: FontWeight.w500),),
                    //       Text('${getCount()}'+AppLocalizations.of(context).translate("actions"), style: TextStyle(color: status == 'pending' ? kPrimaryRedColor : kPrimaryGreenColor, fontWeight: FontWeight.w500),),
                    //       if (status != 'pending') 
                    //       Icon(Icons.check_circle, color: kPrimaryGreenColor, size: 14,)
                    //     ],
                    //   ),
                    // ),
                    // Icon(Icons.chevron_right, color: kBorderLight,)
                  ],
                ),
              ),
            ],),
          ),
        
        
          Column(
            children: <Widget>[
              ...widget.item['items'].map((item) {
                return ActionItem(item: item, parent: this);
              }).toList(),
            ],
          ),
          // Column(
          //   children: <Widget>[
          //     ...widget.item['items'].map((item) {
          //       return ActionItem(item: item, parent: this);
          //     }).toList(),
          //   ],
          // ),
        ],
      ),
    );
  }
  
  // return Container(
  //   child: Column(
  //     children: [
  //     // Container(
  //     //   width: double.infinity,
  //     //   child: Text(AppLocalizations.of(context).translate('pendingActions'), style: TextStyle( fontSize: 16),),
  //     //   padding: EdgeInsets.only(bottom: 15, left: 20),
  //     //   decoration: BoxDecoration(
  //     //     border: Border(
  //     //       bottom: BorderSide(color: kBorderLighter)
  //     //     )
  //     //   ),
  //     // ),
  //     Column(
  //       children: <Widget>[
  //         ...widget.item['items'].map((item) {
  //           return ActionItem(item: item, parent: this);
  //         }).toList(),
  //       ],
  //     ),
  //     ],
  //   ),
  // );
  // }
}
bool btnDisabled = true;
class ActionItem extends StatefulWidget {
  const ActionItem({
    this.item,
    this.parent
  });

  final item;
  final parent;

  @override
  _ActionItemState createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  String status = 'pending';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatus();
  }

  getStatus() {
    setState(() {
      status = widget.item['meta']['status'];
    });
  }

  isCounselling() {
    return widget.item['body']['title'].split(" ").contains('Counseling') || widget.item['body']['title'].split(" ").contains('Counselling');
  }

  setStatus() {
    setState(() {
      btnDisabled = false;
      status = 'completed';
      cpUpdateCount--;
    });

    widget.parent.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

        // if (isCounselling()) {
          Navigator.of(context).pushNamed(ChcpCounsellingConfirmation.path, arguments: { 'data': widget.item, 'parent': this});
          // return;
        // }
        // Navigator.of(context).pushNamed('/chwActionsSwipper', arguments: { 'data': widget.item, 'parent': this});
      },
      child: Container(
        padding: EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
        decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: kBorderLighter)
        )
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.item['body']['title'] ?? '', style: TextStyle(fontSize: 17),),
                        SizedBox(height: 15,),
                        Text(StringUtils.capitalize(status), style: TextStyle(fontSize: 14, color: status == 'completed' ? kPrimaryGreenColor : kPrimaryRedColor),),
                      ],
                    ),
                  ),
                  
                  Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                
                ],
              ),
            ),
            SizedBox(height: 20,),
            
          ],
        ),
      ),
    );
  }
}



class CareplanAction extends StatefulWidget {

  bool checkInState;
  final carePlans;
  String text = '';

  CareplanAction({this.checkInState, this.carePlans, this.text});
  @override
  _CareplanActionState createState() => _CareplanActionState();
}

class _CareplanActionState extends State<CareplanAction> {
  @override
  void initState() {
    super.initState();
    
  }

  getCount(item) {
    var count = 0;

    item['items'].forEach( (goal) {
      setState(() {
        count += 1;
      });
    });

    return count.toString();
  }

  getCompletedDate(goal) {
    var data = '';
    DateTime date;
    // print(goal['items']);
    goal['items'].forEach((item) {
      // print(item['body']['activityDuration']['end']);
      if (item['meta']['status'] != 'completed') {
        DateFormat format = new DateFormat("E LLL d y");
        var endDate;
        try {
          endDate = format.parse(item['body']['activityDuration']['end']);
        } catch(err) {
          endDate = DateTime.parse(item['body']['activityDuration']['end']);
        }
        
        // print(endDate);
        date = endDate;
        if (date != null) {
          date  = endDate;
        } else {
          if (endDate.isBefore(date)) {
            date = endDate;
          }
        }
      }
      
    });
    if (date != null) {
      var test = DateFormat('MMMM d, y').format(date);
      data = 'Complete By ' + test;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ...widget.carePlans.map( (item) {                     
                      return GoalItem(item: item);
                    }).toList()
                    
                  ],
                ),
              ),
              
            ],
          ),
        ),

      ],
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

class CustomClipPath extends CustomClipper<Path> {
  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0.0);
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

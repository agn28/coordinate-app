import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/screens/chw/counselling_framework/counselling_framwork_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/couselling_confirmation_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/unwell/continue_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

bool btnDisabled = true;


class ImproveBpControlScreen extends StatefulWidget {
  final data;
  final parent;
  ImproveBpControlScreen({this.data, this.parent});
  @override
  _ImproveBpControlState createState() => _ImproveBpControlState();
}

class _ImproveBpControlState extends State<ImproveBpControlScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;
  String videoId = '';

  var bloodPressures = [];

  var reports = [];
  List<YoutubePlayerController> _youtubeControllers = [];

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    btnDisabled = true;

    // _getVideoUrl();

    getReports();

  }

  loadingState(value) {
    setState(() {
      isLoading = value;
    });
  }

  getReports() async {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }

    loadingState(true);
    // var data;
    // var data = await HealthReportController().getReports();
    var data = await HealthReportController().getReports();
    loadingState(false);
    if (data['message'] == 'Unauthorized') {
      await Helpers().logout(context);
    } else {
      setState(() {
        reports = data['data'];
      });
    }

    reports.forEach((report) {
      var data = {};
      if (report['result']['assessments']['blood_pressure'] != null) {
        var parsedDate = DateTime.fromMillisecondsSinceEpoch(report['report_date']['_seconds'] * 1000);
        var date = DateFormat('MMM d, y').format(parsedDate);
        data = report['result']['assessments']['blood_pressure'];
        data['date'] = date;
        bloodPressures.add(data);
      }
    });

  }
  getCount() {
    var completedCount = 0;
    var count = 0;

    widget.data['items'].forEach( (goal) {
      count += 1;
      if (goal['meta']['status'] == 'completed') {
        completedCount += 1;
      }
    });
    

    return '$completedCount/$count Actions are Completed';
  }
  _getVideoUrl() async {

    widget.data['itmes']['body']['components'].forEach( (items) {
      items.forEach( (item) {
        if (item['type'] == 'video') {
          var videoId = YoutubePlayer.convertUrlToId(item['uri']);
          _youtubeControllers.add(YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(
              autoPlay: false,
            ),
          )
        );
        }
      });
    });

  }

  _checkAvatar() async {
    avatarExists = await File(Patient().getPatient()['data']['avatar']).exists();
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Helpers().logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.data['title'], style: TextStyle(color: Colors.black87, fontSize: 20),),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(RegisterPatientScreen(isEdit: true));
            },
            child: Container(
              margin: EdgeInsets.only(right: 30),
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit, color: Colors.white,),
                  SizedBox(width: 10),
                  Text(getCount(), style: TextStyle(color: kTextGrey))
                ],
              )
            )
          )
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              
              Column(
                children: <Widget>[
                  PatientTopbar(),
                  SizedBox(height: 40,),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(AppLocalizations.of(context).translate("bpReadings"), style: TextStyle(fontSize: 16),),
                        
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),


                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kBorderLighter, width: 5)
                      )
                    ),
                    child: Row(
                      children: <Widget>[
                        ...bloodPressures.map((bp) {
                          return Container(
                            padding: EdgeInsets.only(left: 20, right: 20, bottom: 15,),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: kBorderLighter)
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(bp['date'],style: TextStyle(color: kTextGrey),),
                                SizedBox(height: 7,),
                                Row(
                                  children: <Widget>[
                                    Text(bp['value'],style: TextStyle(color: ColorUtils.statusColor[bp['tfl']], fontSize: 18,),),
                                    SizedBox(width: 5,),
                                    Icon(Icons.arrow_downward, size: 14, color: ColorUtils.statusColor[bp['tfl']],)
                                  ],
                                ),
                                SizedBox(height: 12,),
                              ],
                            ),
                          );
                        }).toList()
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(AppLocalizations.of(context).translate('pendingActions'), style: TextStyle( fontSize: 16),),
                    padding: EdgeInsets.only(bottom: 15, top: 15, left: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kBorderLighter)
                      )
                    ),
                  ),


                  Column(
                    children: <Widget>[
                      ...widget.data['items'].map((item) {
                        return ActionItem(item: item, parent: this);
                        }).toList(),

                    ],
                  ),

                  SizedBox(height: 20,),

                  // Container(
                  //   margin: EdgeInsets.only(left: 20.0),
                  //   height: 120.0,
                  //   child: ListView(
                  //     scrollDirection: Axis.horizontal,
                  //     children: <Widget>[
                  //       ..._youtubeControllers.map((item) {
                  //         return Container(
                  //           width: 200.0,
                  //           color: Colors.red,
                  //           child: VideoPlayer(controller: item,)
                  //         );
                  //       }).toList(),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 20,),



                    SizedBox(height: 20,),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(left: 30, right: 10),
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: kPrimaryColor)
                              ),
                              child: FlatButton(
                                onPressed: () async {
                                  Navigator.of(context).pushNamed('/chwPatientSummary', arguments: true);
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.normal),)
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(right: 30, left: 10),
                              height: 50,
                              decoration: BoxDecoration(
                                color: btnDisabled ? kTextGrey : kPrimaryColor,
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: FlatButton(
                                onPressed: () async {
                                  // widget.widget.parent.setState(() {
                                  //   widget.widget.parent.setStatus();
                                  // });
                                  // Navigator.of(context).pop();
                                  if (!btnDisabled) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    var response = 'success';
                                    await Future.forEach(widget.data['items'], (item) async {
                                      if (item['meta']['status'] == 'pending') {
                                        response = await CarePlanController().update(context, item, '');
                                      }
                                    });
                                    
                                    setState(() {
                                      isLoading = false;
                                    });
                                    
                                    if (response == 'success') {
                                      widget.parent.setState(() {
                                        widget.parent.setStatus(widget.data);
                                      });
                                      Navigator.of(context).pop();
                                    } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                                  }
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(AppLocalizations.of(context).translate('completeGoal'), style: TextStyle(fontSize: 14, color: btnDisabled ? Colors.white54 : Colors.white, fontWeight: FontWeight.normal),)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    );
  }
}

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
    });
    widget.parent.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isCounselling()) {
          Navigator.of(context).pushNamed(CounsellingFrameworkScreen.path, arguments: { 'data': widget.item, 'parent': this});
          return;
        }
        Navigator.of(context).pushNamed('/chwActionsSwipper', arguments: { 'data': widget.item, 'parent': this});
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.item['body']['title'] ?? '', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                    SizedBox(height: 15,),
                    Text("${status[0].toUpperCase()}${status.substring(1)}", style: TextStyle(fontSize: 14, color: status == 'completed' ? kPrimaryGreenColor : kPrimaryRedColor),),
                  ],
                ),
                
                Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
              
              ],
            ),
            SizedBox(height: 20,),
            // ...item['body']['components'].map((comp) {
            //   if (comp['type'] == 'video') {
            //     return Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Container(
            //           height: 130,
            //           width: 250,
            //           child: VideoPlayer(component: comp),
            //         ),
            //         Row(
            //           children: <Widget>[
            //             Checkbox(
            //               activeColor: kPrimaryColor,
            //               value: item['meta']['status'] == 'completed',
            //               onChanged: (value) {
            //                 setState(() {
            //                   if (value) {
            //                     item['meta']['status'] = 'completed';
            //                   } else {
            //                     item['meta']['status'] = 'pending';
            //                   }
            //                 });
            //               },
            //             ),
            //             Text('Patient has watched at least one of these videos', style: TextStyle(fontSize: 16),)
                        
            //           ],
            //         ),
            //       ],
            //     );
            //   } else if (item['body']['title'] == 'Repeat measurement of BP in community') {
            //     return Container(
            //       margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                     
            //       child: Form(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: <Widget>[
            //             SizedBox(height: 20,),
            //             Container(
            //               child: Wrap(
            //                 children: <Widget>[
            //                   Container(
            //                     width: 200,
            //                     child: PrimaryTextField(
            //                       hintText: 'Systolic',
            //                       topPaadding: 10,
            //                       bottomPadding: 10,
            //                     ),
            //                   ),
            //                   SizedBox(width: 20,),
            //                   Container(
            //                     width: 200,
            //                     child: PrimaryTextField(
            //                       hintText: 'DIastolic',
            //                       topPaadding: 10,
            //                       bottomPadding: 10,
            //                     ),
            //                   ),
            //                   Container(
            //                     width: 200,
            //                     child: PrimaryTextField(
            //                       hintText: 'Pulse',
            //                       topPaadding: 10,
            //                       bottomPadding: 10,
            //                     ),
            //                   ),
            //                   SizedBox(width: 20,),
            //                 ],
            //               ),
            //             ),
            //             Container(
            //               alignment: Alignment.center,
            //               child: PrimaryTextField(
            //                 hintText: 'Select a device',
            //                 topPaadding: 10,
            //                 bottomPadding: 10,
            //               ),
            //             ),

            //           ],
            //         ),
            //       )
            //     );
            //   } else {
            //     return Container();
            //   }
            // })
          
          ],
        ),
      ),
    );
  }
}


class VideoPlayer extends StatefulWidget {
  VideoPlayer({
    this.component,
  });

  final component;

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  YoutubePlayerController _youtubeController;
  @override
  void initState() {
    super.initState();
    getVideoUrl();
  }
  
  getVideoUrl() {

      // videoId = YoutubePlayer.convertUrlToId("https://www.youtube.com/watch?v=prE6Ty2qDq8");
    var videoId = YoutubePlayer.convertUrlToId(widget.component['uri']);
    _youtubeController  = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      color: Colors.red,
      child: YoutubePlayer(
        onEnded: (data) {

        } ,
        
        controller: _youtubeController,
        liveUIColor: Colors.amber,
        progressColors: ProgressBarColors(
          playedColor: Colors.amber,
          handleColor: Colors.amberAccent,
        ),
    
      ),
    );
  }
}

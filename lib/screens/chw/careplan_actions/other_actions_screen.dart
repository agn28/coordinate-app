import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class OtherActionsScreen extends StatefulWidget {
  final data;
  final parent;
  OtherActionsScreen({this.data, this.parent});

  @override
  _OtherActionsScreenState createState() => _OtherActionsScreenState();
}

class _OtherActionsScreenState extends State<OtherActionsScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;
  String videoId = '';
  YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    _getVideoUrl();

  }
  _getVideoUrl() async {

      setState(() {
        videoId = YoutubePlayer.convertUrlToId("https://www.youtube.com/watch?v=prE6Ty2qDq8");
        var url = widget.data['body']['components'].where((item) => item['type'] == 'video');
        if (url.isNotEmpty) {
          videoId = YoutubePlayer.convertUrlToId(url.first['uri']);
        }
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,
          ),
        );
      });

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
      appBar: new AppBar(
        title: new Text(widget.data['body']['goal']['title'], style: TextStyle(color: Colors.black87, fontSize: 20),),
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
                  Text('0/2 Actions completed', style: TextStyle(color: kTextGrey))
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

                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Counsel about reduced salt intake', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                        Text('Completed', style: TextStyle(fontSize: 14, color: kPrimaryGreenColor),),
                       
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    height: 120.0,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Container(
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    padding: EdgeInsets.only(bottom: 10, left: 3),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 5, color: kBorderLighter)
                      )
                    ),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          activeColor: kPrimaryColor,
                          value: true,
                          onChanged: (value) {
                            setState(() {
                              // widget.form = value;
                            });
                          },
                        ),
                        Text('Patient has watched at least one of these videos', style: TextStyle(fontSize: 16),)
                        
                      ],
                    ),
                  ),

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
                                child: Text('CANCEL', style: TextStyle(fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.normal),)
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(right: 30, left: 10),
                              height: 50,
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: FlatButton(
                                onPressed: () async {
                                  // widget.widget.parent.setState(() {
                                  //   widget.widget.parent.setStatus();
                                  // });
                                  // Navigator.of(context).pop();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var response = await CarePlanController().update(widget.data, '');
                                  print(response);
                                  setState(() {
                                    isLoading = false;
                                  });
                                  
                                  if (response == 'success') {
                                    widget.parent.setState(() {
                                      widget.parent.setStatus();
                                    });
                                    Navigator.of(context).pop();
                                  } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text('COMPLETE GOAL', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
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




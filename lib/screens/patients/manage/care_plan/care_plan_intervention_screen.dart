import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/body-measurements/height_screen.dart';
import 'package:nhealth/widgets/primary_button_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CarePlanInterventionScreen extends CupertinoPageRoute {
  final carePlan;
  final parent;
  CarePlanInterventionScreen({this.carePlan, this.parent})
      : super(builder: (BuildContext context) => CarePlanIntervention(carePlan: carePlan, parent: parent));

}

class CarePlanIntervention extends StatefulWidget {
  final carePlan;
  final parent;
  CarePlanIntervention({this.carePlan, this.parent});
  @override
  _CarePlanInterventionState createState() => _CarePlanInterventionState();
}

class _CarePlanInterventionState extends State<CarePlanIntervention> {
  YoutubePlayerController _youtubeController;

  bool form = false;
  bool videoWatched = false;
  bool isLoading = false;
  final commentController = TextEditingController();
  String videoUrl = '';
  String videoId = '';
  String formUrl = '';

  @override
  initState() {
    super.initState();
    print(widget.carePlan);
    _getVideoUrl();
    _getFormUrl();
  }

  _getFormUrl() {
    var form = widget.carePlan['body']['components'].where((item) => item['type'] == 'form');

    if (form.isNotEmpty) {
      setState(() {
        formUrl = form.first['uri'];
      });
    }
    
  }

  _getVideoUrl() {
    var video = widget.carePlan['body']['components'].where((item) => item['type'] == 'video');

    if (video.isNotEmpty) {
      setState(() {
        // videoId = YoutubePlayer.convertUrlToId("https://www.youtube.com/watch?v=prE6Ty2qDq8");
        videoId = YoutubePlayer.convertUrlToId(video.first['uri']);
        _youtubeController  = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
          ),
        );
        videoUrl = video.first != null ? video.first['uri'] : '';
      });
    }

    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Intervention', style: TextStyle(color: Colors.white),),
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

                formUrl != '' ?
                Container(
                  height: 70,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 17),
                  decoration: BoxDecoration(
                    
                  ),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        activeColor: kPrimaryColor,
                        value: form,
                        onChanged: (value) {
                          setState(() {
                            form = value;
                          });
                        },
                      ),
                      Text('Fill up the form',  style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: () async {
                          
                        },
                        child: Text('Click here', 
                          style: TextStyle(
                            fontSize: 16,
                            color: kPrimaryColor,
                            decoration: TextDecoration.underline
                          )
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox(height: 40),

                videoUrl != '' ? Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 17, bottom: 30),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        activeColor: kPrimaryColor,
                        value: videoWatched,
                        onChanged: (value) {
                          setState(() {
                            videoWatched = value;
                          });
                        },
                      ),
                      Text('Watch the video',  style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                elevation: 0.0,
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  // height: 300,
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: YoutubePlayer(
                                    onEnded: (data) {
                                      print(data);
                                      setState(() {
                                        videoWatched = true;
                                      });
                                    } ,
                                    
                                    controller: _youtubeController,
                                    liveUIColor: Colors.amber,
                                    progressColors: ProgressBarColors(
                                    playedColor: Colors.amber,
                                    handleColor: Colors.amberAccent,
                                ),
                                
                                  ),
                                ),
                              );
                            },
                          ).then((value) {
                            print('closed');
                            _youtubeController.reset();
                          });
                        },
                        child: Text(videoUrl, 
                          style: TextStyle(
                            fontSize: 16,
                            color: kPrimaryColor,
                            decoration: TextDecoration.underline
                          )
                        ),
                      ),
                    ],
                  ),
                ) : Container(),
                
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                    controller: commentController,
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
                
                SizedBox(height: 30,),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: PrimaryButton(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      var response = await CarePlanController().update(widget.carePlan, commentController.text);
                      print('hello' + response);
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
                    text: Text('MARK AS COMPLETE', style: TextStyle(color: Colors.white, fontSize: 16),),
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

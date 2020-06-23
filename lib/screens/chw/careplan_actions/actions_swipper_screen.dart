import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/chw/unwell/severity_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_button_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
String videoUrl = '';

class ActionsSwipperScreen extends StatefulWidget {
  final carePlan;
  final parent;
  ActionsSwipperScreen({this.carePlan, this.parent});
  @override
  _ActionsSwipperState createState() => _ActionsSwipperState();
}

class _ActionsSwipperState extends State<ActionsSwipperScreen> {
  YoutubePlayerController _youtubeController;

  PageController _controller = PageController(
    initialPage: 0,
  );


  bool form = false;
  bool videoWatched = false;
  bool isLoading = false;
  final commentController = TextEditingController();
  String videoUrl = '';
  String videoId = '';
  String formUrl = '';
  List<Widget> pages = [];
  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    videoUrl = '';

    print(widget.carePlan['body']['title']);
    _getVideoUrl();
    // _getFormUrl();
    createPages();
  }

  _getFormUrl() {
    var form = widget.carePlan['body']['components'].where((item) => item['type'] == 'form');

    if (form.isNotEmpty) {
      setState(() {
        formUrl = form.first != null ? form.first['uri'] : '';
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
            autoPlay: false,
          ),
        );
        videoUrl = video.first != null ? video.first['uri'] : '';
      });
    }

  }

  createPages() {
    print(widget.carePlan['body']['id']);
    if (widget.carePlan['body']['id'] == 'a4') {
      setState(() {
        pages.add(
          Form4()
        );
      });
    }
    // if (widget.carePlan['body']['id'] == 'a4') {
    //   setState(() {
    //     pages.add(
    //       Form4()
    //     );
    //   });
    // } if (widget.carePlan['body']['id'] == 'a8') {
    //   setState(() {
    //     pages.add(
    //       Form8()
    //     );
    //   });
    // } if (widget.carePlan['body']['id'] == 'a16') {
    //   setState(() {
    //     pages.add(
    //       Form16()
    //     );
    //   });
    // } 
    // else if (formUrl != '') {
    //   setState(() {
    //     pages.add(
    //       FormContainer(form: form)
    //     );
    //   });
    // }

    if (videoUrl != '') {
      setState(() {
        pages.add(
          VideoContainer(youtubeController: _youtubeController, title: _youtubeController.metadata.title, carePlan: widget.carePlan)
        );
      });
    }

    setState(() {
      pages.add(
        CommentContainer(commentController: commentController, widget: widget),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.carePlan['body']['title'], style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: 400,
          color: Color(0xFFefefef),
          child: Column(
            children: <Widget>[
              PatientTopbar(),
              Container(
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    new BoxShadow(
                      offset: Offset(0.0, 0.0),
                      color: Color(0x20000000),
                      blurRadius: 2.0,
                    ),
                  ],
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * .7,
                  child: Stack(
                    children: <Widget>[
                      PageView(
                        controller: _controller,
                        onPageChanged: (value) {
                          setState(() {
                            currentPage = value;
                          });
                        },
                        children: pages  
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * .1,
                child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: 10,
                      alignment: Alignment.bottomCenter,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: pages.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.lens, size: 15, 
                              color: currentPage == index ? kPrimaryColor : kStepperDot,
                            )
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Form4 extends StatefulWidget {
  const Form4({
    Key key,
  }) : super(key: key);

  @override
  _Form4State createState() => _Form4State();
}

class _Form4State extends State<Form4> {

  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  String selectedArm = 'left';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: BoxDecoration(
          
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('What is your blood pressure reading?', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 15,),
                  Row(
                    children: <Widget>[
                      // SizedBox(width: 20,),
                      
                      Radio(
                        activeColor: kPrimaryColor,
                        value: 'left',
                        groupValue: selectedArm,
                        onChanged: (val) {
                          setState(() {
                            selectedArm = val;
                          });
                        },
                      ),
                      Text('Left Arm', style: TextStyle(fontSize: 15),),

                      Radio(
                        activeColor: kPrimaryColor,
                        value: 'right',
                        groupValue: selectedArm,
                        onChanged: (val) {
                          setState(() {
                            selectedArm = val;
                          });
                        },
                      ),
                      Text(
                        'Right Arm',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: PrimaryTextField(
                          topPaadding: 10,
                          bottomPadding: 10,
                          controller: systolicController,
                          hintText: 'Systolic',
                          type: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                        child: PrimaryTextField(
                          controller: diastolicController,
                          topPaadding: 10,
                          bottomPadding: 10,
                          hintText: 'Diastolic',
                          type: TextInputType.number
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20,),

                  Container(
                    padding: EdgeInsets.symmetric(vertical:15),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: kPrimaryColor)
                    ),
                    child: InkWell(
                      onTap: () async {
                        var result = BloodPressure().addBpPreparedItems(selectedArm, int.parse(systolicController.text), int.parse(diastolicController.text), '');
                        if (result == 'success') {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text('Data added'),
                              backgroundColor: Color(0xFF4cAF50),
                            )
                          );
                          await Future.delayed(const Duration(seconds: 1));
                          // Navigator.of(context).pop();
                        } else {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text(result.toString()),
                              backgroundColor: kPrimaryRedColor,
                            )
                          );
                        }
                      },
                      child: Text('Add Blood Presure', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),),
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}

class Form8 extends StatelessWidget {
  const Form8({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('What is your total cholesterol?', style: TextStyle(fontSize: 17),),
                    SizedBox(width: 15,),
                    Text('(add in mg/dL)', style: TextStyle(fontSize: 14),),
                  ],
                ),
                SizedBox(height: 15,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: '',
                        type: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

class Form16 extends StatelessWidget {
  const Form16({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('What is your blood sugar?', style: TextStyle(fontSize: 17),),
                    SizedBox(width: 15,),
                    Text('(add in mg/dL)', style: TextStyle(fontSize: 14),),
                  ],
                ),
                SizedBox(height: 15,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: '',
                        type: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                Text('When the blood sugar is taken?', style: TextStyle(fontSize: 17),),
                SizedBox(height: 15,),
                DropdownButtonFormField(
                  validator: (value) {
                    if (value == null) {
                      // return AppLocalizations.of(context).translate('relationshipRequired');
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kSecondaryTextField,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    )
                  ),
                  ),
                  items: [
                      DropdownMenuItem(
                        child: Text('Fasting'),
                        value: 'fasting'
                      ),
                      DropdownMenuItem(
                        child: Text('Random'),
                        value: 'random'
                      )
                    ,
                  ],
                  value: 'fasting',
                  isExpanded: true,
                  onChanged: (value) {
                    // setState(() {
                    //   selectedRelation = value;
                    // });
                  },
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

class VideoConfirmForm extends StatelessWidget {
  const VideoConfirmForm({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Row(
                  children: <Widget>[
                    // SizedBox(width: 20,),
                    Radio(
                      activeColor: kPrimaryColor,
                      value: 'yes',
                      groupValue: 'yes',
                      onChanged: (val) {
                        // setState(() {
                        //   selectedArm = val;
                        // });
                      },
                    ),
                    Text('Yes', style: TextStyle(fontSize: 15),),

                    Radio(
                      activeColor: kPrimaryColor,
                      value: 'no',
                      groupValue: 'yes',
                      onChanged: (val) {
                        // setState(() {
                        //   selectedArm = val;
                        // });
                      },
                    ),
                    Text(
                      'No',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Text('What did you learn?', style: TextStyle(fontSize: 17),),
                SizedBox(height: 15,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}


class CommentContainer extends StatefulWidget {
  const CommentContainer({
    Key key,
    @required this.commentController,
    @required this.widget,
  }) : super(key: key);

  final TextEditingController commentController;
  final ActionsSwipperScreen widget;

  @override
  _CommentContainerState createState() => _CommentContainerState();
}

class _CommentContainerState extends State<CommentContainer> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
            controller: widget.commentController,
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
            
              hintText: 'What did the patient learn? (optional)',
              hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
            ),
          ),

          SizedBox(height: 30,),

          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: PrimaryButton(
              onTap: () async {
                // showCupertinoDialog(context: null, builder: null)
                widget.widget.parent.setState(() {
                  widget.widget.parent.setStatus();
                });
                Navigator.of(context).pop();
                setState(() {
                  isLoading = true;
                });
                var response = 'success';
                // var response = await CarePlanController().update(widget.widget.carePlan, widget.commentController.text);
                setState(() {
                  isLoading = false;
                });
                
                if (response == 'success') {
                  widget.widget.parent.setState(() {
                    widget.widget.parent.setStatus(widget.widget.carePlan);
                  });
                  Navigator.of(context).pop();
                } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                
              },
              text: isLoading ? CircularProgressIndicator() : Text('COMPLETE ACTION', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          ),
          
        ],
      )
    );
  }
}

class VideoContainer extends StatefulWidget {
  const VideoContainer({
    Key key,
    @required YoutubePlayerController youtubeController,
    this.title,
    this.carePlan
  }) : _youtubeController = youtubeController, super(key: key);

  final YoutubePlayerController _youtubeController;
  final String title;
  final carePlan;

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  @override
  initState() {
    super.initState();
  }
  getTime(time) {
    var data = '';
    DateFormat format = new DateFormat("H:m:s");
    data = DateFormat("mm:s").format(format.parse(time));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Row(
            children: <Widget>[
              // Checkbox(
              //   activeColor: kPrimaryColor,
              //   value: videoWatched,
              //   onChanged: (value) {
              //     setState(() {
              //       videoWatched = value;
              //     });
              //   },
              // ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: YoutubePlayer(
                    onEnded: (data) {
                     
                    } ,
                    
                    controller: widget._youtubeController,
                    liveUIColor: Colors.amber,
                    progressColors: ProgressBarColors(
                      playedColor: Colors.amber,
                      handleColor: Colors.amberAccent,
                    ),
                
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () async {
              //     await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return Dialog(
              //           elevation: 0.0,
              //           backgroundColor: Colors.transparent,
              //           child: Container(
              //             // height: 300,
              //             width: double.infinity,
              //             color: Colors.white,
              //             child: YoutubePlayer(
              //               onEnded: (data) {
              //                 print(data);
              //                 setState(() {
              //                   videoWatched = true;
              //                 });
              //               } ,
                            
              //               controller: _youtubeController,
              //               liveUIColor: Colors.amber,
              //               progressColors: ProgressBarColors(
              //                 playedColor: Colors.amber,
              //                 handleColor: Colors.amberAccent,
              //               ),
                        
              //             ),
              //           ),
              //         );
              //       },
              //     ).then((value) {
              //       print('closed');
              //       _youtubeController.reset();
              //     });
              //   },
              //   child: Text(videoUrl, 
              //     style: TextStyle(
              //       fontSize: 16,
              //       color: kPrimaryColor,
              //       decoration: TextDecoration.underline
              //     )
              //   ),
              // ),
            
            ],
          ),

          SizedBox(height: 20,),
          // Text(widget._youtubeController.metadata.title, style: TextStyle(fontSize: 18),),
          SizedBox(height: 10,),
          // Text(getTime(widget._youtubeController.metadata.duration.toString()), style: TextStyle(fontSize: 14, color: kTextGrey),),
          SizedBox(height: 40,),
          Container(
            padding: EdgeInsets.symmetric(vertical:15),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: kPrimaryColor)
            ),
            child: InkWell(
              onTap: () async {
                var result = Questionnaire().addVideoSurvey(videoUrl, widget.carePlan);
                if (result == 'success') {
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text('Data added'),
                      backgroundColor: Color(0xFF4cAF50),
                    )
                  );
                  await Future.delayed(const Duration(seconds: 1));
                  // Navigator.of(context).pop();
                } else {
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(result.toString()),
                      backgroundColor: kPrimaryRedColor,
                    )
                  );
                }
              },
              child: Text('USER HAS WATCHED THE ENTIRE VIDEO', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),),
            ),
          ),
        ],
      ),
    );
  }
}

class BpFormContainer extends StatefulWidget {
  BpFormContainer({this.form});

  var form;

  @override
  _BpFormContainerState createState() => _BpFormContainerState();
}

class _BpFormContainerState extends State<BpFormContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 70,
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 17),
      decoration: BoxDecoration(
        
      ),
      child: Row(
        children: <Widget>[
          Checkbox(
            activeColor: kPrimaryColor,
            value: widget.form,
            onChanged: (value) {
              setState(() {
                widget.form = value;
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
    );
  }
}



// SingleChildScrollView(
//   child: Stack(
//     children: <Widget>[
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[

//           Container(
//             height: 70,
//             width: double.infinity,
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.only(left: 17),
//             decoration: BoxDecoration(
              
//             ),
//             child: Row(
//               children: <Widget>[
//                 Checkbox(
//                   activeColor: kPrimaryColor,
//                   value: form,
//                   onChanged: (value) {
//                     setState(() {
//                       form = value;
//                     });
//                   },
//                 ),
//                 Text('Fill up the form',  style: TextStyle(fontSize: 16)),
//                 SizedBox(width: 10,),
//                 GestureDetector(
//                   onTap: () async {
                    
//                   },
//                   child: Text('Click here', 
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: kPrimaryColor,
//                       decoration: TextDecoration.underline
//                     )
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           videoUrl != '' ? Container(
//             width: double.infinity,
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.only(left: 17, bottom: 30),
//             child: Row(
//               children: <Widget>[
//                 Checkbox(
//                   activeColor: kPrimaryColor,
//                   value: videoWatched,
//                   onChanged: (value) {
//                     setState(() {
//                       videoWatched = value;
//                     });
//                   },
//                 ),
//                 Text('Watch the video',  style: TextStyle(fontSize: 16)),
//                 SizedBox(width: 10,),
//                 GestureDetector(
//                   onTap: () async {
//                     await showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Dialog(
//                           elevation: 0.0,
//                           backgroundColor: Colors.transparent,
//                           child: Container(
//                             // height: 300,
//                             width: double.infinity,
//                             color: Colors.white,
//                             child: YoutubePlayer(
//                               onEnded: (data) {
//                                 print(data);
//                                 setState(() {
//                                   videoWatched = true;
//                                 });
//                               } ,
                              
//                               controller: _youtubeController,
//                               liveUIColor: Colors.amber,
//                               progressColors: ProgressBarColors(
//                               playedColor: Colors.amber,
//                               handleColor: Colors.amberAccent,
//                           ),
                          
//                             ),
//                           ),
//                         );
//                       },
//                     ).then((value) {
//                       print('closed');
//                       _youtubeController.reset();
//                     });
//                   },
//                   child: Text(videoUrl, 
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: kPrimaryColor,
//                       decoration: TextDecoration.underline
//                     )
//                   ),
//                 ),
//               ],
//             ),
//           ) : Container(),
          
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 30),
//             child: TextField(
//               keyboardType: TextInputType.multiline,
//               maxLines: 5,
//               style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
//               controller: commentController,
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 20, right: 20),
//                 filled: true,
//                 fillColor: kSecondaryTextField,
//                 border: new UnderlineInputBorder(
//                   borderSide: new BorderSide(color: Colors.white),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(4),
//                     topRight: Radius.circular(4),
//                   )
//                 ),
              
//                 hintText: 'Comments/Notes (optional)',
//                 hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
//               ),
//             )
//           ),
          
//           SizedBox(height: 30,),

//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//             child: PrimaryButton(
//               onTap: () async {
//                 setState(() {
//                   isLoading = true;
//                 });
//                 var response = await CarePlanController().update(widget.carePlan, commentController.text);
//                 print('hello' + response);
//                 setState(() {
//                   isLoading = false;
//                 });
//                 if (response == 'success') {
//                   widget.parent.setState(() {
//                     widget.parent.update(widget.carePlan);
//                   });
//                   Navigator.of(context).pop();
//                 } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                
//               },
//               text: Text('MARK AS COMPLETE', style: TextStyle(color: Colors.white, fontSize: 16),),
//             ),
//           ),
//         ],
//       ),
//       isLoading ? Container(
//         height: MediaQuery.of(context).size.height,
//         width: double.infinity,
//         color: Color(0x90FFFFFF),
//         child: Center(
//           child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
//         ),
//       ) : Container(),
//     ],
//   ),
// ),
    

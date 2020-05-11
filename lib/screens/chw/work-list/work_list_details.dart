import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/widgets/primary_button_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkListDetailsScreen extends CupertinoPageRoute {
  final carePlan;
  final parent;
  WorkListDetailsScreen({this.carePlan, this.parent})
      : super(builder: (BuildContext context) => WorkListDetails(carePlan: carePlan, parent: parent));

}

class WorkListDetails extends StatefulWidget {
  final carePlan;
  final parent;
  WorkListDetails({this.carePlan, this.parent});
  @override
  _WorkListDetailsState createState() => _WorkListDetailsState();
}

class _WorkListDetailsState extends State<WorkListDetails> {
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
    print(widget.carePlan);
    _getVideoUrl();
    _getFormUrl();
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
            autoPlay: true,
          ),
        );
        videoUrl = video.first != null ? video.first['uri'] : '';
      });
    }

  }

  createPages() {
    if (widget.carePlan['body']['id'] == 'a4') {
      setState(() {
        pages.add(
          Form4()
        );
      });
    } if (widget.carePlan['body']['id'] == 'a8') {
      setState(() {
        pages.add(
          Form8()
        );
      });
    } if (widget.carePlan['body']['id'] == 'a16') {
      setState(() {
        pages.add(
          Form16()
        );
      });
    } 

    if (videoUrl != '') {
      setState(() {
        pages.add(
          VideoContainer(youtubeController: _youtubeController)
        );
        pages.add(
          VideoConfirmForm()
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Work List', style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        // height: 400,
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
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 100,
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
        ),
      ),
    );
  }
}

class Form4 extends StatelessWidget {
  const Form4({
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
                Text('What is your blood pressure reading?', style: TextStyle(fontSize: 17),),
                SizedBox(height: 15,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: 'Systolic',
                        type: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: 'Diastolic',
                        type: TextInputType.number
                      ),
                    ),
                  ],
                ),
                Text('Second reading of blood pressure?', style: TextStyle(fontSize: 17),),
                SizedBox(height: 15,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: 'Systolic',
                        type: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: 'Diastolic',
                        type: TextInputType.number
                      ),
                    ),
                  ],
                ),
                Text('Third reading of blood pressure?', style: TextStyle(fontSize: 17),),
                SizedBox(height: 15,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: 'Systolic',
                        type: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: 'Diastolic',
                        type: TextInputType.number
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
                    Text('Did you watch the video?', style: TextStyle(fontSize: 17),),
                  ],
                ),
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
  final WorkListDetails widget;

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
            
              hintText: 'Comments/Notes (optional)',
              hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
            ),
          ),

          SizedBox(height: 30,),

          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: PrimaryButton(
              onTap: () async {
                // showCupertinoDialog(context: null, builder: null)
                setState(() {
                  isLoading = true;
                });
                var response = await CarePlanController().update(widget.widget.carePlan, widget.commentController.text);
                setState(() {
                  isLoading = false;
                });
                
                if (response == 'success') {
                  widget.widget.parent.setState(() {
                    widget.widget.parent.update(widget.widget.carePlan);
                  });
                  Navigator.of(context).pop();
                } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                
              },
              text: isLoading ? CircularProgressIndicator() : Text('MARK AS COMPLETE', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          ),
          
        ],
      )
    );
  }
}

class VideoContainer extends StatelessWidget {
  const VideoContainer({
    Key key,
    @required YoutubePlayerController youtubeController,
  }) : _youtubeController = youtubeController, super(key: key);

  final YoutubePlayerController _youtubeController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text('Watch the video', style: TextStyle(fontSize: 17),),
          ),
          SizedBox(height: 20,),

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
                  child: YoutubePlayer(
                    onEnded: (data) {
                      print(data);
                     
                    } ,
                    
                    controller: _youtubeController,
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
        ],
      ),
    );
  }
}

class FormContainer extends StatefulWidget {
  FormContainer({this.form});

  var form;

  @override
  _FormContainerState createState() => _FormContainerState();
}

class _FormContainerState extends State<FormContainer> {
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



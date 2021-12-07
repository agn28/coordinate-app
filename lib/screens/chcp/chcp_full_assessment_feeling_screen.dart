import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'full_assessment_chcp_screen.dart';
import 'unwell_full_assessment_chcp_screen.dart';

class ChcpFullAssessmentFeelingScreen extends StatefulWidget {
  static const path = '/chcpFullAssessmentFeelingScreen';

  final communityClinic;
  ChcpFullAssessmentFeelingScreen({this.communityClinic});
  @override
  _ChcpFullAssessmentFeelingScreenState createState() => _ChcpFullAssessmentFeelingScreenState();
}

class _ChcpFullAssessmentFeelingScreenState extends State<ChcpFullAssessmentFeelingScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('followupVisit'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:Column(
            children: <Widget>[
              PatientTopbar(),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 40,),
                    Container(
                      child: Text(AppLocalizations.of(context).translate('howIsFeelingToday'), style: TextStyle(fontSize: 23),)
                    ),
                    SizedBox(height: 40,),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            height: 180,
                            decoration: BoxDecoration(
                              color: kPrimaryGreenColor,
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                Navigator.of(context).pushNamed(FullAssessmentChcpScreen.path);
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('assets/images/icons/well.png'),
                                  SizedBox(height: 20,),
                                  Text(AppLocalizations.of(context).translate('well'), style: TextStyle(fontSize: 21, color: Colors.white, fontWeight: FontWeight.normal),)
                                ],
                              )
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            height: 180,
                            decoration: BoxDecoration(
                              color: kPrimaryRedColor,
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                
                                Navigator.of(context).pushNamed(UnwellFullAssessmentChcpScreen.path);
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('assets/images/icons/unwell.png'),
                                  SizedBox(height: 20,),
                                  Text(AppLocalizations.of(context).translate('unwell'), style: TextStyle(fontSize: 21, color: Colors.white, fontWeight: FontWeight.normal),)
                                ],
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                  ], 
                ),
              ),
            ],
          ),
    );
  }
}

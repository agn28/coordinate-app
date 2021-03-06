import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/unwell/create_referral_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';


class MedicalRecommendationScreen extends StatefulWidget {
  static const path = '/medicalRecommendation';

  MedicalRecommendationScreen({this.referralData});
  var referralData;
  @override
  _MedicalRecommendationState createState() => _MedicalRecommendationState();
}

class _MedicalRecommendationState extends State<MedicalRecommendationScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();

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
        title: new Text(AppLocalizations.of(context).translate('seekingMedicalAttention'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    PatientTopbar(),
                    SizedBox(height: 60,),

                    widget.referralData['referred_from'] != null &&  widget.referralData['referred_from'] == 'new questionnaire' ? 
                    Container(
                      margin: EdgeInsets.only(left: 50, right: 50),
                      child: Text(AppLocalizations.of(context).translate("NCDscreening"), textAlign: TextAlign.center, style: TextStyle( color: kPrimaryRedColor, fontSize: 22, fontWeight: FontWeight.w400),),
                    ) : 
                    Column(
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/images/icons/unwell_red.png',
                            height: 70,
                          ),
                        ),
                        SizedBox(height: 30,),
                        Text(AppLocalizations.of(context).translate('patientsUnwell'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),),
                        SizedBox(height: 15,),
                        Text(AppLocalizations.of(context).translate("seekingMedicalAttention"), style: TextStyle(color: kPrimaryRedColor, fontSize: 22, fontWeight: FontWeight.w400),),
                      ],
                    ),
                    
                    SizedBox(height: 30,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(left: 30, right: 30),
                            height: 50,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(3)
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                // Navigator.of(context).pushNamed('/chwNavigation',);
                                var data = widget.referralData;
                                if (data['referred_from'] != null) {
                                  data.remove('referred_from');
                                }
                                Navigator.of(context).pushNamed(CreateReferralScreen.path, arguments: widget.referralData);
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Text(AppLocalizations.of(context).translate('referralCreate').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ], 
                  
                ),
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

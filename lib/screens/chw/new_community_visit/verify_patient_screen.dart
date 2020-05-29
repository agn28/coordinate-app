import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';


class VerifyPatientScreen extends StatefulWidget {
  @override
  _VerifyPatientState createState() => _VerifyPatientState();
}

class _VerifyPatientState extends State<VerifyPatientScreen> {
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
        title: new Text('New Community visit', style: TextStyle(color: Colors.white, fontSize: 20),),
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
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30,),
                    Container(
                      child: Text('Verify Patient', style: TextStyle(fontSize: 23),)
                    ),
                    SizedBox(height: 30,),
                    Patient().getPatient()['data']['avatar'] == null ? 
                    ClipRRect(
                      borderRadius: BorderRadius.circular(70.0),
                      child: Image.asset(
                        'assets/images/avatar.png',
                        height: 140.0,
                        width: 140.0,
                      ),
                    ) :
                    CircleAvatar(
                      radius: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Image.network(
                          Patient().getPatient()['data']['avatar'],
                          height: 140.0,
                          width: 140.0,
                        ),
                      ),
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    SizedBox(height: 30,),
                    Text(Helpers().getPatientName(Patient().getPatient()), style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20,),
                    Text(Helpers().getPatientAgeAndGender(Patient().getPatient()), style: TextStyle(fontSize: 20, color: kTextGrey),),
                    SizedBox(height: 30,),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      height: 60,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(3)
                      ),
                      child: FlatButton(
                        onPressed: () async {
                          Navigator.of(context).pushNamed('/patientFeeling');
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text('CONFIRM PATIENT & CONTINUE', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                      ),
                    ),
                    SizedBox(height: 30,),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: kPrimaryColor)
                      ),
                      child: FlatButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SkipAlert();
                            },
                          );
                        },
                          
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text('MARK AS UNSUCCESSFULL VISIT', style: TextStyle(fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.w500),)
                      ),
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


class SkipAlert extends StatefulWidget {

  @override
  _SkipAlertState createState() => _SkipAlertState();
}

class _SkipAlertState extends State<SkipAlert> {
  final GlobalKey<FormState> _skipForm = new GlobalKey<FormState>();
  String selectedReason = 'patient refused';
  bool isOther = false;
  final skipReasonController = TextEditingController();
  List devices = ['Other'];
  String selectedDevice;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('MARK AS UNSUCCESSFULL VISIT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
                // margin: EdgeInsets.symmetric(horizontal: 30),
              
              Text('What went wrong?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
              Container(
                  color: kSecondaryTextField,
                  child: DropdownButtonFormField(
                    hint: Text('Select a reason', style: TextStyle(fontSize: 20, color: kTextGrey),),
                    decoration: InputDecoration(
                      fillColor: kSecondaryTextField,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      border: UnderlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      )
                    ),
                    ),
                    items: [
                      ...devices.map((item) =>
                        DropdownMenuItem(
                          child: Text(item),
                          value: devices.indexOf(item)
                        )
                      ).toList(),
                    ],
                    value: selectedDevice,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedDevice = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  width: double.infinity,
                  child: TextFormField(
                    style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 15.0, bottom: 25.0, left: 10, right: 10),
                      filled: true,
                      fillColor: kSecondaryTextField,
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        )
                      ),

                      hintText: 'Comments/Notes',
                      hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                    ),
                  )
                ),
              SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16),)
                        ),
                        SizedBox(width: 30,),
                        GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pushReplacementNamed('/chwHome');
                          },
                          child: Text('DONE', style: TextStyle(color: kPrimaryColor, fontSize: 16))
                        ),
                      ],
                    )
                  )
                ],
              )
            ],
          ),
        )
      )
      
    );
  }
}

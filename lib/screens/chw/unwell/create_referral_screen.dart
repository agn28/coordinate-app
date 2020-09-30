import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';


class CreateReferralScreen extends StatefulWidget {
  static const path = '/createReferral';
  CreateReferralScreen({this.referralData});
  var referralData;
  @override
  _CreateReferralScreenState createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;

  List referralReasons = ['urgent medical attempt required', 'NCD screening required'];
  var selectedReason;
  List clinicTypes = ['community clinic', 'upazila health complex', 'hospital'];
  var selectedtype;
  var clinicNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    print(widget.referralData);
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
        title: new Text(AppLocalizations.of(context).translate('referralCreate'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
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
                  Text(AppLocalizations.of(context).translate('viewOrEditPatient'), style: TextStyle(color: Colors.white))
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
              Container(
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    PatientTopbar(),
                    SizedBox(height: 30,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Reason for referral', style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: DropdownButtonFormField(
                        hint: Text(AppLocalizations.of(context).translate('selectAReason'), style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                          ...referralReasons.map((item) =>
                            DropdownMenuItem(
                              child: Text(StringUtils.capitalize(item)),
                              value: item
                            )
                          ).toList(),
                        ],
                        value: selectedReason,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                      ),
                    ),


                    SizedBox(height: 30,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Referral location', style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: DropdownButtonFormField(
                        hint: Text('Clinic type *', style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                          ...clinicTypes.map((item) =>
                            DropdownMenuItem(
                              child: Text(StringUtils.capitalize(item)),
                              value: item
                            )
                          ).toList(),
                        ],
                        value: selectedtype,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedtype = value;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 20,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: TextField(
                        controller: clinicNameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          hintText: 'Name of Clinic',
                          hintStyle: TextStyle(fontSize: 18)
                        ),
                      )
                    ),

                    SizedBox(height: 50,),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(left: 20, right: 20),
                            height: 50,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(3)
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                // Navigator.of(context).pushNamed('/chwNavigation',);

                              

                                var data = widget.referralData;

                                data['body']['reason'] = selectedReason;
                                data['body']['location'] = {};
                                data['body']['location']['clinic_type'] = selectedtype;
                                data['body']['location']['clinic_name'] = clinicNameController.text;

                                print(data);

                                setState(() {
                                  isLoading = true;
                                });
                                var response = await FollowupController().create(data);
                                setState(() {
                                  isLoading = false;
                                });
                                print('response');
                                print(response);

                                // return;

                                if (response['error'] == true && response['message'] =='referral exists') {
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AlertDialog(
                                        content: new Text(AppLocalizations.of(context).translate("referralAlreadyExists"), style: TextStyle(fontSize: 20),),
                                        actions: <Widget>[
                                          // usually buttons at the bottom of the dialog
                                          new FlatButton(
                                            child: new Text(AppLocalizations.of(context).translate("referralUpdate"), style: TextStyle(color: kPrimaryColor)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pushNamed('/referralList',);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  Navigator.of(context).pushNamed('/chwHome',);
                                }
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

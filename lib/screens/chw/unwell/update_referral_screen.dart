import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';


class UpdateReferralScreen extends StatefulWidget {
  UpdateReferralScreen({this.referral});
  var referral;
  @override
  _UpdateReferralScreenState createState() => _UpdateReferralScreenState();
}

class _UpdateReferralScreenState extends State<UpdateReferralScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;
  final format = DateFormat("yyyy-MM-dd");


  List referralReasons = ['urgent medical attempt required', 'NCD screening required'];
  var selectedReason;
  List clinicTypes = ['community clinic', 'upazila health complex', 'hospital', 'BRAC NCD Centre' ,'Refer from CHW','Refer from Paramedics'];
  var selectedtype;
  List status = ['pending', 'completed'];
  var selectedStatus;
  var clinicNameController = TextEditingController();
  var outcomeController = TextEditingController();
  var dateController = TextEditingController();

  var selectedDate;

  

  setDate(date) {
    if (date != null) {
      selectedDate = date;
    }
  }

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    setData();
  }

  setData() {
    setState(() {
      selectedStatus = widget.referral['meta']['status'];
      selectedReason = widget.referral['body']['reason'];
      selectedtype = widget.referral['body']['location'] != null ? widget.referral['body']['location']['clinic_type'] : null;
      clinicNameController.text = widget.referral['body']['location'] != null ? widget.referral['body']['location']['clinic_name'] : '';
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
        title: new Text(AppLocalizations.of(context).translate('referralUpdate'), style: TextStyle(color: Colors.white, fontSize: 20),),
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
                      child: Text(AppLocalizations.of(context).translate('reason'), style: TextStyle(fontSize: 20),)
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
                      child: Text(AppLocalizations.of(context).translate('referralLocation'), style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: DropdownButtonFormField(
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
                          hintStyle: TextStyle(fontSize: 18)
                        ),
                      )
                    ),

                    SizedBox(height: 30,),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(AppLocalizations.of(context).translate('status'), style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: DropdownButtonFormField(
                        hint: Text(AppLocalizations.of(context).translate('status'), style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                          ...status.map((item) =>
                            DropdownMenuItem(
                              child: Text(StringUtils.capitalize(item)),
                              value: item
                            )
                          ).toList(),
                        ],
                        value: selectedStatus,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 30,),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(AppLocalizations.of(context).translate('referredOutcome'), style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: TextField(
                        maxLines: 3,
                        controller: outcomeController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          hintStyle: TextStyle(fontSize: 18)
                        ),
                      )
                    ),

                    SizedBox(height: 30,),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(AppLocalizations.of(context).translate('dateOfReferral'), style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: DateTimeField(
                        format: format,
                        controller: dateController,
                        style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(icon: Icon(Icons.close), onPressed: () {}, color: kSecondaryTextField,),
                          hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                          contentPadding: EdgeInsets.only(top: 18, bottom: 18, left: 10, right: 10),
                          // prefixIcon: Icon(Icons.date_range),
                          filled: true,
                          fillColor: kSecondaryTextField,
                          border: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            )
                          ),
                        ),

                        onChanged: (date) {
                          setDate(date);
                        },
                        
                        onShowPicker: (context, currentValue) {
                          return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: selectedDate ?? DateTime.now(),
                            lastDate: DateTime(2021)
                          );
                        },
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
                                // return;
                                // Navigator.of(context).pushNamed('/chwNavigation',);

                                var data = widget.referral;

                                data['body']['reason'] = selectedReason;
                                data['body']['outcome'] = outcomeController.text;
                                data['body']['location'] = {};
                                data['body']['location']['clinic_type'] = selectedtype;
                                data['body']['location']['clinic_name'] = clinicNameController.text;
                                if (selectedStatus == 'completed') {
                                  if  (dateController.text == null || dateController.text == '') {
                                    Toast.show('Please select completion date', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                                    return;
                                  }
                                  data['meta']['completed_at'] = dateController.text;
                                  data['meta']['status'] = 'completed';
                                }

                                // return;


                                setState(() {
                                  isLoading = true;
                                });
                                var response = await FollowupController().update(data);
                                Navigator.of(context).pushReplacementNamed('/referralList',);
                                setState(() {
                                  isLoading = false;
                                });
                                // return;
                                 
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Text(AppLocalizations.of(context).translate('referralUpdate').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
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

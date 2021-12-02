import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/controllers/referral_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';



getDropdownOptionText(context, list, value) {
  var locale = Localizations.localeOf(context);

  if (locale == Locale('bn', 'BN')) {

    if (list['options_bn'] != null) {
      var matchedIndex = list['options'].indexOf(value);
      return list['options_bn'][matchedIndex];
    }
    return (value);
  }
  return (value);
}
getName(context, item) {
  var locale = Localizations.localeOf(context);

  if (locale == Locale('bn', 'BN')) {
    if(item['bn_name'] != null){
      return item['bn_name'];
    }
  }
  return item['name'];
}

class CreateReferralScreen extends StatefulWidget {
  static const path = '/createReferral';
  CreateReferralScreen({this.referralData});
  var referralData;
  @override
  _CreateReferralScreenState createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  var role = '';
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;

  var nextVisitDateController = TextEditingController();

  var referralReasonOptions = {
    'options': ['Urgent medical attempt required', 'NCD screening required'],
    'options_bn': ['তাৎক্ষণিক মেডিকেল প্রচেষ্টা প্রয়োজন', 'এনসিডি স্ক্রিনিং প্রয়োজন']
  };
  List referralReasons;
  var selectedReason;
  var selectedReferralRole;
  var selectedFollowupIn;
  var clinicTypeOptions = {
    'options': ['community clinic', 'upazila health complex', 'hospital', 'BRAC NCD Centre'],
    'options_bn': ['কমিউনিটি ক্লিনিক', 'উপজেলা স্বাস্থ্য কমপ্লেক্স', 'হাসপাতাল', 'ব্র্যাক এনসিডি কেন্দ্র']
  };
  var clinicTypes = [];
  var selectedtype;
  var clinicNameController = TextEditingController();

  var referralToRolesOptions = {
    'options': ['Chcp'],
    'options_bn': ['chcp']
  };
  List referralToRoles;


  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    // referralReasons = Language().getLanguage() == 'Bengali' ? : ;
    _getAuthData();
    getCenters();  
    referralReasons = referralReasonOptions['options'];
    referralToRoles = referralToRolesOptions['options']; 
    // clinicTypes = clinicTypeOptions['options'];
    nextVisitDateController.text = '${DateFormat("yyyy-MM-dd").format(DateTime.now())}';
  }

  _getAuthData() async {
    var data = await Auth().getStorageAuth();

    setState(() {
      role = data['role'];
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

  getCenters() async {
    setState(() {
      isLoading = true;
    });
    var centerData = await PatientController().getCenter();
    setState(() {
      isLoading = false;
    });

    
    if (centerData['error'] != null && !centerData['error']) {
      clinicTypes = centerData['data'];
      for(var center in clinicTypes) {
        if(isNotNull(_patient['data']['center']) && center['id'] == _patient['data']['center']['id']) {
          setState(() {
            selectedtype = center;
          });
        }
      }
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
                      child: Text(AppLocalizations.of(context).translate("reasonForReferral"), style: TextStyle(fontSize: 20),)
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
                              child: Text(getDropdownOptionText(context, referralReasonOptions, item)),
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
                      child: Text(AppLocalizations.of(context).translate("referralLocation"), style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: DropdownButtonFormField(
                        hint: Text(AppLocalizations.of(context).translate("clinicType"), style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                              child: Text(getName(context, item)),
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
                          hintText: AppLocalizations.of(context).translate("clinicName"),
                          hintStyle: TextStyle(fontSize: 18)
                        ),
                      )
                    ),

                    SizedBox(height: 30,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(AppLocalizations.of(context).translate("referTo"), style: TextStyle(fontSize: 20),)
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      color: kSecondaryTextField,
                      child: DropdownButtonFormField(
                        hint: Text(AppLocalizations.of(context).translate("referTo"), style: TextStyle(fontSize: 20, color: kTextGrey),),
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
                          ...referralToRoles.map((item) =>
                            DropdownMenuItem(
                              child: Text(item),
                              value: item
                            )
                          ).toList(),
                        ],
                        value: selectedReferralRole,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedReferralRole = value;
                          });
                        },
                      ),
                    ),


                    SizedBox(height: 30,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(AppLocalizations.of(context).translate("followupIn"), style: TextStyle(color: Colors.black, fontSize: 20)),
                    ),
                    SizedBox(height: 10,),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      child: DateTimeField(
                        resetIcon: null,
                        format: DateFormat("yyyy-MM-dd"),
                        controller: nextVisitDateController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                          contentPadding: EdgeInsets.only(top: 18, bottom: 18),
                          prefixIcon: Icon(Icons.date_range),
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
                        
                        onShowPicker: (context, currentValue) async  {
                          return showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(2100));
                        },
                      ),
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
                                var referralType;
                                if(role == 'chw')
                                {
                                  referralType = 'chw';
                                } else if(role == 'nurse'){
                                  referralType = 'nurse';
                                }  else if(role == 'chcp'){
                                  referralType = 'chcp';
                                } else{
                                  referralType = '';
                                }

                                var data = widget.referralData;

                                data['body']['reason'] = selectedReason;
                                data['body']['type'] = referralType;
                                data['body']['referred_to'] = selectedReferralRole;
                                data['body']['location'] = {};
                                data['body']['location']['clinic_type'] = selectedtype;
                                data['body']['location']['clinic_name'] = clinicNameController.text;
                                data['body']['follow_up_date'] = nextVisitDateController.text;

                                  setState(() {
                                    isLoading = true;
                                  });
                                  await ReferralController().create(data, true, localStatus: 'complete');
                                  setState(() {
                                    isLoading = false;
                                  });

                                  Navigator.of(context).pushNamed('/chwHome',);
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('referralCreate')
                                    .toUpperCase(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              )),
                              ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isLoading
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            color: Color(0x90FFFFFF),
                            child: Center(
                                child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimaryColor),
                              backgroundColor: Color(0x30FFFFFF),
                            )),
                          )
                        : Container(),
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

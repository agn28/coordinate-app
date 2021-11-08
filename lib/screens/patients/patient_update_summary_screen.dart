import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/edit_patient_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';

class PatientUpdateSummary extends StatefulWidget {
  static const path = '/patientUpdateSummary';
  @override
  _PatientUpdateSummaryState createState() => _PatientUpdateSummaryState();
}

class _PatientUpdateSummaryState extends State<PatientUpdateSummary> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;
  final format = DateFormat("yyyy-MM-dd");


  List referralReasons = ['urgent medical attempt required', 'NCD screening required'];
  var selectedReason;
  List clinicTypes = ['community clinic', 'upazila health complex', 'hospital', 'BRAC NCD Centre'];
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
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),

                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: 300,
                      // width: 200,
                      // alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        // border: Border.all(width: 1, color: kTableBorderGrey)
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('patientName') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['first_name'] + ' ' + _patient['data']['last_name'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('gender') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['gender'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),
                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('dateOfBirth') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['birth_date'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),

                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('address') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['address']['street_name'] + ', ' + _patient['data']['address']['village'] + ', ' + _patient['data']['address']['upazila'] + ', ' +  _patient['data']['address']['district'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),

                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('mobile') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['mobile'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),

                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('nationalId') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['nid'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),

                          Row(
                            children: <Widget>[
                              // Text(AppLocalizations.of(context).translate('contactName') + ': ', style: TextStyle(fontSize: 18),),
                              Text(AppLocalizations.of(context).translate("contactname") + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['contact']['first_name'] + ' ' + _patient['data']['contact']['last_name'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),

                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('relationship') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['contact']['relationship'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                          SizedBox(height: 7,),

                          Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('contactMobilePhone') + ': ', style: TextStyle(fontSize: 18),),
                              Text(_patient['data']['contact']['mobile'], style: TextStyle(fontSize: 18),),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 70,),
                    
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        // var url = await uploadImage();
                        // var formData = _RegisterPatientState()._prepareFormData();
                        // var response = isEditState != null ? await PatientController().update(formData) : await PatientController().create(formData);
                        setState(() {
                          isLoading = false;
                        });
                        // if (response == 'success') {
                          Navigator.of(context).pushNamed(EditPatientScreen.path);
                        // }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        height: 50.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: isLoading ? CircularProgressIndicator() : Text("${isEditState != null ? AppLocalizations.of(context).translate('updatePatient') : AppLocalizations.of(context).translate('completeRegistration')}", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400))
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

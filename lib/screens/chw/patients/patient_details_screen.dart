import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_details/healthHistory_tab.dart';
import 'package:nhealth/screens/chw/patients/patient_details/measurements_tab.dart';
import 'package:nhealth/screens/chw/patients/patient_details/medical_history_tab.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';

final searchController = TextEditingController();
List allWorklist = [];
List worklist = [];
List allergies = [];

List allPendingPatients = [];
List pendingPatients = [];

List allCompletedPatients = [];
List completedPatients = [];

List allpastPatients = [];
List pastPatients = [];


class PatientDetailsScreen extends StatefulWidget {
  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetailsScreen> {

  List patients = [];
  bool isLoading = true;
  var report;
  var bmi;
  var cholesterol;
  var bp;
  var cvd;
  var authUser;
  TabController _controller;

  var reports;
  var previousReports = [];
  bool confirmLoading = false;
  bool reviewLoading = false;

  bool canEdit = false;
  final commentsController = TextEditingController();
  var medications = [];
  var conditions = [];
  bool avatarExists = false;

  @override
  initState() {
    super.initState();
    getReports();
    allWorklist = [];
    worklist = [];
    patientSort = 'asc';
    dueDateSort = 'asc';
    patientSortActive = false;
    dueDateSortActive = false;
  }

  getReports() async {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
    // var data;
    // var data = await HealthReportController().getReports();
    var data = await HealthReportController().getReports();
    // print(test);

    // data = test['data'][0]['result'];


    // return;



    if (data == null) {
      return Toast.show('Server Error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }
    if (data['error'] != null && data['error']) {
      if (data['message'] == 'No matching documents.') {
        return Toast.show('No Assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
      }
      return Toast.show('Server Error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }
    var fetchedSurveys = await ObservationController().getLiveSurveysByPatient();

    if(fetchedSurveys.isNotEmpty) {
      fetchedSurveys.forEach((item) {
        if (item['data']['name'] == 'medical_history') { 
          
          allergies = item['data']['allergy_types'] != null ? item['data']['allergy_types'] : [];

          item['data'].keys.toList().forEach((key) {
            if (item['data'][key] == 'yes') {
              setState(() {
                var text = key.replaceAll('_', ' ');
                conditions.add(text[0].toUpperCase() + text.substring(1));
                conditions = conditions.toSet().toList();
              });
            }
          });
        }
        if (item['data']['name'] == 'current_medication' && item['data']['medications'].isNotEmpty) {
          setState(() {
            medications = item['data']['medications'].toSet().toList();
          });
        }
      });
    }

    if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        reports = data['data'][data['data'].length - 1];
        data['data'].removeLast();
        print(data['data']);
         previousReports = data['data'];
        // print(previousReports);
        // print(data['data'].removeLast());
        // previousReports = data['data'];
        isLoading = false;
      });
    }

  }
  
  loaderHandle(value) {
    setState(() {
      isLoading = value;
    });
  }
  _logout() {
    Auth().logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
  }


  /// Get all the worklist


  update(carePlan) {
    var index = worklist.indexOf(carePlan);
    
    if(index > -1) {
      setState(() {
        worklist.removeAt(index);
      });
    }
  }

  _getDuration(item) {

    if (item['body']['activityDuration'] != null && item['body']['activityDuration']['start'] != '' && item['body']['activityDuration']['end'] != '') {
      var start = DateTime.parse(item['body']['activityDuration']['start']);
      var time = DateTime.parse(item['body']['activityDuration']['end']).difference(DateTime.parse(item['body']['activityDuration']['start'])).inDays;

      int result = (time / 30).round();
      if (result >= 1) {
        return 'Within ${result.toString()} months of recommendation of goal';
      }
    }
    return '';
  }

  getReport() async {
    isLoading = true;
    var data = await HealthReportController().getLastReport(context);
    
    if (data['error'] == true) {
      setState(() {
        isLoading = false;
      });
      Toast.show('No Health assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        isLoading = false;
        report = data['data'];
      });
    }
    setState(() {
      bmi = report['body']['result']['assessments']['body_composition'] != null && report['body']['result']['assessments']['body_composition']['components']['bmi'] != null ? report['body']['result']['assessments']['body_composition']['components']['bmi'] : null;
      cvd = report['body']['result']['assessments']['cvd'] != null ? report['body']['result']['assessments']['cvd'] : null;
      bp = report['body']['result']['assessments']['blood_pressure'] != null ? report['body']['result']['assessments']['blood_pressure'] : null;
      cholesterol = report['body']['result']['assessments']['cholesterol'] != null && report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ? report['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] : null;
    });

  }

  getPendingCount() {
    return  pendingPatients.length;

  }
  getCompletedCount() {
    return  completedPatients.length;
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('patientDetails'), style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        bottom: PreferredSize(child: Container(color: Colors.white, height: 0.0,), preferredSize: Size.fromHeight(1.0)),

      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            !isLoading ? Column(
              children: <Widget>[
                PatientTopbar(),

                SizedBox(height: 15,),

                Container(
                  height: MediaQuery.of(context).size.height,
                  
                  child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.white,
                        bottom: PreferredSize(child: Container(color: Colors.white, height: 1.0,), preferredSize: Size.fromHeight(1.0)),
                        
                        flexibleSpace: TabBar(
                          labelPadding: EdgeInsets.all(0),
                          indicatorPadding: EdgeInsets.all(0),
                          indicatorColor: kPrimaryColor,
                          unselectedLabelColor: kTextGrey,
                          labelColor: kPrimaryColor,
                          tabs: [
                            Tab(
                              child: Text(AppLocalizations.of(context).translate('healthHistory'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                            ),
                            Tab(
                              child: Text(AppLocalizations.of(context).translate('measurements'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                            ),
                            Tab(
                              child: Text(AppLocalizations.of(context).translate('medicalHistory'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                            ),
                            
                          ],
                        ),
                      ),
                      body: TabBarView(
                        
                        children: [
                          HealthHistoryTab(reports: reports),
                          
                          
                          MeasurementsTab(reports: reports, previousReports: previousReports),
                          
                          MedicalHistoryTab(conditions: conditions, medications: medications, allergies: allergies,),
                          // MedicationsTab(medications: medications,),
                          // AllergiesTab(allergies: allergies,),

                          
                        ],
                      ),
                    ),
                  ),
                ),
                
              ],
            )
          
            : Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Color(0x90FFFFFF),
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientItem extends StatefulWidget {
  const PatientItem({
    @required this.item,
    @required this.parent,
  });


  final item;
  final _PatientDetailsState parent;

  @override
  _PatientItemState createState() => _PatientItemState();
}

class _PatientItemState extends State<PatientItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Patient().setPatientModify(widget.item);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChwPatientRecordsScreen()));
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: kBorderLighter)
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Patient().getPatient()['data']['avatar'] == '' ? 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Image.asset(
                            'assets/images/avatar.png',
                            height: 40.0,
                            width: 40.0,
                          ),
                        ),
                        // CircleAvatar(
                        //   radius: 30,
                        //   child: ClipRRect(
                        //     borderRadius: BorderRadius.circular(30.0),
                        //     child: Image.network(
                        //       Patient().getPatient()['data']['avatar'],
                        //       height: 70.0,
                        //       width: 70.0,
                        //     ),
                        //   ),
                        //   backgroundImage: AssetImage('assets/images/avatar.png'),
                        // ),
                        // NetworkImage(Patient().getPatient()['data']['avatar'])
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(100),
                        //   child: Image.file(
                        //     File(Patient().getPatient()['data']['avatar']),
                        //     height: 60.0,
                        //     width: 60.0,
                        //     fit: BoxFit.fitWidth,
                        //   ),
                        // ),
                        SizedBox(width: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.item['body']['first_name'] + ' ' + widget.item['body']['last_name'], style: TextStyle( fontSize: 19, fontWeight: FontWeight.normal),),
                            SizedBox(height: 7,),
                            Row(
                              children: <Widget>[
                                Text(widget.item['body']['age'].toString() + 'Y ' + ' - ' + widget.item['body']['gender'], style: TextStyle(fontSize: 16, color: kTextGrey),),
                                SizedBox(width: 10,),
                                SizedBox(width: 10,),
                                Row(
                                  children: <Widget>[

                                    widget.item['body']['assessments'] != null && widget.item['body']['assessments']['lifestyle']['components']['diet'] != null && widget.item['body']['assessments']['lifestyle']['components']['diet']['components']['fruit'] != null ?
                                    CircleAvatar(
                                      child: Image.asset('assets/images/icons/fruit.png', width: 11,),
                                      radius: 11,
                                      backgroundColor: ColorUtils.statusColor[widget.item['body']['assessments']['lifestyle']['components']['diet']['components']['fruit']['tfl']],
                                    ) : Container(),
                                    SizedBox(width: 5,),

                                    widget.item['body']['assessments'] != null && widget.item['body']['assessments']['lifestyle']['components']['diet'] != null && widget.item['body']['assessments']['lifestyle']['components']['diet']['components']['vegetable'] != null ?
                                    CircleAvatar(
                                      child: Image.asset('assets/images/icons/vegetables.png', width: 11,),
                                      radius: 11,
                                      backgroundColor: ColorUtils.statusColor[widget.item['body']['assessments']['lifestyle']['components']['diet']['components']['vegetable']['tfl']],
                                    ) : Container(),
                                    SizedBox(width: 5,),

                                    widget.item['body']['assessments'] != null && widget.item['body']['assessments']['lifestyle']['components']['physical_activity'] != null ?
                                    CircleAvatar(
                                      child: Image.asset('assets/images/icons/activity.png', width: 11,),
                                      radius: 11,
                                      backgroundColor: ColorUtils.statusColor[widget.item['body']['assessments']['lifestyle']['components']['physical_activity']['tfl']],
                                    ) : Container()
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: <Widget>[


                                widget.item['body']['assessments'] != null && widget.item['body']['assessments']['body_composition']['components']['bmi'] != null ?
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor[widget.item['body']['assessments']['body_composition']['components']['bmi']['tfl']]),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('BMI',style: TextStyle(
                                      color: ColorUtils.statusColor[widget.item['body']['assessments']['body_composition']['components']['bmi']['tfl']],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ) : Container(),
                                SizedBox(width: 7,),


                                widget.item['body']['assessments'] != null && widget.item['body']['assessments']['blood_pressure'] != null ?
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor[widget.item['body']['assessments']['blood_pressure']['tfl']]),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('BP',style: TextStyle(
                                      color: ColorUtils.statusColor[widget.item['body']['assessments']['blood_pressure']['tfl']],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ) : Container(),
                                SizedBox(width: 7,),


                                widget.item['body']['assessments'] != null && widget.item['body']['assessments']['cvd'] != null ?
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor[widget.item['body']['assessments']['cvd']['tfl']]),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('CVD Risk',style: TextStyle(
                                      color: ColorUtils.statusColor[widget.item['body']['assessments']['cvd']['tfl']],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ) : Container(),
                                SizedBox(width: 7,),


                                widget.item['body']['assessments'] != null && widget.item['body']['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor[widget.item['body']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']]),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('Cholesterol',style: TextStyle(
                                      color: ColorUtils.statusColor[widget.item['body']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ) : Container(),
                              ],
                            ),
                            // Row(
                            //   children: <Widget>[
                            //     report != null && bmi != null ?
                            //     Container(
                            //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            //       decoration: BoxDecoration(
                            //         border: Border.all(width: 1, color: ColorUtils.statusColor[bmi['tfl']]),
                            //         borderRadius: BorderRadius.circular(2)
                            //       ),
                            //       child: Text('BMI',style: TextStyle(
                            //           color: ColorUtils.statusColor[bmi['tfl']],
                            //           fontWeight: FontWeight.w500
                            //         )  
                            //       ),
                            //     ) 
                            //     : Container(),
                            //     SizedBox(width: 7,),
                            //     report != null && bp != null ?
                            //     Container(
                            //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            //       decoration: BoxDecoration(
                            //         border: Border.all(width: 1, color: ColorUtils.statusColor[bp['tfl']]),
                            //         borderRadius: BorderRadius.circular(2)
                            //       ),
                            //       child: Text('BP',style: TextStyle(
                            //           color: ColorUtils.statusColor[bmi['tfl']],
                            //           fontWeight: FontWeight.w500
                            //         )  
                            //       ),
                            //     ) : Container(),
                            //     SizedBox(width: 7,),
                            //     report != null && cvd != null ?
                            //     Container(
                            //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            //       decoration: BoxDecoration(
                            //         border: Border.all(width: 1, color: ColorUtils.statusColor[cvd['tfl']]),
                            //         borderRadius: BorderRadius.circular(2)
                            //       ),
                            //       child: Text('CVD Risk',style: TextStyle(
                            //           color: ColorUtils.statusColor[cvd['tfl']],
                            //           fontWeight: FontWeight.w500
                            //         )  
                            //       ),
                            //     ) : Container(),
                            //     SizedBox(width: 7,),
                            //     report != null && cholesterol != null ?
                            //     Container(
                            //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            //       decoration: BoxDecoration(
                            //         border: Border.all(width: 1, color: ColorUtils.statusColor[cholesterol['tfl']]),
                            //         borderRadius: BorderRadius.circular(2)
                            //       ),
                            //       child: Text('Cholesterol',style: TextStyle(
                            //           color: ColorUtils.statusColor[cholesterol['tfl']],
                            //           fontWeight: FontWeight.w500
                            //         )  
                            //       ),
                            //     ) : Container(),
                            //   ],
                            // ),

                            // Text('Registered on Jan 5, 2019', style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w400),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 35,)
                  )
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}

class SortDialog extends StatefulWidget {
  _PatientDetailsState parent;
  SortDialog({this.parent});

  @override
  _SortDialogState createState() => _SortDialogState();
}

String patientSort = 'asc';
String dueDateSort = 'asc';
bool patientSortActive = false;
bool dueDateSortActive = false;

class _SortDialogState extends State<SortDialog> {

  _updatePatientSorting(value) {
    setState(() {
      patientSort = value;
    });
  }

  _updateDueDateSorting(value) {
    setState(() {
      dueDateSort = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 450.0,
        color: Colors.white,
        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('sortBy'), style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        patientSort = 'asc';
                        dueDateSort = 'asc';
                        patientSortActive = false;
                        dueDateSortActive = false;
                      });
                      widget.parent.setState((){
                      });
                    },
                    child: Text(AppLocalizations.of(context).translate('clearSort'), style: TextStyle(fontSize: 15, color: kPrimaryColor, fontWeight: FontWeight.w500),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Checkbox(
                        activeColor: kPrimaryColor,
                        value: patientSortActive,
                        onChanged: (value) {
                          setState(() {
                            patientSortActive = value;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context).translate('patients'), style: TextStyle(fontSize: 18,),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Radio(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: 'asc',
                        groupValue: patientSort,
                        activeColor: kPrimaryColor,
                        onChanged: (value) {
                          _updatePatientSorting(value);
                        },
                      ),
                      Text(AppLocalizations.of(context).translate('ascending'), style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Radio(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: 'desc',
                        groupValue: patientSort,
                        activeColor: kPrimaryColor,
                        onChanged: (value) {
                          _updatePatientSorting(value);
                        },
                      ),
                      Text(AppLocalizations.of(context).translate('descending'), style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        activeColor: kPrimaryColor,
                        value: dueDateSortActive,
                        onChanged: (value) {
                          setState(() {
                            dueDateSortActive = value;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context).translate('dueDateIntervention'), style: TextStyle(fontSize: 18),),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Radio(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: 'asc',
                        groupValue: dueDateSort,
                        activeColor: kPrimaryColor,
                        onChanged: (value) {
                          _updateDueDateSorting(value);
                        },
                      ),
                      Text(AppLocalizations.of(context).translate('ascending'), style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Radio(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: 'desc',
                        groupValue: dueDateSort,
                        activeColor: kPrimaryColor,
                        onChanged: (value) {
                          _updateDueDateSorting(value);
                        },
                      ),
                      Text(AppLocalizations.of(context).translate('descending'), style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {
                          setState(() {
                            // _selectedItem = [];
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16),)
                      ),
                      SizedBox(width: 20,),
                      FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.parent.setState(() {
                          });
                          // selectedDiseases = _selectedItem;
                          // this.parent.setState(() {
                          //   this.parent.getSelectedDiseaseText();
                          // });
                        },
                        child: Text(AppLocalizations.of(context).translate('apply'), style: TextStyle(color: kPrimaryColor, fontSize: 16))
                      ),
                    ],
                  )
                )
              ],
            )
          ],
        ),
      )
    );
  }
}

class PatientTopbar extends StatelessWidget {
  const PatientTopbar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
      color: Colors.white,
        
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                children: <Widget>[
                  Patient().getPatient()['data']['avatar'] == null ? 
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image.asset(
                      'assets/images/avatar.png',
                      height: 30.0,
                      width: 30.0,
                    ),
                  ) :
                  CircleAvatar(
                    radius: 17,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.network(
                        Patient().getPatient()['data']['avatar'],
                        height: 35.0,
                        width: 35.0,
                      ),
                    ),
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  SizedBox(width: 15,),
                  Text(Helpers().getPatientName(Patient().getPatient()), style: TextStyle(fontSize: 18))
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(Helpers().getPatientAgeAndGender(Patient().getPatient()), style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
          ),
          Expanded(
            child: Text('PID: N-121933421', style: TextStyle(fontSize: 18))
          )
        ],
      ),
    );
  }
}


class LeaderBoard {
  LeaderBoard(this.username, this.score);

  final String username;
  final double score;
}

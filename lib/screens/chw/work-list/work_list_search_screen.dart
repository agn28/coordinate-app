import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/care_plan_repository_local.dart';
import 'package:get/get.dart';

final searchController = TextEditingController();
List allWorklist = [];
List worklist = [];

List allPendingPatients = [];
List pendingPatients = [];

List allCompletedPatients = [];
List completedPatients = [];

List allPastPatients = [];
List pastPatients = [];

int selectedTab = 0;


class ChwWorkListSearchScreen extends StatefulWidget {
  @override
  _ChwWorkListSearchScreenState createState() => _ChwWorkListSearchScreenState();
}

class _ChwWorkListSearchScreenState extends State<ChwWorkListSearchScreen> {
  final syncController = Get.put(SyncController());
  List patients = [];
  bool isLoading = true;
  var report;
  var bmi;
  var cholesterol;
  var bp;
  var cvd;
  var authUser;
  TabController _tabController;

  @override
  initState() {
    super.initState();
    setState(() {
      searchController.text = '';
    });
    allWorklist = [];
    worklist = [];
    _getAuthUser();
    _getPatients();
    patientSort = 'asc';
    dueDateSort = 'asc';
    patientSortActive = false;
    dueDateSortActive = false;
  }

  _getAuthUserName() {
    var name = '';
    name = authUser != null && authUser['name'] != null ? authUser['name'] + ' (${authUser["role"].toUpperCase()})'  : '';
    return name;
  }

  _getAuthUser() async {
    var data = await Auth().getStorageAuth() ;

    if (!data['status']) {
      await Helpers().logout(context);
    }

    setState(() {
      authUser = data;
    });
  }
  /// Get all the worklist
  _getPatients() async {
    setState(() {
      isLoading = true;
    });

    var allLocalPatients = await PatientController().getPatientsWithAssesments();
    var localPatientPending = [];
    for(var localPatient in allLocalPatients) {
      var isAssigned = false;
      var parsedData = jsonDecode(localPatient['data']);
      var parsedLocalPatient = {
        'id': localPatient['id'],
        'body': parsedData['body'],
        'meta': parsedData['meta'],
      };
      if(isNotNull(parsedLocalPatient['meta']['has_pending']) && parsedLocalPatient['meta']['has_pending']) {
        var careplans = await CarePlanRepositoryLocal().getCareplanByPatient(parsedLocalPatient['id']);
        var careplanAssessment = await AssessmentController().getCarePlanAssessmentsByPatient(parsedLocalPatient['id']);
        var ccFollowup = careplanAssessment['data']['follow_up_info'].where((item) => item['type'] == "cc").first;
        parsedLocalPatient['body']['appointment_date'] = ccFollowup['date'];
        var parsedData;
        for(var careplan in careplans) {
          parsedData = jsonDecode(careplan['data']);
          if (parsedData['meta']['status'] == 'pending'
          && parsedData['meta']['assigned_to'].contains(Auth().getAuth()['uid'])) {
            isAssigned = true;
            break;
          }
        }
        if(isAssigned) {
          localPatientPending.add(parsedLocalPatient);
        }
      }
    }
    localPatientPending.sort((a, b) {
      return DateTime.parse(b['body']['appointment_date']).compareTo(DateTime.parse(a['body']['appointment_date']));
    });

    setState(() {
      allPendingPatients = localPatientPending;
      pendingPatients = allPendingPatients;
      isLoading = false;
    });
  }

  pastPatientsSort() {
    var patientsWithAssignment = [];
    var patients = [];
    allPastPatients.forEach((patient) {
      if (patient['body']['next_assignment'] != null && patient['body']['next_assignment']['meta']['created_at']['_seconds'] != null) {
        patientsWithAssignment.add(patient);
      } else {
        patients.add(patient);
      }
    });


    if (patientsWithAssignment.length > 0) {
      patientsWithAssignment.sort((a, b) {
        return DateTime.fromMillisecondsSinceEpoch(b['body']['next_assignment']['meta']['created_at']['_seconds'] * 1000).compareTo(DateTime.fromMillisecondsSinceEpoch(a['body']['next_assignment']['meta']['created_at']['_seconds'] * 1000));
      });
      allPastPatients = [...patientsWithAssignment, ...patients];
    }
    
  }

  completedPatientsSort() {
    var patientsWithAssignment = [];
    var patients = [];
    allCompletedPatients.forEach((patient) {
      if (patient['body']['next_assignment'] != null && patient['body']['next_assignment']['meta']['created_at']['_seconds'] != null) {
        patientsWithAssignment.add(patient);
      } else {
        patients.add(patient);
      }
    });


    if (patientsWithAssignment.length > 0) {
      patientsWithAssignment.sort((a, b) {
        return DateTime.fromMillisecondsSinceEpoch(b['body']['next_assignment']['meta']['created_at']['_seconds'] * 1000).compareTo(DateTime.fromMillisecondsSinceEpoch(a['body']['next_assignment']['meta']['created_at']['_seconds'] * 1000));
      });
      allCompletedPatients = [...patientsWithAssignment, ...patients];
    }
  }

  getNexDueDate(assignment) {
  }

  update(carePlan) {
    var index = worklist.indexOf(carePlan);
    
    if(index > -1) {
      setState(() {
        worklist.removeAt(index);
      });
    }
  }

  applySort() {
    if (patientSortActive) {
      if (patientSort == 'asc') {
        worklist.sort((a, b) => a['patient']['first_name'].toString().toLowerCase().compareTo(b['patient']['first_name'].toString().toLowerCase()));
      } else {
        worklist.sort((a, b) => b['patient']['first_name'].toString().toLowerCase().compareTo(a['patient']['first_name'].toString().toLowerCase()));
      }
    }

    if (dueDateSortActive) {
      var worklistWithdate = [];
      var worklistWithoutdate = [];
      // worklist = allWorklist;
      // worklist[2]['body']['activityDuration']['end'] = '2020-02-05';
      worklist.forEach((item) {
        if (item['body']['activityDuration']['start'] != '' || item['body']['activityDuration']['end'] != '') {
          worklistWithdate.add(item);
        } else {
          worklistWithoutdate.add(item);
        }
      });
      // worklist.forEach((item){
      //   print(worklist.indexOf(item));
      //   print(DateTime.parse(item['body']['activityDuration']['end']).difference(DateTime.parse(item['body']['activityDuration']['start'])).inDays);
      // });
      if (dueDateSort == 'asc') {
        worklistWithdate.sort((a, b) {
          return DateTime.parse(a['body']['activityDuration']['end']).difference(DateTime.now()).inDays.compareTo(DateTime.parse(b['body']['activityDuration']['end']).difference(DateTime.now()).inDays);
        });
      } else {
        worklistWithdate.sort((a, b) {
          return DateTime.parse(b['body']['activityDuration']['end']).difference(DateTime.now()).inDays.compareTo(DateTime.parse(a['body']['activityDuration']['end']).difference(DateTime.now()).inDays);
        });
      }

      setState(() {
        worklist = worklistWithdate;
        worklistWithoutdate.forEach((item) {
          worklist.add(item);
        });
      });

    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool isPid(String query) {
    return query.length >= 3 && query.substring(0, 3) == 'PA-';
  }

  
  search(query) {
    if (selectedTab == 0) {
      pendingSearch(query);
    } else if (selectedTab == 1) {
      pastSearch(query);
    } else {
      completedSearch(query);
    }
    
  }

  pendingSearch(query) {
    var modifiedWorklist = [...allPendingPatients].map((item)  {
      item['body']['name'] = '${item['body']['first_name']} ${item['body']['last_name']}';
      return item;
    }).toList();

    setState(() {
      if (isNumeric(query)) {
        pendingPatients = modifiedWorklist
        .where((item) => item['body']['mobile']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      } else if (isPid(query)) {
        pendingPatients = modifiedWorklist
        .where((item) => item['body']['pid']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      } else {
        pendingPatients = modifiedWorklist
        .where((item) => item['body']['name']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      }
    });
  }

  pastSearch(query) {
    var modifiedWorklist = [...allPastPatients].map((item)  {
      item['body']['name'] = '${item['body']['first_name']} ${item['body']['last_name']}';
      return item;
    }).toList();

    setState(() {
      if (isNumeric(query)) {
        pastPatients = modifiedWorklist
        .where((item) => item['body']['mobile']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      } else if (isPid(query)) {
        pastPatients = modifiedWorklist
        .where((item) => item['body']['pid']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      } else {
        pastPatients = modifiedWorklist
        .where((item) => item['body']['name']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      }
    });
  }

  completedSearch(query) {
    var modifiedWorklist = [...allCompletedPatients].map((item)  {
      item['body']['name'] = '${item['body']['first_name']} ${item['body']['last_name']}';
      return item;
    }).toList();

    setState(() {
      if (isNumeric(query)) {
        completedPatients = modifiedWorklist
        .where((item) => item['body']['mobile']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      } else if (isPid(query)) {
        completedPatients = modifiedWorklist
        .where((item) => item['body']['pid']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      } else {
        completedPatients = modifiedWorklist
        .where((item) => item['body']['name']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
      }
    });
  }



  clearSort() {
    setState(() {
      worklist = allWorklist;
    });
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
        title: Text(AppLocalizations.of(context).translate('workList')),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: <Widget>[
          // overflow menu
          PopupMenuButton(
            itemBuilder: (_) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                  
                  child: Container(
                    child: Text(AppLocalizations.of(context).translate("logout")),
                  ),
                  value: 'logout'),
              ],
            onSelected: (value) {
              if (value == 'logout') {
                Helpers().logout(context);
              }
            },
            child: Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Text(_getAuthUserName(),),
                  SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image.asset(
                      'assets/images/avatar.png',
                      height: 20.0,
                      width: 20.0,
                    ),
                  ),
                  SizedBox(width: 20,)
                ],
              ),
            ),
          ),

        ],
        bottom: PreferredSize(child: Container(color: kPrimaryColor, height: 1.0,), preferredSize: Size.fromHeight(1.0)),

      ),
      body: Column(
              children: <Widget>[
                Container(
                  color: kPrimaryColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 15, top: 10,),
                        decoration: BoxDecoration(
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) {
                            search(query);
                          },
                          // focusNode: focusNode,
                          autofocus: true,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x4437474F),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5)
                              )
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              onPressed: () { 
                                setState(() {
                                  searchController.text = '';
                                  worklist = allWorklist;
                                });
                              },
                              icon: Icon(Icons.cancel, color: kTextGrey, size: 25,)
                            ),
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(context).translate('searchHere'),
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              right: 20,
                              top: 14,
                              bottom: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,)
                    ],
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    color: Colors.grey.withOpacity(0.15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('appointmentDate'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 2,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('village'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 2,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('name'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 2,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('fathersOrHusbandsName'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 1,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('age'), style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 1,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('gender'), style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                        )
                      ],
                    ),
                  ),
                ) ,


                isLoading ? Container(
                    margin: const EdgeInsets.only(top: 100),
                    child: Center(
                        child: CircularProgressIndicator(),
                      ),
                  ) : pendingPatients.length > 0 ? Expanded(
                  child: ListView.builder(
                      itemCount: pendingPatients.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index){
                        return GestureDetector(
                      onTap: () {
                        Patient().setPatientModify(pendingPatients[index]);
                        // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChwPatientRecordsScreen()));
    Navigator.of(context).pushNamed('/chwPatientSummary', arguments: {'prevScreen' : 'home', 'encounterData': {}});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Text("${pendingPatients[index]['body']['appointment_date'] ?? 'N/A'}", style: TextStyle(fontSize: 14, color: Colors.black),),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  flex: 2,
                                    child: Container(
                                    child: Text(pendingPatients[index]['body']['address']['village'], style: TextStyle(fontSize: 14, color: Colors.black),),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  flex: 2,
                                    child: Container(
                                    child: Text(pendingPatients[index]['body']['first_name'] + ' ' + pendingPatients[index]['body']['last_name'], style: TextStyle(fontSize: 14, color: Colors.black,),),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  flex: 2,
                                    child: Container(
                                      child: Text(pendingPatients[index]['body']['gender'] == 'male' 
                                        ? pendingPatients[index]['body']['father_name']
                                        : pendingPatients[index]['body']['husband_name'] != null && pendingPatients[index]['body']['husband_name'].isNotEmpty ? pendingPatients[index]['body']['husband_name'] : 'n/a',
                                      style: TextStyle(color: Colors.black87, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  flex: 1,
                                    child: Container(
                                    child: Text(pendingPatients[index]['body']['age'].toString(), style: TextStyle(fontSize: 14, color: Colors.black),),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  flex: 1,
                                    child: Container(
                                    child: Text(pendingPatients[index]['body']['gender'], style: TextStyle(fontSize: 14, color: Colors.black),),
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              height: 0,
                              thickness: 0.5,
                              color: Colors.grey.withOpacity(0.50)
                            ),
                          ],
                        ), 
                       ),
                    );
                  },
                ),
              ) : Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text(AppLocalizations.of(context).translate('noPatientFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
                  ),
            ],
          ),
    );
  }
}

class PatientItem extends StatefulWidget {
  const PatientItem({
    @required this.item,
   // @required this.parent,
  });


  final item;
  // final _WorkListSearchState parent;

  @override
  _PatientItemState createState() => _PatientItemState();
}

class _PatientItemState extends State<PatientItem> {

  getNexDueDate(assignment) {
    var parsedDate = getParsedDate(assignment['meta']['created_at']['_seconds']);

    if (isBeforeToday(parsedDate)) {
      return DateFormat("MMMM d, y").format(parsedDate).toString() + ' (Overdue)';
    }

    return DateFormat("MMMM d, y").format(parsedDate).toString();
  }

  getParsedDate(seconds) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  isBeforeToday(date) {
    var today = DateTime.now();
    return date.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Patient().setPatientModify(widget.item);
        // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChwPatientRecordsScreen()));
    Navigator.of(context).pushNamed('/chwPatientSummary', arguments: {'prevScreen' : 'home', 'encounterData': {}});
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
                        widget.item['body']['avatar'] == '' && widget.item['body']['avatar'] != null ? 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Image.asset(
                            'assets/images/avatar.png',
                            height: 40.0,
                            width: 40.0,
                          ),
                        ) :
                        CircleAvatar(
                          radius: 30,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Image.network(
                              widget.item['body']['avatar'],
                              height: 70.0,
                              width: 70.0,
                            ),
                          ),
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                        ),
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
                              ],
                            ),
                            SizedBox(height: 5,),

                            Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('village') + ': ', style: TextStyle(fontSize: 16, color: Colors.black87),),
                                Text(widget.item['body']['address']['village'] + ',', style: TextStyle(fontSize: 16, color: Colors.black87),),

                                widget.item['body']['address']['ward'] != null ?
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 5,),
                                    Text(AppLocalizations.of(context).translate('ward') + ': ', style: TextStyle(fontSize: 16, color: Colors.black87),),
                                    Text(widget.item['body']['address']['ward'], style: TextStyle(fontSize: 16, color: Colors.black87),),
                                  ],
                                ) 
                                : Container(),

                                
                              ],
                            ),
                            SizedBox(height: 5,),

                            Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('address') + ': ', style: TextStyle(fontSize: 16, color: Colors.black87),),
                                SizedBox(height: 7,),
                                Text(widget.item['body']['address']['street_name'], style: TextStyle(fontSize: 16, color: Colors.black87),),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('contactNumber') + ': ', style: TextStyle(fontSize: 16, color: Colors.black87),),
                                SizedBox(height: 5,),
                                Text(widget.item['body']['mobile'], style: TextStyle(fontSize: 16, color: Colors.black87),),
                              ],
                            ) 
                          ],
                        ),
                      
                        
                      ],
                    ),
                  ),

                  
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        widget.item['body']['next_assignment'] != null && widget.item['body']['next_assignment']['meta']['created_at']['_seconds'] != null ?
                        Column(
                          children: <Widget>[
                            Text(AppLocalizations.of(context).translate('nextCarePlanAction'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                            Text(getNexDueDate(widget.item['body']['next_assignment']),
                              style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: isBeforeToday(getParsedDate(widget.item['body']['next_assignment']['meta']['created_at']['_seconds'])) ?
                                    kPrimaryRedColor
                                    : 
                                    Colors.black
                                ),
                            )
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),

                        widget.item['meta']['referral_required'] != null && widget.item['meta']['referral_required'] ? 
                        Text(AppLocalizations.of(context).translate('pendingReferral'), style: TextStyle(fontSize: 15, color: kPrimaryYellowColor),) :
                        Container()
                        
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
  // _WorkListSearchState parent;
  // SortDialog({this.parent});

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
                      // widget.parent.setState((){
                      //   widget.parent.clearSort();
                      // });
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
                          // widget.parent.setState(() {
                          //   widget.parent.applySort();
                          // });
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

class LeaderBoard {
  LeaderBoard(this.username, this.score);

  final String username;
  final double score;
}



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/controllers/sync_controller.dart';
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


class ChcpWorkListSearchScreen extends StatefulWidget {
  @override
  _ChcpWorkListSearchScreenState createState() => _ChcpWorkListSearchScreenState();
}

class _ChcpWorkListSearchScreenState extends State<ChcpWorkListSearchScreen> {
  final syncController = Get.put(SyncController());
  List patients = [];
  bool isLoading = true;
  var authUser;

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
                            child: Text(AppLocalizations.of(context).translate('name'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 2,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('fathersOrHusbandsName'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 1,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('age'), style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 2,
                            child: Container(
                            child: Text(AppLocalizations.of(context).translate('streetPara'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),textAlign: TextAlign.center),
                          ),
                        ),
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
                            Navigator.of(context).pushNamed('/chcpWorkListSummary', arguments: {'prevScreen' : 'home', 'encounterData': {}});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                            child: Column(
                              children : [
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
                                        child: Text(pendingPatients[index]['body']['first_name'] + ' ' + pendingPatients[index]['body']['last_name'], style: TextStyle(fontSize: 14, color: Colors.black,),textAlign: TextAlign.center,),
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
                                        child: Text(pendingPatients[index]['body']['age'].toString(), style: TextStyle(fontSize: 14, color: Colors.black),textAlign: TextAlign.center,),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(pendingPatients[index]['body']['address']['street_name'],
                                        style: TextStyle(color: Colors.black87, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),  
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
            )
    );
  }
}



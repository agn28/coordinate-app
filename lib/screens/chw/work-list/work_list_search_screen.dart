import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/worklist_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';
import 'package:nhealth/screens/work-list/work_list_details.dart';

final searchController = TextEditingController();
List allWorklist = [];
List worklist = [];


class ChwWorkListSearchScreen extends StatefulWidget {
  @override
  _WorkListSearchState createState() => _WorkListSearchState();
}

class _WorkListSearchState extends State<ChwWorkListSearchScreen> {

  List patients = [];
  bool isLoading = true;
   var report;
  var bmi;
  var cholesterol;
  var bp;
  var cvd;
  
  loaderHandle(value) {
    setState(() {
      isLoading = value;
    });
  }
  /// Get all the worklist
  _getWorklist() async {

    var data = await WorklistController().getWorklist();

    if (data['error'] != null && data['error']) {
      return Toast.show('Server Error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }

    setState(() {
      allWorklist = data['data'];
      worklist = allWorklist;
      isLoading = false;
    });
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

  search(query) {

    var modifiedWorklist = [...allWorklist].map((item)  {
      item['patient']['name'] = '${item['patient']['first_name']} ${item['patient']['last_name']}' ;
      return item;
    }).toList();

    setState(() {
      worklist = modifiedWorklist
      .where((item) => item['patient']['name']
      .toLowerCase()
      .contains(query.toLowerCase()))
      .toList();
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
    var data = await HealthReportController().getLastReport();
    
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
    var items = worklist.where((item) => item['meta']['status'] == 'pending');

    return items.isNotEmpty ? items.length : 0;
  }
  getCompletedCount() {
    var items = worklist.where((item) => item['meta']['completed'] == 'pending');

    return items.isNotEmpty ? items.length : 0;
  }

  TabController _controller;

  @override
  initState() {
    super.initState();
    allWorklist = [];
    worklist = [];
    _getWorklist();
    getReport();
    patientSort = 'asc';
    dueDateSort = 'asc';
    patientSortActive = false;
    dueDateSortActive = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('workList')),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Auth().logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
            },
            child: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16),),
          )
        ],
        bottom: PreferredSize(child: Container(color: kPrimaryColor, height: 1.0,), preferredSize: Size.fromHeight(1.0)),

      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            !isLoading ? Column(
              children: <Widget>[
                Container(
                  // padding: EdgeInsets.symmetric(vertical: 20),
                  color: kPrimaryColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          border: Border( bottom: BorderSide(color: kPrimaryColor))
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
                    ],
                  )
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        bottom: PreferredSize(child: Container(color: kPrimaryColor, height: 1.0,), preferredSize: Size.fromHeight(1.0)),
                        flexibleSpace: TabBar(
                          labelPadding: EdgeInsets.all(0),
                          indicatorPadding: EdgeInsets.all(0),
                          indicatorColor: Colors.white,
                          tabs: [
                            Tab(
                              child: Text('Pending (${getPendingCount()})', style: TextStyle(fontSize: 17)),
                            ),
                            Tab(
                              child: Text('Completed (${getCompletedCount()})', style: TextStyle(fontSize: 17)),
                            ),
                          ],
                        ),
                      ),
                      body: TabBarView(
                        
                        children: [
                          Container(
                            child: ListView(
                              children: <Widget>[
                                SizedBox(height: 20,),
                                ...worklist.map((item) => 
                                item['meta']['status'] == 'pending' ?

                                WorklistItem(item: item, report: report, bmi: bmi, bp: bp, cvd: cvd, cholesterol: cholesterol, parent: this, onTap: () async {
                                  loaderHandle(true);
                                  var data = await Patient().setPatientById(item['body']['patient_id']);
                                  loaderHandle(false);
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChwPatientRecordsScreen()));
                                },) : Container()).toList(),
                                
                                worklist.length == 0 ? Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  child: Text(AppLocalizations.of(context).translate('worklistFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
                                ) : Container()
                              ],
                            )
                          ),
                          Container(
                            child: ListView(
                              children: <Widget>[
                                SizedBox(height: 20,),
                                ...worklist.map((item) => 
                                item['meta']['status'] == 'completed' ?
                                
                                WorklistItem(item: item, report: report, bmi: bmi, bp: bp, cvd: cvd, cholesterol: cholesterol, parent: this, onTap: () async {
                                  loaderHandle(true);
                                  var data = await Patient().setPatientById(item['body']['patient_id']);
                                  loaderHandle(false);
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChwPatientRecordsScreen()));
                                },) : Container()).toList(),

                                worklist.length == 0 ? Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  child: Text(AppLocalizations.of(context).translate('worklistFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
                                ) : Container()
                              ],
                            )
                          ),
                          
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

class WorklistItem extends StatefulWidget {
  const WorklistItem({
    @required this.item,
    @required this.report,
    @required this.bmi,
    @required this.bp,
    @required this.cvd,
    @required this.cholesterol,
    @required this.parent,
    @required this.onTap,
  });

  final report;
  final bmi;
  final bp;
  final cvd;
  final cholesterol;
  final item;
  final _WorkListSearchState parent;
  final onTap;

  @override
  _WorklistItemState createState() => _WorklistItemState();
}

class _WorklistItemState extends State<WorklistItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                            Text(widget.item['patient'] != null ? widget.item['patient']['first_name'] + ' ' + widget.item['patient']['last_name'] : '', style: TextStyle( fontSize: 19, fontWeight: FontWeight.normal),),
                            SizedBox(height: 7,),
                            Row(
                              children: <Widget>[
                                Text(widget.item['patient'] != null ? widget.item['patient']['age'].toString() + 'Y ' + ' - ' + widget.item['patient']['gender'] : '', style: TextStyle(fontSize: 16, color: kTextGrey),),
                                SizedBox(width: 10,),
                                SizedBox(width: 10,),
                                Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Image.asset('assets/images/icons/fruit.png', width: 11,),
                                      radius: 11,
                                      backgroundColor: kPrimaryRedColor,
                                    ),
                                    SizedBox(width: 5,),
                                    CircleAvatar(
                                      child: Image.asset('assets/images/icons/vegetables.png', width: 11,),
                                      radius: 11,
                                      backgroundColor: kPrimaryRedColor,
                                    ),
                                    SizedBox(width: 5,),
                                    CircleAvatar(
                                      child: Image.asset('assets/images/icons/activity.png', width: 11,),
                                      radius: 11,
                                      backgroundColor: kPrimaryAmberColor,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor['RED']),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('BMI',style: TextStyle(
                                      color: ColorUtils.statusColor['RED'],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ),
                                SizedBox(width: 7,),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor['RED']),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('BP',style: TextStyle(
                                      color: ColorUtils.statusColor['RED'],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ),
                                SizedBox(width: 7,),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor['RED']),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('CVD Risk',style: TextStyle(
                                      color: ColorUtils.statusColor['RED'],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ),
                                SizedBox(width: 7,),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: ColorUtils.statusColor['AMBER']),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: Text('Cholesterol',style: TextStyle(
                                      color: ColorUtils.statusColor['AMBER'],
                                      fontWeight: FontWeight.w500
                                    )  
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            Text(' 3 Interventions due today', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,))
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
  _WorkListSearchState parent;
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
                  Text('Sort by', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),),
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
                        widget.parent.clearSort();
                      });
                    },
                    child: Text('CLEAR SORT', style: TextStyle(fontSize: 15, color: kPrimaryColor, fontWeight: FontWeight.w500),),
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
                      Text('Patients', style: TextStyle(fontSize: 18,),),
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
                      Text('Ascending', style: TextStyle(color: Colors.black)),
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
                      Text('Descending', style: TextStyle(color: Colors.black)),
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
                      Text('Due Date for Intervention', style: TextStyle(fontSize: 18),),
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
                      Text('Ascending', style: TextStyle(color: Colors.black)),
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
                      Text('Descending', style: TextStyle(color: Colors.black)),
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
                            widget.parent.applySort();
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

class LeaderBoard {
  LeaderBoard(this.username, this.score);

  final String username;
  final double score;
}



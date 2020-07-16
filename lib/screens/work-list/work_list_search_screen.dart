import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/controllers/worklist_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/screens/work-list/work_list_details.dart';

final searchController = TextEditingController();
List allWorklist = [];
List worklist = [];

class WorkListSearchScreen extends CupertinoPageRoute {
  WorkListSearchScreen()
      : super(builder: (BuildContext context) => new WorkListSearch());

}

class WorkListSearch extends StatefulWidget {
  @override
  _WorkListSearchState createState() => _WorkListSearchState();
}

class _WorkListSearchState extends State<WorkListSearch> {

  List patients = [];
  bool isLoading = true;
  

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

  

  @override
  initState() {
    super.initState();
    allWorklist = [];
    worklist = [];
    _getWorklist();
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
                        padding: EdgeInsets.only(left: 15, right: 15, top: 20),
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
                      SizedBox(height: 10,),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(right: 15, bottom: 10),
                        child: GestureDetector(
                          onTap: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SortDialog(parent: this);
                            },
                          );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.sort, color: Colors.white,),
                              SizedBox(width: 5),
                              Text(AppLocalizations.of(context).translate('sort'), style: TextStyle(color: Colors.white),)
                            ],
                          )
                        ),
                      ),
                    ],
                  )
                ),
                SizedBox(height: 20,),
                ...worklist.map((item) => 
                item['meta']['status'] == 'pending' ?
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(WorkListDetailsScreen(carePlan: item, parent: this));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: kBackgroundGrey,
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: kLightPrimaryColor,
                            shape: BoxShape.circle
                          ),
                          child: Icon(Icons.perm_identity),
                        ),
                        // item['patient']['avatar'] != null ?
                        // CircleAvatar(
                        //   backgroundColor: kPrimaryRedColor,
                        //   radius: 20,
                        //   backgroundImage: FileImage(File(item['patient']['avatar'])),
                        // ) : Container(),

                        SizedBox(width: 20,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(item['patient'] != null ? item['patient']['first_name'] + ' ' + item['patient']['last_name'] : '', style: TextStyle(fontSize: 18),),
                              SizedBox(height: 12,),
                              Text(item['patient'] != null ? item['patient']['age'].toString() + 'Y ' + ' - ' + StringUtils.capitalize(item['patient']['gender']) : '', style: TextStyle(fontSize: 15),),
                              SizedBox(height: 12,),
                              Text(item['body']['title'], style: TextStyle(fontSize: 15, color: kTextGrey),),
                              SizedBox(height: 12,),
                              Text(_getDuration(item), style: TextStyle(fontSize: 15, color: kTextGrey),),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 35),
                          child: Icon(Icons.arrow_forward, color: kPrimaryColor,),
                        )
                      ],
                    ),
                  ),
                ) : Container()).toList(),

                worklist.length == 0 ? Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(AppLocalizations.of(context).translate('worklistFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
                ) : Container()
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
                        widget.parent.clearSort();
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



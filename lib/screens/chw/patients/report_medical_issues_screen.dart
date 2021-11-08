import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/medical_issues_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

int selectedOption = -1;
var _questions = {};
int _secondQuestionOption = 0;
int _selectedOption = 1;
List allMedications =  ['fever', 'cough' ];
List _medications = [];
final problemController = TextEditingController();
bool showItems = false;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


class ReportMedicalIssuesScreen extends StatefulWidget {
  @override
  _ReportMedicalIssuesScreenState createState() => _ReportMedicalIssuesScreenState();
}

class _ReportMedicalIssuesScreenState extends State<ReportMedicalIssuesScreen> {
  int _currentStep = 0; 
  bool isLoading = false;

 @override
 void initState() {
    super.initState();
    setState(() {
      _questions = Questionnaire().questions['current_medication'];
      _selectedOption = 1;
    });
    getMedicalIssues();
  }

  setLoader(value) {
    setState(() {
      isLoading = value;
    });
  }

  getMedicalIssues() async {
    var data = await MedicalIssuesController().getIssues();
    if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
    if (data['data'].length > 0) {
      allMedications = [];
      data['data'].forEach((item) => {
        allMedications.add(item['name'])
      });
    }
    _medications = allMedications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('reportMedicalIssues'), style: TextStyle(color: kPrimaryColor)),
        backgroundColor: Colors.white,
        elevation: 0.0,
        bottomOpacity: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),

      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            setState(() {
              showItems = false;
            });
          },
          child: 
            Stack(
              children: <Widget>[
                !isLoading ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PatientTopbar(),
                    Container(
                      height: 70,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        border: Border(
                        )
                      ),
                      child: Text(AppLocalizations.of(context).translate('issueInVisit'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
                    ),


                    Container(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                      child: MedicationList(parent: this)
                    ),
                    SizedBox(height: 10,),
                  ],
                )
              
              
                : Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Color(0x90FFFFFF),
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
                  ),
                ) ,
              ],
            ),
            
            
            
            
        ),
      ),
    );
  }

}



 class MedicationList extends StatefulWidget {
   MedicationList({this.parent});
   final _ReportMedicalIssuesScreenState parent;

  @override
  _MedicationListState createState() => _MedicationListState();
}

var selectedDiseases = [];
final lastVisitDateController = TextEditingController();
var _selectedItem = [];
class _MedicationListState extends State<MedicationList> {

  
  var _checkValue = {};

  @override
  void initState() {
    super.initState();
    _preparedata();
    _selectedItem = [];
  }

  _preparedata() async {
    _preapareCheckboxValue();
  }
  _preapareCheckboxValue() {
    _medications.forEach((item) {
      selectedDiseases.indexOf(item) == -1 ? _checkValue[item] = false : _checkValue[item] = true;
    });

  }

  _addSelectedItem(value, index) {
    
    if (_selectedItem.indexOf(value) == -1) {
      setState(() {
        _selectedItem.add(value);
      });
    }
    setState(() {
      showItems = false;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showItems = false;
        });
      },
      child: Container(
        width: double.infinity,
        height: 500.0,
        child: Form(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10,),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('reportedSymptoms'), style: TextStyle(fontSize: 18),),
                  ],
                ),
              ),

              SizedBox(height: 10,),
              
              SizedBox(height: 10,),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            
                            TextField(
                              
                              style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                              onChanged: (value) => {
                                setState(() {
                                  _medications = allMedications
                                    .where((item) => item
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                    .toList();
                                })
                              },
                              onTap: () {
                                setState(() {
                                  showItems = true;
                                });
                              },
                              decoration: InputDecoration(
                                counterText: ' ',
                                contentPadding: EdgeInsets.only(top: 10, bottom: 10,),
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: kSecondaryTextField,
                                border: new OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: 'Search',
                                hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                              )
                            )
                          ],
                        )
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          // direction: Axis.horizontal,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          
                          children: <Widget>[
                            ..._selectedItem.map((item) => 
                              Container(
                                margin: EdgeInsets.only(right: 10, bottom: 10),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: kBorderLighter)
                                ),
                                child: Wrap(
                                  children: <Widget>[
                                    Text(item, style: TextStyle(color: Colors.black87),),
                                    SizedBox(width: 5,),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _checkValue[item] = false;
                                          _selectedItem.removeAt(_selectedItem.indexOf(item));
                                        });
                                      },
                                      child: Icon(Icons.close, size: 15, color: Colors.black87,),
                                    ),
                                  ],
                                )
                              ),
                            ).toList()
                          ],
                        )
                      ),

                    ],
                  ),

                  SizedBox(height: 50,),
                  showItems ? Container(
                    margin: EdgeInsets.only(top: 60),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 0.2,
                          blurRadius: 20,
                          offset: Offset(0, 5), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      child: Column(
                        children: <Widget>[
                          ..._medications.map((item) {
                            return InkWell(
                              onTap: () {
                                _addSelectedItem(item, _medications.indexOf(item));
                              },
                              child: Container(
                                height: 50,
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 20,),
                                    
                                    Text(StringUtils.capitalize(_medications[_medications.indexOf(item)]), style: TextStyle(fontSize: 17),)
                                  ],
                                )
                              ),
                            );
                          }).toList()
                        ],
                      ),
                    )
                  ) : Container(),

                ],
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.3),
              //         spreadRadius: 0.2,
              //         blurRadius: 20,
              //         offset: Offset(0, 5), // changes position of shadow
              //       ),
              //     ],
              //   ),
              //   child: Card(
              //     elevation: 0,
              //     child: ListView.builder(
              //       scrollDirection: Axis.vertical,
              //       itemCount: _medications.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         return Container(
              //           height: 50,
              //           child: Row(
              //             children: <Widget>[
              //               SizedBox(width: 10,),
              //               Checkbox(
              //                 activeColor: kPrimaryColor,
              //                 value: _checkValue[_medications[index]],
              //                 onChanged: (value) {
              //                   _updateCheckBox(value, index);
              //                 },
              //               ),
              //               Text(StringUtils.capitalize(_medications[index]), style: TextStyle(fontSize: 17),)
              //             ],
              //           )
              //         );
              //       },
              //     ),
              //   )
              // ),


              SizedBox(height: 40,),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 20, right: 20),
                  filled: true,
                  fillColor: kSecondaryTextField,
                  border: new UnderlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    )
                  ),
                
                  hintText: AppLocalizations.of(context).translate('comments'),
                  hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                ),
              ),

              Container(
                width: double.infinity,
                margin: EdgeInsets.only( top: 20),
                height: 50,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(3)
                ),
                child: FlatButton(
                  onPressed: () async {
                    // Navigator.of(_scaffoldKey.currentContext).pushNamed('/chwNavigation');
                    widget.parent.setLoader(true);
                    await Future.delayed(const Duration(seconds: 5));

                    var result = '';
                    
                    result = await AssessmentController().create('visit', 'follow-up', '');
                    widget.parent.setLoader(false);

                    Navigator.of(_scaffoldKey.currentContext).pushNamed('/chwNavigation');
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(AppLocalizations.of(context).translate('completeVisit'), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                ),
              ),

              
            ],
          )
        ),
      ),
    );
  }
}

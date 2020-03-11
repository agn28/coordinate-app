import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_records_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';

import '../../../app_localizations.dart';


final birthDateController = TextEditingController();
final birthmonthController = TextEditingController();
final birthYearController = TextEditingController();
List patients = [];
List allPatients = [];
final searchController = TextEditingController();
bool isPendingRecommendation = false;

class PatientSearchScreen extends CupertinoPageRoute {
  PatientSearchScreen()
      : super(builder: (BuildContext context) => new PatientSearch());

}

class PatientSearch extends StatefulWidget {
  @override
  _PatientSearchState createState() => _PatientSearchState();
}

class _PatientSearchState extends State<PatientSearch> {
  bool isLoading = false;
  @override
  initState() {
    super.initState();
    // getPatients();
    isLoading = true;
    getLivePatients();
  }

  getPatients() async {
    
    var data = await PatientController().getAllPatients();

    setState(() {
      allPatients = data;
      patients = allPatients;
    });
  }

  getLivePatients() async {
    
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }

    setState(() {
      isLoading = true;
    });

    var data = await PatientController().getAllLivePatients();

    if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }

    var parsedPatients = [];

    for(var item in data['data']) {
      parsedPatients.add({
        'uuid': item['id'],
        'data': item['body'],
        'meta': item['meta']
      });
    }

    setState(() {
      allPatients = parsedPatients;
      patients = allPatients;
      isLoading = false;
    });
  }

  search(query) {
    var modifiedPatients = [...allPatients].map((item)  {
      item['data']['name'] = '${item['data']['first_name']} ${item['data']['last_name']}' ;
      return item;
    }).toList();

    setState(() {
      patients = modifiedPatients
        .where((item) => item['data']['name']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    });
  }

  LeaderBoard _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('patients')),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Icon(Icons.person_add, color: Colors.white, size: 20,),
                SizedBox(height: 5,),
                Text(AppLocalizations.of(context).translate('newPatient'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),)
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(RegisterPatientScreen());
            },
          ),
          Configs().configAvailable('isBarcode') ? FlatButton(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Icon(Icons.line_weight, color: Colors.white, size: 20,),
                SizedBox(height: 5,),
                Text(AppLocalizations.of(context).translate('scanBarcode'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),)
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(RegisterPatientScreen());
            },
          ): Container(),

          Configs().configAvailable('isThumbprint') ? FlatButton(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Icon(Icons.fingerprint, color: Colors.white, size: 20,),
                SizedBox(height: 5,),
                Text(AppLocalizations.of(context).translate('useThumbprint'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),)
              ],
            ),
            onPressed: () {},
          ) : Container()
        ],
      ),
      body: Stack(
        children: <Widget>[
          !isLoading ? SingleChildScrollView(
            child: Column(
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
                                  patients = allPatients;
                                });
                              },
                              icon: Icon(Icons.cancel, color: kTextGrey, size: 25,)
                            ),
                            border: InputBorder.none,
                            hintText: "Search here...",
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              right: 20,
                              top: 14,
                              bottom: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 2),
                            child: Row(
                              children: <Widget>[
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: Colors.white
                                  ),
                                  child: Checkbox(
                                    materialTapTargetSize: null,
                                    activeColor: Colors.white,
                                    checkColor: kPrimaryColor,
                                    value: isPendingRecommendation,
                                    onChanged: (value) {
                                      setState(() {
                                        isPendingRecommendation = value;
                                      });
                                    },
                                  ),
                                ),
                                Text(AppLocalizations.of(context).translate('pendingRecommendation'), style: TextStyle(color: Colors.white),)
                              ],
                            ),
                          ),
                          
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(right: 15),
                            child: GestureDetector(
                              onTap: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FiltersDialog(parent: this,);
                                },
                              );
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.filter_list, color: Colors.white,),
                                  SizedBox(width: 10),
                                  Text(AppLocalizations.of(context).translate('filters'), style: TextStyle(color: Colors.white),)
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,)
                    ],
                  )
                ),
                SizedBox(height: 20,),
                ...patients.map((item) => GestureDetector(
                  onTap: () {
                    Patient().setPatient(item);
                      Navigator.of(context).push(PatientRecordsScreen());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(item['data']['first_name'] + ' ' + item['data']['last_name'],
                            style: TextStyle(color: Colors.black87, fontSize: 18),
                          ),
                        ),
                        Expanded(
                          child: Text(item['data']['age'].toString() + 'Y ' + '${item['data']['gender'][0].toUpperCase()}' + ' - ' + item['data']['nid'].toString(), 
                          style: TextStyle(
                              color: Colors.black38,
                              fontWeight: FontWeight.w400
                            ), 
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
                patients.length == 0 ? Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(AppLocalizations.of(context).translate('noPatientFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
                ) : Container()
              ],
            ),
          ) : Container(
            height: double.infinity,
            width: double.infinity,
            color: Color(0x20FFFFFF),
            child: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),backgroundColor: Color(0x30FFFFFF),)
            ),
          ),
        ],
      ),
    );
  }
}

// Column(
//   children: <Widget>[
//     CustomSearchWidget(
//       listContainerHeight: 500,
//       dataList: [...patients],
//       hideSearchBoxWhenItemSelected: false,
//       queryBuilder: (query, list) {
//         return [...patients]
//           .where((item) => item['data']['name']
//           .toLowerCase()
//           .contains(query.toLowerCase()))
//           .toList();
//       },
//       popupListItemBuilder: (item) {
//         print(item);
//         return PopupListItemWidget(item);
//       },
//       selectedItemBuilder: (selectedItem, deleteSelectedItem) {
//         return SelectedItemWidget(selectedItem, deleteSelectedItem);
//       },
//       // widget customization
//       // noItemsFoundWidget: NoItemsFound(),
//       textFieldBuilder: (controller, focusNode) {
//         return MyTextField(controller, focusNode);
//       },
//       onItemSelected: (item) {
//         setState(() {
//           _selectedItem = item;
//         });
//       },
//     ),
//     Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         patients.length == 0 ? Container(
//           alignment: Alignment.centerLeft,
//           padding: EdgeInsets.only(top: 15),
//           child: Text('No patient found', style: TextStyle(color: Colors.white, fontSize: 20),),
//         ) :
//         Container(
//           alignment: Alignment.centerLeft,
//           padding: EdgeInsets.only(top: 15),
//           child: Text('Pending Recommendations Only', style: TextStyle(color: Colors.white),),
//         ),
        
//         Container(
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.only(top: 15),
//             child: GestureDetector(
//               onTap: () async {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return FiltersDialog(parent: this,);
//                 },
//               );
//               },
//               child: Row(
//                 children: <Widget>[
//                   Icon(Icons.filter_list, color: Colors.white,),
//                   SizedBox(width: 10),
//                   Text('Filters', style: TextStyle(color: Colors.white),)
//                 ],
//               )
//             ),
//           ),
//       ],
//     )
//   ],
// )


class DiseasesDialog extends StatefulWidget {
  _FiltersDialogState parent;

  DiseasesDialog({this.parent});

  @override
  _DiseasesDialogState createState() => _DiseasesDialogState();
}

var selectedDiseases = [];
final lastVisitDateController = TextEditingController();
class _DiseasesDialogState extends State<DiseasesDialog> {

  List _allDiseases = ['lupus', 'diabetes', 'bronchitis', 'hypertension', 'cancer', 'Ciliac', 'Scleroderma', 'Abulia', 'Agraphia', 'Chorea', 'Coma' ];
  List _diseases = [];
  var _checkValue = {};

  var _selectedItem = selectedDiseases;

  @override
  void initState() {
    super.initState();
    setState(() {
      _diseases = _allDiseases;
    });
    _preapareCheckboxValue();
    
  }
  _preapareCheckboxValue() {
    _diseases.forEach((item) => {
      selectedDiseases.indexOf(item) == -1 ? _checkValue[item] = false : _checkValue[item] = true
    });

  }

  _updateCheckBox(value, index) {
    if (value == true && _selectedItem.length == 3) {
      return Toast.show(AppLocalizations.of(context).translate('notMoreThanThree'), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }

    setState(() {
      value ? _selectedItem.add(_diseases[index]) : _selectedItem.removeAt(_selectedItem.indexOf(_diseases[index]));
      _checkValue[_diseases[index]] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 630.0,
        color: Colors.white,
        child: Form(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('selectDiseases'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                  ],
                ),
              ),

              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('selectThreeDiseases'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    
                    TextField(
                      
                      style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                      onChanged: (value) => {
                        setState(() {
                          _diseases = _allDiseases
                            .where((item) => item
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                            .toList();
                        })
                      },
                      decoration: InputDecoration(
                        counterText: ' ',
                        contentPadding: EdgeInsets.only(top: 18, bottom: 18, left: 10, right: 10),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: kSecondaryTextField,
                        border: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          )
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                      )
                    )
                  ],
                )
              ),

              Container(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _diseases.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 10,),
                          Checkbox(
                            activeColor: kPrimaryColor,
                            value: _checkValue[_diseases[index]],
                            onChanged: (value) {
                              _updateCheckBox(value, index);
                            },
                          ),
                          Text(StringUtils.capitalize(_diseases[index]), style: TextStyle(fontSize: 17),)
                        ],
                      )
                    );
                  },
                )
              ),
              
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              _selectedItem = [];
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16),)
                        ),
                        SizedBox(width: 30,),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            selectedDiseases = _selectedItem;
                            this.widget.parent.setState(() {
                              this.widget.parent.getSelectedDiseaseText();
                            });
                          },
                          child: Text(AppLocalizations.of(context).translate('apply'), style: TextStyle(color: kPrimaryColor, fontSize: 16))
                        ),
                      ],
                    )
                  )
                ],
              )
            ],
          )
        ),
      )
      
    );
  }
}


class FiltersDialog extends StatefulWidget {
  
  _PatientSearchState parent;
  FiltersDialog({this.parent});

  @override
  _FiltersDialogState createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {

  final format = DateFormat("yyyy-MM-dd");
  String _selectedDiseaseText = '';

  @override
  void initState() {
    super.initState();

    getSelectedDiseaseText();
  }

  getSelectedDiseaseText() {
    if (selectedDiseases.length > 0) {
      setState(() {
        _selectedDiseaseText = selectedDiseases.join(', ');
      });
    } else {
      setState(() {
        _selectedDiseaseText = 'Select Diagnosed Disease(s)';
      });
    }
  }

  applyFilter() async {
    await this.widget.parent.getPatients();
    var birthDate = '';
    if (birthDateController.text != '' && birthMonthController.text != '' && birthYearController.text != '') {
      birthDate = birthYearController.text + '-' + birthMonthController.text + '-' + birthDateController.text;
    }

    if (birthDate != '') {
      this.widget.parent.setState(() {
        patients = patients.where((item) => item['data']['birth_date'] == birthDate).toList();
      });
    }

    if (lastVisitDateController.text != '') {
      var assessments = await AssessmentController().getAllAssessments();

      var filteredAssessments = assessments.where((item) => item['data']['assessment_date'] == lastVisitDateController.text).toList();
      var filteredPatients = [];
      patients.forEach((patient) { 
        filteredAssessments.forEach((assessment) {
          if (assessment['data']['patient_id'] == patient['uuid']) {
            filteredPatients.add(patient);
          } 
        });
      });

      this.widget.parent.setState(() => {
        patients = filteredPatients
      });
    }
  }

  clearFilters() {
    setState(() {
      birthDateController.clear();
      birthMonthController.clear();
      birthYearController.clear();
      lastVisitDateController.clear();
      selectedDiseases = [];
    });

    this.widget.parent.getPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 530.0,
        color: Colors.white,
        child: Form(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30,),
              GestureDetector(
                onTap: () {
                  clearFilters();
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('filters'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                      Text(AppLocalizations.of(context).translate('clearFilter'), style: TextStyle(fontSize: 15, color: kPrimaryColor, fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Date of Birth', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 18,
                            bottomPadding: 18,
                            hintText: 'dd',
                            controller: birthDateController,
                            name: "Date",
                            validation: true,
                            type: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 18,
                            bottomPadding: 18,
                            hintText: 'mm',
                            controller: birthMonthController,
                            name: "Month",
                            validation: true,
                            type: TextInputType.number
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 18,
                            bottomPadding: 18,
                            hintText: 'yyyy',
                            controller: birthYearController,
                            name: "Year",
                            validation: true,
                            type: TextInputType.number
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ),
              
              Divider(),

              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('diagnosedDiseases'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    Container(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: kSecondaryTextField,
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_selectedDiseaseText, style: TextStyle(fontSize: 16, color: Colors.black54),),
                              Icon(Icons.arrow_drop_down)
                            ],
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return DiseasesDialog(parent: this,);
                              },
                            );
                          },
                        )
                      )
                    ),
                  ],
                )
              ),
              SizedBox(height: 20,),
              
              Divider(),

              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: DateTimeField(
                  format: format,
                  controller: lastVisitDateController,
                  decoration: InputDecoration(
                    hintText: 'Last Visit Date',
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
                  
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
              ),
            
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16),)
                        ),
                        SizedBox(width: 30,),
                        FlatButton(
                          onPressed: () {
                            applyFilter();
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('apply'), style: TextStyle(color: kPrimaryColor, fontSize: 16))
                        ),
                      ],
                    )
                  )
                ],
              )
            ],
          )
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

class SelectedItemWidget extends StatelessWidget {
  const SelectedItemWidget(this.selectedItem, this.deleteSelectedItem);

  final selectedItem;
  final VoidCallback deleteSelectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField(this.controller, this.focusNode);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
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
              controller.text = '';
             },
            icon: Icon(Icons.cancel, color: kTextGrey, size: 25,)
          ),
          border: InputBorder.none,
          hintText: "AppLocalizations.of(context).translate('searchHere')",
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            bottom: 14,
          ),
        ),
      ),
    );
  }
}


class PopupListItemWidget extends StatelessWidget {
  const PopupListItemWidget(this.item);

  final item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Patient().setPatient(item);
          Navigator.of(context).push(PatientRecordsScreen());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(item['data']['name'],
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
            Expanded(
              child: Text(item['data']['age'].toString() + 'Y ' + '${item['data']['gender'][0].toUpperCase()}' + ' - ' + item['data']['nid'].toString(), 
              style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400
                ), 
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

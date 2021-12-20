import 'dart:convert';
import 'package:basic_utils/basic_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:get/get.dart';
import '../../../../app_localizations.dart';


final birthDateController = TextEditingController();
final birthmonthController = TextEditingController();
final birthYearController = TextEditingController();
final ageFromController = TextEditingController();
final ageToController = TextEditingController();
final upazilaController = TextEditingController();
final unionController = TextEditingController();
final villageController = TextEditingController();
List patients = [];
List allPatients = [];
final searchController = TextEditingController();
bool isPendingRecommendation = false;

// class PatientSearchScreen extends CupertinoPageRoute {
//   PatientSearchScreen()
//       : super(builder: (BuildContext context) => new PatientSearch());

// }

class FirstCenterSearchScreen extends StatefulWidget {
  @override
  _FirstCenterSearchState createState() => _FirstCenterSearchState();
}

class _FirstCenterSearchState extends State<FirstCenterSearchScreen> {
  final syncController = Get.put(SyncController());
  bool isLoading = false;
  @override
  initState() {
    super.initState();
    setState(() {
      searchController.text = '';
    });
    isLoading = true;
    clearFilters();
    getLivePatients();
  }

  clearFilters() {
    setState(() {
      ageFromController.clear();
      ageToController.clear();
      selectedUpazila = {};
      unionController.clear();
      villageController.clear();
      birthDateController.clear();
      birthMonthController.clear();
      birthYearController.clear();
      lastVisitDateController.clear();
      selectedDiseases = [];
    });
  }

  getLivePatients() async {
    setState(() {
      isLoading = true;
      searchController.text = '';
      print('getPatients before query : ${DateTime.now()}');
    });

    var parsedLocalPatient = [];
    var allLocalPatients = await PatientController().getPatientsWithAssesments();
    for(var localPatient in allLocalPatients) {
      var parsedData = jsonDecode(localPatient['data']);
      if (localPatient['assessment_type'] == 'registration'
        || localPatient['assessment_screening_type'] != 'follow-up'
        && (localPatient['assessment_status'] != null || localPatient['assessment_status'] != "" || localPatient['assessment_status'] != "complete")) {
        //TODO: Will remove this later
        if(localPatient['assessment_status'] == 'incomplete') {
          parsedData['body']['incomplete_encounter'] = true;
        }
        parsedLocalPatient.add({
          'id': localPatient['id'],
          'data': parsedData['body'],
          'meta': parsedData['meta'],
        });
      }
    }

    setState(() {
      allPatients = parsedLocalPatient;
      patients = allPatients;
      isLoading = false;
    });
  }

  search(query) {
    var searchKey = Helpers().isNumeric(query) ? 'mobile' : 'name';

    var modifiedPatients = [...allPatients].map((item)  {
      item['data']['name'] = '${item['data']['first_name']} ${item['data']['last_name']}' ;
      return item;
    }).toList();

    setState(() {
      patients = modifiedPatients
        .where((item) => item['data'][searchKey]
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home');
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        //resizeToAvoidBottomPadding: false,
        //Migrate Projects
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
        body: Column(
                children: <Widget>[
                  Container(
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
                              child: Text(AppLocalizations.of(context).translate('age'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),textAlign: TextAlign.center),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Expanded(
                            flex: 2,
                              child: Container(
                              child: Text(AppLocalizations.of(context).translate('streetPara'), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),textAlign: TextAlign.center),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Expanded(
                            flex: 3,
                              child: Container(
                              child: Text(AppLocalizations.of(context).translate('status'), style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),textAlign: TextAlign.center),
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
                  ) : patients.length > 0 ? Expanded(
                    child: ListView.builder(
                      itemCount: patients.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index){
                        return GestureDetector(
                          onTap: () {
                            Patient().setPatient(patients[index]);
                            Navigator.of(context).pushNamed('/ncdPatientSummary');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Text(patients[index]['data']['first_name'] + ' ' + patients[index]['data']['last_name'],
                                    style: TextStyle(color: Colors.black87, fontSize: 18),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(patients[index]['data']['gender'] == 'male' 
                                      ? patients[index]['data']['father_name']
                                      : patients[index]['data']['husband_name'] != null && patients[index]['data']['husband_name'].isNotEmpty ? patients[index]['data']['husband_name'] : 'n/a',
                                    style: TextStyle(color: Colors.black87, fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(patients[index]['data']['age'].toString(), 
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400
                                    ), 
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(patients[index]['data']['address']['street_name'],
                                    style: TextStyle(color: Colors.black87, fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ),                      
                                Expanded(
                                  flex: 3,
                                  child: patients[index]['data']['incomplete_encounter'] != null && patients[index]['data']['incomplete_encounter'] ? 
                                    Container(
                                        alignment: Alignment.center,
                                        width: 160,
                                        height: 24,
                                        color: Colors.red[400],
                                        child: Text(AppLocalizations.of(context).translate('incompleteEncounter'),
                                          style: TextStyle(color: Colors.white, fontSize: 15),
                                        ),
                                    ) : Container(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  ) : Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text(AppLocalizations.of(context).translate('noPatientFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
                  ), 
                ],
              ),
      ),
    );
  }
}


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
                        hintText: AppLocalizations.of(context).translate("search"),
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


List filteredUpazilas = [];
var selectedUpazila = {};
var selectedDistrict = {};

class FiltersDialog extends StatefulWidget {
  
  _FirstCenterSearchState parent;
  FiltersDialog({this.parent});

  @override
  _FiltersDialogState createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {

  final format = DateFormat("yyyy-MM-dd");
  String _selectedDiseaseText = '';

  var selectedDobType = 'age';
  @override
  void initState() {
    super.initState();
    getLocations();
    getSelectedDiseaseText();
  }

  getLocations() async {
    setState(() {
      isLoading = true;
    });
    var locationData = await PatientController().getLocations();
    var districtsData = [];
    if (locationData['error'] != null && !locationData['error']) {
      districtsData = locationData['data'][0]['districts'];
    }
    setState(() {
      isLoading = false;
      districts = districtsData;
    });
    populateUpazilas();
  }

  populateUpazilas() async {
    var data = await Auth().getStorageAuth();

    setState(() {
      filteredUpazilas = [];
      selectedDistrict = {};
      if (data['address'].isNotEmpty) {
        var authUserDistrict = districts.where(
            (district) => district['name'] == data['address']['district']);
        if (authUserDistrict.isNotEmpty) {
          selectedDistrict = authUserDistrict.first;
          var authUserUpazila = selectedDistrict['thanas'].where(
              (upazila) => upazila['name'] == data['address']['upazila']);
          if (authUserUpazila.isNotEmpty) {
            filteredUpazilas = selectedDistrict['thanas'];
          } else {
            selectedUpazila = {};
          }
        } else {
          selectedDistrict = {};
          selectedUpazila = {};
        }
      }
    });
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
    await this.widget.parent.getLivePatients();
    if (ageFromController.text != '' || ageToController.text != '') {
      var filteredPatients = [];
      var startingAge = ageFromController.text != '' ? int.parse(ageFromController.text) : 0 ;
      var endingAge = ageToController.text != '' ? int.parse(ageToController.text) : 150 ;
      filteredPatients =  allPatients.where((item) => item['data']['age'] >= startingAge && item['data']['age'] <= endingAge).toList();
      this.widget.parent.setState(() => {
        allPatients = filteredPatients,
        patients = allPatients
      });
    }

    if (selectedUpazila.isNotEmpty) {
      var filteredPatients = [];
      filteredPatients =  allPatients.where((item) => item['data']['address']['upazila'] == selectedUpazila['name']).toList();
      this.widget.parent.setState(() => {
        allPatients = filteredPatients,
        patients = allPatients
      });
    }

    if (unionController.text != '') {
      var filteredPatients = [];
      filteredPatients =  allPatients.where((item) => item['data']['address']['union'] == unionController.text).toList();
      this.widget.parent.setState(() => {
        allPatients = filteredPatients,
        patients = allPatients
      });
    }

    if (villageController.text != '') {
      var filteredPatients = [];
      filteredPatients =  allPatients.where((item) => item['data']['address']['union'] == villageController.text).toList();
      this.widget.parent.setState(() => {
        allPatients = filteredPatients,
        patients = allPatients
      });
    }

    var birthDate = '';
    if (birthDateController.text != '' && birthMonthController.text != '' && birthYearController.text != '') {
      birthDate = birthYearController.text + '-' + birthMonthController.text + '-' + birthDateController.text;
    }

    if (birthDate != '') {
      var filteredPatients = [];
      filteredPatients = patients.where((item) => item['data']['birth_date'] == birthDate).toList();
      this.widget.parent.setState(() => {
        allPatients = filteredPatients,
        patients = allPatients
      });
    }

    if (lastVisitDateController.text != '') {
      var assessments = await AssessmentController().getAllAssessments();

      var filteredAssessments = assessments.where((item) => item['data']['assessment_date'] == lastVisitDateController.text).toList();
      var filteredPatients = [];
      patients.forEach((patient) { 
        filteredAssessments.forEach((assessment) {
          if (assessment['data']['patient_id'] == patient['id']) {
            filteredPatients.add(patient);
          } 
        });
      });

      this.widget.parent.setState(() => {
        allPatients = filteredPatients,
        patients = allPatients
      });
    }
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
                onTap: () async {
                  this.widget.parent.clearFilters();
                  await this.widget.parent.getLivePatients();
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
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'age',
                          groupValue: selectedDobType,
                          onChanged: (value) {
                            setState(() {
                              selectedDobType = value;
                            });
                          },
                        ),
                        Text(
                          AppLocalizations.of(context).translate('ageRange'),
                        ),
                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'dob',
                          groupValue: selectedDobType,
                          onChanged: (value) {
                            setState(() {
                              selectedDobType = value;
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context).translate('dateOfBirth'),style: TextStyle(color: Colors.black)),
                        SizedBox(width: 10,),
                        Text('(DD/MM/YYYY)',style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              selectedDobType == 'dob' ?
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate("dateOfBirth"), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText: AppLocalizations.of(context).translate("dd"),
                            controller: birthDateController,
                            name: "Date",
                            validation: true,
                            type: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText: AppLocalizations.of(context).translate("mm"),
                            controller: birthMonthController,
                            name: "Month",
                            validation: true,
                            type: TextInputType.number
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText:AppLocalizations.of(context).translate("yy"),
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
              )
              : Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate("ageRange"), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText: AppLocalizations.of(context).translate('year'),
                            controller: ageFromController,
                            name: 'Age From',
                            type: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          height: 65,
                          child: Center(child: Text(AppLocalizations.of(context).translate("from"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),))
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText: AppLocalizations.of(context).translate('year'),
                            controller: ageToController,
                            name: 'Age To',
                            type: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          height: 65,
                          child: Center(child: Text(AppLocalizations.of(context).translate("to"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),))
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: DropdownSearch(
                  validator: (v) => v == null ? "required field" : null,
                  hint: AppLocalizations.of(context).translate('upazila'),
                  mode: Mode.BOTTOM_SHEET,
                  items: filteredUpazilas,
                  // showClearButton: true,
                  dropdownSearchDecoration: InputDecoration(
                    counterText: ' ',
                    contentPadding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 10, right: 10),
                    filled: true,
                    fillColor: kSecondaryTextField,
                    border: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        )),
                    hintText: 'Upazilas',
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedUpazila = value;

                      // districtController.text = value;
                    });
                  },
                  selectedItem: selectedUpazila['name'],
                  popupItemBuilder: _customPopupItemBuilderExample2,
                  showSearchBox: true,
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('union'),
                  controller: unionController,
                  name: AppLocalizations.of(context).translate('union'),
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('village'),
                  controller: villageController,
                  name: AppLocalizations.of(context).translate('village'),
                ),
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
                    hintText: AppLocalizations.of(context).translate("lastVisitDate"),
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

Widget _customPopupItemBuilderExample2(
    BuildContext context, item, bool isSelected) {
  return SingleChildScrollView(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item['name']),
      ),
    ),
  );
}

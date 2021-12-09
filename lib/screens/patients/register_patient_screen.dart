import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_success_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../custom-classes/custom_stepper.dart';

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final fatherNameController = TextEditingController();
// final gender = TextEditingController();
final dobController = TextEditingController();
final birthDateController = TextEditingController();
final birthMonthController = TextEditingController();
final birthYearController = TextEditingController();
final ageController = TextEditingController();
final districtController = TextEditingController();
final postalCodeController = TextEditingController();
final townController = TextEditingController();
final upazilaController = TextEditingController();
final villageController = TextEditingController();
final hhNumberController = TextEditingController();
final serialController = TextEditingController();
final unionController = TextEditingController();
final streetNameController = TextEditingController();
final mobilePhoneController = TextEditingController();
final emailController = TextEditingController();
final nidController = TextEditingController();
final bracPatientIdContoller = TextEditingController();
final creationDateTimeController = TextEditingController();

final contactFirstNameController = TextEditingController();
final contactLastNameController = TextEditingController();
final contactRelationshipController = TextEditingController();
final contactMobilePhoneController = TextEditingController();
final alternativePhoneController = TextEditingController();
final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _contactFormKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
String uploadedImageUrl = '';
bool isEditState = false;
String selectedGender = 'male';
String selectedGuardian = 'father';
var selectedCenters = 0;
var centers;
List relationships = [
  'father',
  'mother',
  'sister',
  'brother',
  'spouse',
  'uncle',
  'aunt'
];
int selectedRelation;
var selectedDistrict = {};
var selectedUpazila = {};
bool isContactAddressSame = false;
var districts = [];
var upazilas = [];

int selectedOption = -1;
var _questions = {};
int _secondQuestionOption = 0;
int _selectedOption = 1;
List allMedications = ['fever', 'cough'];
List allDestricts = [];
List allUpazilas = [];
List filteredUpazilas = [];
List _medications = [];
final problemController = TextEditingController();
bool showItems = false;
bool showUpazilaItems = false;

var selectedDiseases = [];
var _selectedItem = [];

class RegisterPatientScreen extends CupertinoPageRoute {
  bool isEdit = false;
  RegisterPatientScreen({this.isEdit})
      : super(
            builder: (BuildContext context) => new RegisterPatient(
                  isEdit: isEdit,
                ));
}

class RegisterPatient extends StatefulWidget {

  final isEdit;
  RegisterPatient({this.isEdit});
  @override
  _RegisterPatientState createState() => _RegisterPatientState();
}

int _currentStep = 0;

var centersList = [];

class _RegisterPatientState extends State<RegisterPatient> {
  final syncController = Get.put(SyncController());
  String nextText = 'NEXT';
  bool isLoading = false;

  var subscription;

  @override
  void initState() {
    super.initState();
    getAddresses();
    _prepareState();
    _checkAuth();
    getCenters();
    // selectedDistrict = {};
    // selectedUpazila = {};
    _currentStep = 0;
  }

  nextStep() {
    setState(() {
      _currentStep += 1;
    });
  }

  populateLocation() async {
    var data = await Auth().getStorageAuth();

    setState(() {
      filteredUpazilas = [];
      selectedDistrict = {};
      selectedUpazila = {};
      if (data['address'].isNotEmpty) {
        unionController.text = data['address']['union'] ?? '';
        villageController.text = data['address']['village'] ?? '';
        var authUserDistrict = districts.where((district) => district['name'] == data['address']['district']);
        if (authUserDistrict.isNotEmpty) {
          selectedDistrict = authUserDistrict.first;
          var authUserUpazila = selectedDistrict['thanas'].where((upazila) => upazila['name'] == data['address']['upazila']);
          if(authUserUpazila.isNotEmpty){
            selectedUpazila = authUserUpazila.first;
            upazilas = selectedDistrict['thanas'];
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
  getCenters () async{

    setState(() {
      isLoading = true;
    });
    var centerData = await PatientController().getCenter();
    setState(() {
      isLoading = false;
    });

   
    if (centerData['error'] != null && !centerData['error']) {
      centersList = centerData['data'];
    }
   
  }




  getAddresses() async {
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
    });

    // return;

    setState(() {
      districts = districtsData;
      allDestricts = districts;
      // upazilas = json.decode(upazilasData);
      // allUpazilas = upazilas;
    });

    populateLocation();
  }

  _checkAuth() async {
    var data = await Auth().getStorageAuth();
    if (!data['status']) {
      Helpers().logout(context);
    }

    // print('address');
    // print(data['address']);
    // setState(() {
    //   if(data['address'].isNotEmpty){
    //     unionController.text = data['address']['union'] ?? '';
    //     villageController.text = data['address']['village'] ?? '';
    //     var authUserDistrict = districts.where((district) => district['name'] == data['address']['district']);
    //     if(authUserDistrict != null){
    //       selectedDistrict = authUserDistrict.first;
    //       var authUserUpazila = selectedDistrict['thanas'].where((upazila) => upazila['name'] == data['address']['upazila']);
    //       if(authUserUpazila != null){
    //         selectedUpazila = authUserUpazila.first;
    //       }
    //     }
    //   }

    // });
    // if (Auth().isExpired()) {
    //   Helpers().logout(context);
    //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    // }
  }

  _prepareState() {
    isEditState = widget.isEdit;
    setState(() {
      showItems = false;
      showUpazilaItems = false;
      // selectedDistrict = {};
      // selectedUpazila = {};
      // filteredUpazilas = [];
    });

    if (isEditState != null) {
      _clearForm();
      _fillFormData();
    } else {
      _clearForm();
    }
  }

  _fillFormData() {
    var patient = Patient().getPatient();
    firstNameController.text = patient['data']['first_name'];
    fatherNameController.text = patient['data']['father_name'];
    lastNameController.text = patient['data']['last_name'];
    // setState(() {
    //   _image = File(patient['data']['avatar']);
    // });
    // birthDateController.text = DateFormat('d').format(DateTime.parse(patient['data']['birth_date']));
    // birthMonthController.text = DateFormat('MM').format(DateTime.parse(patient['data']['birth_date']));
    // birthYearController.text = DateFormat('y').format(DateTime.parse(patient['data']['birth_date']));
    districtController.text = patient['data']['address']['district'];
    postalCodeController.text = patient['data']['address']['postal_code'];
    townController.text = patient['data']['address']['town'];
    villageController.text = patient['data']['address']['village'];
    streetNameController.text = patient['data']['address']['street_name'];
    mobilePhoneController.text = patient['data']['mobile'];
    emailController.text = patient['data']['email'];
    nidController.text = patient['data']['nid'];
    bracPatientIdContoller.text = patient['data']['brac_id'];
    //centers = patient['data']['centers'];
    hhNumberController.text = patient['data']['hh_number'];
    serialController.text = patient['data']['serial'];
    unionController.text = patient['data']['union'];
    contactFirstNameController.text = patient['data']['contact']['first_name'];
    contactLastNameController.text = patient['data']['contact']['last_name'];
    contactRelationshipController.text =
        patient['data']['contact']['relationship'];
    alternativePhoneController.text = patient['data']['alternative_phone'];
    selectedRelation =
        relationships.indexOf(patient['data']['contact']['relationship']);
  }

  fillDummyData() {
    firstNameController.text = 'Dummy';
    fatherNameController.text = 'Father test';
    lastNameController.text = 'Test';
    // setState(() {
    //   _image = File(patient['data']['avatar']);
    // });
    birthDateController.text = '11';
    birthMonthController.text = '10';
    birthYearController.text = '1990';
    // districtController.text = patient['data']['address']['district'];
    postalCodeController.text = '1216';
    villageController.text = 'Test';
    streetNameController.text = '1234';
    mobilePhoneController.text = '01960229599';
    emailController.text = 'rasel@augnitive.com';
    nidController.text = '1111111111';
    contactFirstNameController.text = 'Contact';
    contactLastNameController.text = 'Test';
    contactRelationshipController.text = 'Brother';
    alternativePhoneController.text = '01960229599';
    selectedRelation = 1;
  }

  _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    fatherNameController.clear();
    birthDateController.clear();
    birthMonthController.clear();
    birthYearController.clear();
    dobController.clear();
    ageController.clear();
    streetNameController.clear();
    hhNumberController.clear();
    serialController.clear();
    villageController.clear();
    unionController.clear();
    upazilaController.clear();
    districtController.clear();
    postalCodeController.clear();
    mobilePhoneController.clear();
    alternativePhoneController.clear();
    emailController.clear();
    nidController.clear();
    bracPatientIdContoller.clear();
    selectedCenters = null;
    townController.clear();
    contactFirstNameController.clear();
    contactLastNameController.clear();
    contactRelationshipController.clear();
    _image = null;
    uploadedImageUrl = '';

    selectedRelation = null;
    selectedGuardian = 'father';
  }

  goBack() {
    setState(() {
      _currentStep = _currentStep - 1;
      nextText = AppLocalizations.of(context).translate('next');
    });
  }

  goBackToEdit() {
    setState(() {
      _currentStep = _currentStep - 2;
      nextText = AppLocalizations.of(context).translate('next');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: FlatButton(
            onPressed: () {
              _currentStep != 0
                  ? setState(() {
                      goBack();
                    })
                  : setState(() {
                      Navigator.pop(context);
                    });
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(AppLocalizations.of(context).translate('register')),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                setState(() {
                  showItems = false;
                  showUpazilaItems = false;
                });
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: CustomStepper(
                physics: ClampingScrollPhysics(),
                type: CustomStepperType.horizontal,
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Row();
                },
                onStepTapped: (step) {
                  setState(() {
                    // _currentStep = step;
                  });
                },
                steps: _mySteps(),
                currentStep: _currentStep,
              ),
            ),
      bottomNavigationBar: Container(
          color: kBottomNavigationGrey,
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: _currentStep != 0
                      ? FlatButton(
                          onPressed: () {
                            goBack();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.chevron_left),
                              Text(
                                  AppLocalizations.of(context)
                                      .translate('back'),
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        )
                      : Text('')),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _mySteps().length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.lens,
                            size: 15,
                            color: _currentStep == index
                                ? kPrimaryColor
                                : kStepperDot,
                          ));
                    },
                  ),
                ),
              ),
              Expanded(
                  child: _currentStep < _mySteps().length - 1
                      ? FlatButton(
                          onPressed: () {
                            // Navigator.of(context).push(RegisterPatientSuccessScreen());
                            // return;

                            setState(() {
                              if (_currentStep == 1) {
                                _currentStep = _currentStep + 1;
                                nextText = AppLocalizations.of(context).translate('finish');
                              }
                              if (_currentStep < 1) {
                                if (selectedDobType == 'dob') {
                                  if (birthDateController.text == null ||
                                      birthDateController.text == '') {
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                          .translate("inputBirthday")),
                                      backgroundColor: kPrimaryRedColor,
                                    ));

                                    _patientFormKey.currentState.validate();
                                    return;
                                  }
                                } else {
                                  if (ageController.text == null ||
                                      ageController.text == '') {
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                          .translate("inputAge")),
                                      backgroundColor: kPrimaryRedColor,
                                    ));

                                    _patientFormKey.currentState.validate();
                                    return;
                                  }
                                }

                                if (_patientFormKey.currentState.validate()) {
                                  _currentStep = _currentStep + 1;
                                }
                              }
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                  AppLocalizations.of(context)
                                      .translate('next'),
                                  style: TextStyle(fontSize: 20)),
                              Icon(Icons.chevron_right)
                            ],
                          ),
                        )
                      : Container()),
            ],
          )),
    );
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [
      CustomStep(
        title: Text(
          AppLocalizations.of(context).translate('registerDetails'),
          textAlign: TextAlign.center,
        ),
        content: PatientDetails(parent: this),
        isActive: _currentStep >= 0,
      ),
      // CustomStep(
      //   title: Text(AppLocalizations.of(context).translate('contactDetails')),
      //   content: ContactDetails(),
      //   isActive: _currentStep >= 1,
      // ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate('photo')),
        content: AddPhoto(parent: this),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate('viewSummary')),
        content: ViewSummary(parent: this),
        isActive: _currentStep >= 1,
      ),
    ];

    if (Configs().configAvailable('isThumbprint')) {
      _steps.add(CustomStep(
        title: Text(AppLocalizations.of(context).translate('thumbprint')),
        content: Text(''),
        isActive: _currentStep >= 3,
      ));
    }

    return _steps;
  }

  _prepareFormData() {
    var data = {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'father_name': '',
      'gender': selectedGender,
      'avatar': uploadedImageUrl,
      'age': ageController.text, //age needs to be calculated
      'birth_date': birthDateController.text,
      'birth_month': birthMonthController.text,
      'birth_year': birthYearController.text,
      'nid': nidController.text,
      'brac_id': bracPatientIdContoller.text,
      'creationDateTime' : creationDateTimeController.text,

      'registration_date': DateFormat('y-MM-dd').format(DateTime.parse(creationDateTimeController.text)),
      'address': {
        'district': selectedDistrict['name'],
        'postal_code': postalCodeController.text,
        'upazila': selectedUpazila['name'],
        'village': villageController.text,
        'hh_number': hhNumberController.text,
        'serial': serialController.text,
        'union': unionController.text,
        'street_name': streetNameController.text,
      },
      //TODO: remove validation from api for contact
      'contact': {
        'first_name': 'test',
        'last_name': 'test',
        'relationship': 'test',
        'mobile': 'test'
      },
      'mobile': mobilePhoneController.text,
      'email': emailController.text,
      'alternative_phone': alternativePhoneController.text,
      'selected_dob_type': selectedDobType,
    };

    if (selectedGuardian == 'husband') {
      data['husband_name'] = fatherNameController.text;
      //print(data['husband_name']);
    } else {
      data['father_name'] = fatherNameController.text;
    }

    if (centersList.length > 0 && selectedCenters != null && selectedCenters > -1) {
      data['center'] = {
        'id': centersList[selectedCenters]['id'],
        'name': centersList[selectedCenters]['name']
      };
    }

    return data;
  }
}

class PatientDetails extends StatefulWidget {
  PatientDetails({this.parent});
  _RegisterPatientState parent;

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

DateTime selectedDate = DateTime.now();
var selectedDobType = 'dob';

class _PatientDetailsState extends State<PatientDetails> {
  final format = DateFormat("yyyy-MM-dd");

  @override
  initState() {
    super.initState();
  }

  updateUpazilas(district) {
    // print(district);
    setState(() {
      upazilaController.text = '';
      filteredUpazilas = district['thanas'];
    });
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          child: Form(
            key: _patientFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('registerDetails'),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText:
                            AppLocalizations.of(context).translate('firstName'),
                        controller: firstNameController,
                        name:
                            AppLocalizations.of(context).translate('firstName'),
                        validation: true,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText:
                            AppLocalizations.of(context).translate('lastName'),
                        controller: lastNameController,
                        name:
                            AppLocalizations.of(context).translate('lastName'),
                        //validation: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    // margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).translate('gender'),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: <Widget>[
                        // SizedBox(width: 20,),
                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'male',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                              selectedGuardian = 'father';
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context).translate('male'),
                            style: TextStyle(color: Colors.black)),

                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'female',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                        ),
                        Text(
                          AppLocalizations.of(context).translate('female'),
                        ),

                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'other',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context).translate('other'),
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                selectedGender == 'female'
                    ? Container(
                        // margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              // SizedBox(width: 20,),
                              Radio(
                                activeColor: kPrimaryColor,
                                value: 'father',
                                groupValue: selectedGuardian,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGuardian = value;
                                  });
                                },
                              ),
                              Text(
                                  AppLocalizations.of(context)
                                      .translate('fathersName'),
                                  style: TextStyle(color: Colors.black)),

                              Radio(
                                activeColor: kPrimaryColor,
                                value: 'husband',
                                groupValue: selectedGuardian,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGuardian = value;
                                  });
                                },
                              ),
                              Text(
                                AppLocalizations.of(context)
                                    .translate('husbandsName'),
                              ),
                            ],
                          ),
                        ],
                      ))
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context)
                      .translate(selectedGuardian + 'sName'),
                  controller: fatherNameController,
                  name: AppLocalizations.of(context).translate('fathersName'),
                  validation: true,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    // Text(AppLocalizations.of(context).translate('dateOfBirth'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                    // SizedBox(width: 10,),
                    // Text('(DD/MM/YYYY)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),),

                    Row(
                      children: <Widget>[
                        // SizedBox(width: 20,),
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
                        Text(
                            AppLocalizations.of(context)
                                .translate('dateOfBirth'),
                            style: TextStyle(color: Colors.black)),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '(DD/MM/YYYY)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),

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
                          AppLocalizations.of(context).translate('age'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                selectedDobType == 'dob'
                    ? Row(
                        children: [
                          Expanded(
                            child: PrimaryTextField(
                              topPaadding: 10,
                              bottomPadding: 10,
                              hintText:
                                  AppLocalizations.of(context).translate('dd'),
                              controller: birthDateController,
                              name: 'Date',
                              type: TextInputType.number,
                              validation: true,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: PrimaryTextField(
                              topPaadding: 10,
                              bottomPadding: 10,
                              hintText:
                                  AppLocalizations.of(context).translate('mm'),
                              controller: birthMonthController,
                              type: TextInputType.number,
                              name: 'Month',
                              validation: true,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: PrimaryTextField(
                              topPaadding: 10,
                              bottomPadding: 10,
                              hintText:
                                  AppLocalizations.of(context).translate('yy'),
                              controller: birthYearController,
                              name: 'Year',
                              type: TextInputType.number,
                              validation: true,
                            ),
                          ),
                        ],
                      )
                    : PrimaryTextField(
                        topPaadding: 10,
                        bottomPadding: 10,
                        hintText: AppLocalizations.of(context).translate('age'),
                        controller: ageController,
                        name: 'Age',
                        type: TextInputType.number,
                        validation: true,
                      ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context).translate('address'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 20,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText:
                      AppLocalizations.of(context).translate('streetPara'),
                  controller: streetNameController,
                  name: AppLocalizations.of(context).translate('streetPara'),
                  validation: true,
                ),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('hhNumber'),
                  controller: hhNumberController,
                  name: AppLocalizations.of(context).translate('hhNumber'),
                  validation: true,
                ),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('serial'),
                  controller: serialController,
                  name: AppLocalizations.of(context).translate('serial'),
                  validation: true,
                ),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('village'),
                  controller: villageController,
                  name: AppLocalizations.of(context).translate('village'),
                ),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('union'),
                  controller: unionController,
                  name: AppLocalizations.of(context).translate('union'),
                ),
                SizedBox(
                  height: 10,
                ),

                Text(
                  AppLocalizations.of(context).translate('upazila'),
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownSearch(
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
                SizedBox(
                  height: 10,
                ),
                Text(
                  AppLocalizations.of(context).translate('district'),
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownSearch(
                  validator: (v) => v == null ? "required field" : null,
                  hint: AppLocalizations.of(context).translate('district'),
                  mode: Mode.BOTTOM_SHEET,
                  items: districts,
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
                    hintText: 'District',
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      updateUpazilas(selectedDistrict);
                      selectedUpazila = {};
                      // districtController.text = value;
                    });
                  },
                  selectedItem: selectedDistrict['name'],
                  popupItemBuilder: _customPopupItemBuilderExample2,
                  showSearchBox: true,
                ),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                    topPaadding: 10,
                    bottomPadding: 10,
                    hintText:
                        AppLocalizations.of(context).translate('postalCode'),
                    controller: postalCodeController,
                    name: AppLocalizations.of(context).translate('postalCode'),
                    type: TextInputType.number),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
                PrimaryTextField(
                    topPaadding: 10,
                    bottomPadding: 10,
                    prefixIcon: Icon(Icons.phone),
                    hintText: AppLocalizations.of(context).translate('mobile'),
                    controller: mobilePhoneController,
                    name: AppLocalizations.of(context).translate('mobile'),
                    validation: true,
                    type: TextInputType.number),
                PrimaryTextField(
                    topPaadding: 7,
                    bottomPadding: 7,
                    prefixIcon: Icon(Icons.phone),
                    hintText: AppLocalizations.of(context)
                        .translate("alternativePhone"),
                    controller: alternativePhoneController,
                    name: AppLocalizations.of(context)
                        .translate("alternativePhone"),
                    validation: false,
                    type: TextInputType.number),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                    topPaadding: 10,
                    bottomPadding: 10,
                    prefixIcon: Icon(Icons.email),
                    hintText: AppLocalizations.of(context)
                        .translate('emailAddressOptional'),
                    name: AppLocalizations.of(context)
                        .translate('emailAddressOptional'),
                    controller: emailController),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText:
                      AppLocalizations.of(context).translate('nationalId'),
                  controller: nidController,
                  name: AppLocalizations.of(context).translate('nationalId'),
                  validation: true,
                  type: TextInputType.number,
                ),
                SizedBox(
                  height: 10,
                ),
                PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('projectId'),
                  controller: bracPatientIdContoller,
                  name: AppLocalizations.of(context).translate('projectId'),
                  validation: true,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 65,
                  color: kSecondaryTextField,
                  alignment: Alignment.center,
                  child: DropdownButtonFormField(
                    hint: Text(
                      AppLocalizations.of(context).translate("center"),
                      style: TextStyle(fontSize: 20, color: kTextGrey),
                    ),
                    decoration: InputDecoration(
                      fillColor: kSecondaryTextField,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      )),
                    ),
                    items: centersList
                        .map((center) => DropdownMenuItem(
                              child: Text(center['name']),
                              value: centersList.indexOf(center),
                            ))
                        .toList(),
                    value: selectedCenters,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedCenters = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          )),
    );
  }
}

class DatePicker extends StatefulWidget {
  DatePicker({this.controller, this.hintText, this.levelText});
  final controller;
  String hintText = '';
  String levelText = '';

  @override
  _DatePickerState createState() => _DatePickerState();
}

bool autoValidate = false;

class _DatePickerState extends State<DatePicker> {
  final format = DateFormat("yyyy-MM-dd");
  var selectedDate;
  setDate(date) {
    if (date != null) {
      selectedDate = date;
      birthDateController.text = DateFormat('dd').format(date);
      birthMonthController.text = DateFormat('MM').format(date);
      birthYearController.text = DateFormat('y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSecondaryTextField,
      ),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
            labelText: widget.levelText,
            hintText: widget.hintText,
            contentPadding: EdgeInsets.only(left: 15, top: 10, bottom: 10)),
        autovalidate: true,
        onTap: () async {
          DateTime date = DateTime(1900);
          FocusScope.of(context).requestFocus(new FocusNode());
          date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: selectedDate ?? DateTime.now(),
              lastDate: DateTime(2030));
          setDate(date);
        },
      ),
    );
  }
}

class AddPhoto extends StatefulWidget {
  AddPhoto({this.parent});
  _RegisterPatientState parent;

  @override
  _AddPhotoState createState() => _AddPhotoState();
}

File _image;

class _AddPhotoState extends State<AddPhoto> {
  bool isLoading = false;
  bool firstTime = true;
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: gsBucket);
  StorageUploadTask _uploadTask;
  String storageAvatar = '';

  @override
  initState() {
    super.initState();
    _image = null;
    if (isEditState != null) {
      storageAvatar =
          isEditState ? Patient().getPatient()['data']['avatar'] : '';
    }
  }

  Future getImageFromCam() async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      return;
    }
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    // setState(() {
    //   _image = image;
    // });

    await cropImage();
  }

  uploadImage() async {
    var url = '';
    if (_image != null) {
      String filePath =
          'images/patients/${firstNameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      setState(() {
        _uploadTask = _storage.ref().child(filePath).putFile(_image);
      });
      await _uploadTask.onComplete;
      if (_uploadTask.isComplete) {
        var url = await _storage.ref().child(filePath).getDownloadURL();
        setState(() {
          uploadedImageUrl = url;
        });
      }

      // if (_uploadTask.isCanceled) {
      // }
      return url;
    }
  }

  cropImage() async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: kPrimaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (croppedImage != null) {
      _image.delete();
      setState(() {
        _image = croppedImage;
      });
    } else if (firstTime) {
      _image.delete();
      setState(() {
        firstTime = false;
        _image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text(
              AppLocalizations.of(context).translate('takePhoto'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                height: 200,
                // width: 200,
                // alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: kTableBorderGrey)),
                child: _image == null && storageAvatar == ''
                    ? GestureDetector(
                        onTap: () => getImageFromCam(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.camera_alt,
                                size: 90,
                                color: kPrimaryColor,
                              ),
                              Text(
                                  AppLocalizations.of(context)
                                      .translate('addPhoto'),
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 20,
                                      height: 2))
                            ],
                          ),
                        ),
                      )
                    : _image == null && storageAvatar != ''
                        ? Container(
                            height: 200,
                            width: 200,
                            child: Stack(
                              children: <Widget>[
                                Image.network(storageAvatar,
                                    fit: BoxFit.contain),
                                CachedNetworkImage(
                                  imageUrl: storageAvatar,
                                  placeholder: (context, url) => Center(),
                                  errorWidget: (context, url, error) => Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.error),
                                      Text(AppLocalizations.of(context)
                                          .translate("imageNotFound"))
                                    ],
                                  )),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 80,
                                  child: GestureDetector(
                                    onTap: () => getImageFromCam(),
                                    child: CircleAvatar(
                                      child: Icon(Icons.edit),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(
                            height: 200,
                            width: 200,
                            child: Stack(
                              children: <Widget>[
                                Image.file(_image, fit: BoxFit.contain),
                                Positioned(
                                  bottom: 0,
                                  left: 30,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _image.delete();
                                        setState(() {
                                          storageAvatar = '';
                                        });
                                        _image = null;
                                        firstTime = true;
                                      });
                                    },
                                    child: CircleAvatar(
                                      child: Icon(Icons.delete),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 30,
                                  child: GestureDetector(
                                    onTap: () => cropImage(),
                                    child: CircleAvatar(
                                      child: Icon(Icons.edit),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
            SizedBox(
              height: 70,
            ),
            GestureDetector(
              onTap: () async {
                widget.parent.nextStep();
              },
              child: Container(
                  width: double.infinity,
                  height: 62.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          "${isEditState != null ? AppLocalizations.of(context).translate('updatePatient') : AppLocalizations.of(context).translate('viewSummary')}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400))),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewSummary extends StatefulWidget {
  final _RegisterPatientState parent;
  ViewSummary({this.parent});
  @override
  _ViewSummaryState createState() => _ViewSummaryState();
}

class _ViewSummaryState extends State<ViewSummary> {
  bool isLoading = false;
  bool firstTime = true;
  bool _isRegisterButtonDisabled;

  final FirebaseStorage _storage = FirebaseStorage(storageBucket: gsBucket);
  StorageUploadTask _uploadTask;
  String storageAvatar = '';

  @override
  initState() {
    super.initState();
    _isRegisterButtonDisabled = false;
    creationDateTimeController.text = '${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}';
  }

  uploadImage() async {
    var url = '';
    if (_image != null) {
      String filePath =
          'images/patients/${firstNameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      setState(() {
        _uploadTask = _storage.ref().child(filePath).putFile(_image);
      });
      await _uploadTask.onComplete;
      if (_uploadTask.isComplete) {
        var url = await _storage.ref().child(filePath).getDownloadURL();
        setState(() {
          uploadedImageUrl = url;
        });
      }

      // if (_uploadTask.isCanceled) {

      // }

      return url;
    }
  }

  getAddress() {
    var address = '';
    if (streetNameController.text != '' && streetNameController.text != null) {
      address = streetNameController.text;
    }
    if (villageController.text != '' && villageController.text != null) {
      address = address + ', ' + villageController.text;
    }
    if (selectedUpazila['name'] != null) {
      address = address + ', ' + selectedUpazila['name'];
    }
    if (selectedDistrict['name'] != null) {
      address = address + ', ' + selectedDistrict['name'];
    }
    if (postalCodeController.text != '') {
      address = address + ', ' + postalCodeController.text;
    }

    if (address[0] == ',') {
      address = address.substring(1);
    }

    return address;
  }
  
  completeRegistration() async {
    setState(() {
      isLoading = true;
      _isRegisterButtonDisabled = true;
    });
    var url = await uploadImage();
    var formData = _RegisterPatientState()._prepareFormData();
    var response = isEditState != null
      ? await PatientController().update(formData, false)
      : await PatientController().createOffline(context, formData);
    if (response != null) {
      if (response == 'success') {
        _RegisterPatientState()._clearForm();
        Navigator.of(context).pushReplacementNamed(RegisterPatientSuccessScreen.path, arguments: isEditState);
      } else {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('somethingWrong')),
            backgroundColor: kPrimaryRedColor,
          )
        );
      }
      // else if (response['error'] != null && response['error']) {
      //   if (response['message'] == 'Patient already exists.') {
      //     _scaffoldKey.currentState.showSnackBar(
      //       SnackBar(
      //         content: Text(AppLocalizations.of(context).translate('nidValidation')),
      //         backgroundColor: kPrimaryRedColor,
      //       )
      //     );
      //     return;
      //   }

      //   _scaffoldKey.currentState.showSnackBar(
      //     SnackBar(
      //       content: Text(AppLocalizations.of(context).translate('somethingWrong')),
      //       backgroundColor: kPrimaryRedColor,
      //     )
      //   );
      //   return;     
      // } else if (response['message'] != null && response['message'] == 'Unauthorized') {
      //   Helpers().logout(context);
      //   return;
      // } 
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('somethingWrong')),
          backgroundColor: kPrimaryRedColor,
        )
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),

            Container(
              height: 480,
              // width: 200,
              // alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  // border: Border.all(width: 1, color: kTableBorderGrey)
                  ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('name') + ': ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        firstNameController.text +
                            ' ' +
                            lastNameController.text,
                        style: TextStyle(fontSize: 18),
                      ),
                      Spacer(),
                      ClipOval(
                        child: Material(
                          child: InkWell(
                            onTap: () {
                              widget.parent.goBackToEdit();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(color: kPrimaryColor),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      selectedGuardian == 'husband'
                          ? Text(
                              AppLocalizations.of(context)
                                      .translate('husbandName') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            )
                          : Text(
                              AppLocalizations.of(context)
                                      .translate('fathersName') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            ),
                      Text(
                        fatherNameController.text,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('gender') + ': ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        selectedGender,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  selectedDobType == 'dob'
                      ? Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)
                                      .translate('dateOfBirth') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              birthDateController.text +
                                  '-' +
                                  birthMonthController.text +
                                  '-' +
                                  birthYearController.text,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context).translate('age') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '${ageController.text}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('address') +
                            ': ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        getAddress(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('hhNumber') +
                            ': ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        hhNumberController.text,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('serial') + ': ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        serialController.text,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('union') + ': ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        unionController.text,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  emailController.text.isNotEmpty
                      ? Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context).translate('email') +
                                  ": ",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              emailController.text,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : Container(
                          height: 0,
                        ),
                  SizedBox(
                    height: 7,
                  ),
                  mobilePhoneController.text.isNotEmpty
                      ? Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context).translate('mobile') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              mobilePhoneController.text,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : Container(height: 0),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate('nationalId') +
                            ': ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        nidController.text,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  alternativePhoneController.text.isNotEmpty
                      ? Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)
                                      .translate('alternativePhone') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              alternativePhoneController.text,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : Container(height: 0),
                  SizedBox(
                    height: 7,
                  ),
                  bracPatientIdContoller.text.isNotEmpty
                      ? Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)
                                      .translate('projectId') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              bracPatientIdContoller.text,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : Container(
                          height: 0,
                        ),
                  SizedBox(
                    height: 7,
                  ),
                  centersList.isNotEmpty
                      ? Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context).translate('center') +
                                  ': ',
                              style: TextStyle(fontSize: 18),
                            ),
                            selectedCenters != null && selectedCenters > -1 && centersList[selectedCenters].isNotEmpty ? 
                            Text(centersList[selectedCenters]['name'], style: TextStyle(fontSize: 18),) 
                            : Text(''),
                          ],
                        )
                      : Container(
                          height: 0,
                        ),
                      SizedBox(
                        height: 7,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context).translate('creationDateAndTime'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                            Container(
                              // margin: EdgeInsets.symmetric(horizontal: 10),
                              child: DateTimeField(
                                resetIcon: null,
                                format: DateFormat("yyyy-MM-dd HH:mm:ss"),
                                controller: creationDateTimeController,
                                decoration: InputDecoration(
                                  // hintText: '${DateTime.now()}',//AppLocalizations.of(context).translate("lastVisitDate"),
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
                                
                                onShowPicker: (context, currentValue) async{
                                  final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                                    if (date != null) {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                      );
                                      return DateTimeField.combine(date, time);
                                    } else {
                                      return currentValue;
                                    }
                                },
                              ),
                            ),
                          ],
                        )
                      ),
                      
                      SizedBox(height: 20,),
                ],
              ),
            ),

            SizedBox(height: 20,),
            

            GestureDetector(
              onTap: _isRegisterButtonDisabled ? null : completeRegistration,
              child: Container(
                  width: double.infinity,
                  height: 62.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          "${isEditState != null ? AppLocalizations.of(context).translate('updatePatient') : AppLocalizations.of(context).translate('completeRegistration')}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400))),
            ),
          ],
        ),
      ),
    );
  }
}

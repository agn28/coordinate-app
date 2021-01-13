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
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/patients/register_patient_success_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import '../../custom-classes/custom_stepper.dart';

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final fatherNameController = TextEditingController();
// final gender = TextEditingController();
final dobController = TextEditingController();
final birthDateController = TextEditingController();
final birthMonthController = TextEditingController();
final birthYearController = TextEditingController();
final districtController = TextEditingController();
final postalCodeController = TextEditingController();
final townController = TextEditingController();
final upazilaController = TextEditingController();
final villageController = TextEditingController();
final streetNameController = TextEditingController();
final mobilePhoneController = TextEditingController();
final emailController = TextEditingController();
final nidController = TextEditingController();

final contactFirstNameController = TextEditingController();
final contactLastNameController = TextEditingController();
final contactRelationshipController = TextEditingController();
final contactMobilePhoneController = TextEditingController();
final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _contactFormKey = new GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
String uploadedImageUrl = '';
bool isEditState = false;
String selectedGender = 'male';
String selectedGuardian = 'father';
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
List allMedications =  ['fever', 'cough' ];
List allDestricts = [];
List allUpazilas = [];
List filteredUpazilas = [];
List _medications = [];
final problemController = TextEditingController();
bool showItems = false;
bool showUpazilaItems = false;

var selectedDiseases = [];
final lastVisitDateController = TextEditingController();
var _selectedItem = [];

class RegisterPatientScreen extends CupertinoPageRoute {
  bool isEdit = false;
  RegisterPatientScreen({this.isEdit})
      : super(builder: (BuildContext context) => new RegisterPatient(isEdit: isEdit,));

}


class RegisterPatient extends StatefulWidget {
  final isEdit;
  RegisterPatient({this.isEdit});
  @override
  _RegisterPatientState createState() => _RegisterPatientState();
}
int _currentStep = 0;

class _RegisterPatientState extends State<RegisterPatient> {
  


  String nextText = 'NEXT';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAddresses();
    _prepareState();
    _checkAuth();
    selectedDistrict = {};
    selectedUpazila = {};
    _currentStep = 0;

  }
  nextStep() {
    setState(() {
      _currentStep += 1;
    });
  }

  getAddresses() async {

    setState(() {
      isLoading = true;
    });
    var locationData = await PatientController().getLocations();
    var districtsData = [];
    if (locationData['error'] != null && !locationData['error']) {
      districtsData =  locationData['data'][0]['districts'];
    }



    setState(() {
      isLoading = false;
    });

    // return;

    print(districts);

    setState(() {
      districts = districtsData;
      allDestricts = districts;
      // upazilas = json.decode(upazilasData);
      // allUpazilas = upazilas;
    });
    print(districts);
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } 
  }

  

  _prepareState() {
    isEditState = widget.isEdit;
    setState(() {
      showItems = false;
      showUpazilaItems = false;
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
    contactFirstNameController.text = patient['data']['contact']['first_name'];
    contactLastNameController.text = patient['data']['contact']['last_name'];
    contactRelationshipController.text = patient['data']['contact']['relationship'];
    contactMobilePhoneController.text = patient['data']['contact']['mobile'];
    selectedRelation = relationships.indexOf(patient['data']['contact']['relationship']);

  }

  _clearForm() {
    firstNameController.clear();
    lastNameController .clear();
    fatherNameController .clear();
    dobController.clear();
    birthDateController.clear();
    birthMonthController.clear();
    birthYearController.clear();
    districtController.clear();
    postalCodeController.clear();
    townController.clear();
    villageController.clear();
    streetNameController.clear();
    mobilePhoneController.clear();
    emailController.clear();
    nidController.clear();
    contactFirstNameController.clear();
    contactLastNameController.clear();
    contactRelationshipController.clear();
    contactMobilePhoneController.clear();
    _image = null;

    selectedRelation = null;
    selectedGuardian = 'father';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('registerNewPatient')),
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : GestureDetector(
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

          controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
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
              child: _currentStep != 0 ? FlatButton(
                onPressed: () {

                  setState(() {
                    _currentStep = _currentStep - 1;
                    nextText = AppLocalizations.of(context).translate('next');
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.chevron_left),
                    Text(AppLocalizations.of(context).translate('back'), style: TextStyle(fontSize: 20)),
                  ],
                ),
              ) : Text('')
            ),
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
                      child: Icon(Icons.lens, size: 15, color: _currentStep == index ? kPrimaryColor : kStepperDot,)
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: _currentStep < _mySteps().length - 1 ? FlatButton(
                onPressed: () {
                  // Navigator.of(context).push(RegisterPatientSuccessScreen());
                  // return;

                  setState(() {
                    if (_currentStep == 1) {
                        _currentStep = _currentStep + 1;
                        nextText = AppLocalizations.of(context).translate('finish');
                    }
                    if (_currentStep < 1) {
                      if (birthDateController.text == null || birthDateController.text == '') {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).translate("inputBirthday")),
                            backgroundColor: kPrimaryRedColor,
                          )
                        );

                        _patientFormKey.currentState.validate();
                        return;
                      }

                      if (_patientFormKey.currentState.validate()) {
                        _currentStep = _currentStep + 1;
                      }
                    }
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('next'), style: TextStyle(fontSize: 20)),
                    Icon(Icons.chevron_right)
                  ],
                ),
              ) : Container()
            ),
          ],
        )
      ),
    );
  }

  List<CustomStep> _mySteps() {
    List<CustomStep> _steps = [
      CustomStep(
        title: Text(AppLocalizations.of(context).translate('patientDetails'), textAlign: TextAlign.center,),
        content: PatientDetails(),
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
        content: ViewSummary(),
        isActive: _currentStep >= 2,
      ),
    ];

    if (Configs().configAvailable('isThumbprint')) {
      _steps.add(
        CustomStep(
          title: Text(AppLocalizations.of(context).translate('thumbprint')),
          content: Text(''),
          isActive: _currentStep >= 3,
        )
      );
    }
      
    return _steps;
  }

  _prepareFormData() {
    var data =  {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'father_name': '',
      'gender': selectedGender,
      'avatar': uploadedImageUrl,
      'age': 26, //age needs to be calculated
      'birth_date': birthDateController.text,
      'birth_month': birthMonthController.text,
      'birth_year': birthYearController.text,
      'nid': nidController.text,
      'registration_date': DateFormat('y-MM-dd').format(DateTime.now()),
      'address': {
        'district': selectedDistrict['name'],
        'postal_code': postalCodeController.text,
        'upazila': selectedUpazila['name'],
        'village': villageController.text,
        'street_name': streetNameController.text,
      },
      'mobile': mobilePhoneController.text,
      'email': emailController.text,
      'contact': {
        'first_name': contactFirstNameController.text,
        'last_name': contactLastNameController.text,
        'relationship': selectedRelation != null ? relationships[selectedRelation] : '', 
        'mobile': contactMobilePhoneController.text,
      },

    };

    if (selectedGuardian == 'husband') {
      data['husband_name'] = fatherNameController.text;
    } else {
      data['father_name'] = fatherNameController.text;
    }

    return data;

  }
  
}

class PatientDetails extends StatefulWidget {

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

DateTime selectedDate = DateTime.now();

class _PatientDetailsState extends State<PatientDetails> {
  
  final lastVisitDateController = TextEditingController();
  final format = DateFormat("yyyy-MM-dd");

  updateUpazilas(district) {
    // print(district);
    setState(() {
      upazilaController.text = '';
      filteredUpazilas = district['thanas'];
    });
    print(allUpazilas);
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
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('patientDetails'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),

            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 10,
                    bottomPadding: 10,
                    hintText: AppLocalizations.of(context).translate('firstName'),
                    controller: firstNameController,
                    name: AppLocalizations.of(context).translate('firstName'),
                    validation: true,
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 10,
                    bottomPadding: 10,
                    hintText: AppLocalizations.of(context).translate('lastName'),
                    controller: lastNameController,
                    name: AppLocalizations.of(context).translate('firstName'),
                    validation: true,
                  ),
                ),
              ],
            ),


            SizedBox(height: 20,),

            Container(
              // margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('gender'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
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
                      Text(AppLocalizations.of(context).translate('male'), style: TextStyle(color: Colors.black)),

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
                    ],
                  ),
                ],
              )
            ),

            SizedBox(height: 20,),

            selectedGender == 'female' ? Container(
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
                      Text(AppLocalizations.of(context).translate('fathersName'), style: TextStyle(color: Colors.black)),

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
                        AppLocalizations.of(context).translate('husbandsName'),
                      ),
                    ],
                  ),
                ],
              )
            ) : Container(),
            
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 10,
              bottomPadding: 10,
              hintText: AppLocalizations.of(context).translate(selectedGuardian + 'sName'),
              controller: fatherNameController,
              name: AppLocalizations.of(context).translate('fathersName'),
              validation: true,
            ),

            SizedBox(height: 20,),

            Row(
              children: [
                Text(AppLocalizations.of(context).translate('dateOfBirth'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                SizedBox(width: 10,),
                Text('(DD/MM/YYYY)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),),
              ],
            ),
            SizedBox(height: 20,),

            Row(
              children: [
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 10,
                    bottomPadding: 10,
                    hintText: AppLocalizations.of(context).translate('dd'),
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
                    hintText: AppLocalizations.of(context).translate('mm'),
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
                    hintText: AppLocalizations.of(context).translate('yy'),
                    controller: birthYearController,
                    name: 'Year',
                    type: TextInputType.number,
                    validation: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),
            Divider(),
            SizedBox(height: 20,),
            Text(AppLocalizations.of(context).translate('address'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),

            DropdownSearch(
              validator: (v) => v == null ? "required field" : null,
              hint: AppLocalizations.of(context).translate('district'),
              mode: Mode.BOTTOM_SHEET,
              items: districts,
              // showClearButton: true,
              dropdownSearchDecoration: InputDecoration(
                counterText: ' ',
                contentPadding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10, right: 10),
                filled: true,
                fillColor: kSecondaryTextField,
                border: new UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  )
                ),

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

            SizedBox(height: 20,),

            DropdownSearch(
              validator: (v) => v == null ? "required field" : null,
              hint: AppLocalizations.of(context).translate('upazila'),
              mode: Mode.BOTTOM_SHEET,
              items: filteredUpazilas,
              // showClearButton: true,
              dropdownSearchDecoration: InputDecoration(
                counterText: ' ',
                contentPadding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10, right: 10),
                filled: true,
                fillColor: kSecondaryTextField,
                border: new UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  )
                ),

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

            SizedBox(height: 10,),
            PrimaryTextField(
                topPaadding: 10,
                bottomPadding: 10,
              hintText: AppLocalizations.of(context).translate('postalCode'),
              controller: postalCodeController,
              name: AppLocalizations.of(context).translate('postalCode'),
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 10,
              bottomPadding: 10,
              hintText: AppLocalizations.of(context).translate('village'),
              controller: villageController,
              name: AppLocalizations.of(context).translate('village'),
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 10,
              bottomPadding: 10,
              hintText: AppLocalizations.of(context).translate('streetName'),
              controller: streetNameController,
              name: AppLocalizations.of(context).translate('streetName'),
            ),
            Divider(),
            SizedBox(height: 20,),
            PrimaryTextField(
              topPaadding: 10,
              bottomPadding: 10,
              prefixIcon: Icon(Icons.phone),
              hintText: AppLocalizations.of(context).translate('mobile'),
              controller: mobilePhoneController,
              name: AppLocalizations.of(context).translate('mobile'),
              validation: true,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 10,
              bottomPadding: 10,
              prefixIcon: Icon(Icons.email),
              hintText: AppLocalizations.of(context).translate('emailAddressOptional'),
              name: AppLocalizations.of(context).translate('nationalId'),
              controller: emailController
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 10,
              bottomPadding: 10,
              hintText: AppLocalizations.of(context).translate('nationalId'),
              controller: nidController,
              name: AppLocalizations.of(context).translate('nationalId'),
              validation: true,
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                      topPaadding: 7,
                      bottomPadding: 7,
                      hintText: AppLocalizations.of(context).translate("contactFirstName"),
                      controller: contactFirstNameController,
                      name: AppLocalizations.of(context).translate("contactFirstName"),
                      validation: true
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                      topPaadding: 7,
                      bottomPadding: 7,
                      hintText: AppLocalizations.of(context).translate("contactLastName"),
                      controller: contactLastNameController,
                      name: AppLocalizations.of(context).translate("contactLastName"),
                      validation: true
                  ),
                ),
              ],
            ),


            SizedBox(height: 10,),

            Container(
              child: DropdownButtonFormField(

                hint: Text(AppLocalizations.of(context).translate('relationship'), style: TextStyle(fontSize: 20, color: kTextGrey),),
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context).translate('relationshipRequired');
                  }
                  // return '';
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kSecondaryTextField,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      )
                  ),
                ),
                items: [
                  ...relationships.map((item) =>
                      DropdownMenuItem(
                          child: Text(StringUtils.capitalize(item)),
                          value: relationships.indexOf(item)
                      )
                  ).toList(),
                ],
                value: selectedRelation,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedRelation = value;
                  });
                },
              ),
            ),

            SizedBox(height: 20,),
            Divider(),

            SizedBox(height: 20,),
            PrimaryTextField(
                topPaadding: 7,
                bottomPadding: 7,
                prefixIcon: Icon(Icons.phone),
                hintText: AppLocalizations.of(context).translate("contactMobilePhone"),
                controller: contactMobilePhoneController,
                name: AppLocalizations.of(context).translate("mobile"),
                validation: true,
                type: TextInputType.number
            ),
            SizedBox(height: 30,),
          ],
        ),
      )
    );
  }
}

class DatePicker extends StatefulWidget {
  DatePicker({
   this.controller,
   this.hintText,
    this.levelText
  });

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
      child:  TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText:widget.levelText,
          hintText:widget.hintText,
          contentPadding: EdgeInsets.only(left: 15,top: 10,bottom: 10)
        ),
        autovalidate: true,

        onTap: () async{
          DateTime date = DateTime(1900);
          FocusScope.of(context).requestFocus(new FocusNode());
          date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: selectedDate ?? DateTime.now(),
              lastDate: DateTime(2030)
          );
          setDate(date);
        },
      ),
    );
  }
}

class AddPhoto extends StatefulWidget {
  AddPhoto({
    this.parent
  });
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
      storageAvatar = isEditState ? Patient().getPatient()['data']['avatar'] : '';
    }
  }

  Future getImageFromCam() async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    // setState(() {
    //   _image = image;
    // });

    await cropImage();
  }

  uploadImage() async {
    var url = '';
    if (_image != null) {
      String filePath = 'images/patients/${firstNameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('file path');
      print(filePath);

      setState(() {
        _uploadTask = _storage.ref().child(filePath).putFile(_image);
      });
      await _uploadTask.onComplete;
      if (_uploadTask.isComplete) {
        var url = await _storage.ref().child(filePath).getDownloadURL();
        print('url');
        print(url);
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
      )
    );
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30,),
          Text(AppLocalizations.of(context).translate('takePhoto'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
          SizedBox(height: 30,),

          Container(
            height: 200,
            // width: 200,
            // alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: kTableBorderGrey)
            ),
            child: _image == null && storageAvatar == '' ? 
            GestureDetector(
              onTap: () => getImageFromCam(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.camera_alt, size: 90, color: kPrimaryColor,),
                    Text(AppLocalizations.of(context).translate('addPhoto'), style: TextStyle(color: kPrimaryColor, fontSize: 20, height: 2))
                  ],
                ),
              ),
            ) : _image == null && storageAvatar != '' ? 
            Container(
              height: 200,
              width: 200,
              child: Stack(
              children: <Widget>[
                Image.network(storageAvatar, fit: BoxFit.contain),
                CachedNetworkImage(
                  imageUrl: storageAvatar,
                  placeholder: (context,url) => 
                  Center(),
                  errorWidget: (context,url,error) => 
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.error),
                        Text(AppLocalizations.of(context).translate("imageNotFound"))
                      ],
                    )
                  ),
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
            ) : Container(
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
            )
          ) ,

          SizedBox(height: 70,),
          
          GestureDetector(
            onTap: () async {
              print(_currentStep);
              widget.parent.nextStep();
              
            },
            child: Container(
              width: double.infinity,
              height: 62.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(4)
              ),
              child: isLoading ? CircularProgressIndicator() : Text("${isEditState != null ? AppLocalizations.of(context).translate('updatePatient') : AppLocalizations.of(context).translate('viewSummary')}", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400))
            ),
          ),
        ],
      ),
    );
  }
}

class ViewSummary extends StatefulWidget {
  const ViewSummary({
    Key key,
  }) : super(key: key);

  @override
  _ViewSummaryState createState() => _ViewSummaryState();
}

class _ViewSummaryState extends State<ViewSummary> {
  bool isLoading = false;
  bool firstTime = true;

  final FirebaseStorage _storage = FirebaseStorage(storageBucket: gsBucket);
  StorageUploadTask _uploadTask;
  String storageAvatar = '';

  @override
  initState() {
    super.initState();
  }

    uploadImage() async {
    var url = '';
    if (_image != null) {
      String filePath = 'images/patients/${firstNameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('file path');
      print(filePath);

      setState(() {
        _uploadTask = _storage.ref().child(filePath).putFile(_image);
      });
      await _uploadTask.onComplete;
      if (_uploadTask.isComplete) {
        var url = await _storage.ref().child(filePath).getDownloadURL();
        print('url');
        print(url);
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
      print('hi');
      address = streetNameController.text;
    }
    if (villageController.text != '' && villageController.text != null) {
      print('hello');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10,),

          Container(
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
                    Text(firstNameController.text + ' ' + lastNameController.text, style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),
                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('gender') + ': ', style: TextStyle(fontSize: 18),),
                    Text(selectedGender, style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),
                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('dateOfBirth') + ': ', style: TextStyle(fontSize: 18),),
                    Text(birthDateController.text + '-' + birthMonthController.text + '-' + birthYearController.text, style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),

                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('address') + ': ', style: TextStyle(fontSize: 18),),
                    Text(getAddress(), style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),

                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('mobile') + ': ', style: TextStyle(fontSize: 18),),
                    Text(mobilePhoneController.text, style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),

                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('nationalId') + ': ', style: TextStyle(fontSize: 18),),
                    Text(nidController.text, style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),

                Row(
                  children: <Widget>[
                    // Text(AppLocalizations.of(context).translate('contactName') + ': ', style: TextStyle(fontSize: 18),),
                    Text(AppLocalizations.of(context).translate("contactname") + ': ', style: TextStyle(fontSize: 18),),
                    Text(contactFirstNameController.text + ' ' + contactLastNameController.text, style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),

                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('relationship') + ': ', style: TextStyle(fontSize: 18),),
                    Text(StringUtils.capitalize(relationships[selectedRelation]), style: TextStyle(fontSize: 18),),
                  ],
                ),
                SizedBox(height: 7,),

                Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('contactMobilePhone') + ': ', style: TextStyle(fontSize: 18),),
                    Text(contactMobilePhoneController.text, style: TextStyle(fontSize: 18),),
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
              var url = await uploadImage();
              var formData = _RegisterPatientState()._prepareFormData();
              print('formdata');
              var response = isEditState != null ? await PatientController().update(formData, false) : await PatientController().create(formData);
              setState(() {
                isLoading = false;
              });
              if (response == 'success') {
                _RegisterPatientState()._clearForm();
                Navigator.of(context).pushReplacement(RegisterPatientSuccessScreen(isEditState: isEditState));
              }
            },
            child: Container(
              width: double.infinity,
              height: 62.0,
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
    );
  }
}

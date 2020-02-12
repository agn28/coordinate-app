import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/configs/configs.dart';
import 'dart:async';
import 'dart:io';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/register_patient_success_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import '../../custom-classes/custom_stepper.dart';

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
// final gender = TextEditingController();
final birthDateController = TextEditingController();
final birthMonthController = TextEditingController();
final birthYearController = TextEditingController();
final districtController = TextEditingController();
final postalCodeController = TextEditingController();
final townController = TextEditingController();
final villageController = TextEditingController();
final streetNameController = TextEditingController();
final mobilePhoneController = TextEditingController();
final homePhoneController = TextEditingController();
final emailController = TextEditingController();
final nidController = TextEditingController();

final contactFirstNameController = TextEditingController();
final contactLastNameController = TextEditingController();
final contactRelationshipController = TextEditingController();
final contactDistrictController = TextEditingController();
final contactPostalCodeController = TextEditingController();
final contactTownController = TextEditingController();
final contactVillageController = TextEditingController();
final contactStreetNameController = TextEditingController();
final contactMobilePhoneController = TextEditingController();
final contactHomePhoneController = TextEditingController();
final contactEmailController = TextEditingController();
final GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _contactFormKey = new GlobalKey<FormState>();
bool isEditState = false;
String selectedGender = 'male';
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

class _RegisterPatientState extends State<RegisterPatient> {
  
  int _currentStep = 0;

  String nextText = 'NEXT';

  @override
  void initState() {
    super.initState();
    _prepareState();
  }

  _prepareState() {
    isEditState = widget.isEdit;

    if (isEditState != null) {
      _fillFormData();
    } else {
      _clearForm();
    }
  }

  _fillFormData() {
    var patient = Patient().getPatient();
    print(patient);
    firstNameController.text = patient['data']['first_name'];
    lastNameController.text = patient['data']['last_name'];
    birthDateController.text = DateFormat('d').format(DateTime.parse(patient['data']['birth_date']));
    birthMonthController.text = DateFormat('MM').format(DateTime.parse(patient['data']['birth_date']));
    birthYearController.text = DateFormat('y').format(DateTime.parse(patient['data']['birth_date']));
    districtController.text = patient['data']['address']['district'];
    postalCodeController.text = patient['data']['address']['postal_code'];
    townController.text = patient['data']['address']['town'];
    villageController.text = patient['data']['address']['village'];
    streetNameController.text = patient['data']['address']['street_name'];
    mobilePhoneController.text = patient['data']['mobile'];
    homePhoneController.text = patient['data']['phone'];
    emailController.text = patient['data']['email'];
    nidController.text = patient['data']['nid'];   
    contactFirstNameController.text = patient['data']['contact_first_name'];
    contactLastNameController.text = patient['data']['contact_last_name'];
    contactRelationshipController.text = patient['data']['contact_relationship'];
    contactDistrictController.text = patient['data']['contact_address']['contact_district'];
    contactPostalCodeController.text = patient['data']['contact_address']['contact_postal_code'];
    contactTownController.text = patient['data']['contact_address']['contact_town'];
    contactVillageController.text = patient['data']['contact_address']['contact_village'];
    contactStreetNameController.text = patient['data']['contact_address']['contact_street_name'];
    contactMobilePhoneController.text = patient['data']['contact_mobile'];
    contactHomePhoneController.text = patient['data']['contact_phone'];
    contactEmailController.text = patient['data']['contact_email'];
    selectedRelation = relationships.indexOf(patient['data']['contact_relationship']);

  }

  _clearForm() {
    firstNameController.clear();
    lastNameController .clear();
    birthDateController.clear();
    birthMonthController.clear();
    birthYearController.clear();
    districtController.clear();
    postalCodeController.clear();
    townController.clear();
    villageController.clear();
    streetNameController.clear();
    mobilePhoneController.clear();
    homePhoneController.clear();
    emailController.clear();
    nidController.clear();   contactFirstNameController.clear();
    contactLastNameController.clear();
    contactRelationshipController.clear();
    contactDistrictController.clear();
    contactPostalCodeController.clear();
    contactTownController.clear();
    contactVillageController.clear();
    contactStreetNameController.clear();
    contactMobilePhoneController.clear();
    contactHomePhoneController.clear();
    contactEmailController.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register a New Patient'),
      ),
      body: CustomStepper(
        physics: ClampingScrollPhysics(),
        type: CustomStepperType.horizontal,
        
        controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
        return Row();
      },
        onStepTapped: (step) {
          // setState(() {
          //   this._currentStep = step;
          // });
        },
        steps: _mySteps(),
        currentStep: this._currentStep,
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
                    nextText = 'NEXT';
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.chevron_left),
                    Text('BACK', style: TextStyle(fontSize: 20)),
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
                  setState(() {
                    if (_currentStep == 1) {
                      if (_contactFormKey.currentState.validate()) {
                        _currentStep = _currentStep + 1;
                        nextText = 'FINISH';
                      }
                    }
                    if (_currentStep < 1) {
                      
                      if (_patientFormKey.currentState.validate()) {
                        // If the form is valid, display a Snackbar.
                        _currentStep = _currentStep + 1;
                      }
                    }
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(nextText, style: TextStyle(fontSize: 20)),
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
        title: Text('Patient Details', textAlign: TextAlign.center,),
        content: PatientDetails(),
        isActive: _currentStep >= 0,
      ),
      CustomStep(
        title: Text('Contact Details'),
        content: ContactDetails(),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text('Photo'),
        content: AddPhoto(),
        isActive: _currentStep >= 2,
      ),
    ];

    if (Configs().configAvailable('isThumbprint')) {
      _steps.add(
        CustomStep(
          title: Text('Thumbprint'),
          content: Text(''),
          isActive: _currentStep >= 3,
        )
      );
    }
      
    return _steps;
  }

  _prepareFormData() {
    return {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'gender': selectedGender,
      'age': 26, //age needs to be calculated
      'birth_date': birthDateController.text,
      'birth_month': birthMonthController.text,
      'birth_year': birthYearController.text,
      'nid': nidController.text,
      'pid': 'PA-19284921',
      'registration_date': DateFormat('y-MM-dd').format(DateTime.now()),
      'address': {
        'district': districtController.text,
        'postal_code': postalCodeController.text,
        'town': townController.text,
        'village': villageController.text,
        'street_name': streetNameController.text,
      },
      'mobile': mobilePhoneController.text,
      'phone': homePhoneController.text,
      'email': emailController.text,
      'contact': {
        'first_name': contactFirstNameController.text,
        'last_name': contactLastNameController.text,
        'relationship': selectedRelation != null ? relationships[selectedRelation] : '', 
        'address': {
          'district': contactDistrictController.text,
          'postal_code': contactPostalCodeController.text,
          'town': contactTownController.text,
          'village': contactVillageController.text,
          'street_name': contactStreetNameController.text,
        },
        'mobile': contactMobilePhoneController.text,
        'phone': contactHomePhoneController.text,
        'email': contactEmailController.text,
      },

    };
  }
  
}

class PatientDetails extends StatefulWidget {

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Form(
        key: _patientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Patient Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),

            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: 'First Name',
                    controller: firstNameController,
                    name: "First Name",
                    validation: true,
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: 'Last Name',
                    controller: lastNameController,
                    name: "Last Name",
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
                    Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
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
                            });
                          },
                        ),
                        Text("Male", style: TextStyle(color: Colors.black)),

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
                          "Female",
                        ),
                      ],
                    ),
                  ],
                )
              ),

              SizedBox(height: 20,),

              Text('Date of Birth', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
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
            SizedBox(height: 10,),
            Divider(),

            SizedBox(height: 20,),

            Text('Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),

            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'District',
              controller: districtController,
              name: "District",
              validation: true,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Postal Code',
              controller: postalCodeController,
              name: "Postal Code",
              validation: true,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Town',
              controller: townController,
              name: "Town",
              validation: true,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Village',
              controller: villageController,
              name: "Village",
              validation: true,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Street Name',
              controller: streetNameController,
              name: "Street Name",
              validation: true,
            ),
            Divider(),
            SizedBox(height: 20,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: 'Mobile Phone',
              controller: mobilePhoneController,
              name: "Mobile Phone",
              validation: true,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: 'Home Phone (Optional)',
              controller: homePhoneController,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.email),
              hintText: 'Email Address (Optional)',
              controller: emailController
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'National ID',
              controller: nidController,
              name: "National ID",
              validation: true,
            ),
          ],
        ),
      )
    );
  }
}

class ContactDetails extends StatefulWidget {

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Contact Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: "Contact's First Name",
                    controller: contactFirstNameController,
                    name: "Contact's First Name",
                    validation: true
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: "Contact's Last Name",
                    controller: contactLastNameController,
                    name: "Contact's Last Name",
                    validation: true
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),

            Container(
              child: DropdownButtonFormField(
                hint: Text('Relationship with contact', style: TextStyle(fontSize: 20, color: kTextGrey),),
                validator: (value) {
                  if (value == null) {
                    return 'Relationship is required';
                  }
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
            SizedBox(height: 15,),

            Text("Contact's Address", style: TextStyle(fontSize: 16),),
            SizedBox(height: 20,),

            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'District',
              controller: contactDistrictController,
              name: "District",
              validation: true
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Postal Code',
              controller: contactPostalCodeController,
              name: "Postal Code",
              validation: true,
              type: TextInputType.number,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Town',
              controller: contactTownController,
              name: "Town",
              validation: true
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Village',
              controller: contactVillageController,
              name: "Village",
              validation: true
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Street Name',
              controller: contactStreetNameController,
              name: "Street Name",
              validation: true
            ),
            
            Divider(),

            SizedBox(height: 20,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: "Contact's Mobile Phone",
              controller: contactMobilePhoneController,
              name: "Mobile Phone",
              validation: true,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: "Contact's Home Phone (Optional)",
              controller: contactHomePhoneController,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.email),
              hintText: "Contact's Email Address (Optional)",
              controller: contactEmailController,
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}

class AddPhoto extends StatefulWidget {
  const AddPhoto({
    Key key,
  }) : super(key: key);

  @override
  _AddPhotoState createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  // String selectedGender = 'male';

  File _image;

  Future getImageFromCam() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30,),
          Text('Take a Photo of the Patient', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
          SizedBox(height: 30,),

          GestureDetector(
            onTap: getImageFromCam,
            child: Container(
              height: 240,
              width: 240,
              // alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: kTableBorderGrey)
              ),
              child: _image == null ? Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.camera_alt, size: 90, color: kPrimaryColor,),
                  Text('Add a Photo', style: TextStyle(color: kPrimaryColor, fontSize: 20, height: 2))
                ],
              ) : Container(
                child: Stack(
                children: <Widget>[
                  Image.file(_image, fit: BoxFit.fill),
                  Positioned(
                    bottom: 0,
                    left: 70,
                    child: CircleAvatar(
                      child: Icon(Icons.delete),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 70,
                    child: CircleAvatar(
                      child: Icon(Icons.edit),
                    ),
                  )
                ],
              ),
              )
            ),
          ),

          SizedBox(height: 70,),
          
          GestureDetector(
            onTap: () async {
              var formData = _RegisterPatientState()._prepareFormData();
              var response = isEditState != null ? await PatientController().update(formData) : await PatientController().create(formData);
              if (response == 'success') {
                _RegisterPatientState()._clearForm();
                Navigator.of(context).pushReplacement(RegisterPatientSuccessScreen());
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
              child: Text("${isEditState != null ? 'UPDATE PATIENT' : 'COMPLETE REGISTRATION'}", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400))
            ),
          ),
        ],
      ),
    );
  }
}

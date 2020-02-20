import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';
import 'dart:async';
import 'dart:io';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
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
    _getCarePlan();
  }

  _getCarePlan() async {
    var data = await CarePlanController().getCarePlan();
    if (data != null && data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } 
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
    contactFirstNameController.text = patient['data']['contact']['first_name'];
    contactLastNameController.text = patient['data']['contact']['last_name'];
    contactRelationshipController.text = patient['data']['contact']['relationship'];
    contactDistrictController.text = patient['data']['contact']['address']['district'];
    contactPostalCodeController.text = patient['data']['contact']['address']['postal_code'];
    contactTownController.text = patient['data']['contact']['address']['town'];
    contactVillageController.text = patient['data']['contact']['address']['village'];
    contactStreetNameController.text = patient['data']['contact']['address']['street_name'];
    contactMobilePhoneController.text = patient['data']['contact']['mobile'];
    contactHomePhoneController.text = patient['data']['contact']['phone'];
    contactEmailController.text = patient['data']['contact']['email'];
    selectedRelation = relationships.indexOf(patient['data']['contact']['relationship']);

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
        title: Text(AppLocalizations.of(context).translate('registerNewPatient')),
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
                  setState(() {
                    if (_currentStep == 1) {
                      if (_contactFormKey.currentState.validate()) {
                        _currentStep = _currentStep + 1;
                        nextText = AppLocalizations.of(context).translate('finish');
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
        title: Text(AppLocalizations.of(context).translate('patientDetails'), textAlign: TextAlign.center,),
        content: PatientDetails(),
        isActive: _currentStep >= 0,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate('contactDetails')),
        content: ContactDetails(),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text(AppLocalizations.of(context).translate('photo')),
        content: AddPhoto(),
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
            Text(AppLocalizations.of(context).translate('patientDetails'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),

            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: AppLocalizations.of(context).translate('firstName'),
                    controller: firstNameController,
                    name: AppLocalizations.of(context).translate('firstName'),
                    validation: true,
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
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

              Text(AppLocalizations.of(context).translate('dateOfBirth'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
              SizedBox(height: 20,),

              Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: AppLocalizations.of(context).translate('dd'),
                    controller: birthDateController,
                    name: AppLocalizations.of(context).translate('date'),
                    validation: true,
                    type: TextInputType.number,
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: AppLocalizations.of(context).translate('mm'),
                    controller: birthMonthController,
                    name: AppLocalizations.of(context).translate('month'),
                    validation: true,
                    type: TextInputType.number
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: AppLocalizations.of(context).translate('yy'),
                    controller: birthYearController,
                    name: AppLocalizations.of(context).translate('year'),
                    validation: true,
                    type: TextInputType.number
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Divider(),

            SizedBox(height: 20,),

            Text(AppLocalizations.of(context).translate('address'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),

            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('district'),
              controller: districtController,
              name: AppLocalizations.of(context).translate('district'),
              validation: true,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('postalCode'),
              controller: postalCodeController,
              name: AppLocalizations.of(context).translate('postalCode'),
              validation: true,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('town'),
              controller: townController,
              name: AppLocalizations.of(context).translate('town'),
              validation: true,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('village'),
              controller: villageController,
              name: AppLocalizations.of(context).translate('village'),
              validation: true,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('streetName'),
              controller: streetNameController,
              name: AppLocalizations.of(context).translate('streetName'),
              validation: true,
            ),
            Divider(),
            SizedBox(height: 20,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: AppLocalizations.of(context).translate('mobile'),
              controller: mobilePhoneController,
              name: AppLocalizations.of(context).translate('mobile'),
              validation: true,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: AppLocalizations.of(context).translate('homePhone'),
              controller: homePhoneController,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.email),
              hintText: AppLocalizations.of(context).translate('emailAddress'),
              controller: emailController
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('nationalId'),
              controller: nidController,
              name: AppLocalizations.of(context).translate('nationalId'),
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
            Text(AppLocalizations.of(context).translate('contactDetails'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: AppLocalizations.of(context).translate("contactFirstName"),
                    controller: contactFirstNameController,
                    name: AppLocalizations.of(context).translate("contactFirstName"),
                    validation: true
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
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

            Text(AppLocalizations.of(context).translate("contact'sAddress"), style: TextStyle(fontSize: 16),),
            SizedBox(height: 20,),

            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('district'),
              controller: contactDistrictController,
              name: AppLocalizations.of(context).translate('district'),
              validation: true
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('postalCode'),
              controller: contactPostalCodeController,
              name: AppLocalizations.of(context).translate('postalCode'),
              validation: true,
              type: TextInputType.number,
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('town'),
              controller: contactTownController,
              name: AppLocalizations.of(context).translate('town'),
              validation: true
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('village'),
              controller: contactVillageController,
              name: AppLocalizations.of(context).translate('village'),
              validation: true
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: AppLocalizations.of(context).translate('streetName'),
              controller: contactStreetNameController,
              name: AppLocalizations.of(context).translate('streetName'),
              validation: true
            ),
            
            Divider(),

            SizedBox(height: 20,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: AppLocalizations.of(context).translate("contactMobilePhone"),
              controller: contactMobilePhoneController,
              name: AppLocalizations.of(context).translate("mobile"),
              validation: true,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: AppLocalizations.of(context).translate("contactHomePhone"),
              controller: contactHomePhoneController,
              type: TextInputType.number
            ),
            SizedBox(height: 10,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.email),
              hintText: AppLocalizations.of(context).translate("contactEmail"),
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
          Text(AppLocalizations.of(context).translate('takePhoto'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
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
                  Text(AppLocalizations.of(context).translate('addPhoto'), style: TextStyle(color: kPrimaryColor, fontSize: 20, height: 2))
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
              child: Text("${isEditState != null ? AppLocalizations.of(context).translate('updatePatient') : AppLocalizations.of(context).translate('completeRegistration')}", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400))
            ),
          ),
        ],
      ),
    );
  }
}

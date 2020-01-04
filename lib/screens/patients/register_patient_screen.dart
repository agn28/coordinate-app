import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/patients.dart';
import 'package:nhealth/screens/patients/register_patient_second_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import '../../custom-classes/custom_stepper.dart';

class RegisterPatientScreen extends CupertinoPageRoute {
  RegisterPatientScreen()
      : super(builder: (BuildContext context) => new RegisterPatient());

}


class RegisterPatient extends StatefulWidget {
  @override
  _RegisterPatientState createState() => _RegisterPatientState();
}

class _RegisterPatientState extends State<RegisterPatient> {
  
  int _currentStep = 0;

  String nextText = 'NEXT';

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
  String selectedGender = 'male';
  static GlobalKey<FormState> _patientFormKey = new GlobalKey<FormState>();
  
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
          setState(() {
            this._currentStep = step;
          });
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
                  print('firstname' + firstNameController.text);
                  print('contact email ' + contactEmailController.text);
                  setState(() {
                    print('step' + _currentStep.toString());

                    

                    // print('formData ' + formData.toString());

                    if (nextText == 'SAVE') {
                      var formData = _prepareFormData();
                      Patients().createPatient(formData);
                      // return;
                    }

                    if (_currentStep < 1) {
                      
                      print(_patientFormKey);
                      if (_patientFormKey.currentState.validate()) {
                        // If the form is valid, display a Snackbar.
                        _currentStep = _currentStep + 1;
                      }
                      nextText = 'SAVE';
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
              ) : Text('')
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
        content: PatientDetails(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
          birthDateController: birthDateController,
          birthMonthController: birthMonthController,
          birthYearController: birthYearController,
          districtController: districtController,
          postalCodeController: postalCodeController,
          townController: townController,
          villageController: villageController,
          streetNameController: streetNameController,
          mobilePhoneController: mobilePhoneController,
          homePhoneController: homePhoneController,
          emailController: emailController,
          nidController: nidController,
          selectedGender: selectedGender,
          formKey: _patientFormKey
        ),
        isActive: _currentStep >= 0,
      ),
      CustomStep(
        title: Text('Contact Details'),
        content: ContactDetails(
          contactFirstNameController: contactFirstNameController,
          contactLastNameController: contactLastNameController,
          contactRelationshipController: contactRelationshipController,
          contactDistrictController: contactDistrictController,
          contactPostalCodeController: contactPostalCodeController,
          contactTownController: contactTownController,
          contactVillageController: contactVillageController,
          contactStreetNameController: contactStreetNameController,
          contactMobilePhoneController: contactMobilePhoneController,
          contactHomePhoneController: contactHomePhoneController,
          contactEmailController: contactEmailController
        ),
        isActive: _currentStep >= 1,
      ),
      CustomStep(
        title: Text('Photo'),
        content: AddPhoto(),
        isActive: _currentStep >= 2,
      ),
      CustomStep(
        title: Text('Thumbprint'),
        content: Text(''),
        isActive: _currentStep >= 3,
      )
    ];

    return _steps;
  }

  _prepareFormData() {
    return {
      'name': firstNameController.text + ' ' + lastNameController.text,
      'gender': selectedGender,
      'age': 26, //age needs to be calculated
      'nid': nidController.text,
      'registration_data': DateTime.now().toString(),
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

      'contact_first_name': contactFirstNameController.text,
      'contact_last_name': contactLastNameController.text,
      'contact_relationship': contactRelationshipController.text, //age needs to be calculated
      'contact_address': {
        'contact_district': contactDistrictController.text,
        'contact_postal_code': contactPostalCodeController.text,
        'contact_town': contactTownController.text,
        'contact_village': contactVillageController.text,
        'contact_street_name': contactStreetNameController.text,
      },
      'contact_mobile': contactMobilePhoneController.text,
      'contact_phone': contactHomePhoneController.text,
      'contact_email': contactEmailController.text,
      
    };
  }
  
}

class PatientDetails extends StatefulWidget {
  getData() => createState()._getData();

  // validateForm() {
  //   if (formKey.currentState.validate()) {
  //       // If the form is valid, display a Snackbar.
  //       Scaffold.of(context)
  //           .showSnackBar(SnackBar(content: Text('Processing Data')));
  //     }
  // }

  final firstNameController;
  final lastNameController;
  // final gender = TextEditingController();
  final birthDateController;
  final birthMonthController;
  final birthYearController;
  final districtController;
  final postalCodeController;
  final townController;
  final villageController;
  final streetNameController;
  final mobilePhoneController;
  final homePhoneController;
  final emailController;
  final nidController;
  String selectedGender;
  final GlobalKey<FormState> formKey;

  PatientDetails({this.firstNameController, this.lastNameController, this.birthDateController, this.birthMonthController, this.birthYearController, this.districtController, this.postalCodeController, this.townController, this.villageController, this.streetNameController, this.mobilePhoneController, this.homePhoneController, this.emailController, this.nidController, this.selectedGender, this.formKey});

  validateForm() {
    print('validateform');
    if (formKey.currentState.validate()) {
      // If the form is valid, display a Snackbar.
      
    }
  }
  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  
  // final firstNameController = TextEditingController();

  _getData() {
    // print('hello' + firstNameController.text);
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Form(
        key: widget.formKey,
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
                    controller: widget.firstNameController,
                    name: "First Name"
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: 'Last Name',
                    controller: widget.lastNameController,
                  ),
                ),
              ],
            ),

            SizedBox(height: 40,),

            Container(
                // margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Gender', style: TextStyle(fontSize: 16),),
                    Row(
                      children: <Widget>[
                        // SizedBox(width: 20,),
                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'male',
                          groupValue: widget.selectedGender,
                          onChanged: (value) {
                            setState(() {
                              widget.selectedGender = value;
                            });
                          },
                        ),
                        Text("Male", style: TextStyle(color: Colors.black)),

                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'female',
                          groupValue: widget.selectedGender,
                          onChanged: (value) {
                            setState(() {
                              widget.selectedGender = value;
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

              SizedBox(height: 30,),

              Text('Date of Birth', style: TextStyle(fontSize: 16),),
              SizedBox(height: 20,),

              Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: 'dd',
                    controller: widget.birthDateController,
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: 'mm',
                    controller: widget.birthMonthController,
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: PrimaryTextField(
                    topPaadding: 18,
                    bottomPadding: 18,
                    hintText: 'yyyy',
                    controller: widget.birthYearController,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
            Divider(),

            SizedBox(height: 30,),

            Text('Address', style: TextStyle(fontSize: 16),),
            SizedBox(height: 20,),

            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'District',
              controller: widget.districtController,
            ),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Postal Code',
              controller: widget.postalCodeController,
            ),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Town',
            ),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Village',
              controller: widget.villageController,
            ),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'Street Name',
              controller: widget.streetNameController,
            ),
            SizedBox(height: 30,),
            Divider(),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: 'Mobile Phone',
              controller: widget.mobilePhoneController,
            ),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.phone),
              hintText: 'Home Phone (Optional)',
              controller: widget.homePhoneController,
            ),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              prefixIcon: Icon(Icons.email),
              hintText: 'Email Address (Optional)',
              controller: widget.emailController,
            ),
            SizedBox(height: 30,),
            PrimaryTextField(
              topPaadding: 18,
              bottomPadding: 18,
              hintText: 'National ID',
              controller: widget.nidController,
            ),

            RaisedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false
                // otherwise.
                if (widget.formKey.currentState.validate()) {
                  // If the form is valid, display a Snackbar.
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      )
    );
  }
}

class ContactDetails extends StatefulWidget {

  final contactFirstNameController;
  final contactLastNameController;
  final contactRelationshipController;
  final contactDistrictController;
  final contactPostalCodeController;
  final contactTownController;
  final contactVillageController;
  final contactStreetNameController;
  final contactMobilePhoneController;
  final contactHomePhoneController;
  final contactEmailController;

  ContactDetails({
    this.contactFirstNameController,
    this.contactLastNameController,
    this.contactRelationshipController,
    this.contactDistrictController,
    this.contactPostalCodeController,
    this.contactTownController,
    this.contactVillageController,
    this.contactStreetNameController,
    this.contactMobilePhoneController,
    this.contactHomePhoneController,
    this.contactEmailController
  });

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  String selectedGender = 'male';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
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
                  controller: widget.contactFirstNameController,
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: PrimaryTextField(
                  topPaadding: 18,
                  bottomPadding: 18,
                  hintText: "Contact's Last Name",
                  controller: widget.contactLastNameController,
                ),
              ),
            ],
          ),

          SizedBox(height: 30,),

          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Relationship with contact',
            controller: widget.contactRelationshipController,
          ),


          SizedBox(height: 30,),
          Divider(),

          SizedBox(height: 20,),

          Text("Contact's Address", style: TextStyle(fontSize: 16),),
          SizedBox(height: 20,),

          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'District',
            controller: widget.contactDistrictController,
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Postal Code',
            controller: widget.contactPostalCodeController,
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Town',
            controller: widget.contactTownController,
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Village',
            controller: widget.contactVillageController,
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Street Name',
            controller: widget.contactStreetNameController,
          ),
          
          SizedBox(height: 30,),
          Divider(),

          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.phone),
            hintText: "Contact's Mobile Phone",
            controller: widget.contactMobilePhoneController,
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.phone),
            hintText: "Contact's Home Phone (Optional)",
            controller: widget.contactHomePhoneController,
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.email),
            hintText: "Contact's Email Address (Optional)",
            controller: widget.contactEmailController,
          ),
          SizedBox(height: 30,),
        ],
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

          
        ],
      ),
    );
  }
}

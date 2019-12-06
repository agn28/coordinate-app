import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/screens/patients/register_patient_second_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';

class RegisterPatientFirstScreen extends CupertinoPageRoute {
  RegisterPatientFirstScreen()
      : super(builder: (BuildContext context) => new RegisterPatientFirst());

}


class RegisterPatientFirst extends StatefulWidget {
  @override
  _RegisterPatientFirstState createState() => _RegisterPatientFirstState();
}

class _RegisterPatientFirstState extends State<RegisterPatientFirst> {
  
  int _currentStep = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stepper(
        physics: ClampingScrollPhysics(),
        type: StepperType.horizontal,
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
                    _currentStep = _currentStep + 1;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('NEXT', style: TextStyle(fontSize: 20)),
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

  List<Step> _mySteps() {
    List<Step> _steps = [
      Step(
        title: Text('Patient Details', textAlign: TextAlign.center,),
        content: PatientDetails(),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: Text('Contact Details'),
        content: ContactDetails(),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: Text('Photo'),
        content: AddPhoto(),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: Text('Thumbprint'),
        content: TextField(),
        isActive: _currentStep >= 3,
      )
    ];

    return _steps;
  }
  
}

class PatientDetails extends StatefulWidget {
  const PatientDetails({
    Key key,
  }) : super(key: key);

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  String selectedGender = 'male';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
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
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: PrimaryTextField(
                  topPaadding: 18,
                  bottomPadding: 18,
                  hintText: 'Last Name',
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
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: PrimaryTextField(
                  topPaadding: 18,
                  bottomPadding: 18,
                  hintText: 'mm',
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: PrimaryTextField(
                  topPaadding: 18,
                  bottomPadding: 18,
                  hintText: 'yyyy',
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
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Postal Code',
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
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Street Name',
          ),
          SizedBox(height: 30,),
          Divider(),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.phone),
            hintText: 'Mobile Phone',
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.phone),
            hintText: 'Home Phone (Optional)',
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.email),
            hintText: 'Email Address (Optional)',
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'National ID',
          ),
        ],
      ),
    );
  }
}

class ContactDetails extends StatefulWidget {
  const ContactDetails({
    Key key,
  }) : super(key: key);

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
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: PrimaryTextField(
                  topPaadding: 18,
                  bottomPadding: 18,
                  hintText: "Contact's Last Name",
                ),
              ),
            ],
          ),

          SizedBox(height: 30,),

          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Relationship with contact',
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
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Postal Code',
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
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            hintText: 'Street Name',
          ),
          
          SizedBox(height: 30,),
          Divider(),

          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.phone),
            hintText: "Contact's Mobile Phone",
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.phone),
            hintText: "Contact's Home Phone (Optional)",
          ),
          SizedBox(height: 30,),
          PrimaryTextField(
            topPaadding: 18,
            bottomPadding: 18,
            prefixIcon: Icon(Icons.email),
            hintText: "Contact's Email Address (Optional)",
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
  String selectedGender = 'male';

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
                  Icon(Icons.camera_alt, size: 90, color: kTextGrey,),
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

          SizedBox(height: 800,)
          
        ],
      ),
    );
  }
}

// Container(
//               alignment: Alignment.topLeft,
//               margin: EdgeInsets.only(left: 40, right: 40),
//               width: double.infinity,
//               child: Column(
//                 children: <Widget>[
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "First Name",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Last Name",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Gender",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Date of Birth",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Address",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Mobile Phone",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Home Phone",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   TextField(
//                     style: TextStyle(
//                       fontSize: 22,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Email",
//                       contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   ButtonTheme(
//                     minWidth: 200.0,
//                     height: 60.0,
//                     child: RaisedButton(
//                       onPressed: () => Navigator.push(context, 
//                         MaterialPageRoute(builder: (ctx) => RegisterPatientSecondScreen())
//                       ),
//                       child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 22),),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

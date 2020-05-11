import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/home_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/new_encounter_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';


class RegisterPatientSuccessScreen extends CupertinoPageRoute {
  bool isEditState;
  RegisterPatientSuccessScreen({this.isEditState})
      : super(builder: (BuildContext context) => new RegisterPatientSuccess(isEditState: isEditState));

}

class RegisterPatientSuccess extends StatefulWidget {
  bool isEditState;
  RegisterPatientSuccess({this.isEditState});
  @override
  _RegisterPatientSuccessState createState() => _RegisterPatientSuccessState();
}

class _RegisterPatientSuccessState extends State<RegisterPatientSuccess> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('isedit');
    print(widget.isEditState);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('patientRegComplete')),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 40, right: 40),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF1dc555),
                          shape: BoxShape.circle
                        ),
                        child: Icon(Icons.done, size: 40, color: Colors.white,)
                      ),
                      SizedBox(width: 15,),
                      Text(widget.isEditState != null && widget.isEditState ? AppLocalizations.of(context).translate('patientUpdated') : AppLocalizations.of(context).translate('patientRegistered'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: Text(Helpers().getPatientName(Patient().getPatient()), style: TextStyle(fontSize: 22),),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(Helpers().getPatientAgeAndGender(Patient().getPatient()), style: TextStyle(fontSize: 18),),
                        SizedBox(width: 30,),
                        Text('PID: N-1213244232', style: TextStyle(fontSize: 18),),
                      ],
                    )
                  ),
                  SizedBox(height: 40,),
                  GestureDetector(
                    onTap: () {
                      // Navigator.of(context).pushReplacement( RegisterPatientSuccessScreen());
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      height: 58.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(AppLocalizations.of(context).translate('patientCard'), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400))
                    ),
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/patientOverview');
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      height: 58.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black54),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(AppLocalizations.of(context).translate('patientOverview'), style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w400))
                    ),
                  ),

                  SizedBox(height: 40,),

                  GestureDetector(
                    onTap: () => Navigator.of(context).push(NewEncounterScreen()),
                    child: Container(
                      // height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 5,
                            offset: Offset(0.0, 1.0,)
                          ),
                        ]
                      ),
                      child: Card(
                        elevation: 0,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset('assets/images/icons/manage_patient.png'),
                                        SizedBox(width: 20,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate('screenPatient'), style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w600),),
                                            SizedBox(height: 10,),
                                            Text(AppLocalizations.of(context).translate('newAssessment'), style: TextStyle(color: kTextGrey, fontSize: 14,),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      child: Icon(Icons.chevron_right, size: 40, color: kPrimaryColor,),
                                    )
                                  )
                                ],
                              ),
                            ),  

                          ],
                        )
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  GestureDetector(
                    onTap: () => Navigator.of(context).push(RegisterPatientScreen()),
                    child: Container(
                      // height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 5,
                            offset: Offset(0.0, 1.0,)
                          ),
                        ]
                      ),
                      child: Card(
                        elevation: 0,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset('assets/images/icons/register_patient.png'),
                                        SizedBox(width: 20,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate('registerNewPatient'), style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w600),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      child: Icon(Icons.chevron_right, size: 40, color: kPrimaryColor,),
                                    )
                                  )
                                ],
                              ),
                            ),  

                          ],
                        )
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => HomeScreen())),
                    child: Container(
                      // height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 5,
                            offset: Offset(0.0, 1.0,)
                          ),
                        ]
                      ),
                      child: Card(
                        elevation: 0,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset('assets/images/icons/home.png'),
                                        SizedBox(width: 20,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate('goHome'), style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.w600),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      child: Icon(Icons.chevron_right, size: 40, color: kPrimaryColor,),
                                    )
                                  )
                                ],
                              ),
                            ),  

                          ],
                        )
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/custom-classes/custom_stepper.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/careplan_delivery_screen.dart';
import 'package:nhealth/screens/chw/unwell/create_referral_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

final GlobalKey<FormState> _causesFormKey = new GlobalKey<FormState>();
List causes = ['Fever', 'Shortness of breath', 'Feeling faint', 'Stomach discomfort', 'Vision', 'Smell', 'Mental Health', 'Other'];

class UnwellCareplanScreen extends StatefulWidget {
  static const path = '/unwellCareplanScreen';
  @override
  _UnwellCareplanScreen createState() => _UnwellCareplanScreen();
}

class _UnwellCareplanScreen extends State<UnwellCareplanScreen> { 
  int _currentStep = 0;
  String nextText = 'Ok to Proceed';

  @override
  void initState() {
    super.initState();
    nextText = (Language().getLanguage() == 'Bengali') ? 'এগিয়ে যান' : 'Ok to Proceed';
    _checkAuth();
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _causesFormKey,
      appBar: AppBar(
        leading: FlatButton(
          onPressed: (){
            setState(() {
              Navigator.pop(context);
            });
          }, 
        child: Icon(Icons.arrow_back, color: Colors.white,)
        ),
        title: Text(AppLocalizations.of(context).translate('deliverCarePlan')),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: CustomStepper(
          isHeader: false,
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
      ),
      bottomNavigationBar: Container(
        color: kBottomNavigationGrey,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _currentStep == 0 ? FlatButton(
                onPressed: () {
                  setState(() {
                    var data = {
                      'meta': {
                        'patient_id': Patient().getPatient()['uuid'],
                        "collected_by": Auth().getAuth()['uid'],
                        "status": "pending"
                      },
                      'body': {}
                    };
                    Navigator.of(context).pushNamed(CreateReferralScreen.path, arguments: data);
                    return;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate("unableToProceed"), style: TextStyle(fontSize: 20)),
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
              child: _currentStep < _mySteps().length ? FlatButton(
                onPressed: () {
                  setState(() {
                    if (_currentStep == 0) {
                      Navigator.of(context).pushNamed(ChwCareplanDeliveryScreen.path);
                    }
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(nextText, style: TextStyle(fontSize: 20)),
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
        title: Text(AppLocalizations.of(context).translate("causes"), textAlign: TextAlign.center,),
        content: UnwellCauses(),
        isActive: _currentStep >= 0,
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

}

class UnwellCauses extends StatefulWidget {
  @override
  _UnwellCausesState createState() => _UnwellCausesState();
}

class _UnwellCausesState extends State<UnwellCauses> { 
  var selectedReason = 0;

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Form(
        key: _causesFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PatientTopbar(),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context).translate('unwellCause'), style: TextStyle(fontSize: 21),),
            ),
            SizedBox(height: 30,),

            Container(
              color: kSecondaryTextField,
              margin: EdgeInsets.symmetric(horizontal: 100),
              child: DropdownButtonFormField(
                hint: Text(AppLocalizations.of(context).translate("selectAReason"), style: TextStyle(fontSize: 20, color: kTextGrey),),
                decoration: InputDecoration(
                  fillColor: kSecondaryTextField,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  border: UnderlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  )
                ),
                ),
                items: [
                  ...causes.map((item) =>
                    DropdownMenuItem(
                      child: Text(item),
                      value: causes.indexOf(item)
                    )
                  ).toList(),
                ],
                value: selectedReason,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                    print('selectedReason $selectedReason');
                  });
                },
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/chw/careplan_actions/careplan_delivery_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../app_localizations.dart';

class CounsellingConfirmation extends StatefulWidget {
  static const path = '/counsellingConfirm';
  var data;
  var actionsState;
  CounsellingConfirmation({this.data, this.actionsState});

  @override
  _CounsellingConfirmationState createState() => _CounsellingConfirmationState();
}

class _CounsellingConfirmationState extends State<CounsellingConfirmation> {
  String selectedWith5A = 'with5A';
  String selectedWithout5A = 'without5A';
  bool withFramework = true;
  bool isLoading = false;
  
  bool checkValue = false;

  @override
  initState() {
    super.initState();
    isLoading = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.data['body']['goal']['title']),),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
            child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: !isLoading ? Column(
          
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              PatientTopbar(),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(AppLocalizations.of(context).translate("confirmHowCounsellingWasProvided"),style: TextStyle(color: Colors.black,fontSize: 18),),

                      Row(
                        children: [
                        Radio(
                          activeColor: kPrimaryColor,
                          value: true,
                          groupValue: withFramework,
                          onChanged: (val) {
                            setState(() {
                              withFramework = val;
                            });
                          },
                          ),
                          Text(AppLocalizations.of(context).translate("with5AFarmework"), style: TextStyle(fontSize: 17),),
                        ],
                      ),
                      Row(
                        children: [
                        Radio(
                            activeColor: kPrimaryColor,
                            value: false,
                            groupValue: withFramework,
                            onChanged: (val) {
                              setState(() {
                                withFramework = val;
                              });
                            },
                          ),
                        Text(AppLocalizations.of(context).translate("without5AFarmework"), style: TextStyle(fontSize: 17),),
                        ],
                      ),

                      SizedBox(height: 60,),
                  
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              //margin: EdgeInsets.only(left: 15, right: 15),
                              height: 50,
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: FlatButton(
                                onPressed: () async {
                                  widget.actionsState.setState(() {
                                    widget.actionsState.setStatus();
                                  });
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var result = await Questionnaire().addCounselling(withFramework, widget.data);
                                  print('result');
                                  print(result);
                                  print('widget.data');
                                  print(widget.data);

                                  var response ='success';
                                  // var response = await CarePlanController().update(widget.data, '');
                                  setState(() {
                                    isLoading = false;
                                  });
                                  int count = 0;
                                  Navigator.of(context).popUntil((_) => count++ >= 2);
                                  if (response == 'success') {
                                    
                                    // Navigator.of(context).pop();
                                  } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                                  
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(AppLocalizations.of(context).translate('completeAction').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
              ),
                  
            ]
          ) : Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Color(0x90FFFFFF),
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
              ),
            ),
        ),
      ),
    );
    
  }
}






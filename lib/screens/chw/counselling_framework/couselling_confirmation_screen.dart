import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../app_localizations.dart';

class CounsellingConfirmation extends StatefulWidget {
  static const path = '/counsellingConfirm';
  var data;
  CounsellingConfirmation({this.data});

  @override
  _CounsellingConfirmationState createState() => _CounsellingConfirmationState();
}

class _CounsellingConfirmationState extends State<CounsellingConfirmation> {
  String selectedWith5A = 'with5A';
  String selectedWithout5A = 'without5A';
  bool withFramework = false;
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
      appBar: AppBar(title: Text("Quite tabacco use"),),
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
                      Text("Confirm how counselling was provided:",style: TextStyle(color: Colors.black,fontSize: 18),),

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
                          Text('With 5A Farmwork', style: TextStyle(fontSize: 17),),
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
                        Text('Without 5A Farmwork', style: TextStyle(fontSize: 17),),
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
                                  // widget.parent.setState(() {
                                  //   widget.parent.setStatus();
                                  // });
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var response = await CarePlanController().update(widget.data, '');
                                  Navigator.of(context).pop();
                                  if (response == 'success') {
                                    
                                    Navigator.of(context).pop();
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





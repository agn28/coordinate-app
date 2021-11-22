import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/care_plan_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/screens/chw/careplan_actions/careplan_delivery_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

class ChcpCounsellingConfirmation extends StatefulWidget {
  static const path = '/chcpCounsellingConfirm';
  var data;
  var parent;
  ChcpCounsellingConfirmation({this.data, this.parent});

  @override
  _ChcpCounsellingConfirmationState createState() => _ChcpCounsellingConfirmationState();
}
var isCounsellingProvided = null;
class _ChcpCounsellingConfirmationState extends State<ChcpCounsellingConfirmation> {
  String selectedWith5A = 'with5A';
  String selectedWithout5A = 'without5A';
  bool withFramework = true;
  bool isLoading = false;
  final commentController = TextEditingController();

  bool checkValue = false;

  @override
  initState() {
    super.initState();
    isLoading = false;
    isCounsellingProvided = null;
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
                SizedBox(height: 30,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 35, top: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: kBorderLighter)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(AppLocalizations.of(context).translate('counselingProvided'),style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    )
                                  ),
                                  SizedBox(height: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width * .5,
                                    child: Row(
                                      children: <Widget>[
                                        // ...question['options'].map((option) =>
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            width: 100,
                                            margin: EdgeInsets.only(right: 20, left: 0),
                                            decoration: BoxDecoration(
                                              border: Border.all(width: 1, color: (isCounsellingProvided != null && isCounsellingProvided) ? Color(0xFF01579B) : Colors.black),
                                              borderRadius: BorderRadius.circular(3),
                                              color: (isCounsellingProvided != null && isCounsellingProvided) ? Color(0xFFE1F5FE) : null
                                            ),
                                            child: FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  isCounsellingProvided = true;
                                                });
                                              },
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              child: Text(AppLocalizations.of(context).translate('yes'),
                                                style: TextStyle(color: (isCounsellingProvided != null && isCounsellingProvided) ? kPrimaryColor : null),
                                              ),
                                            ),
                                          )
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            width: 100,
                                            margin: EdgeInsets.only(right: 20, left: 0),
                                            decoration: BoxDecoration(
                                              border: Border.all(width: 1, color: (isCounsellingProvided == null || isCounsellingProvided) ? Colors.black  : Color(0xFF01579B)),
                                              borderRadius: BorderRadius.circular(3),
                                              color: (isCounsellingProvided == null || isCounsellingProvided) ? null : Color(0xFFE1F5FE)
                                            ),
                                            child: FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  isCounsellingProvided = false;
                                                });
                                              },
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              child: Text(AppLocalizations.of(context).translate('NO'),
                                                style: TextStyle(color: (isCounsellingProvided == null || isCounsellingProvided) ? null : kPrimaryColor),
                                              ),
                                            ),
                                          )
                                        ),
                                        // ).toList()
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  (isCounsellingProvided != null && isCounsellingProvided) ?
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context).translate('whatOutcome'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                      SizedBox(height: 20,),
                                      TextField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 5,
                                        style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                                        controller: commentController,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 20, right: 20),
                                          filled: true,
                                          fillColor: kSecondaryTextField,
                                          border: new UnderlineInputBorder(
                                            borderSide: new BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            )
                                          ),

                                          hintText: '',
                                          hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                                        ),
                                      ),
                                    ],
                                  ) : Container(),
                                  SizedBox(height: 20,),
                                  Container(
                                    width: double.infinity,
                                      //margin: EdgeInsets.only(left: 15, right: 15),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: FlatButton(
                                      onPressed: () async {
                                        widget.parent.setState(() {
                                          widget.parent.setStatus();
                                        });
                                        setState(() {
                                          isLoading = true;
                                        });
                                        var response = await CarePlanController().update(context, widget.data, commentController.text);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.of(context).pop();
                                        if (response != 'success') {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('Error! ${response}'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Text(AppLocalizations.of(context).translate('completeAction').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ),

                    ],
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

      // body: SingleChildScrollView(
      //   scrollDirection: Axis.vertical,
      //       child: Container(
      //       margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      //       child: !isLoading ? Column(

      //       mainAxisAlignment: MainAxisAlignment.start,
      //       children: <Widget>[
      //         PatientTopbar(),
      //         Padding(
      //           padding: const EdgeInsets.all(15.0),
      //           child: Padding(
      //             padding: const EdgeInsets.all(15.0),
      //             child: Container(
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.start,
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                 Text(AppLocalizations.of(context).translate("confirmHowCounsellingWasProvided"),style: TextStyle(color: Colors.black,fontSize: 18),),

      //                 Row(
      //                   children: [
      //                   Radio(
      //                     activeColor: kPrimaryColor,
      //                     value: true,
      //                     groupValue: withFramework,
      //                     onChanged: (val) {
      //                       setState(() {
      //                         withFramework = val;
      //                       });
      //                     },
      //                     ),
      //                     Text(AppLocalizations.of(context).translate("with5AFarmework"), style: TextStyle(fontSize: 17),),
      //                   ],
      //                 ),
      //                 Row(
      //                   children: [
      //                   Radio(
      //                       activeColor: kPrimaryColor,
      //                       value: false,
      //                       groupValue: withFramework,
      //                       onChanged: (val) {
      //                         setState(() {
      //                           withFramework = val;
      //                         });
      //                       },
      //                     ),
      //                   Text(AppLocalizations.of(context).translate("without5AFarmework"), style: TextStyle(fontSize: 17),),
      //                   ],
      //                 ),

      //                 SizedBox(height: 60,),

      //                 Row(
      //                   children: <Widget>[
      //                     Expanded(
      //                       child: Container(
      //                         width: double.infinity,
      //                         //margin: EdgeInsets.only(left: 15, right: 15),
      //                         height: 50,
      //                         decoration: BoxDecoration(
      //                           color: kPrimaryColor,
      //                           borderRadius: BorderRadius.circular(3)
      //                         ),
      //                         child: FlatButton(
      //                           onPressed: () async {
      //                             widget.actionsState.setState(() {
      //                               widget.actionsState.setStatus();
      //                             });
      //                             setState(() {
      //                               isLoading = true;
      //                             });
      //                             var result = await Questionnaire().addCounselling(withFramework, widget.data);
      //                             print('result');
      //                             print(result);
      //                             print('widget.data');
      //                             print(widget.data);

      //                             var response = await CarePlanController().update(widget.data, '');
      //                             setState(() {
      //                               isLoading = false;
      //                             });
      //                             int count = 0;
      //                             Navigator.of(context).popUntil((_) => count++ >= 2);
      //                             if (response == 'success') {

      //                               // Navigator.of(context).pop();
      //                             } else Toast.show('There is some error', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);

      //                           },
      //                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //                           child: Text(AppLocalizations.of(context).translate('completeAction').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //           ),
      //         ),

      //       ]
      //     ) : Container(
      //         height: MediaQuery.of(context).size.height,
      //         width: double.infinity,
      //         color: Color(0x90FFFFFF),
      //         child: Center(
      //           child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
      //         ),
      //       ),
      //   ),
      // ),
    );
    
  }
}






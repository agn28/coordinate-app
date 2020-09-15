

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/screens/chw/counselling_framework/couselling_confirmation_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../app_localizations.dart';

final GlobalKey<FormState> _counsellingFormKey =  GlobalKey<FormState>();

class CounsellingFrameworkScreen extends StatefulWidget {
  static const path = '/counsellingFramework';
  final data;
  final parent;
  CounsellingFrameworkScreen({this.data, this.parent});

  @override
  _CounsellingFrameworkScreenState createState() => _CounsellingFrameworkScreenState();
}

class _CounsellingFrameworkScreenState extends State<CounsellingFrameworkScreen> {
  bool ask = false;
  bool advise = false;
  bool assess = false;
  bool assist = false;
  bool arrange = false;
  
  bool checkValue = false;

  handleComplete() {
    if (ask && advise && assess && assist && arrange) {
      Navigator.of(context).pushNamed(CounsellingConfirmation.path, arguments: { 'data': widget.data});
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Alert();
      },
    );

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.data['body']['title']),),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Form(
            key: _counsellingFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PatientTopbar(),
                SizedBox(height: 30,),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: Text('Deliver counselling for risk behavior', style: TextStyle(fontSize: 18,),),
                ),
                SizedBox(height: 20,),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 35, top: 20),
                        decoration: BoxDecoration(
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: ExpandableNotifier(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: kBorderLighter)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ScrollOnExpand(
                                          scrollOnExpand: true,
                                          scrollOnCollapse: false,
                                          child: ExpandablePanel(
                                            theme: const ExpandableThemeData(
                                              headerAlignment: ExpandablePanelHeaderAlignment.center,
                                              tapBodyToCollapse: true,
                                            ),
                                            header: Container(
                                              padding: EdgeInsets.only(top:10, left: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Ask'.toUpperCase(),
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            expanded: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 15,),
                                                Container(
                                                  padding: EdgeInsets.only(left: 16),
                                                  child: Text('Ask important aspects of behavioural risk factor', style: TextStyle( fontSize: 17)),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Checkbox(
                                                      activeColor: kPrimaryColor,
                                                      value: ask,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          ask = value;
                                                        });
                                                      },
                                                    ),
                                                    Text('Completed', style: TextStyle(color: Colors.black, fontSize: 17)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            builder: (_, collapsed, expanded) {
                                              return Padding(
                                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                child: Expandable(
                                                  collapsed: collapsed,
                                                  expanded: expanded,
                                                  theme: const ExpandableThemeData(crossFadePoint: 0),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ),
                            ),

                            SizedBox(height: 30,),
                            
                            Container(
                              child: ExpandableNotifier(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: kBorderLighter)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ScrollOnExpand(
                                          scrollOnExpand: true,
                                          scrollOnCollapse: false,
                                          child: ExpandablePanel(
                                            theme: const ExpandableThemeData(
                                              headerAlignment: ExpandablePanelHeaderAlignment.center,
                                              tapBodyToCollapse: true,
                                            ),
                                            header: Container(
                                              padding: EdgeInsets.only(top:10, left: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Advise'.toUpperCase(),
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            expanded: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 15,),
                                                Container(
                                                  padding: EdgeInsets.only(left: 16),
                                                  child: Text("Provide important key message on the risk factor ", style: TextStyle(fontSize: 17),),
                                                ),
                                                
                                                Row(
                                                  children: <Widget>[
                                                    Checkbox(
                                                      activeColor: kPrimaryColor,
                                                      value: advise,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          advise = value;
                                                        });
                                                      
                                                      },
                                                    ),
                                                    Text('Completed', style: TextStyle(color: Colors.black, fontSize: 17)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            builder: (_, collapsed, expanded) {
                                              return Padding(
                                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                child: Expandable(
                                                  collapsed: collapsed,
                                                  expanded: expanded,
                                                  theme: const ExpandableThemeData(crossFadePoint: 0),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ),
                            ),

                            SizedBox(height: 30,),

                            Container(
                              child: ExpandableNotifier(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: kBorderLighter)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ScrollOnExpand(
                                          scrollOnExpand: true,
                                          scrollOnCollapse: false,
                                          child: ExpandablePanel(
                                            theme: const ExpandableThemeData(
                                              headerAlignment: ExpandablePanelHeaderAlignment.center,
                                              tapBodyToCollapse: true,
                                            ),
                                            header: Container(
                                              padding: EdgeInsets.only(top:10, left: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Assess'.toUpperCase(),
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            expanded: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 15,),
                                                Container(
                                                  padding: EdgeInsets.only(left: 16),
                                                  child: Text("Determine if patinet is ready for information and assistance ", style: TextStyle(fontSize: 17),),
                                                ),

                                                Row(
                                                  children: <Widget>[
                                                    Checkbox(
                                                      activeColor: kPrimaryColor,
                                                      value: assess,
                                                      onChanged: (value) {
                                                        setState(() {
                                                            assess = value;
                                                        });
                                                      
                                                      },
                                                    ),
                                                    Text('Completed', style: TextStyle(color: Colors.black, fontSize: 17)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            builder: (_, collapsed, expanded) {
                                              return Padding(
                                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                child: Expandable(
                                                  collapsed: collapsed,
                                                  expanded: expanded,
                                                  theme: const ExpandableThemeData(crossFadePoint: 0),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ),
                            ),

                            SizedBox(height: 30,),

                            Container(
                              child: ExpandableNotifier(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: kBorderLighter)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ScrollOnExpand(
                                          scrollOnExpand: true,
                                          scrollOnCollapse: false,
                                          child: ExpandablePanel(
                                            theme: const ExpandableThemeData(
                                              headerAlignment: ExpandablePanelHeaderAlignment.center,
                                              tapBodyToCollapse: true,
                                            ),
                                            header: Container(
                                              padding: EdgeInsets.only(top:10, left: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Assist'.toUpperCase(),
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            expanded: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 15,),
                                                Container(
                                                  padding: EdgeInsets.only(left: 16),
                                                  child: Text("Provide in-depth counselling and assistance", style: TextStyle(fontSize: 17),),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Checkbox(
                                                      activeColor: kPrimaryColor,
                                                      value: assist,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          assist = value;
                                                        });
                                                      
                                                      },
                                                    ),
                                                    Text('Completed', style: TextStyle(color: Colors.black, fontSize: 18)),
                                                  ],
                                                ), 
                                              ],
                                            ),
                                            builder: (_, collapsed, expanded) {
                                              return Padding(
                                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                child: Expandable(
                                                  collapsed: collapsed,
                                                  expanded: expanded,
                                                  theme: const ExpandableThemeData(crossFadePoint: 0),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ),
                            ),

                            SizedBox(height: 30,),

                            Container(
                              child: ExpandableNotifier(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: kBorderLighter)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ScrollOnExpand(
                                          scrollOnExpand: true,
                                          scrollOnCollapse: false,
                                          child: ExpandablePanel(
                                            theme: const ExpandableThemeData(
                                              headerAlignment: ExpandablePanelHeaderAlignment.center,
                                              tapBodyToCollapse: true,
                                            ),
                                            header: Container(
                                              padding: EdgeInsets.only(top:10, left: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Arrange '.toUpperCase(),
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            expanded: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 15,),
                                                Container(
                                                  padding: EdgeInsets.only(left: 16),
                                                  child: Text("Provide guideance on referral and follow-up actions", style: TextStyle(fontSize: 17),),
                                                ),

                                                Row(
                                                  children: <Widget>[
                                                    Checkbox(
                                                      activeColor: kPrimaryColor,
                                                      value: arrange,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          arrange = value;
                                                        });
                                                      
                                                      },
                                                    ),
                                                    Text('Completed', style: TextStyle(color: Colors.black, fontSize: 18)),
                                                  ],
                                                ),
                                              
                                              ],
                                            ),
                                            builder: (_, collapsed, expanded) {
                                              return Padding(
                                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                child: Expandable(
                                                  collapsed: collapsed,
                                                  expanded: expanded,
                                                  theme: const ExpandableThemeData(crossFadePoint: 0),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ),
                            ),
                            
                          
                            SizedBox(height: 50,),

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
                                      onPressed: ()  {

                                        handleComplete();

                                      // Route route = MaterialPageRoute(
                                      //   builder: (context) =>
                                      //   CounsellingFramworkScreen());
                                      //   Navigator.push(context, route);
                                        
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: Text(AppLocalizations.of(context).translate('completeCounselling').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ),

                    ],
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
    
  }
}


class Alert extends StatelessWidget {
  const Alert({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return     AlertDialog(
      title: Icon(Icons.warning,size: 40,color: Colors.orange,),
      content: Text("Please ensure all sections are completed before proceeding",
      style: TextStyle(fontSize: 17,color: Colors.black),),
    
      actions: [
        Container(
          alignment: Alignment.bottomRight,
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context).translate('back'), style: TextStyle(color: kPrimaryColor, fontSize: 17))
              ),
              SizedBox(width: 15,)
    
            ],
    
          )
    
        ),
    
      ],
    
    );
  }
}





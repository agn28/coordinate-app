import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

var preParedCarePlans = [];

class CarePlanDetailsScreen extends StatefulWidget {
  var carePlans;
  CarePlanDetailsScreen({this.carePlans});
  @override
  _CarePlanDetailsState createState() => _CarePlanDetailsState();
}

class _CarePlanDetailsState extends State<CarePlanDetailsScreen> {
  var reports;
  bool isLoading = false;
  bool canEdit = false;
  final commentsController = TextEditingController();
  String generateDate = '';

  @override
  void initState() {
    super.initState();
    // getReports();
    prepareCarePlans();
  }

  prepareCarePlans() {
    var data = widget.carePlans;
    preParedCarePlans = [];
    

    data.forEach((carePlan) { 
      if (carePlan['body']['goal'] != null) {
        var existedCp = preParedCarePlans.where( (cp) => cp['id'] == carePlan['body']['goal']['id']);
        // print(carePlan['body']['goal']);
        // print(existedCp);

        if (existedCp.isEmpty) {
          var items = [];
          items.add(carePlan);
          // print(items);
          if (carePlan['body']['goal'] != null) {
            preParedCarePlans.add({
              'items': items,
              'title': carePlan['body']['goal']['title'],
              'id': carePlan['body']['goal']['id']
            });
          }
        } else {
          preParedCarePlans[preParedCarePlans.indexOf(existedCp.first)]['items'].add(carePlan);
        }
      }
    });

    print(preParedCarePlans[0]);
  }


  getReports() async {
    isLoading = true;
    var data = await HealthReportController().getLastReport(context);
    
    if (data['error'] == true) {
      setState(() {
        isLoading = false;
      });
      Toast.show('No Health assessment found', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    } else if (data['message'] == 'Unauthorized') {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    } else {
      setState(() {
        isLoading = false;
        reports = data['data'];
        if (reports['meta']['report_date']['_seconds'] != null) {
          var parsedDate = DateTime.fromMillisecondsSinceEpoch(reports['meta']['report_date']['_seconds'] * 1000);

          generateDate =  DateFormat("MMMM d, y").format(parsedDate).toString();
        }
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("carePlan"), style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            widget.carePlans != null && !isLoading ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PatientTopbar(),

                Container(
                  color: Colors.white,
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('generatedOn') + generateDate, style: TextStyle(fontSize: 16),),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: kBorderLight)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('summary'), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                      SizedBox(height: 20,),
                      reports != null ?
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  reports['body']['result']['assessments']['body_composition']['components']['body_fat'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate("fat"), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['body_fat']['value']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['body_fat']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                             ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['body_fat']['eval']}', 
                                              style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['body_fat']['tfl']] ?? Colors.black, 
                                                fontWeight: FontWeight.w500
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),
                                  SizedBox(height: 35,),

                                  reports['body']['result']['assessments']['lifestyle']['components']['smoking'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate('tobaccoUse'), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['lifestyle']['components']['smoking']['eval']}', 
                                              style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['lifestyle']['components']['smoking']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),

                                  SizedBox(height: 35,),

                                  reports['body']['result']['assessments']['lifestyle']['components']['physical_activity'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate('physicalActivity'), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['lifestyle']['components']['physical_activity']['eval']}', 
                                              style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['lifestyle']['components']['physical_activity']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            )
                                            
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),

                                  SizedBox(height: 35,),

                                  reports['body']['result']['assessments']['diabetes'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate('fastingBloodSugar'), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['diabetes']['value']}',
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['diabetes']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['diabetes']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['diabetes']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),

                                  SizedBox(height: 35,),

                                  reports['body']['result']['assessments']['cvd'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate("cvdRisk"), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['cvd']['value']}',
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['cvd']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['cvd']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['cvd']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),
                                ],
                              ),
                            ),

                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  reports['body']['result']['assessments']['body_composition']['components']['bmi'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate("bmi"), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['bmi']['value']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['body_composition']['components']['bmi']['eval']}', 
                                            style: TextStyle(
                                              fontSize: 14, 
                                              color: ColorUtils.statusColor[reports['body']['result']['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),

                                  SizedBox(height: 35,),

                                  reports['body']['result']['assessments']['lifestyle']['components']['alcohol'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate('alcoholConsumption'), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['lifestyle']['components']['alcohol']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['lifestyle']['components']['alcohol']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),

                                  SizedBox(height: 35,),

                                  reports['body']['result']['assessments']['blood_pressure'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate("bloodPressure"), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['blood_pressure']['value']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['blood_pressure']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['blood_pressure']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['blood_pressure']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),

                                  SizedBox(height: 35,),
                                  
                                  reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(AppLocalizations.of(context).translate("totalCholesterol"), style: TextStyle(fontSize: 19),),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: <Widget>[
                                            Text('${reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['value']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(width: 40,),
                                            Text('${reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['eval']}', 
                                            style: TextStyle(
                                                fontSize: 14, 
                                                color: ColorUtils.statusColor[reports['body']['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ) : Container(),
                                  
                                ],
                              ),
                            )
                          ],
                        ),
                      ) : Container(),
                    ],
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: kBorderLight)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('interventions'), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                      SizedBox(height: 20,),

                      ...preParedCarePlans.map<Widget>((item) => 
                        Interventions(carePlan: item),
                      ).toList(),
                      SizedBox(height: 25,),

                      SizedBox(height: 20,),

                      Container(
                        child: ExpandableTheme(
                          data: ExpandableThemeData(
                            iconColor: kBorderGrey,
                            iconPlacement: ExpandablePanelIconPlacement.left,
                            useInkWell: true,
                            iconPadding: EdgeInsets.only(top: 12, left: 8, right: 8)
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  child: ExpandableNotifier(
                                    child: Padding(
                                    padding: const EdgeInsets.all(10),
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
                                                padding: EdgeInsets.only(top:10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Nutrition',
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(height: 30,),
        
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
                                )
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        child: ExpandableTheme(
                          data: ExpandableThemeData(
                            iconColor: kBorderGrey,
                            iconPlacement: ExpandablePanelIconPlacement.left,
                            useInkWell: true,
                            iconPadding: EdgeInsets.only(top: 12, left: 8, right: 8)
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  child: ExpandableNotifier(
                                    child: Padding(
                                    padding: const EdgeInsets.all(10),
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
                                                padding: EdgeInsets.only(top:10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Physical Activity',
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(height: 30,),
        
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
                                )
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        child: ExpandableTheme(
                          data: ExpandableThemeData(
                            iconColor: kBorderGrey,
                            iconPlacement: ExpandablePanelIconPlacement.left,
                            useInkWell: true,
                            iconPadding: EdgeInsets.only(top: 12, left: 8, right: 8)
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  child: ExpandableNotifier(
                                    child: Padding(
                                    padding: const EdgeInsets.all(10),
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
                                                padding: EdgeInsets.only(top:10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Managing Medication',
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(height: 20,),
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(AppLocalizations.of(context).translate("goals"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                                        SizedBox(width: 50,),
                                                        Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Row(
                                                                children: <Widget>[
                                                                  Icon(Icons.lens, size: 8, color: kPrimaryColor),
                                                                  SizedBox(width: 10,),
                                                                  Text(AppLocalizations.of(context).translate("improveGlycemic"), style: TextStyle(fontSize: 16,))
                                                                ],
                                                              ),
                                                              SizedBox(height: 10,),
                                                              Row(
                                                                children: <Widget>[
                                                                  Icon(Icons.lens, size: 8, color: kPrimaryColor),
                                                                  SizedBox(width: 10,),
                                                                  Text(AppLocalizations.of(context).translate("medicationAdherence"), style: TextStyle(fontSize: 16,))
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                
                                                
                                                  SizedBox(height: 30,),
                                                  Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                                          padding: EdgeInsets.only(bottom: 12),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              bottom: BorderSide(width: 2, color: kBorderLighter)
                                                            )
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Text(
                                                                  'Interventions',
                                                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                                ),
                                                              ),
                                                              SizedBox(width: 20,),
                                                              Expanded(
                                                                child: Text(
                                                                  'Frequency',
                                                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),

                                                        Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                                          padding: EdgeInsets.only(bottom: 12),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Container(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      SizedBox(height: 10,),
                                                                      Text(
                                                                        'MEDICATION',
                                                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: kTextGrey),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      Text(
                                                                        'Initiate METFORMIN 250 - 500 mg once daily   ',
                                                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15,),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      Text(
                                                                        'Diabetic therapy - first time',
                                                                        style: TextStyle(fontSize: 14,),
                                                                      ),

                                                                      SizedBox(height: 15,),

                                                                      Row(
                                                                        children: <Widget>[
                                                                          Container(
                                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(color: kPrimaryColor),
                                                                              borderRadius: BorderRadius.circular(2)
                                                                            ),
                                                                            child: InkWell(
                                                                              onTap: () {},
                                                                              child: Text(
                                                                                'Components',
                                                                                style: TextStyle(color: kPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                                                                              ),
                                                                            )
                                                                          ),

                                                                          SizedBox(width: 20,),

                                                                          Text(
                                                                            'Doctor',
                                                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 20,),
                                                              Expanded(
                                                                child: Container(
                                                                  margin: EdgeInsets.only(top: 10),
                                                                  child: Text(
                                                                    'Followup: After 1 month',
                                                                    style: TextStyle(fontSize: 14,),
                                                                  ),
                                                                )
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
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
                                )
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        child: ExpandableTheme(
                          data: ExpandableThemeData(
                            iconColor: kBorderGrey,
                            iconPlacement: ExpandablePanelIconPlacement.left,
                            useInkWell: true,
                            iconPadding: EdgeInsets.only(top: 12, left: 8, right: 8)
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  child: ExpandableNotifier(
                                    child: Padding(
                                    padding: const EdgeInsets.all(10),
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
                                                padding: EdgeInsets.only(top:10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Cessation of bad habits',
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(height: 30,),
        
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
                                )
                              ),
                            ],
                          ),
                        ),
                      ),


                      Container(
                        child: ExpandableTheme(
                          data: ExpandableThemeData(
                            iconColor: kBorderGrey,
                            iconPlacement: ExpandablePanelIconPlacement.left,
                            useInkWell: true,
                            iconPadding: EdgeInsets.only(top: 12, left: 8, right: 8)
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  child: ExpandableNotifier(
                                    child: Padding(
                                    padding: const EdgeInsets.all(10),
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
                                                padding: EdgeInsets.only(top:10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Tracking Vitals',
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(height: 30,),
        
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
                                )
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20,),

                      // Container(
                      //   padding: EdgeInsets.symmetric(vertical: 25),
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     color: kBackgroundGrey,
                      //     borderRadius: BorderRadius.circular(3)                     
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: <Widget>[
                      //       Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 25,),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             Text('Goal', style: TextStyle(color: kTextGrey),),
                      //             SizedBox(height: 10,),
                      //             Text('Decrease cholesterol levels', style: TextStyle(fontSize: 19),),
                      //           ],
                      //         )
                      //       ),
                      //       SizedBox(height: 30,),
                      //       Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 25,),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             Text('Intervention', style: TextStyle(color: kTextGrey),),
                      //             SizedBox(height: 10,),
                      //             Text('Counselling about reduced salt intake', style: TextStyle(fontSize: 19),),
                      //           ],
                      //         )
                      //       ),

                      //       SizedBox(height: 30,),
                      //       Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 25,),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: <Widget>[
                      //             Text('When', style: TextStyle(color: kTextGrey),),
                      //             SizedBox(height: 10,),
                      //             Text('Within 1 month of recommendation of goal', style: TextStyle(fontSize: 19),),
                      //           ],
                      //         )
                      //       ),
                      //       SizedBox(height: 20,),
                      //       Divider(),
                      //       SizedBox(height: 15,),
                      //       GestureDetector(
                      //         onTap: () {
                      //           Navigator.of(context).push(CarePlanInterventionScreen());
                      //         },
                      //         child: Container(
                      //           padding: EdgeInsets.symmetric(horizontal: 25,),
                      //           child: Row(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //             children: <Widget>[
                      //               Text('Pending', style: TextStyle(color: kPrimaryRedColor, fontSize: 19),),
                      //               Icon(Icons.arrow_forward, color: kPrimaryColor,)
                      //             ],
                      //           )
                      //         ),
                      //       ),
                      //     ],
                      //   )
                      // ),
                    
                    ]
                  )
                ),

                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     border: Border(
                //       bottom: BorderSide(color: kBorderLight)
                //     )
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       Text('Medications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                //       SizedBox(height: 20,),
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.of(context).push(CarePlanMedicationScreen());
                //         },
                //         child: Container(
                //           padding: EdgeInsets.symmetric(horizontal: 25,),
                //           height: 70,
                //           decoration: BoxDecoration(
                //             color: kBackgroundGrey
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: <Widget>[
                //               Text('Napa 12 mg', style: TextStyle(fontSize: 19),),
                //               Icon(Icons.arrow_forward, color: kPrimaryColor,)
                //             ],
                //           )
                //         ),
                //       ),
                //       SizedBox(height: 20,),
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.of(context).push(CarePlanMedicationScreen());
                //         },
                //         child: Container(
                //           padding: EdgeInsets.symmetric(horizontal: 25,),
                //           height: 70,
                //           decoration: BoxDecoration(
                //             color: kBackgroundGrey
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: <Widget>[
                //               Text('Metfornim 50 mg', style: TextStyle(fontSize: 19),),
                //               Icon(Icons.arrow_forward, color: kPrimaryColor,)
                //             ],
                //           )
                //         ),
                //       ),
                //     ]
                //   )
                // ),

                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     border: Border(
                //       bottom: BorderSide(color: kBorderLight)
                //     )
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       Text('Followup', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21)),
                //       SizedBox(height: 20,),
                //       Text('After 3 months', style: TextStyle(fontSize: 19),)
                //     ]
                //   )
                // ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: double.infinity,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child: FlatButton(
                      onPressed: () {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text(AppLocalizations.of(context).translate("generatePatientCard"), style: TextStyle(fontSize: 15, color: Colors.white),)
                    ),
                  ),
                )
                
              ],
            ) : Container(),
            isLoading ? Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Color(0x90FFFFFF),
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}

class Interventions extends StatefulWidget {
  var carePlan;
  Interventions({this.carePlan});

  @override
  InterventionsState createState() => InterventionsState();
}

class InterventionsState extends State<Interventions> {
  var status;

  @override
  void initState() {
    super.initState();
    // getStatus();
  }

  _getDuration(item) {
    return '';
    if (item['body']['activityDuration'] != null && item['body']['activityDuration']['start'] != '' && item['body']['activityDuration']['end'] != '') {
      var start = DateTime.parse(item['body']['activityDuration']['start']);
      var time = DateTime.parse(item['body']['activityDuration']['end']).difference(DateTime.parse(item['body']['activityDuration']['start'])).inDays;

      int result = (time / 30).round();
      if (result >= 1) {
        return 'Within ${result.toString()} months of recommendation of goal';
      }
    }
    return '';
  }

  getStatus() {
    // return 'asd';
    String completedDate = '';
    // print(widget.carePlan['meta']['completed_at']);
    // return ;
    if (widget.carePlan['meta']['status'] == 'completed') {
      // if (widget.carePlan['meta']['completed_at'] != null && widget.carePlan['meta']['completed_at']['_seconds'] != null) {
      //   var parsedDate = DateTime.fromMillisecondsSinceEpoch(widget.carePlan['meta']['completed_at']['_seconds'] * 1000);

      //   completedDate = DateFormat("MMMM d, y").format(parsedDate).toString();
      // }

      if (widget.carePlan['meta']['completed_at'] != null) {
        // var parsedDate = DateTime.parse(widget.carePlan['meta']['completed_at']);

        completedDate = widget.carePlan['meta']['completed_at'].toString();
      }

      setState(() {
        status = widget.carePlan['meta']['status'] + ' on ' + completedDate;
      });
      
    } else {
      setState(() {
        status = widget.carePlan['meta']['status'];
      });
    }
  }

  setStatus() {
    setState(() {
      widget.carePlan['meta']['status'] = 'completed';
      status = 'completed';
    });
  }

  getStatusText(meta) {
    var text = '';
    if (meta['status'] != null) {
      text = meta['status'][0].toUpperCase() + meta['status'].substring(1);
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25),
      margin: EdgeInsets.only(bottom: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kBackgroundGrey,
        borderRadius: BorderRadius.circular(3)                     
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // widget.carePlan['body']['goal'] != null ?
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(AppLocalizations.of(context).translate("goals"), style: TextStyle(color: kTextGrey),),
                SizedBox(height: 10,),
                Text(widget.carePlan['title'], style: TextStyle(fontSize: 19),),
              ],
            )
          ) 
          // : Container()
          ,
          SizedBox(height: 30,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25,),
            child: Text(AppLocalizations.of(context).translate("interventions"), style: TextStyle(color: kTextGrey),),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...widget.carePlan['items'].map( (item) {
                  print(item);
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 20,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text(item['body']['title'], style: TextStyle(fontSize: 19),),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(getStatusText(item['meta']), 
                              style: TextStyle(
                                fontSize: 18,
                                color: getStatusText(item['meta']) == 'Completed' ? kPrimaryGreenColor : kPrimaryRedColor
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                }).toList()
                
              ],
            )
          ),

          SizedBox(height: 30,),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 25,),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Text('When', style: TextStyle(color: kTextGrey),),
          //       SizedBox(height: 10,),
          //       // Text(_getDuration(widget.carePlan), style: TextStyle(fontSize: 19),),
          //       Text('', style: TextStyle(fontSize: 19),),
          //     ],
          //   )
          // ),
          // SizedBox(height: 20,),
          // GestureDetector(
          //   onTap: () {
          //     if (widget.carePlan['meta']['status'] != 'completed') {
          //       // Navigator.of(context).push(CarePlanInterventionScreen(carePlan: widget.carePlan, parent: this));
          //       Navigator.of(context).pushNamed('/carePlanInterventions', arguments: {'carePlan' : widget.carePlan, 'parent': this });
          //     }
          //   },
          //   child: Container(
          //     height: 60,
          //     decoration: BoxDecoration(
          //       // color: Colors.red,
          //       border: Border(
          //         top: BorderSide(color: kBorderLighter)
          //       )
          //     ),
          //     padding: EdgeInsets.symmetric(horizontal: 25,),
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: <Widget>[
          //         Text('${status != null ? status[0].toUpperCase() + status.substring(1) : 'Pending'}', style: TextStyle(color: status != 'pending' ? kPrimaryGreenColor : kPrimaryRedColor, fontSize: 19, height: .5),),
          //         Icon(Icons.arrow_forward, color: kPrimaryColor,)
          //       ],
          //     )
          //   ),
          // ),
        ],
      )
    );
  }
}

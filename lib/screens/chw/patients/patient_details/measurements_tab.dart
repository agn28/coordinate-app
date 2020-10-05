import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';



class MeasurementsTab extends StatefulWidget {
  MeasurementsTab({this.reports, this.previousReports});

  var reports;
  var previousReports = [];

  @override
  _MeasurementsState createState() => _MeasurementsState();
}

class _MeasurementsState extends State<MeasurementsTab> {
  bool isLoading = false;
  bool confirmLoading = false;
  bool reviewLoading = false;

  bool canEdit = false;
  final commentsController = TextEditingController();
  var medications = [];
  var conditions = [];
  bool avatarExists = false;

  @override
  initState() {
    super.initState();

    // getReports();
  }

  getDate(date) {
    if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);

      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  getGlucoseData(data) {
    var value = '';
    data.forEach((item) {
      if (item['name'] == 'blood_sugar') {
      print(item);
        value = item['value'].toString() + ' ' + item['units'];
      }
    });
    return value;
  }
  getA1cData(data) {
    var value = '';
    data.forEach((item) {
      if (item['name'] == 'a1c') {
      print(item);
        value = item['value'].toString() + ' ' + item['units'];
      }
    });
    return value;
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 5, color: kBorderLighter)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                widget.reports['result']['assessments']['body_composition']['components']['bmi'] != null ?
                Container(
                  // alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    color: kBackgroundGrey,
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate("bmi"), style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                          canEdit ? GestureDetector(
                            child: Icon(Icons.edit, color: kPrimaryColor,),
                            onTap: () {}
                          ) : Container(),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['value']} ${widget.reports['result']['assessments']['body_composition']['components']['bmi']['eval']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorUtils.statusColor[widget.reports['result']['assessments']['body_composition']['components']['bmi']['tfl']] ?? Colors.black,

                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  // Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['unit']}',
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: kTextGrey
                                  //   ),
                                  // )
                                ],
                              ),
                            )
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryBlueColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['body_composition']['components']['bmi']['tfl'] == 'BLUE' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryBlueColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kGreenColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['body_composition']['components']['bmi']['tfl'] == 'GREEN' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kGreenColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryAmberColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['body_composition']['components']['bmi']['tfl'] == 'AMBER' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryAmberColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        color: kRedColor,
                                        height: 11,
                                        width: 40,
                                        margin: EdgeInsets.only(right: 10),
                                      ),
                                      widget.reports['result']['assessments']['body_composition']['components']['bmi']['tfl'] == 'RED' ||  widget.reports['result']['assessments']['body_composition']['components']['bmi']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryDeepRedColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['body_composition']['components']['bmi']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryDeepRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),  
                                  SizedBox(width: 20,),

                                  Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['target']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kTextGrey
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child:  Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['target']}',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: kTextGrey
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                    ],
                  ),
                ) :
                Container(),

                SizedBox(height: 15,),

                widget.previousReports.length > 0 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('history'), style: TextStyle(color: kTextGrey, fontSize: 16)),
                    SizedBox(height: 10,),

                    Row(
                      children: <Widget>[
                        ...widget.previousReports.map((item) {
                          if (widget.previousReports.indexOf(item) < 6) {
                            return Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 10, bottom: 15, left: widget.previousReports.indexOf(item) == 0 ? 0 : 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: kBorderLighter, width: widget.previousReports.length > 0 ? 1 : 0)
                                      )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(getDate(item['report_date']),style: TextStyle(color: kTextGrey, fontSize: 12),),
                                        SizedBox(height: 4,),
                                        Row(
                                          children: <Widget>[
                                            Text("${item['result']['assessments']['body_composition']['components']['bmi']['value']}",style: TextStyle(color: kPrimaryRedColor, fontSize: 15,),),
                                          ],
                                        ),
                                        SizedBox(height: 4,),
                                        // Text('mg/dL',style: TextStyle(color: kTextGrey, fontSize: 12),),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList()
                      ],
                    )

                  ],
                ) : Container()


              ],
            )
          ),


          Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 5, color: kBorderLighter)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                widget.reports['result']['assessments']['blood_pressure'] != null ?
                Container(
                  // alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    color: kBackgroundGrey,
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate("bloodPressure"), style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                          canEdit ? GestureDetector(
                            child: Icon(Icons.edit, color: kPrimaryColor,),
                            onTap: () {}
                          ) : Container(),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${widget.reports['result']['assessments']['blood_pressure']['value']} ${widget.reports['result']['assessments']['blood_pressure']['eval']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorUtils.statusColor[widget.reports['result']['assessments']['blood_pressure']['tfl']] ?? Colors.black,

                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  // Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['unit']}',
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: kTextGrey
                                  //   ),
                                  // )
                                ],
                              ),
                            )
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryBlueColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['blood_pressure']['tfl'] == 'BLUE' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryBlueColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kGreenColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['blood_pressure']['tfl'] == 'GREEN' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kGreenColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryAmberColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['blood_pressure']['tfl'] == 'AMBER' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryAmberColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        color: kRedColor,
                                        height: 11,
                                        width: 40,
                                        margin: EdgeInsets.only(right: 10),
                                      ),
                                      widget.reports['result']['assessments']['blood_pressure']['tfl'] == 'RED' ||  widget.reports['result']['assessments']['blood_pressure']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryDeepRedColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['blood_pressure']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryDeepRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),  
                                  SizedBox(width: 20,),

                                  Text('${widget.reports['result']['assessments']['blood_pressure']['target']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kTextGrey
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child:  Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['target']}',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: kTextGrey
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                    ],
                  ),
                ) :
                Container(),

                SizedBox(height: 15,),


                widget.previousReports.length > 0 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('history'), style: TextStyle(color: kTextGrey, fontSize: 16)),
                    SizedBox(height: 10,),

                    Row(
                      children: <Widget>[
                        ...widget.previousReports.map((item) {
                          if (widget.previousReports.indexOf(item) < 6) {
                            return Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 10, bottom: 15, left: widget.previousReports.indexOf(item) == 0 ? 0 : 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: kBorderLighter, width: widget.previousReports.length > 0 ? 1 : 0)
                                      )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(getDate(item['report_date']),style: TextStyle(color: kTextGrey, fontSize: 12),),
                                        SizedBox(height: 4,),
                                        Row(
                                          children: <Widget>[
                                            Text("${item['result']['assessments']['blood_pressure']['value']}",style: TextStyle(color: ColorUtils.statusColor[widget.reports['result']['assessments']['blood_pressure']['tfl']] ?? Colors.black, fontSize: 15,),),
                                          ],
                                        ),
                                        SizedBox(height: 4,),
                                        // Text('mg/dL',style: TextStyle(color: kTextGrey, fontSize: 12),),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList()
                      ],
                    )

                  ],
                ) : Container()
              ],
            )
          ),

      

          Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 5, color: kBorderLighter)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                widget.reports['result']['assessments']['diabetes'] != null ?
                Container(
                  // alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    color: kBackgroundGrey,
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate('diabetes'), style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                          canEdit ? GestureDetector(
                            child: Icon(Icons.edit, color: kPrimaryColor,),
                            onTap: () {}
                          ) : Container(),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${widget.reports['result']['assessments']['diabetes']['value']} ${widget.reports['result']['assessments']['diabetes']['eval']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorUtils.statusColor[widget.reports['result']['assessments']['diabetes']['tfl']] ?? Colors.black,

                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  widget.reports['input'] != null && widget.reports['input']['params']['components']['biological-samples'] != null ?
                                  Row(
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context).translate("bloodGlucose")+ ":" + getGlucoseData(widget.reports['input']['params']['components']['biological-samples']),
                                        style: TextStyle(
                                          fontSize: 15,

                                        ),
                                      ),
                                    ],
                                  ) : Container(),
                                  SizedBox(height: 10,),
                                  widget.reports['input'] != null && widget.reports['input']['params']['components']['biological-samples'] != null ?
                                  Row(
                                    children: <Widget>[
                                      Text('HbA1c: ' + getA1cData(widget.reports['input']['params']['components']['biological-samples']),
                                        style: TextStyle(
                                          fontSize: 15,

                                        ),
                                      ),
                                    ],
                                  ) : Container(),
                                  SizedBox(height: 5,),
                                  // Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['unit']}',
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: kTextGrey
                                  //   ),
                                  // )
                                ],
                              ),
                            )
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryBlueColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['diabetes']['tfl'] == 'BLUE' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryBlueColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kGreenColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['diabetes']['tfl'] == 'GREEN' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kGreenColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryAmberColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['diabetes']['tfl'] == 'AMBER' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryAmberColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        color: kRedColor,
                                        height: 11,
                                        width: 40,
                                        margin: EdgeInsets.only(right: 10),
                                      ),
                                      widget.reports['result']['assessments']['diabetes']['tfl'] == 'RED' ||  widget.reports['result']['assessments']['diabetes']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryDeepRedColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['diabetes']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryDeepRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),  
                                  SizedBox(width: 20,),

                                  Flexible(
                                    child: Text('${widget.reports['result']['assessments']['diabetes']['target']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kTextGrey
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child:  Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['target']}',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: kTextGrey
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                    ],
                  ),
                ) :
                Container(),

                SizedBox(height: 15,),


                widget.previousReports.length > 0 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('history'), style: TextStyle(color: kTextGrey, fontSize: 16)),
                    SizedBox(height: 10,),

                    Row(
                      children: <Widget>[
                        ...widget.previousReports.map((item) {
                          if (widget.previousReports.indexOf(item) < 6) {
                            return Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 10, bottom: 15, left: widget.previousReports.indexOf(item) == 0 ? 0 : 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: kBorderLighter, width: widget.previousReports.length > 0 ? 1 : 0)
                                      )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(getDate(item['report_date']),style: TextStyle(color: kTextGrey, fontSize: 12),),
                                        SizedBox(height: 7,),
                                        Row(
                                          children: <Widget>[
                                            Text("${item['result']['assessments']['diabetes']['value']}",style: TextStyle(color: ColorUtils.statusColor[item['result']['assessments']['diabetes']['tfl']], fontSize: 15,),),
                                          ],
                                        ),
                                        SizedBox(height: 4,),
                                        Row(
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate("glucose")+":",style: TextStyle(color: kTextGrey, fontSize: 12),),
                                            Text(getGlucoseData(item['input']['params']['components']['biological-samples']),style: TextStyle(color: kTextGrey, fontSize: 12, fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate("hba1c")+":",style: TextStyle(color: kTextGrey, fontSize: 12),),
                                            Text(getA1cData(item['input']['params']['components']['biological-samples']),style: TextStyle(color: kTextGrey, fontSize: 12, fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                        SizedBox(height: 4,),
                                        // Text('mg/dL',style: TextStyle(color: kTextGrey, fontSize: 12),),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList()
                      ],
                    )

                  ],
                ) : Container()
              ],
            )
          ),


          Container(
            padding: EdgeInsets.only(left: 15, right: 0, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 5, color: kBorderLighter)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
                Container(
                  // alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    color: kBackgroundGrey,
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate("totalCholesterol")+":", style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                          canEdit ? GestureDetector(
                            child: Icon(Icons.edit, color: kPrimaryColor,),
                            onTap: () {}
                          ) : Container(),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['value']} ${widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['eval']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorUtils.statusColor[widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']] ?? Colors.black,

                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  // Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['unit']}',
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: kTextGrey
                                  //   ),
                                  // )
                                ],
                              ),
                            )
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryBlueColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'BLUE' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryBlueColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kGreenColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'GREEN' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kGreenColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryAmberColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'AMBER' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryAmberColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        color: kRedColor,
                                        height: 11,
                                        width: 40,
                                        margin: EdgeInsets.only(right: 10),
                                      ),
                                      widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryDeepRedColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryDeepRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),  
                                  SizedBox(width: 10,),

                                  Flexible(
                                    child: Text('${widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['target']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kTextGrey
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child:  Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['target']}',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: kTextGrey
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                    ],
                  ),
                ) :
                Container(),

                SizedBox(height: 15,),
                widget.previousReports.length > 0 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('history'), style: TextStyle(color: kTextGrey, fontSize: 16)),
                    SizedBox(height: 10,),

                    Row(
                      children: <Widget>[
                        ...widget.previousReports.map((item) {
                          if (widget.previousReports.indexOf(item) < 6) {
                            return Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 10, bottom: 15, left: widget.previousReports.indexOf(item) == 0 ? 0 : 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: kBorderLighter, width: widget.previousReports.length > 0 ? 1 : 0)
                                      )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(getDate(item['report_date']),style: TextStyle(color: kTextGrey, fontSize: 12),),
                                        SizedBox(height: 4,),
                                        Row(
                                          children: <Widget>[
                                            Text("${item['result']['assessments']['cholesterol']['components']['total_cholesterol']['value']}",
                                              style: TextStyle(color: ColorUtils.statusColor[item['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl']], fontSize: 15,),),
                                          ],
                                        ),
                                        SizedBox(height: 4,),
                                        // Text('mg/dL',style: TextStyle(color: kTextGrey, fontSize: 12),),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList()
                      ],
                    )

                  ],
                ) : Container()
              ],
            )
          ),

          
          Container(
            padding: EdgeInsets.only(left: 15, right: 0, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 5, color: kBorderLighter)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol'] != null ?
                Container(
                  // alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    color: kBackgroundGrey,
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate("cvd"), style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),),
                          canEdit ? GestureDetector(
                            child: Icon(Icons.edit, color: kPrimaryColor,),
                            onTap: () {}
                          ) : Container(),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${widget.reports['result']['assessments']['cvd']['value']} ${widget.reports['result']['assessments']['cvd']['eval']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorUtils.statusColor[widget.reports['result']['assessments']['cvd']['tfl']] ?? Colors.black,

                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  // Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['unit']}',
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: kTextGrey
                                  //   ),
                                  // )
                                ],
                              ),
                            )
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryBlueColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cvd']['tfl'] == 'BLUE' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryBlueColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kGreenColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cvd']['tfl'] == 'GREEN' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kGreenColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryAmberColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cvd']['tfl'] == 'AMBER' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryAmberColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        color: kRedColor,
                                        height: 11,
                                        width: 40,
                                        margin: EdgeInsets.only(right: 10),
                                      ),
                                      widget.reports['result']['assessments']['cvd']['tfl'] == 'RED' ||  widget.reports['result']['assessments']['cholesterol']['components']['total_cholesterol']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        color: kPrimaryDeepRedColor,
                                        height: 11,
                                        width: 40,
                                      ),
                                      widget.reports['result']['assessments']['cvd']['tfl'] == 'DEEP-RED' ?
                                      Container(
                                        child: Icon(Icons.arrow_drop_up, size: 30, color: kPrimaryDeepRedColor,),
                                      ) :
                                      Container(),
                                    ],
                                  ),  
                                  SizedBox(width: 10,),

                                  Flexible(
                                    child: Text('${widget.reports['result']['assessments']['cvd']['target']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kTextGrey
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child:  Text('${widget.reports['result']['assessments']['body_composition']['components']['bmi']['target']}',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: kTextGrey
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                    ],
                  ),
                ) :
                Container(),

                SizedBox(height: 15,),
                widget.previousReports.length > 0 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('history'), style: TextStyle(color: kTextGrey, fontSize: 16)),
                    SizedBox(height: 10,),

                    Row(
                      children: <Widget>[
                        ...widget.previousReports.map((item) {
                          if (widget.previousReports.indexOf(item) < 6) {
                            return Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 10, bottom: 15, left: widget.previousReports.indexOf(item) == 0 ? 0 : 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: kBorderLighter, width: widget.previousReports.length > 0 ? 1 : 0)
                                      )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(getDate(item['report_date']),style: TextStyle(color: kTextGrey, fontSize: 12),),
                                        SizedBox(height: 4,),
                                        Row(
                                          children: <Widget>[
                                            Text("${item['result']['assessments']['cvd']['value']}",style: TextStyle(color: ColorUtils.statusColor[item['result']['assessments']['cvd']['tfl']], fontSize: 15,),),
                                          ],
                                        ),
                                        SizedBox(height: 4,),
                                        // Text('mg/dL',style: TextStyle(color: kTextGrey, fontSize: 12),),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList()
                      ],
                    )

                  ],
                ) : Container()
              ],
            )
          ),

          
          SizedBox(height: 130,)

        ],
      ),
    );
  }
}

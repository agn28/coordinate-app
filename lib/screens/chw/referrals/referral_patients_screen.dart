import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
// import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';

import '../../../app_localizations.dart';


final birthDateController = TextEditingController();
final birthmonthController = TextEditingController();
final birthYearController = TextEditingController();
List patients = [];
List allPatients = [];

final searchController = TextEditingController();
bool isPendingRecommendation = false;

// class PatientSearchScreen extends CupertinoPageRoute {
//   PatientSearchScreen()
//       : super(builder: (BuildContext context) => new PatientSearch());

// }

class ChwReferralPatientsScreen extends StatefulWidget {
  @override
  _ChwReferralPatientsScreenState createState() => _ChwReferralPatientsScreenState();
}

class _ChwReferralPatientsScreenState extends State<ChwReferralPatientsScreen> {
  bool isLoading = true;
  var test = '';
  var authUser;
  TabController _tabController;
  int selectedTab = 0;

  var sortListEn = ['patient', 'date', 'location', 'reason'];
  var sortListBn = ['রোগী', 'তারিখ', 'অবস্থান', 'কারণ'];
  var selectedSort;

  @override
  initState() {
    super.initState();
    // getPatients();
    _getAuthUser();
    getLivePatients();
  }

  _getAuthUserName() {
    var name = '';
    name = authUser != null && authUser['name'] != null ? authUser['name'] + ' (${authUser["role"].toUpperCase()})'  : '';
    return name;
  }

  _getAuthUser() async {
    var data = await Auth().getStorageAuth() ;
    if (!data['status']) {
      Helpers().logout(context);
    }

    setState(() {
      authUser = data;
    });
  }

  matchBarcodeData(data) async {
    var patient;
    await allPatients.forEach((item) {
      if (data == '${item['data']['first_name']} ${item['data']['last_name']}') {
        patient = item;
        Patient().setPatient(item);
        Navigator.of(context).pushNamed('/patientOverview');
      }
    });

    if (patient == null) {
      Toast.show('Patient not mached!', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }

  }

  getPatients() async {
    
    var data = await PatientController().getAllPatients();

    setState(() {
      allPatients = data;
      patients = allPatients;
    });
  }
 

  getLivePatients() async {

    setState(() {
      isLoading = true;
    });

    var data = await PatientController().getReferralPatients();

    print(data['data'][0]['body']['pending_referral']);

    if (data['message'] == 'Unauthorized') {
      Helpers().logout(context);
    }

    var parsedNewPatients = [];
    var parsedExistingPatients = [];

    for(var item in data['data']) {
      parsedNewPatients.add({
        'uuid': item['id'],
        'data': item['body'],
        'meta': item['meta']
      });
    }

    setState(() {
      allPatients = parsedNewPatients;
      patients = allPatients;

      isLoading = false;
    });
  }

  search(query) {
    var modifiedPatients = [...allPatients].map((item)  {
      item['data']['name'] = '${item['data']['first_name']} ${item['data']['last_name']}' ;
      return item;
    }).toList();

    setState(() {
      patients = modifiedPatients
        .where((item) => item['data']['name']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    });
  }

  convertDateFromSeconds(date) {
    if (date['_seconds'] != null) {
      var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);
      return DateFormat("MMMM d, y").format(parsedDate).toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('referralPatients')),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (_) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                  
                  child: Container(
                    child: Text(AppLocalizations.of(context).translate("logout")),
                  ),
                    value: 'logout'),
              ],
            onSelected: (value) {
              if (value == 'logout') {
                Helpers().logout(context);
              }
            },
            child: Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Text(_getAuthUserName(),),
                  SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image.asset(
                      'assets/images/avatar.png',
                      height: 20.0,
                      width: 20.0,
                    ),
                  ),
                  SizedBox(width: 20,)
                ],
              ),
            ),
          ),
          
        ],
      ),
      body: Stack(
        children: <Widget>[
          !isLoading ? SingleChildScrollView(
            child: Column(
              children: <Widget>[
                

                Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                  // color: kPrimaryColor,
                    border: Border.all(width: 0, color: kPrimaryColor)
                  ),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20,),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context).translate('sortBy') + ': ', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
                              SizedBox(width: 20,),
                              Container(
                                width: 200,
                                child:AppLocalizations.of(context).translate('sortBy')=="সাজান"? DropdownButtonFormField(
                                  // hint: Text('', style: TextStyle(fontSize: 20, color: kTextGrey),),
                                  
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: kSecondaryTextField,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    )
                                  ),
                                  ),
                                  items: [
                                    ...sortListBn.map((item) =>
                                      DropdownMenuItem(
                                        child: Text(StringUtils.capitalize(item)),
                                        value: sortListBn.indexOf(item)
                                      )
                                    ).toList(),
                                  ],
                                  value: selectedSort,
                                  isExpanded: true,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSort = value;
                                    });
                                  },
                                ):DropdownButtonFormField(
                                  // hint: Text('', style: TextStyle(fontSize: 20, color: kTextGrey),),

                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: kSecondaryTextField,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        )
                                    ),
                                  ),
                                  items: [
                                    ...sortListEn.map((item) =>
                                        DropdownMenuItem(
                                            child: Text(StringUtils.capitalize(item)),
                                            value: sortListEn.indexOf(item)
                                        )
                                    ).toList(),
                                  ],
                                  value: selectedSort,
                                  isExpanded: true,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSort = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border(
                                bottom: BorderSide(color: kBorderLighter)
                              )
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(AppLocalizations.of(context).translate('patients'),
                                    style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
                                  )
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(AppLocalizations.of(context).translate('date'),
                                        style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
                                      )
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(AppLocalizations.of(context).translate('location'),
                                    style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
                                  )
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(AppLocalizations.of(context).translate('location'),
                                    style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
                                  )
                                ),
                              ],
                            ),
                          ),
                          
                        ...patients.map((item) => GestureDetector(
                          onTap: () {
                              Patient().setPatient(item);
                              Navigator.of(context).pushNamed('/referralList');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: kBorderLighter)
                              )
                            ),
                            child: Row(
                              children: <Widget>[

                                Expanded(
                                  flex: 3,
                                  child: Text(item['data']['first_name'] + ' ' + item['data']['last_name'] + ' ' + item['data']['age'].toString() + 'Y ' + '${item['data']['gender'][0].toUpperCase()}',
                                    style: TextStyle(color: Colors.black87, fontSize: 18),
                                  )
                                ),
                                Expanded(
                                  flex: 2,
                                  child: item['data']['pending_referral'] != null ?
                                    Text(convertDateFromSeconds(item['data']['pending_referral']['meta']['created_at']),
                                      style: TextStyle(color: Colors.black87, fontSize: 16),
                                    ) : Container()
                                ),
                                Expanded(
                                  flex: 2,
                                  child: item['data']['pending_referral'] != null ?
                                    Text(item['data']['pending_referral']['body']['location'] != null && item['data']['pending_referral']['body']['location']['clinic_name'] != null ? item['data']['pending_referral']['body']['location']['clinic_name'] : '',
                                      style: TextStyle(color: Colors.black87, fontSize: 16),
                                    ) : Container()
                                ),
                                Expanded(
                                  flex: 2,
                                  child: item['data']['pending_referral'] != null ?
                                    Text(item['data']['pending_referral']['body']['reason'] ?? '',
                                      style: TextStyle(color: Colors.black87, fontSize: 16),
                                    ) : Container()
                                ),
                                ],
                            ),
                          ),
                        )).toList(),
                      ],
                    )
                  ),
                ),
                
                
                
                patients.length == 0 ? Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(AppLocalizations.of(context).translate('noPatientFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
                ) : Container()
              ],
            ),
          ) : Container(
            height: double.infinity,
            width: double.infinity,
            color: Color(0x20FFFFFF),
            child: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),backgroundColor: Color(0x30FFFFFF),)
            ),
          ),
        ],
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.bottomRight,
              child: Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // FloatingActionButton(
                //   heroTag: 'btn1',
                //   onPressed: () {},
                //   backgroundColor: kPrimaryColor,
                //   child: Icon(Icons.fingerprint,),
                // ),
                // SizedBox(height: 15,),
                // FloatingActionButton(
                //   heroTag: 'btn2',
                //   onPressed: () async {
                //     print('hello');
                    
                //     try {
                //       // print(await BarcodeScanner.scan());
                //       var result = await BarcodeScanner.scan();
                //       matchBarcodeData(result);
                //     } catch (e) {
                //       print('hi');
                //       print(e);
                //     }
                //   },
                //   backgroundColor: kPrimaryColor,
                //   child: Icon(Icons.line_weight),
                // )
              ],
            ),
            )
          )
    );
  }
}

// Column(
//   children: <Widget>[
//     CustomSearchWidget(
//       listContainerHeight: 500,
//       dataList: [...patients],
//       hideSearchBoxWhenItemSelected: false,
//       queryBuilder: (query, list) {
//         return [...patients]
//           .where((item) => item['data']['name']
//           .toLowerCase()
//           .contains(query.toLowerCase()))
//           .toList();
//       },
//       popupListItemBuilder: (item) {
//         print(item);
//         return PopupListItemWidget(item);
//       },
//       selectedItemBuilder: (selectedItem, deleteSelectedItem) {
//         return SelectedItemWidget(selectedItem, deleteSelectedItem);
//       },
//       // widget customization
//       // noItemsFoundWidget: NoItemsFound(),
//       textFieldBuilder: (controller, focusNode) {
//         return MyTextField(controller, focusNode);
//       },
//       onItemSelected: (item) {
//         setState(() {
//           _selectedItem = item;
//         });
//       },
//     ),
//     Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         patients.length == 0 ? Container(
//           alignment: Alignment.centerLeft,
//           padding: EdgeInsets.only(top: 15),
//           child: Text('No patient found', style: TextStyle(color: Colors.white, fontSize: 20),),
//         ) :
//         Container(
//           alignment: Alignment.centerLeft,
//           padding: EdgeInsets.only(top: 15),
//           child: Text('Pending Recommendations Only', style: TextStyle(color: Colors.white),),
//         ),
        
//         Container(
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.only(top: 15),
//             child: GestureDetector(
//               onTap: () async {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return FiltersDialog(parent: this,);
//                 },
//               );
//               },
//               child: Row(
//                 children: <Widget>[
//                   Icon(Icons.filter_list, color: Colors.white,),
//                   SizedBox(width: 10),
//                   Text('Filters', style: TextStyle(color: Colors.white),)
//                 ],
//               )
//             ),
//           ),
//       ],
//     )
//   ],
// )


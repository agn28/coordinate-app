import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';
import '../../../app_localizations.dart';


final birthDateController = TextEditingController();
final birthmonthController = TextEditingController();
final birthYearController = TextEditingController();
List patients = [];
List allPatients = [];

final searchController = TextEditingController();
bool isPendingRecommendation = false;

class ChwReferralListScreen extends StatefulWidget {
  @override
  _ChwReferralListScreenState createState() => _ChwReferralListScreenState();
}

class _ChwReferralListScreenState extends State<ChwReferralListScreen> {
  bool isLoading = true;
  var test = '';
  var authUser;
  int selectedTab = 0;

  var referrals = [];

  var sortList = ['patient', 'date', 'location', 'reason'];
  var selectedSort;

  @override
  initState() {
    super.initState();
    // getPatients();
    _getAuthUser();
    getReferralsByPatient();
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

  getReferralsByPatient() async {

    setState(() {
      isLoading = true;
    });

    var patientID = Patient().getPatient()['id'];

    var data = await FollowupController().getFollowupsByPatient(patientID);
    

    // if (data['message'] == 'Unauthorized') {
    //   Helpers().logout(context);
    // }
    // print(data['data'][0]);

    setState(() {
      referrals = data['data'];
      isLoading = false;
    });

    var pendingReferral;

    referrals.forEach((element) {
      if (element['meta']['status'] != null && element['meta']['status'] == 'pending') {
        setState(() {
          pendingReferral = element;
        });
      }
    });
    referrals.removeAt(referrals.indexOf(pendingReferral));

    setState(() {
      referrals.insert(0, pendingReferral);
    });
  }

  getLivePatients() async {

    setState(() {
      isLoading = true;
    });

    var data = await PatientController().getReferralPatients();

    if (data['message'] == 'Unauthorized') {
      Helpers().logout(context);
    }

    var parsedNewPatients = [];
    var parsedExistingPatients = [];

    for(var item in data['data']) {
      parsedNewPatients.add({
        'id': item['id'],
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

  convertDateFromSeconds(date) {
    if (isNotNull(date)) {
      if (date is String) {
        return date;
      } else if (date['_seconds'] != null) {
        var parsedDate = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);
        return DateFormat("MMMM d, y").format(parsedDate).toString();
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: false,
      //Migrate Projects
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('referralList')),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (_) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                  
                  child: Container(
                    child: Text(AppLocalizations.of(context).translate("Logout")),
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
                
                PatientTopbar(),
                
                SizedBox(height: 20,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      //pending referral
                      ...referrals.map((referral) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]),
                            borderRadius: BorderRadius.circular(3)
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(AppLocalizations.of(context).translate('dateOfReferral') + ': ', style: TextStyle(fontSize: 16),),
                                  Text(convertDateFromSeconds(referral['meta']['created_at']), style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 5,),

                              Row(
                                children: <Widget>[
                                  Text(AppLocalizations.of(context).translate('reason') + ': ', style: TextStyle(fontSize: 16)),
                                  Text(referral['body']['reason'] ?? '', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 5,),

                              Row(
                                children: <Widget>[
                                  Text(AppLocalizations.of(context).translate('status') + ': ', style: TextStyle(fontSize: 16)),
                                  Text(referral['meta']['status'] != null ? StringUtils.capitalize(referral['meta']['status']) : '', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 5,),

                              Row(
                                children: <Widget>[
                                  Text(AppLocalizations.of(context).translate('referralLocation') + ': ', style: TextStyle(fontSize: 16)),
                                  Text(referral['body']['location'] != null && referral['body']['location']['clinic_name'] != null ? referral['body']['location']['clinic_name'] : '', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 5,),

                              Row(
                                children: <Widget>[
                                  Text(AppLocalizations.of(context).translate('referredBy') + ': ', style: TextStyle(fontSize: 16)),
                                  Text('', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 5,),

                              Row(
                                children: <Widget>[
                                  Text(AppLocalizations.of(context).translate('referredOutcome') + ': ', style: TextStyle(fontSize: 16)),
                                  Text(referral['body']['outcome'] ?? '', style: TextStyle(fontSize: 16)),
                                ],
                              ),

                              referral['meta']['status'] != null && referral['meta']['status'] == 'pending' ? 
                              Center(
                                child: Container(
                                  width: 200,
                                  margin: EdgeInsets.only(top: 20),
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(3)
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
                                      // Navigator.of(context).pushNamed('/chwNavigation',);
                                      Navigator.of(context).pushNamed('/updateReferral', arguments: referral);
                                    },
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    child: Text(AppLocalizations.of(context).translate('referralUpdate').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                                  ),
                                ),
                              ) : Container(),
                            ],
                          ),
                        );
                      }).toList()
                    
                    ],
                  ),
                ),

                referrals.length == 0 ? Container(
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


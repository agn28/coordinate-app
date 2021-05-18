import 'package:basic_utils/basic_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
// import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/configs/configs.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/assessment_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/widgets/primary_textfield_widget.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';


import '../../../app_localizations.dart';


final birthDateController = TextEditingController();
final birthmonthController = TextEditingController();
final birthYearController = TextEditingController();
final ageFromController = TextEditingController();
final ageToController = TextEditingController();
final upazilaController = TextEditingController();
final unionController = TextEditingController();
final villageController = TextEditingController();
List newPatients = [];
List allNewPatients = [];

List existingPatients = [];
List allExistingPatients = [];
final searchController = TextEditingController();
bool isPendingRecommendation = false;

// class PatientSearchScreen extends CupertinoPageRoute {
//   PatientSearchScreen()
//       : super(builder: (BuildContext context) => new PatientSearch());

// }

class ChwPatientSearchScreen extends StatefulWidget {
  @override
  _PatientSearchState createState() => _PatientSearchState();
}
int selectedTab = 0;
class _PatientSearchState extends State<ChwPatientSearchScreen> {
  bool isLoading = true;
  var test = '';
  var authUser;
  TabController _tabController;
  

  @override
  initState() {
    super.initState();
    setState(() {
      searchController.text = '';
    });
    // getPatients();
    selectedTab = 0;
    _getAuthUser();
    clearFilters();
    getLivePatients();
  }

  clearFilters() {
    print('clear');
    setState(() {
      ageFromController.clear();
      ageToController.clear();
      selectedUpazila = {};
      unionController.clear();
      villageController.clear();
      birthDateController.clear();
      birthMonthController.clear();
      birthYearController.clear();
      lastVisitDateController.clear();
      selectedDiseases = [];
    });
  }
  _getAuthUserName() {
    var name = '';
    name = authUser != null && authUser['name'] != null ? authUser['name'] + ' (${authUser["role"].toUpperCase()})'  : '';
    return name;
  }

  _getAuthUser() async {
    var data = await Auth().getStorageAuth();
    if (!data['status']) {
      Helpers().logout(context);
    }

    setState(() {
      authUser = data;
    });
  }

  matchBarcodeData(data) async {
    var patient;
    await allNewPatients.forEach((item) {
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

  // getPatients() async {
    
  //   var data = await PatientController().getAllPatients();

  //   setState(() {
  //     allNewPatients = data;
  //     newPatients = allNewPatients;
  //   });
  // }
 

  getLivePatients() async {

    setState(() {
      isLoading = true;
    });

    var data = await PatientController().getFirstAssessmentPatients();
    var existingData = await PatientController().getExistingPatients();
    print('hello');
    // print(existingData['data'].length);
    

    if (data != null && data['message'] == 'Unauthorized') {
      Helpers().logout(context);
    }

    var parsedNewPatients = [];
    var parsedExistingPatients = [];

    if (data != null && data['data'] != null) {
      for(var item in data['data']) {
        print(item['body']['last_name']);
        parsedNewPatients.add({
          'uuid': item['id'],
          'data': item['body'],
          'meta': item['meta']
        });
      }
    }

    if (existingData != null && existingData['data'] != null) {
      for(var item in existingData['data']) {
        parsedExistingPatients.add({
          'uuid': item['id'],
          'data': item['body'],
          'meta': item['meta']
        });
      }
    }



    setState(() {
      allNewPatients = parsedNewPatients;
      newPatients = allNewPatients;

      allExistingPatients = parsedExistingPatients;
      existingPatients = allExistingPatients;
      isLoading = false;
    });
  }

  search(query) {

    var searchKey = Helpers().isNumeric(query) ? 'mobile' : 'name';

    if (selectedTab == 0) {
      var modifiedPatients = [...allNewPatients].map((item)  {
        item['data']['name'] = '${item['data']['first_name']} ${item['data']['last_name']}' ;
        return item;
      }).toList();


      setState(() {
        newPatients = modifiedPatients
          .where((item) => item['data']['nid']
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          item['data']['name']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
      });

      
    } else if (selectedTab == 1) {
      var modifiedPatients = [...allExistingPatients].map((item)  {
        item['data']['name'] = '${item['data']['first_name']} ${item['data']['last_name']}' ;
        return item;
      }).toList();

      setState(() {
        existingPatients = modifiedPatients
          .where((item) => item['data']['nid']
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          item['data']['name']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
      });
    }
    
  }

  LeaderBoard _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //Migrate Projects
      //resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('patients')),
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
          Configs().configAvailable('isBarcode') ? FlatButton(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Icon(Icons.line_weight, color: Colors.white, size: 20,),
                SizedBox(height: 5,),
                Text(AppLocalizations.of(context).translate('scanBarcode'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),)
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(RegisterPatientScreen());
            },
          ): Container(),

          Configs().configAvailable('isThumbprint') ? FlatButton(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Icon(Icons.fingerprint, color: Colors.white, size: 20,),
                SizedBox(height: 5,),
                Text(AppLocalizations.of(context).translate('useThumbprint'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),)
              ],
            ),
            onPressed: () {},
          ) : Container()
        ],
      ),
      body: Stack(
        children: <Widget>[
          !isLoading ? SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  // padding: EdgeInsets.symmetric(vertical: 20),
                  color: kPrimaryColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) {
                            search(query);
                          },
                          // focusNode: focusNode,
                          autofocus: true,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x4437474F),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5)
                              )
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FiltersDialog(parent: this,);
                                },
                              );
                              },
                              icon: Icon(Icons.filter_list, color: kPrimaryColor, size: 25,)
                            ),
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(context).translate('searchHere'),
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              right: 20,
                              top: 14,
                              bottom: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      
                    ],
                  )
                ),

                Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(bottom: 220),
                  decoration: BoxDecoration(
                  // color: kPrimaryColor,
                    border: Border.all(width: 0, color: kPrimaryColor)
                  ),
                  child: DefaultTabController(
                    initialIndex: 0,

                    length: 2,
                    child: Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        backgroundColor: kPrimaryColor,
                        bottom: PreferredSize(child: Container(color: kPrimaryColor, height: 1.0,), preferredSize: Size.fromHeight(1.0)),
                        flexibleSpace: TabBar(
                          onTap: (value) {
                            setState(() {
                              searchController.text = '';
                              selectedTab = value;
                            });
                          },
                          labelPadding: EdgeInsets.all(0),
                          indicatorPadding: EdgeInsets.all(0),
                          indicatorColor: Colors.white,
                          tabs: [
                            Tab(
                              child: Text(AppLocalizations.of(context).translate('newlyRegistered'), style: TextStyle(fontSize: 17)),
                            ),
                            Tab(
                              child: Text(AppLocalizations.of(context).translate('existing'), style: TextStyle(fontSize: 17)),
                            ),
                            
                          ],
                        ),
                      ),
                      body: TabBarView(
                        controller: _tabController,
                                        
                        children: [
                          Container(
                            child: ListView(
                              children: <Widget>[
                                SizedBox(height: 20,),
                                ...newPatients.map((item) => GestureDetector(
                                  onTap: () {
                                      Patient().setPatient(item);
                                      print('hello');
                                      print(item);
                                      Navigator.of(context).pushNamed('/patientOverview');
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
                                          child: Row(
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(30.0),
                                                child: Image.asset(
                                                  'assets/images/avatar.png',
                                                  height: 25.0,
                                                  width: 25.0,
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Text(item['data']['first_name'] + ' ' + item['data']['last_name'],
                                                style: TextStyle(color: Colors.black87, fontSize: 18),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(item['data']['age'].toString() + 'Y ' + '${item['data']['gender'][0].toUpperCase()}' + ' - ' + item['data']['nid'].toString(), 
                                          style: TextStyle(
                                              color: Colors.black38,
                                              fontWeight: FontWeight.w400
                                            ), 
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              ],
                            )
                          ),
                          
                          
                          Container(
                            child: ListView(
                              children: <Widget>[
                                SizedBox(height: 20,),
                                ...existingPatients.map((item) => GestureDetector(
                                  // onTap: () {
                                  //     Patient().setPatient(item);
                                  //     Navigator.of(context).pushNamed('/patientOverview');
                                  // },
                                  onTap: () {
                                    // Patient().setPatientModify(item);
                                    Patient().setPatient(item);
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChwPatientRecordsScreen()));
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
                                          child: Row(
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(30.0),
                                                child: Image.asset(
                                                  'assets/images/avatar.png',
                                                  height: 25.0,
                                                  width: 25.0,
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Text(item['data']['first_name'] + ' ' + item['data']['last_name'],
                                                style: TextStyle(color: Colors.black87, fontSize: 18),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(item['data']['age'].toString() + 'Y ' + '${item['data']['gender'][0].toUpperCase()}' + ' - ' + item['data']['nid'].toString(), 
                                          style: TextStyle(
                                              color: Colors.black38,
                                              fontWeight: FontWeight.w400
                                            ), 
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              ],
                            )
                          ),

                          
                        ],
                      ),
                    ),
                  ),
                ),
                
                
                
                newPatients.length == 0 ? Container(
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
                FloatingActionButton(
                  heroTag: 'btn1',
                  onPressed: () {},
                  backgroundColor: kPrimaryColor,
                  child: Icon(Icons.fingerprint,),
                ),
                SizedBox(height: 15,),
                FloatingActionButton(
                  heroTag: 'btn2',
                  onPressed: () async {
                    print('hello');
                    
                    try {
                      // print(await BarcodeScanner.scan());
                      var result = await BarcodeScanner.scan();
                      matchBarcodeData(result);
                    } catch (e) {
                      print('hi');
                      print(e);
                    }
                  },
                  backgroundColor: kPrimaryColor,
                  child: Icon(Icons.line_weight),
                )
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


class DiseasesDialog extends StatefulWidget {
  _FiltersDialogState parent;

  DiseasesDialog({this.parent});

  @override
  _DiseasesDialogState createState() => _DiseasesDialogState();
}

var selectedDiseases = [];
final lastVisitDateController = TextEditingController();
class _DiseasesDialogState extends State<DiseasesDialog> {

  List _allDiseases = ['lupus', 'diabetes', 'bronchitis', 'hypertension', 'cancer', 'Ciliac', 'Scleroderma', 'Abulia', 'Agraphia', 'Chorea', 'Coma' ];
  List _diseases = [];
  var _checkValue = {};

  var _selectedItem = selectedDiseases;

  @override
  void initState() {
    super.initState();
    setState(() {
      _diseases = _allDiseases;
    });
    _preapareCheckboxValue();
    
  }
  _preapareCheckboxValue() {
    _diseases.forEach((item) => {
      selectedDiseases.indexOf(item) == -1 ? _checkValue[item] = false : _checkValue[item] = true
    });

  }

  _updateCheckBox(value, index) {
    if (value == true && _selectedItem.length == 3) {
      return Toast.show(AppLocalizations.of(context).translate('notMoreThanThree'), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundRadius: 5);
    }

    setState(() {
      value ? _selectedItem.add(_diseases[index]) : _selectedItem.removeAt(_selectedItem.indexOf(_diseases[index]));
      _checkValue[_diseases[index]] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 630.0,
        color: Colors.white,
        child: Form(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('selectDiseases'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                  ],
                ),
              ),

              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('selectThreeDiseases'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    
                    TextField(
                      
                      style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
                      onChanged: (value) => {
                        setState(() {
                          _diseases = _allDiseases
                            .where((item) => item
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                            .toList();
                        })
                      },
                      decoration: InputDecoration(
                        counterText: ' ',
                        contentPadding: EdgeInsets.only(top: 18, bottom: 18, left: 10, right: 10),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: kSecondaryTextField,
                        border: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          )
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                      )
                    )
                  ],
                )
              ),

              Container(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _diseases.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 10,),
                          Checkbox(
                            activeColor: kPrimaryColor,
                            value: _checkValue[_diseases[index]],
                            onChanged: (value) {
                              _updateCheckBox(value, index);
                            },
                          ),
                          Text(StringUtils.capitalize(_diseases[index]), style: TextStyle(fontSize: 17),)
                        ],
                      )
                    );
                  },
                )
              ),
              
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              _selectedItem = [];
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16),)
                        ),
                        SizedBox(width: 30,),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            selectedDiseases = _selectedItem;
                            this.widget.parent.setState(() {
                              this.widget.parent.getSelectedDiseaseText();
                            });
                          },
                          child: Text(AppLocalizations.of(context).translate('apply'), style: TextStyle(color: kPrimaryColor, fontSize: 16))
                        ),
                      ],
                    )
                  )
                ],
              )
            ],
          )
        ),
      )
      
    );
  }
}

List filteredUpazilas = [];
var selectedUpazila = {};
var selectedDistrict = {};

class FiltersDialog extends StatefulWidget {
  
  _PatientSearchState parent;
  FiltersDialog({this.parent});

  @override
  _FiltersDialogState createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {

  final format = DateFormat("yyyy-MM-dd");
  String _selectedDiseaseText = '';
  var selectedDobType = 'age';  

  @override
  void initState() {
    super.initState();

    getLocations();
    getSelectedDiseaseText();
  }

  getLocations() async {
    setState(() {
      isLoading = true;
    });
    var locationData = await PatientController().getLocations();
    var districtsData = [];
    if (locationData['error'] != null && !locationData['error']) {
      districtsData = locationData['data'][0]['districts'];
    }
    setState(() {
      isLoading = false;
      districts = districtsData;
    });
    populateUpazilas();
  }

  populateUpazilas() async {
    var data = await Auth().getStorageAuth();

    print('set address');
    // print(districts);
    print(data['address']);
    setState(() {
      filteredUpazilas = [];
      selectedDistrict = {};
      // selectedUpazila = {};
      if (data['address'].isNotEmpty) {
        // unionController.text = data['address']['union'] ?? '';
        // villageController.text = data['address']['village'] ?? '';
        var authUserDistrict = districts.where(
            (district) => district['name'] == data['address']['district']);
        if (authUserDistrict.isNotEmpty) {
          selectedDistrict = authUserDistrict.first;
          var authUserUpazila = selectedDistrict['thanas'].where(
              (upazila) => upazila['name'] == data['address']['upazila']);
          if (authUserUpazila.isNotEmpty) {
            // selectedUpazila = authUserUpazila.first;
            // selectedUpazila = {};
            filteredUpazilas = selectedDistrict['thanas'];
            print('filteredUpazilas $filteredUpazilas');
          } else {
            selectedUpazila = {};
          }
        } else {
          selectedDistrict = {};
          selectedUpazila = {};
        }
      }
    });
  }

  getSelectedDiseaseText() {
    if (selectedDiseases.length > 0) {
      setState(() {
        _selectedDiseaseText = selectedDiseases.join(', ');
      });
    } else {
      setState(() {
        _selectedDiseaseText = 'Select Diagnosed Disease(s)';
      });
    }
  }

  applyFilter() async {
    await this.widget.parent.getLivePatients();
    
    allNewPatients.forEach((patient) { 
      print('allNewPatients $patient');
    });
    allExistingPatients.forEach((patient) { 
      print('allExistingPatients $patient');
    });
    if (ageFromController.text != '' || ageToController.text != '') {
      print(ageFromController.text);
      print(ageToController.text);
      var filteredPatients = [];
      var startingAge = ageFromController.text != '' ? int.parse(ageFromController.text) : 0 ;
      var endingAge = ageToController.text != '' ? int.parse(ageToController.text) : 150 ;
      filteredPatients =  allNewPatients.where((item) => item['data']['age'] >= startingAge && item['data']['age'] <= endingAge).toList();
      this.widget.parent.setState(() => {
        allNewPatients = filteredPatients,
        newPatients = allNewPatients,
        allExistingPatients = filteredPatients,
        existingPatients = allExistingPatients
      }); 
    }

    if (selectedUpazila.isNotEmpty) {
      print(selectedUpazila);
      var filteredPatients = [];
      filteredPatients =  allNewPatients.where((item) => item['data']['address']['upazila'] == selectedUpazila['name']).toList();
      print('filteredPatients $filteredPatients');
      this.widget.parent.setState(() => {
        allNewPatients = filteredPatients,
        newPatients = allNewPatients,
        allExistingPatients = filteredPatients,
        existingPatients = allExistingPatients
      });
    }

    if (unionController.text != '') {
      print(unionController.text);
      var filteredPatients = [];
      filteredPatients =  allNewPatients.where((item) => item['data']['address']['union'] == unionController.text).toList();
      print('filteredPatients $filteredPatients');
      this.widget.parent.setState(() => {
        allNewPatients = filteredPatients,
        newPatients = allNewPatients,
        allExistingPatients = filteredPatients,
        existingPatients = allExistingPatients
      });
    }

    if (villageController.text != '') {
      print(villageController.text);
      var filteredPatients = [];
      filteredPatients =  allNewPatients.where((item) => item['data']['address']['union'] == villageController.text).toList();
      print('filteredPatients $filteredPatients');
      this.widget.parent.setState(() => {
        allNewPatients = filteredPatients,
        newPatients = allNewPatients,
        allExistingPatients = filteredPatients,
        existingPatients = allExistingPatients
      });
    }
    var birthDate = '';
    if (birthDateController.text != '' && birthMonthController.text != '' && birthYearController.text != '') {
      birthDate = birthYearController.text + '-' + birthMonthController.text + '-' + birthDateController.text;
    }

    if (birthDate != '') {
      var filteredPatients = [];
      filteredPatients = allNewPatients.where((item) => item['data']['birth_date'] == birthDate).toList();
      print('filteredPatients $filteredPatients');
      this.widget.parent.setState(() => {
        allNewPatients = filteredPatients,
        newPatients = allNewPatients,
        allExistingPatients = filteredPatients,
        existingPatients = allExistingPatients
      });
    }

    if (lastVisitDateController.text != '') {
      var assessments = await AssessmentController().getAllAssessments();

      var filteredAssessments = assessments.where((item) => item['data']['assessment_date'] == lastVisitDateController.text).toList();
      var filteredPatients = [];
      
      if (selectedTab == 0) {
        allNewPatients.forEach((patient) { 
          filteredAssessments.forEach((assessment) {
            if (assessment['data']['patient_id'] == patient['uuid']) {
              filteredPatients.add(patient);
            } 
          });
        });

        this.widget.parent.setState(() => {
          allNewPatients = filteredPatients,
          newPatients = allNewPatients
        });
      } else if (selectedTab == 1) {
        allExistingPatients.forEach((patient) { 
          filteredAssessments.forEach((assessment) {
            if (assessment['data']['patient_id'] == patient['uuid']) {
              filteredPatients.add(patient);
            } 
          });
        });

        this.widget.parent.setState(() => {
          allExistingPatients = filteredPatients,
          existingPatients = allExistingPatients
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 530.0,
        color: Colors.white,
        child: Form(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30,),
              GestureDetector(
                onTap: () async {
                  this.widget.parent.clearFilters();
                  await this.widget.parent.getLivePatients();
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).translate('filters'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                      Text(AppLocalizations.of(context).translate('clearFilter'), style: TextStyle(fontSize: 15, color: kPrimaryColor, fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'age',
                          groupValue: selectedDobType,
                          onChanged: (value) {
                            setState(() {
                              selectedDobType = value;
                            });
                          },
                        ),
                        Text(
                          AppLocalizations.of(context).translate('ageRange'),
                        ),
                        Radio(
                          activeColor: kPrimaryColor,
                          value: 'dob',
                          groupValue: selectedDobType,
                          onChanged: (value) {
                            setState(() {
                              selectedDobType = value;
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context).translate('dateOfBirth'),style: TextStyle(color: Colors.black)),
                        SizedBox(width: 10,),
                        Text('(DD/MM/YYYY)',style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),), 
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              selectedDobType == 'dob' ? 
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate("dateOfBirth"), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText: AppLocalizations.of(context).translate("dd"),
                            controller: birthDateController,
                            name: "Date",
                            validation: true,
                            type: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText: AppLocalizations.of(context).translate("mm"),
                            controller: birthMonthController,
                            name: "Month",
                            validation: true,
                            type: TextInputType.number
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: PrimaryTextField(
                            topPaadding: 10,
                            bottomPadding: 10,
                            hintText:AppLocalizations.of(context).translate("yy"),
                            controller: birthYearController,
                            name: "Year",
                            validation: true,
                            type: TextInputType.number
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              )
              : Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate("ageRange"), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: PrimaryTextField(
                              topPaadding: 10,
                              bottomPadding: 10,
                              hintText: AppLocalizations.of(context).translate('year'),
                              controller: ageFromController,
                              name: 'Age From',
                              type: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            height: 65,
                            child: Center(child: Text(AppLocalizations.of(context).translate("from"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),))),
                          SizedBox(width: 20,),
                          Expanded(
                            child: PrimaryTextField(
                              topPaadding: 10,
                              bottomPadding: 10,
                              hintText: AppLocalizations.of(context).translate('year'),
                              controller: ageToController,
                              name: 'Age To',
                              type: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            height: 65,
                            child: Center(child: Text(AppLocalizations.of(context).translate("to"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: DropdownSearch(
                  validator: (v) => v == null ? "required field" : null,
                  hint: AppLocalizations.of(context).translate('upazila'),
                  mode: Mode.BOTTOM_SHEET,
                  items: filteredUpazilas,
                  // showClearButton: true,
                  dropdownSearchDecoration: InputDecoration(
                    counterText: ' ',
                    contentPadding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 10, right: 10),
                    filled: true,
                    fillColor: kSecondaryTextField,
                    border: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        )),
                    hintText: 'Upazilas',
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedUpazila = value;

                      // districtController.text = value;
                    });
                  },
                  selectedItem: selectedUpazila['name'],
                  popupItemBuilder: _customPopupItemBuilderExample2,
                  showSearchBox: true,
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('union'),
                  controller: unionController,
                  name: AppLocalizations.of(context).translate('union'),
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: PrimaryTextField(
                  topPaadding: 10,
                  bottomPadding: 10,
                  hintText: AppLocalizations.of(context).translate('village'),
                  controller: villageController,
                  name: AppLocalizations.of(context).translate('village'),
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('diagnosedDiseases'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                    SizedBox(height: 20,),
                    Container(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: kSecondaryTextField,
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_selectedDiseaseText, style: TextStyle(fontSize: 16, color: Colors.black54),),
                              Icon(Icons.arrow_drop_down)
                            ],
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return DiseasesDialog(parent: this,);
                              },
                            );
                          },
                        )
                      )
                    ),
                  ],
                )
              ),
              SizedBox(height: 20,),
              
              Divider(),

              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: DateTimeField(
                  format: format,
                  controller: lastVisitDateController,
                  decoration: InputDecoration(
                    hintText: 'Last Visit Date',
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
                    contentPadding: EdgeInsets.only(top: 18, bottom: 18),
                    prefixIcon: Icon(Icons.date_range),
                    filled: true,
                    fillColor: kSecondaryTextField,
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      )
                    ),
                  ),
                  
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
              ),
            
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(color: kPrimaryColor, fontSize: 16),)
                        ),
                        SizedBox(width: 30,),
                        FlatButton(
                          onPressed: () {
                            applyFilter();
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context).translate('apply'), style: TextStyle(color: kPrimaryColor, fontSize: 16))
                        ),
                      ],
                    )
                  )
                ],
              )
            ],
          )
        ),
      )
      
    );
  }


}
Widget _customPopupItemBuilderExample2(
    BuildContext context, item, bool isSelected) {
  return SingleChildScrollView(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item['name']),
      ),
    ),
  );
}

class LeaderBoard {
  LeaderBoard(this.username, this.score);

  final String username;
  final double score;
}

class SelectedItemWidget extends StatelessWidget {
  const SelectedItemWidget(this.selectedItem, this.deleteSelectedItem);

  final selectedItem;
  final VoidCallback deleteSelectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField(this.controller, this.focusNode);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x4437474F),
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5)
            )
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () { 
              controller.text = '';
             },
            icon: Icon(Icons.cancel, color: kTextGrey, size: 25,)
          ),
          border: InputBorder.none,
          hintText: "AppLocalizations.of(context).translate('searchHere')",
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            bottom: 14,
          ),
        ),
      ),
    );
  }
}


class PopupListItemWidget extends StatelessWidget {
  const PopupListItemWidget(this.item);

  final item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Patient().setPatient(item);
        Navigator.of(context).pushNamed('/patientOverview');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(item['data']['name'],
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
            Expanded(
              child: Text(item['data']['age'].toString() + 'Y ' + '${item['data']['gender'][0].toUpperCase()}' + ' - ' + item['data']['nid'].toString(), 
              style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400
                ), 
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:basic_utils/basic_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'dart:math';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/nurse/new_patient_questionnairs/new_questionnaire_feeling_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';
import 'package:nhealth/screens/patients/ncd/search/followup_search_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/screens/settings/settings_screen.dart';
import 'package:nhealth/screens/work-list/work_list_search_screen.dart';
// import './patients/register_patient_screen.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:get/get.dart';


class ChcpHomeScreen extends StatefulWidget {
  static const path = '/chcpHome';
  @override
  _ChcpHomeState createState() => _ChcpHomeState();
}

class _ChcpHomeState extends State<ChcpHomeScreen> {
  final syncController = Get.put(SyncController());
  String userName = '';
  String role = '';
  
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  @override
  initState() {
    _getAuthData();
    super.initState();
    // Connectivity().onConnectivityChanged.listen(syncController.checkConnection);
    
    initConnectivity();
    _connectivitySubscription =_connectivity.onConnectivityChanged.listen(_updateConnectionStatus);  
    // getSyncData();
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });

    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {

      syncController.isConnected.value = true;
      // await syncController.initializeSync();
    } else {
      syncController.isConnected.value = false;
      syncController.isSyncing.value = false;

    }
  }
  _getAuthData() async {
    var data = await Auth().getStorageAuth();
    if (!data['status']) {
      Helpers().logout(context);
    }
    // Navigator.of(context).pushNamed('/login',);
    setState(() {
      userName = data['name'];
      role = data['role'];
    });
  }

  getSyncData() async {
    await syncController.getAllStatsData();
    var connectivityResult = await (Connectivity().checkConnectivity());
    await _updateConnectionStatus(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      syncController.isConnected.value = true;
      await syncController.initializeSync();
    } else {
      syncController.isConnected.value = false;
    }
  }
  liveToLocalSync() async {
    // await syncController.getAllStatsData();
    var connectivityResult = await (Connectivity().checkConnectivity());
    // await _updateConnectionStatus(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      print('connected');
      syncController.isConnected.value = true;
      await syncController.initializeLiveToLocalSync();
    } else {
      print('not connected');
      syncController.isConnected.value = false;
    }
  }

  syncLocalToLive() async {
    // await syncController.getAllStatsData();
    var connectivityResult = await (Connectivity().checkConnectivity());
    // await _updateConnectionStatus(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      print('connected');
      syncController.isConnected.value = true;
      await syncController.syncLocalToLive();
    } else {
      print('not connected');
      syncController.isConnected.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).translate('home'),
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            Obx(() => !syncController.isConnected.value
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: kPrimaryRedColor),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sentiment_very_dissatisfied,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'You are offline',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  )
                : Container())
          ],
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 60,),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.perm_identity, size: 40, color: Colors.black54,),
                  ),
                  SizedBox(height: 30,),
                  Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                  Text(role != null ? StringUtils.capitalize(role) : '', style: TextStyle(fontSize: 17, height: 1.8),),
                  GestureDetector(
                    onTap: () {},
                    child: Text(AppLocalizations.of(context).translate('gotoProfile'), style: TextStyle(fontSize: 17, height: 2.5, color: kPrimaryColor),),
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.black26)
                )
              ),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.only(left: 10, right: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    color: kLightPrimaryColor,
                    height: 50,
                    child: FlatButton(
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.home, color: kPrimaryColor,),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('home'),style: TextStyle( fontSize: 18,fontWeight: FontWeight.w500, color: kPrimaryColor))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/patientSearch');
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.supervisor_account, color: Colors.black54,),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('patients'),style: TextStyle( fontSize: 18,fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).push(WorkListSearchScreen());
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.list, color: Colors.black54,),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('workList'),style: TextStyle( fontSize: 18,fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.black26)
                )
              ),
            ),

            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.only(left: 10, right: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () => Navigator.of(context).push(SettingsScreen()),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.settings, color: Colors.black54),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('settings'),style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () async {
                        Helpers().logout(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.exit_to_app, color: Colors.black54),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('logout'), style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 18),
                    child: Row(
                      children: <Widget>[
                        Text( AppLocalizations.of(context).translate("version") + '0.0.8.2 (beta)', style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400)),
                      ],
                    )
                  )
                ],
              )
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: 360,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_home.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 70, top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Text(AppLocalizations.of(context).translate('welcome'), style: TextStyle(color: Colors.white70, fontSize: 18),),
                        SizedBox(height: 15,),
                        Text(userName, style: TextStyle(color: Colors.white, fontSize: 24),),
                        SizedBox(height: 15,),
                        Text(role != null ? StringUtils.capitalize(role) : '', style: TextStyle(color: Colors.white70, fontSize: 16),),
                        SizedBox(height: 40,),
                        
                        Text(AppLocalizations.of(context).translate('homeIntro'), style: TextStyle(color: Colors.white, fontSize: 34),)
                      ],
                    ),
                  ),
                  Obx(
                    () => Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 40, right: 40),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[

                          SizedBox(height: 60,),

                          Row(
                            children: [
                              Expanded(
                                child: InkWell(

                                  onTap: () async {
                                    Navigator.of(context).pushNamed('/chcpNavigation',);
                                  },
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    child: Card(
                                      elevation: 2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset('assets/images/icons/inventory.png', width: 50,),
                                          SizedBox(height: 15,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(AppLocalizations.of(context).translate('workList'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),

                                            ],
                                          ),
                                        ],
                                      )
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: InkWell(
                                  // onTap: () => Navigator.of(context).pushNamed('/chwNavigation', arguments: 1),
                                  onTap: () => Navigator.of(context).pushNamed('/patientListChcp'),
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Card(
                                      elevation: 2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.group, color: kPrimaryColor, size: 60),
                                          SizedBox(height: 10,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[

                                              Text(AppLocalizations.of(context).translate('patientList'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),


                          SizedBox(height: 20,),

                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).push(RegisterPatientScreen()),
                                  child: Container(
                                    height: 140,
                                    width: double.infinity,
                                    child: Card(
                                      elevation: 2,
                                      child: Column(
                                        children: <Widget>[
                                          Icon(Icons.person_add_alt_1, color: kPrimaryColor, size: 70,),
                                          SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(AppLocalizations.of(context).translate('newRegistration'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pushNamed('/chwReferralPatients'),
                                  child: Container(
                                    height: 140,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Card(
                                      elevation: 2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset('assets/images/icons/questionnaire.png'),
                                          SizedBox(height: 10,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(AppLocalizations.of(context).translate('referralList'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 50,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: kPrimaryGreenColor,
                                  shape: BoxShape.circle
                                ),
                                alignment: Alignment.center,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_upward_outlined,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    await syncLocalToLive();
                                }),
                              ),

                              SizedBox(width: 30,),

                              Container(
                                decoration: BoxDecoration(
                                  color: kPrimaryYellowColor,
                                  shape: BoxShape.circle
                                ),
                                alignment: Alignment.center,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_downward_outlined,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async{
                                    await liveToLocalSync();
                                }),
                              ),

                            ]
                          ),
                          syncController.showSyncInfoflag.value
                          ? Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (syncController.isSyncing.value)
                                  Column(
                                    children: [
                                  //     Container(
                                  //       width: 230,
                                  //       padding: EdgeInsets.symmetric(
                                  //           vertical: 15, horizontal: 10),
                                  //       decoration: BoxDecoration(
                                  //           borderRadius:
                                  //               BorderRadius.circular(5),
                                  //           color: kPrimaryAmberColor),
                                  //       child: Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.center,
                                  //         children: [
                                  //           if (syncController.isSyncingToLive.value)
                                  //           Column(
                                  //             children: [
                                  //               Text('${syncController.localNotSyncedPatients.value.length+syncController.localNotSyncedAssessments.value.length+syncController.localNotSyncedObservations.value.length+syncController.localNotSyncedReferrals.value.length+syncController.localNotSyncedCareplans.value.length+syncController.localNotSyncedHealthReports.value.length} data is syncing to server',
                                  //                 style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                                  //               ),
                                  //             ],
                                  //           )
                                  //           else if (syncController.syncs.value.length > 0 && syncController.isSyncingToLocal.value)
                                  //           Column(
                                  //             children: [
                                  //               Text(
                                  //                 '${syncController.syncs.value.length} data is syncing to deivce',
                                  //                 style: TextStyle(
                                  //                     fontSize: 16,
                                  //                     fontWeight:
                                  //                         FontWeight.w500),
                                  //               ),
                                  //             ],
                                  //           )
                                  //           else
                                  //           Column(
                                  //             children: [
                                  //               Text(
                                  //                 'Processing data',
                                  //                 style: TextStyle(
                                  //                     fontSize: 16,
                                  //                     fontWeight:
                                  //                         FontWeight.w500),
                                  //               ),
                                  //             ],
                                  //           )
                                  //         ],
                                  //       ),
                                  //     ),
                                  //     SizedBox(
                                  //       height: 20,
                                  //     ),

                                    ],
                                  ),
                                  // else if (syncController.localNotSyncedPatients.value.length > 0
                                  // || syncController.localNotSyncedAssessments.value.length > 0
                                  // || syncController.localNotSyncedObservations.value.length > 0
                                  // || syncController.localNotSyncedReferrals.value.length > 0
                                  // || syncController.localNotSyncedCareplans.value.length > 0
                                  // || syncController.localNotSyncedHealthReports.value.length > 0)
                                  //   Container(
                                  //     width: 300,
                                  //     padding: EdgeInsets.symmetric(
                                  //         vertical: 15, horizontal: 10),
                                  //     decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(5),
                                  //         color: kPrimaryAmberColor),
                                  //     child: Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         Text(
                                  //           'You have ${syncController.localNotSyncedPatients.value.length + syncController.localNotSyncedAssessments.value.length + syncController.localNotSyncedObservations.value.length + syncController.localNotSyncedReferrals.value.length + syncController.localNotSyncedCareplans.value.length} device data left to sync',
                                  //           style: TextStyle(
                                  //               fontSize: 16,
                                  //               fontWeight: FontWeight.w500),
                                  //         )
                                  //       ],
                                  //     ),
                                  //   )
                                  // else
                                  if (syncController.syncs.value > 0)
                                    Container(
                                      width: 300,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: kPrimaryAmberColor),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(width: 10),
                                          Text(
                                            '${syncController.syncs.value} server data left',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 240,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.greenAccent),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'All data has been synced',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // if (!syncController.isSyncing.value)
                                  //   IconButton(
                                  //       icon: Icon(
                                  //         Icons.sync,
                                  //         size: 30,
                                  //       ),
                                  //       onPressed: () {
                                  //         syncController.initializeSync();
                                  //         // syncController.syncLocalDataToLiveByPatient();
                                  //       })
                                ],
                              ),
                            ]
                          )
                          : Container(),

                          //       //for development
                          //       // Column(
                          //       //   children: [
                          //       //     Text('Updates in server: ${syncController.syncs.value.length}', style: TextStyle(fontSize: 20),),
                          //       //     Text('Updates in Local: ${syncController.localNotSyncedPatients.value.length + syncController.localNotSyncedAssessments.value.length + syncController.localNotSyncedObservations.value.length + syncController.localNotSyncedReferrals.value.length + syncController.localNotSyncedCareplans.value.length}', style: TextStyle(fontSize: 20),),
                          //       //     SizedBox(height: 20,),

                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Assessments Not synced in Local: ${syncController.localNotSyncedAssessments.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),
                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Observations Not synced in Local: ${syncController.localNotSyncedObservations.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),
                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Referrals Not synced in Local: ${syncController.localNotSyncedReferrals.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),
                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Careplans Not synced in Local: ${syncController.localNotSyncedCareplans.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),
                          //       //     SizedBox(height: 20,),

                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Patients in server: ${syncController.livePatientsAll.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //         // FlatButton(
                          //       //         //   color: kPrimaryColor,
                          //       //         //   onPressed: () async {
                          //       //         //     await syncController.syncLivePatientsToLocal();
                          //       //         //     // Get.offAll(ChwHomeScreen());
                          //       //         //   },
                          //       //         //   child: Text('Sync', style: TextStyle(color: Colors.white),)
                          //       //         // )
                          //       //       ],
                          //       //     ),

                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Patients in Local: ${syncController.localPatientsAll.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),

                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Assessments in Local: ${syncController.localAssessmentsAll.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),

                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Observations in Local: ${syncController.localObservationsAll.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),

                          //       //     Row(
                          //       //       mainAxisAlignment: MainAxisAlignment.center,
                          //       //       children: [
                          //       //         Text('Careplans in Local: ${syncController.localCareplansAll.value.length}', style: TextStyle(fontSize: 20),),
                          //       //         SizedBox(width: 20),
                          //       //       ],
                          //       //     ),

                          //       //     SizedBox(height: 30),
                          //       //     FlatButton(
                          //       //       color: kPrimaryRedColor,
                          //       //       onPressed: () {
                          //       //         syncController.emptyLocalDatabase();
                          //       //       },
                          //       //       child: Text('Empty Synced Databases', style: TextStyle(color: Colors.white),)
                          //       //     ),

                          //       //     SizedBox(height: 20),

                          //       //   ],
                          //       // ),
                          //     ],
                          //   ),

                          // InkWell(

                          //   onTap: () async {
                          //     // await Auth().isExpired();
                          //     // return;
                          //     Navigator.of(context).pushNamed('/patientSearch');
                          //     // Navigator.of(context).push(PatientSearchScreen());
                          //   },
                          //   child: Container(
                          //     height: 140,
                          //     width: double.infinity,
                          //     child: Card(
                          //       elevation: 2,
                          //       child: Column(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: <Widget>[
                          //           Image.asset('assets/images/icons/manage_patient.png'),
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.center,
                          //             children: <Widget>[
                          //               Text(AppLocalizations.of(context).translate('manageExistingPatient'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 24),),
                          //               Container(
                          //                 alignment: Alignment.center,
                          //                 child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                          //               )
                          //             ],
                          //           ),
                          //         ],
                          //       )
                          //     ),
                          //   ),
                          // ),

                          // SizedBox(height: 20,),

                          // InkWell(
                          //   onTap: () => Navigator.of(context).push(RegisterPatientScreen()),
                          //   child: Container(
                          //     height: 140,
                          //     width: double.infinity,
                          //     alignment: Alignment.center,
                          //     child: Card(
                          //       elevation: 2,
                          //       child: Column(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: <Widget>[
                          //           Image.asset('assets/images/icons/register_patient.png'),
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.center,
                          //             children: <Widget>[
                          //               Text(AppLocalizations.of(context).translate('registerNewPatient'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 24),),
                          //               Container(
                          //                 alignment: Alignment.centerLeft,
                          //                 child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                          //               )
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // SizedBox(height: 20,),

                          // InkWell(
                          //   onTap: () => Navigator.of(context).pushNamed('/chwReferralPatients'),
                          //   child: Container(
                          //     height: 140,
                          //     width: double.infinity,
                          //     alignment: Alignment.center,
                          //     child: Card(
                          //       elevation: 2,
                          //       child: Column(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: <Widget>[
                          //           Image.asset('assets/images/icons/questionnaire.png'),
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.center,
                          //             children: <Widget>[
                          //               Text(AppLocalizations.of(context).translate('referralList'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 24),),
                          //               Container(
                          //                 alignment: Alignment.centerLeft,
                          //                 child: Icon(Icons.chevron_right, color: kPrimaryColor, size: 30,)
                          //               )
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),

                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.height, size.width / 2);
    path.lineTo(size.width, 0.0);
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


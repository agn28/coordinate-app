import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/assessment_repository.dart';
import 'package:nhealth/repositories/care_plan_repository.dart';
import 'package:nhealth/repositories/health_report_repository.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'package:nhealth/repositories/local/care_plan_repository_local.dart';
import 'package:nhealth/repositories/local/health_report_repository_local.dart';
import 'package:nhealth/repositories/local/observation_repository_local.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'package:nhealth/repositories/local/referral_repository_local.dart';
import 'package:nhealth/repositories/observation_repository.dart';
import 'package:nhealth/repositories/patient_repository.dart';
import 'package:nhealth/repositories/referral_repository.dart';
import 'package:nhealth/repositories/sync_repository.dart';
import 'package:device_info/device_info.dart';
import 'package:sqflite/sqflite.dart';

import 'assessment_controller.dart';

var bloodPressures = [];

class SyncController extends GetxController {
  var isPoorNetwork = false.obs;
  var isConnected = false.obs;
  var isSyncing = false.obs;
  var isSyncingToLive = false.obs;
  var isSyncingToLocal = false.obs;
  var showSyncInfoflag = false.obs;

  var syncs = 0.obs;
  var localNotSyncedPatients = [].obs;
  var livePatientsAll = [].obs;
  var localPatientsAll = [].obs;
  var localAssessmentsAll = [].obs;
  var localNotSyncedAssessments = [].obs;
  var localObservationsAll = [].obs;
  var localNotSyncedObservations = [].obs;
  var localNotSyncedReferrals = [].obs;
  var localCareplansAll = [].obs;
  var localHealthReportsAll = [].obs;
  var localNotSyncedCareplans = [].obs;
  var localNotSyncedHealthReports = [].obs;
  var syncRepo = SyncRepository();
  var patientRepoLocal = PatientReposioryLocal();
  var patientRepo = PatientRepository();
  var patientController = PatientController();
  var assessmentController = AssessmentController();
  var assessmentRepoLocal = AssessmentRepositoryLocal();
  var assessmentRepo = AssessmentRepository();
  var observationController = ObservationController();
  var observationRepoLocal = ObservationRepositoryLocal();
  var observationRepo = ObservationRepository();
  var referralRepo = ReferralRepository();
  var referralRepoLocal = ReferralRepositoryLocal();
  var careplanRepo = CarePlanRepository();
  var careplanRepoLocal = CarePlanRepositoryLocal();
  var healthReportController = HealthReportController();
  var healthReportRepoLocal = HealthReportRepositoryLocal();
  var healthReportRepo = HealthReportRepository();

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  create(type, screening_type, comment) async {}

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  createOnlyAssessment(type, screening_type, comment) async {}

  getAllStatsData() async {
    getLocalNotSyncedPatient();
    getLocalNotSyncedAssessments();
    getLocalNotSyncedObservations();
    getLocalNotSyncedReferrals();
    getLocalNotSyncedCareplans();
    getLocalNotSyncedHealthReports();
  }

  getLocalNotSyncedPatient() async {
    var response = await patientRepoLocal.getNotSyncedPatients();

    if (isNotNull(response)) {
      localNotSyncedPatients.value = [];
      response.forEach((patient) {
        var parsedData = jsonDecode(patient['data']);

        localNotSyncedPatients.value.add({
          'id': patient['id'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      });
    }
  }

  getLocalNotSyncedAssessments() async {
    var response = await assessmentRepoLocal.getNotSyncedAssessments();

    if (isNotNull(response)) {
      localNotSyncedAssessments.value = [];

      response.forEach((assessment) {
        var parsedData = jsonDecode(assessment['data']);
        localNotSyncedAssessments.add({
          'id': assessment['id'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      });
    }
  }

  getLocalNotSyncedObservations() async {
    var response = await observationRepoLocal.getNotSyncedObservations();

    if (isNotNull(response)) {
      localNotSyncedObservations.value = [];

      response.forEach((item) {
        var parsedData = jsonDecode(item['data']);
        localNotSyncedObservations.add({
          'id': item['id'],
          'data': {
            'type': parsedData['body']['type'],
            'data': parsedData['body']['data'],
            'comment': parsedData['body']['comment'],
            'patient_id': parsedData['body']['patient_id'],
            'assessment_id': parsedData['body']['assessment_id'],
          },
          'meta': parsedData['meta']
        });
      });
    }
  }

  getLocalNotSyncedReferrals() async {
    
    var response = await referralRepoLocal.getNotSyncedReferrals();
    if (isNotNull(response)) {
      localNotSyncedReferrals.value = [];

      response.forEach((item) {
        var parsedData = jsonDecode(item['data']);
        localNotSyncedReferrals.add({
          'id': item['id'],
          'body': parsedData['body'],
          'meta': parsedData['meta']
        });
      });
    }
  }
  getLocalNotSyncedCareplans() async {
    var response = await careplanRepoLocal.getNotSyncedCareplans();

    if (isNotNull(response)) {
      localNotSyncedCareplans.value = [];
      response.forEach((careplan) {
        var parsedData = jsonDecode(careplan['data']);

        localNotSyncedCareplans.value.add({
          'id': careplan['id'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      });
    }
  }

    getLocalNotSyncedHealthReports() async {
    var response = await healthReportRepoLocal.getNotSyncedHealthReports();

    if (isNotNull(response)) {
      localNotSyncedHealthReports.value = [];
      response.forEach((healthReport) {
        var parsedData = jsonDecode(healthReport['data']);

        localNotSyncedHealthReports.value.add({
          'id': healthReport['id'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      });
    }
  }

  checkConnection(result) async {
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      isConnected.value = true;
      await initializeSync();
    } else {
      isConnected.value = false;
    }
  }

  // initializeLocalToLiveSync() async {
  //   print('sync initiated');
  //   await getLocalNotSyncDataData();

  //   if (!isSyncing.value) {
  //     isSyncing.value = true;

  //     // await syncLocalPatientsToLive();
  //     await syncLocalDataToLiveByPatient();
  //     isSyncing.value = false;
  //   }
  // }

  getLocalNotSyncDataData() async {
    await getLocalNotSyncedPatient();
    await getLocalNotSyncedAssessments();
    await getLocalNotSyncedObservations();
    await getLocalNotSyncedReferrals();
    return;
  }
  getLocalData() async{
    var localData = await referralRepoLocal.getAllReferrals();
    for(var item in localData){
      var data = jsonDecode(item['data']);
    }
  }
  initializeLiveToLocalSync() async {
    isSyncing.value = true;
    showSyncInfoflag.value = true;
    await checkLocationData();
    await checkCenterData();
    var flag = true;
    var liveSync = true;
    // var num = 0;

    while(flag) {
      var response = await fetchLatestSyncs();
      flag = !(response['data'].length == 0);
      // flag = !(num == 2);
      // print(num);
      // num++;
    }
    //TODO: use while loop here
    while(liveSync) {
      await syncLivePatientsToLocal();
      var syncCount = await syncRepo.checkTempSyncsCount();
      syncs.value = syncCount;
      liveSync = !(syncCount == 0);
    }
    isSyncing.value = liveSync;
  }

  syncLocalToLive() async {
    var authData = await Auth().getStorageAuth() ;
    var notSyncedLocalPatients = await patientRepoLocal.getNotSyncedPatients();
    var notSyncedLocalAssessments = await assessmentRepoLocal.getNotSyncedAssessments();
    var notSyncedLocalObservations = await observationRepoLocal.getNotSyncedObservations();
    var notSyncedLocalReferrals = await referralRepoLocal.getNotSyncedReferrals();
    var notSyncedLocalCareplans = await careplanRepoLocal.getNotSyncedCareplans();
    
      if (isNotNull(notSyncedLocalPatients)) {
        for(var patient in notSyncedLocalPatients){
          var parsedData = jsonDecode(patient['data']);
          var data = {
            'id': patient['id'],
            'body': parsedData['body'],
            'meta': parsedData['meta'],
            'deviceId': authData['deviceId']
          };
          
          var response = await patientRepo.create(data);
          if(isNotNull(response['error']) && !response['error']){
            await patientRepoLocal.updateLocalStatus(patient['id'], 1);
          }
          
        }
      }

      if(isNotNull(notSyncedLocalAssessments)){
        for(var assessment in notSyncedLocalAssessments){
          var parsedData = jsonDecode(assessment['data']);
          var data = {
            'id': assessment['id'],
            'body': parsedData['body'],
            'meta': parsedData['meta'],
            'deviceId': authData['deviceId']
          };
          var response = await assessmentRepo.create(data);
          if(isNotNull(response['error']) && !response['error']){
            await assessmentRepoLocal.updateLocalStatus(assessment['id'], 1);
          }
        }
      }

      if(isNotNull(notSyncedLocalObservations)){
        for(var observation in notSyncedLocalObservations){
          var parsedData = jsonDecode(observation['data']);
          var data = {
            'id': observation['id'],
            'body': parsedData['body'],
            'meta': parsedData['meta'],
            'deviceId': authData['deviceId']
          };

          var response = await observationRepo.create(data);
          if(isNotNull(response['error']) && !response['error']){
            await observationRepoLocal.updateLocalStatus(observation['id'], 1);
          }
        }
      }

      if(isNotNull(notSyncedLocalReferrals)){
        for(var referral in notSyncedLocalReferrals){
          var parsedData = jsonDecode(referral['data']);
          var data = {
            'id': referral['id'],
            'body': parsedData['body'],
            'meta': parsedData['meta'],
            'deviceId': authData['deviceId']
          };

          var response = await referralRepo.create(data);
          if(isNotNull(response['error']) && !response['error']){
            await referralRepoLocal.updateLocalStatus(referral['id'], 1);
          }
          
        }
      }

      if(isNotNull(notSyncedLocalCareplans)){
        for(var careplan in notSyncedLocalCareplans){
          var parsedData = jsonDecode(careplan['data']);
          var data = {
            'id': careplan['id'],
            'body': parsedData['body'],
            'meta': parsedData['meta'],
            'deviceId': authData['deviceId']
          };
          var response = await careplanRepo.create(data);
          if(isNotNull(response['error']) && !response['error']){
            await careplanRepoLocal.updateLocalStatus(careplan['id'], 1);
          }
        }
      }
  }

  initializeSync() async {
    // if (!isSyncing.value) {
    //   isSyncing.value = true;
    //   await checkLocationData();
    //   await checkCenterData();
    //   await fetchLatestSyncs();

    //   //sync to live
    //   // if (!isPoorNetwork.value) {

    //   await Future.delayed(const Duration(seconds: 2));
    //   await syncLivePatientsToLocal();
    //   await Future.delayed(const Duration(seconds: 2));
    //   // await syncLocalPatientsToLive();
    //   await syncLocalDataToLive();
    //   isSyncing.value = false;
    // }
    // else {
    //   isSyncing.value = false;
    //   initializeSync();
    // }
    // }
  }

  fetchLatestSyncs() async {
    var dbEmpty = await syncRepo.checkTempSyncsCount();
    var response;
    // if(dbEmpty == 0) {
    //   print('dbEmpty');
    //   // TODO: call another api to fetch all data for first time
    //   // response = await syncRepo.fetchLatestSyncs();
    // } else {
    // }
    try {
      response = await syncRepo.fetchLatestSyncs();
      await syncRepo.createTempSyncs(response['data']);
    } catch(error) {
      print('error $error');
    }
    return response;
  }


//  syncLocalDataToLiveByPatient() async {
//     print('syncing local patient data');
//     print(await careplanRepoLocal.getNotSyncedCareplans());
//     if (localNotSyncedPatients.value.isEmpty 
//     && localNotSyncedAssessments.value.isEmpty 
//     && localNotSyncedObservations.value.isEmpty 
//     && localNotSyncedReferrals.value.isEmpty 
//     && localNotSyncedCareplans.value.isEmpty) {
//       return;
//     }
//     var syncData = [];
//     isSyncing.value = true;
//     for (var patient in localNotSyncedPatients) {
//       print('into local patients $patient');
//       var patientData = {
//         'id': patient['id'],
//         'body': patient['data'],
//         'meta': patient['meta']
//       };
//       syncData.add({
//         'patient_id': patient['id'],
//         'sync_data':{
//           'patient_data':patientData,
//           'assessment_data': [],
//           'referral_data': [],
//           'careplan_data': []
//         }
//       });
//       print('patientData $syncData');
//     }
//     for (var assessment in localNotSyncedAssessments) {
//       print('into local assessments $assessment');
//       var assessmentData = {
//         'id': assessment['id'],
//         'body': assessment['data'],
//         'meta': assessment['meta'],
//         'observation_data' : []
//       };
//       var matchedData = syncData.where((data) => data['patient_id'] == assessment['data']['patient_id']);
//       if(matchedData.isEmpty) {
//         syncData.add({
//           'patient_id': assessment['data']['patient_id'],
//           'sync_data':{
//             'assessment_data': [assessmentData]
//           }
//         });
//       } else if(matchedData.isNotEmpty) {
//         var matchedGroupIndex = syncData.indexOf(matchedData.first);
//         syncData[matchedGroupIndex]['sync_data']['assessment_data'].add(assessmentData);
//       }
//       // var matchedGroup = assessmentsByPatient.where((item) => item['patient_id'] == assessment['data']['patient_id']);
//       // if(matchedGroup.isEmpty) {
//       //   assessmentsByPatient.add({
//       //     'patient_id': assessment['data']['patient_id'],
//       //     'assessment_data': [assessmentData]
//       //   });
//       // } else if(matchedGroup.isNotEmpty) {
//       //   var matchedGroupIndex = assessmentsByPatient.indexOf(matchedGroup.first);
//       //   assessmentsByPatient[matchedGroupIndex]['assessment_data'].add(assessmentData);
//       // }
//     }

//     for (var observation in localNotSyncedObservations) {
//       print('into local observations $observation');
//       var observationData = {
//         'id': observation['id'],
//         'body': observation['data'],
//         'meta': observation['meta']
//       };
//       var matchedAssessmentIndex;
//       var matchedData = syncData.where((data) {
//         var matchedAssessment = data['sync_data']['assessment_data'].where((assessment) => assessment['id'] == observation['data']['assessment_id']);
//         matchedAssessmentIndex = data['sync_data']['assessment_data'].indexOf(matchedAssessment.first);
//         if (matchedAssessment.isNotEmpty) {
//           return true;
//         } else {
//           return false;
//         }
//       });
//       if(matchedData.isNotEmpty) {
//         print('matchedData $matchedData');
//         var matchedGroupIndex = syncData.indexOf(matchedData.first);
//         print('matchedGroupIndex $matchedGroupIndex');
//         var matchedAssessment = syncData[matchedGroupIndex]['sync_data']['assessment_data'][matchedAssessmentIndex];
//         matchedAssessment['observation_data'].add(observationData);
//         print(matchedAssessment);
//       }
//     }
//     for (var referral in localNotSyncedReferrals) {
//       print('into local referrals $referral');
//       var referralData = {
//         'id': referral['id'],
//         'body': referral['body'],
//         'meta': referral['meta']
//       };
//       var matchedData = syncData.where((data) => data['patient_id'] == referral['meta']['patient_id']);
//       if(matchedData.isEmpty) {
//         syncData.add({
//           'patient_id': referral['meta']['patient_id'],
//           'sync_data':{
//             'referral_data': [referralData]
//           }
//         });
//       } else if(matchedData.isNotEmpty) {
//         var matchedGroupIndex = syncData.indexOf(matchedData.first);
//         print(syncData[matchedGroupIndex]);
//         if(syncData[matchedGroupIndex]['sync_data']['referral_data'] != null){
//           syncData[matchedGroupIndex]['sync_data']['referral_data'].add(referralData);
//         } else {
//           syncData[matchedGroupIndex]['sync_data']['referral_data'] = [referralData];
//         }
//       }
//     }

//     for (var careplan in localNotSyncedCareplans) {
//       print('into local careplan $careplan');
//       var careplanData = {
//         'id': careplan['id'],
//         'body': careplan['data'],
//         'meta': careplan['meta']
//       };
//       var matchedData = syncData.where((data) => data['patient_id'] == careplan['data']['patient_id']);
//       if(matchedData.isEmpty) {
//         syncData.add({
//           'patient_id': careplan['data']['patient_id'],
//           'sync_data':{
//             'careplan_data': [careplanData]
//           }
//         });
//       } else if(matchedData.isNotEmpty) {
//         var matchedGroupIndex = syncData.indexOf(matchedData.first);
//         print(syncData[matchedGroupIndex]);
//         if(syncData[matchedGroupIndex]['sync_data']['careplan_data'] != null){
//           syncData[matchedGroupIndex]['sync_data']['careplan_data'].add(careplanData);
//         } else {
//           syncData[matchedGroupIndex]['sync_data']['careplan_data'] = [careplanData];
//         }
//       }
//     }

//     // Initiating API request
//     for (var data in syncData) {
//       print('reqData ${jsonEncode(data['sync_data']['careplan_data'])}');
//       // return;
//       var response = await syncRepo.create(data['sync_data']);
//       print('sync resposne $response');

//       if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
//         isPoorNetwork.value = true;
//         isSyncing.value = false;
//         showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
//         retryForStableNetwork();
//         break;
//       }

//       if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
//         print('sync created');

//         // For Patient
//         if (isNotNull(response['data']['patient']) && isNotNull(response['data']['patient']['sync']) && isNotNull(response['data']['patient']['sync']['key'])) {
//           await patientRepoLocal.updateLocalStatus(response['data']['patient']['sync']['document_id'], 1);
//           await syncRepo.updateLatestLocalSyncKey(response['data']['patient']['sync']['key']);
//         }

//         //For Assessments
//         if (response['data']['assessments'].isNotEmpty) {
//           for (var assessment in response['data']['assessments']) {
//             if (isNotNull(assessment['sync']) && isNotNull(assessment['sync']['key'])) {
//               await assessmentRepoLocal.updateLocalStatus(assessment['sync']['document_id'], 1);
//               await syncRepo.updateLatestLocalSyncKey(assessment['sync']['key']);
//             }
//           }
//         }

//         //For Observations
//         if (response['data']['observations'].isNotEmpty) {
//           for (var observation in response['data']['observations']) {
//             if (isNotNull(observation['sync']) && isNotNull(observation['sync']['key'])) {
//               await observationRepoLocal.updateLocalStatus(observation['sync']['document_id'], 1);
//               await syncRepo.updateLatestLocalSyncKey(observation['sync']['key']);
//             }
//           }
//         }

//         //For Referrals
//         if (response['data']['referrals'].isNotEmpty) {
//           for (var referral in response['data']['referrals']) {
//             if (isNotNull(referral['sync']) && isNotNull(referral['sync']['key'])) {
//               await referralRepoLocal.updateLocalStatus(referral['sync']['document_id'], 1);
//               await syncRepo.updateLatestLocalSyncKey(referral['sync']['key']);
//             }
//           }
//         }

//         //For Careplans
//         if (response['data']['careplans'].isNotEmpty) {
//           for (var careplan in response['data']['careplans']) {
//             if (isNotNull(careplan['sync']) && isNotNull(careplan['sync']['key'])) {
//               await referralRepoLocal.updateLocalStatus(careplan['sync']['document_id'], 1);
//               await syncRepo.updateLatestLocalSyncKey(careplan['sync']['key']);
//             }
//           }
//         }

//       } else {
//         print('data not synced');
//         print(response);
//         if (isNotNull(response) && response['message'] == 'Unauthorized') {
//           showWarningSnackBar(
//               'Error', 'Session is expired. Login again to sync data');
//         }
//       }
//     }

//     await Future.delayed(const Duration(seconds: 5));

//     isSyncing.value = false;
//     if (!isPoorNetwork.value) {
//       getAllStatsData();
//     }
//   }

  // syncLocalPatientsToLive() async {
  //   print('syncing local patient');
  //   // if (localNotSyncedPatients.value.isEmpty) {
  //   //   return;
  //   // }
  //   print(localNotSyncedPatients);
  //   isSyncing.value = true;
  //   for (var patient in localNotSyncedPatients) {
  //     print(localNotSyncedPatients);

  //     print('local patient');
  //     print(patient['data']);
  //     print(patient['meta']);
  //     var data = {
  //       'id': patient['id'],
  //       'body': patient['data'],
  //       'meta': patient['meta']
  //     };

  //     var response = await patientRepo.create(data);
  //     print('patient create resposne');
  //     print(response);

  //     if (isNotNull(response['exception']) &&
  //         response['type'] == 'poor_network') {
  //       isPoorNetwork.value = true;
  //       isSyncing.value = false;
  //       showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
  //       retryForStableNetwork();
  //       break;
  //     }

  //     if (isNotNull(response) &&
  //         isNotNull(response['error']) &&
  //         !response['error']) {
  //       print('patient created');

  //       if (isNotNull(response['data']['sync']) &&
  //           isNotNull(response['data']['sync']['key'])) {
  //         await patientRepoLocal.updateLocalStatus(patient['id'], 1);
  //         await syncRepo
  //             .updateLatestLocalSyncKey(response['data']['sync']['key']);
  //       }

  //       // patientRepoLocal.updateLocalStatus(patient['id'], true);
  //       // syncRepo.updateLatestLocalSyncKey(key);

  //     } else {
  //       print('patient not synced');
  //       print(response);
  //       if (isNotNull(response) && response['message'] == 'Unauthorized') {
  //         showWarningSnackBar(
  //             'Error', 'Session is expired. Login again to sync data');
  //       }
  //     }
  //   }

  //   for (var assessment in localNotSyncedAssessments) {
  //     print('into local assessments');
  //     print(assessment['data']);
  //     print(assessment['meta']);
  //     var data = {
  //       'id': assessment['id'],
  //       'body': assessment['data'],
  //       'meta': assessment['meta']
  //     };

  //     var response = await assessmentRepo.create(data);
  //     //TODO:check if created
  //     print('assessment create resposne');
  //     print(response);

  //     //TODO: check slow network

  //     // if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
  //     //   isPoorNetwork.value = true;
  //     //   isSyncing.value = false;
  //     //   showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
  //     //   retryForStableNetwork();
  //     //   break;
  //     // }
  //     print('resperr ${response['error']}');
  //     print('resperr ${response['error']}');
  //     if (isNotNull(response) &&
  //         isNotNull(response['error']) &&
  //         !response['error']) {
  //       print('assessment created');

  //       if (isNotNull(response['data']['sync']) &&
  //           isNotNull(response['data']['sync']['key'])) {
  //         await assessmentRepoLocal.updateLocalStatus(assessment['id'], 1);
  //         //TODO:check if updated
  //         await syncRepo
  //             .updateLatestLocalSyncKey(response['data']['sync']['key']);
  //       }

  //       // patientRepoLocal.updateLocalStatus(patient['id'], true);
  //       // syncRepo.updateLatestLocalSyncKey(key);

  //     } else {
  //       print('assessment not synced');
  //       print(response);
  //       if (isNotNull(response) && response['message'] == 'Unauthorized') {
  //         showWarningSnackBar(
  //             'Error', 'Session is expired. Login again to sync data');
  //       }
  //     }
  //   }

  //   print('localNotSyncedObservations $localNotSyncedObservations');
  //   for (var observation in localNotSyncedObservations) {
  //     print('into local observations $observation');
  //     print(observation['data']);
  //     print(observation['meta']);
  //     var data = {
  //       'id': observation['id'],
  //       'body': observation['data'],
  //       'meta': observation['meta']
  //     };

  //     var response = await observationRepo.create(data);
  //     print('observation create resposne');
  //     print(response);

  //     //TODO: check slow network

  //     // if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
  //     //   isPoorNetwork.value = true;
  //     //   isSyncing.value = false;
  //     //   showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
  //     //   retryForStableNetwork();
  //     //   break;
  //     // }

  //     if (isNotNull(response) &&
  //         isNotNull(response['error']) &&
  //         !response['error']) {
  //       print('observation created');

  //       if (isNotNull(response['data']['sync']) &&
  //           isNotNull(response['data']['sync']['key'])) {
  //         await observationRepoLocal.updateLocalStatus(observation['id'], 1);
  //         await syncRepo
  //             .updateLatestLocalSyncKey(response['data']['sync']['key']);
  //       }

  //       // patientRepoLocal.updateLocalStatus(patient['id'], true);
  //       // syncRepo.updateLatestLocalSyncKey(key);

  //     } else {
  //       print('observaton not synced');
  //       print(response);
  //       if (isNotNull(response) && response['message'] == 'Unauthorized') {
  //         showWarningSnackBar(
  //             'Error', 'Session is expired. Login again to sync data');
  //       }
  //     }
  //   }

  //   for (var referral in localNotSyncedReferrals) {
  //     print('into local referrals');
  //     print(referral['data']);
  //     print(referral['meta']);
  //     var data = {
  //       'id': referral['id'],
  //       'body': referral['body'],
  //       'meta': referral['meta']
  //     };

  //     var response = await referralRepo.create(data);
  //     print('referral create resposne');
  //     print(response);

  //     //TODO: check slow network

  //     // if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
  //     //   isPoorNetwork.value = true;
  //     //   isSyncing.value = false;
  //     //   showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
  //     //   retryForStableNetwork();
  //     //   break;
  //     // }

  //     if (isNotNull(response) &&
  //         isNotNull(response['error']) &&
  //         !response['error']) {
  //       print('referral created');

  //       if (isNotNull(response['data']['sync']) &&
  //           isNotNull(response['data']['sync']['key'])) {
  //         await referralRepoLocal.updateLocalStatus(referral['id'], 1);
  //         await syncRepo
  //             .updateLatestLocalSyncKey(response['data']['sync']['key']);
  //       }

  //       // patientRepoLocal.updateLocalStatus(patient['id'], true);
  //       // syncRepo.updateLatestLocalSyncKey(key);

  //     } else {
  //       print('referral not synced');
  //       print(response);
  //       if (isNotNull(response) && response['message'] == 'Unauthorized') {
  //         showWarningSnackBar(
  //             'Error', 'Session is expired. Login again to sync data');
  //       }
  //     }
  //   }

  //   await Future.delayed(const Duration(seconds: 5));

  //   isSyncing.value = false;
  //   // localNotSyncedPatients.forEach( (patient) async {

  //   // });
  //   if (!isPoorNetwork.value) {
  //     getAllStatsData();
  //   }
  // }

  syncLocalDataToLive() async {
    var authData = await Auth().getStorageAuth() ;
    var syncedPatients = 0, syncedAssessments = 0, syncedObservations = 0, syncedReferrals = 0, syncedCareplans = 0;
    if (localNotSyncedPatients.value.isEmpty
        && localNotSyncedAssessments.value.isEmpty
        && localNotSyncedObservations.value.isEmpty
        && localNotSyncedReferrals.value.isEmpty
        && localNotSyncedCareplans.value.isEmpty) {
      return;
    }
    isSyncingToLive.value = true;
    isSyncing.value = true;
    for (var patient in localNotSyncedPatients) {
      patient['meta']['is_synced'] = false;
      var data = {
        'id': patient['id'],
        'body': patient['data'],
        'meta': patient['meta']
      };
      var existingPatient = await patientController.getPatient(patient['id']);
      var response;
      if(isNotNull(existingPatient) && existingPatient.isNotEmpty && isNotNull(existingPatient['error']) && !existingPatient['error']) {
        response = await patientRepo.updateSyncStatus(patient['id'], false);
      } else {
        response = await patientRepo.create(data);
      }

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedPatients++;
          // await patientRepoLocal.updateLocalStatus(patient['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
        }
      } else {
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }

    var localAssessments = [...localNotSyncedAssessments.value];
    for (var assessment in localAssessments) {
      var data = {
        'id': assessment['id'],
        'body': assessment['data'],
        'meta': assessment['meta']
      };

      var response = await assessmentRepo.create(data);

      // check slow network
      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        break;
      }
      
      // check if created
      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedAssessments++;
          await assessmentRepoLocal.updateLocalStatus(assessment['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
          localNotSyncedAssessments.remove(assessment);
        }
      } else {
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
        // check for existing assessment
        else if (isNotNull(response) && response['message'] == 'Assessment already exist!') {
          if (isNotNull(response['data']['assessment']) && isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
            syncedAssessments++;
            await assessmentRepoLocal.deleteLocalAssessment(assessment['id']);
            await assessmentRepoLocal.createLocalAssessment(response['data']['assessment']['id'], response['data']['assessment'], true);
            await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
            localNotSyncedAssessments.remove(assessment);
          }
        }
        // check for failed assessment
        else if (isNotNull(response) && response['message'] == 'Assessment could not be created!') {
          await patientRepoLocal.updateLocalStatus(assessment['data']['patient_id'], 0);
        }
      }
    }
    //TODO: attach each observations to corresponding assessments
    var localObservations = [...localNotSyncedObservations.value];
    for (var observation in localObservations) {

      var data = {
        'id': observation['id'],
        'body': observation['data'],
        'meta': observation['meta']
      };

      var response = await observationRepo.create(data);

      // TODO: check slow network

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedObservations++;
          await observationRepoLocal.updateLocalStatus(observation['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
          localNotSyncedObservations.remove(observation);
        }
      } else {
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }
    var localReferrals = [...localNotSyncedReferrals.value];
    for (var referral in localReferrals) {
      var data = {
        'id': referral['id'],
        'body': referral['body'],
        'meta': referral['meta']
      };

      var response = await referralRepo.create(data);

      //TODO: check slow network

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedReferrals++;
          await referralRepoLocal.updateLocalStatus(referral['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
          localNotSyncedReferrals.remove(referral);
        }
      } else {
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }
    var localCareplans = [...localNotSyncedCareplans.value];
    for (var careplan in localCareplans) {
      var data = {
        'id': careplan['id'],
        'body': careplan['data'],
        'meta': careplan['meta']
      };

      var response = await careplanRepo.update(careplan['data'], careplan['data']['comment']);

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedCareplans++;
          await careplanRepoLocal.updateLocalStatus(careplan['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
          localNotSyncedCareplans.remove(careplan);
        }
      } else {
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }

    await Future.delayed(const Duration(seconds: 5));
    
    if(syncedPatients == localNotSyncedPatients.value.length
    && syncedAssessments == localAssessments.length
    && syncedObservations == localObservations.length
    && syncedReferrals == localReferrals.length
    && syncedReferrals == localCareplans.length) {
      var localPatients = [...localNotSyncedPatients.value];
      for(var patient in localPatients) {
        var response = await patientRepo.updateSyncStatus(patient['id'], true);

        if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
          isPoorNetwork.value = true;
          isSyncing.value = false;
          // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
          break;
        }

        if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
          if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
            await patientRepoLocal.updateLocalStatus(patient['id'], 1);
            await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
            localNotSyncedPatients.remove(patient);
          }
        } else {
          if (isNotNull(response) && response['message'] == 'Unauthorized') {
            showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
          }
        }
      }
    }
    isSyncing.value = false;
    isSyncingToLive.value = false;
    if (!isPoorNetwork.value) {
      getAllStatsData();
    }
  }

  retryForStableNetwork() async {
    var retryCount = 100;
    var count = 0;
    var duration = Duration(seconds: 5);

    Timer.periodic(duration, (timer) async {
      count++;
      try {
        var response = await syncRepo.getLatestSyncInfo({'key': 'test'});
        if (isNotNull(response) && isNotNull(response['error'])) {
          isPoorNetwork.value = false;
          isConnected.value = true;
          initializeSync();
          timer.cancel();
        } else if (isNotNull(response) && isNotNull(response['exception'] && response['type'] == 'no_internet')) {

          isConnected.value = false;
        }
        if (count == retryCount) {
          timer.cancel();
        }
      } catch (error) {
        timer.cancel();
      }
    });
    return;
  }
  checktoSync() async {
    // if(!isSyncingToLocal.value) {
      //TODO need to check sync_type later
      int syncCount = Sqflite.firstIntValue(await syncRepo.getTempSyncsCount());
      if(syncCount > 0) {
        syncLivePatientsToLocal();
      }
    // }
  }

  syncLivePatientsToLocal() async {
    if (isPoorNetwork.value || isSyncingToLocal.value) {
      return;
    }

    var subPatients = [];
    var subAssessments = [];
    var subObservations = [];
    var subReferrals = [];
    var subCarePlans = [];
    var subHealthReports = [];

    isSyncingToLocal.value = true;

    var patientsSync = await syncRepo.getTempSyncs('patients', 1000);
    for (var patient in patientsSync) {
      subPatients.add(patient['document_id']);
    }
    //TODO: check subpatient empty
    if(subPatients.length > 0) {
      await insertPatients(subPatients);
      subPatients = [];
    }

    var assessmentsSync = await syncRepo.getTempSyncs('assessments', 1000);
    for (var assessment in assessmentsSync) {
      subAssessments.add(assessment['document_id']);
    }
    if(subAssessments.length > 0) {
      await insertAssessments(subAssessments);
      subAssessments = [];
    }

    var observationsSync = await syncRepo.getTempSyncs('observations', 1000);
    for (var observation in observationsSync) {
      subObservations.add(observation['document_id']);
    }
    if(subObservations.length > 0) {
      await insertObservations(subObservations);
      subObservations = [];
    }
    
    var referralsSync = await syncRepo.getTempSyncs('referrals', 10);
    for (var referral in referralsSync) {
      subReferrals.add(referral['document_id']);
    }
    if(subReferrals.length > 0) {
      await insertReferrals(subReferrals);
      subReferrals = [];
    }

    var carePlansSync = await syncRepo.getTempSyncs('care_plans', 10);
    for (var carePlan in carePlansSync) {
      subCarePlans.add(carePlan['document_id']);
    }
    if(subCarePlans.length > 0) {
      await insertCarePlans(subCarePlans);
      subCarePlans = [];
    }

    var healthReportsSync = await syncRepo.getTempSyncs('health_reports', 10);
    for (var healthReport in healthReportsSync) {
      subHealthReports.add(healthReport['document_id']);
    }
    if(subHealthReports.length > 0) {
      await insertHealthReports(subHealthReports);
      subHealthReports = [];
    }

    await Future.delayed(const Duration(seconds: 2));
    isSyncingToLocal.value = false;
    getAllStatsData();
  }

  insertPatients(ids) async {
    var patients = await patientController.getPatientByIds(ids);

    if (isNotNull(patients) && isNotNull(patients['error']) && !patients['error'] && isNotNull(patients['data'])) {

      await patientRepoLocal.syncFromLive(patients['data']);
    } 
    await syncRepo.updateSyncStatus(ids, 1);
  }

  insertAssessments(ids) async {
  var assessments = await assessmentController.getAssessmentByIds(ids);
    if (isNotNull(assessments) && isNotNull(assessments['error']) && !assessments['error'] && isNotNull(assessments['data'])) {
      await assessmentRepoLocal.syncFromLive(assessments['data'], true);
    }
    await syncRepo.updateSyncStatus(ids, 1);
  }

  insertObservations(ids) async {
    var observations = await observationController.getLiveObservationsByIds(ids);
    if (isNotNull(observations) && isNotNull(observations['error']) && !observations['error'] && isNotNull(observations['data'])) {
      await observationRepoLocal.syncFromLive(observations['data'], true);
    }
    await syncRepo.updateSyncStatus(ids, 1);
  }

  insertReferrals(ids) async {
  var referrals = await referralRepo.getReferralByIds(ids);
    if (isNotNull(referrals) && isNotNull(referrals['error']) && !referrals['error'] && isNotNull(referrals['data'])) {
      await referralRepoLocal.syncFromLive(referrals['data'], true);
    }
    await syncRepo.updateSyncStatus(ids, 1);
  }


  insertCarePlans(ids) async {
  var careplans = await careplanRepo.getCarePlanByIds(ids);

    if (isNotNull(careplans) && isNotNull(careplans['error']) && !careplans['error'] && isNotNull(careplans['data'])) {
      await careplanRepoLocal.syncFromLive(careplans['data'],true);
    }
    await syncRepo.updateSyncStatus(ids, 1);
  }

  insertHealthReports(ids) async {
    var healthreports = await healthReportRepo.getHealthReportByIds(ids);

    if (isNotNull(healthreports) && isNotNull(healthreports['error']) && !healthreports['error'] && isNotNull(healthreports['data'])) {
      await healthReportRepoLocal.syncFromLive(healthreports['data'], true);
    }
    await syncRepo.updateSyncStatus(ids, 1);
  }

  getLocalSyncKey() async {
    var response = await syncRepo.getLocalSyncKey();

    var key = '';
    var created_at = '';
    if (isNotNull(response) && response.isNotEmpty) {
      key = response[0]['key'];
      created_at = response[0]['created_at'];
    }

    var apiResponse = await getLatestSyncInfo(key);
    if (key != '' && isNotNull(apiResponse) && isNotNull(apiResponse['message']) && apiResponse['message'] == 'No sync found') {
      await getLatestSyncInfo(key, createdAt:created_at);
    }
  }


  checkLocationData() async {
    var response = await syncRepo.checkLocalLocationData();
    if (isNotNull(response) && response.isNotEmpty) {
      return;
    }
    syncLocationData();
  }

  syncLocationData() async {
    var response = await patientController.getLocations();

    if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
      createLocations(response['data']);
    }
  }

  createLocations(data) async {
    await syncRepo.createLocation(data);
  }

  checkCenterData() async {
    var response = await syncRepo.checkLocalCenterData();
    if (isNotNull(response) && response.isNotEmpty) {
      return;
    }
    syncCenterData();
  }
  syncCenterData() async {
    var response = await patientController.getCenter();

    if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
      createCenters(response['data']);
    }
  }

  createCenters(data) async {
    var response = await syncRepo.createCenter(data);
  }

  getLatestSyncInfo(key, {createdAt:''}) async {
    var data = {};

    if(createdAt != '') {
      data['created_at'] = createdAt;
    } else if (key != '') {
      data['key'] = key;
    }

    var response = await syncRepo.getLatestSyncInfo(data);
    if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
      isPoorNetwork.value = true;
      isSyncing.value = false;
      // isConnected.value = false;
      // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
      return;
    } else if (isNotNull(response['exception']) && response['type'] == 'no_network') {
      // isPoorNetwork.value = true;
      isSyncing.value = false;
      isConnected.value = false;
      showErrorSnackBar('Error', 'No Internet. Cannot sync now');
      // retryForStableNetwork();
      return;
    }
    if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
      // syncs.value = response['data'];

      // sync from live
      // syncLivePatientsToLocal();
    } else if (isNotNull(response) && isNotNull(response['message']) && response['message'] == 'Unauthorized') {
      isSyncing.value = false;
      showErrorSnackBar('Error', 'Session Expired.');
      return;
    }
    return response;
  }

  updateLocalSyncKey(key) async {
    var response = await syncRepo.getLocalSyncKey();

    var oldKey = '';
    if (isNotNull(response) && response.isNotEmpty) {
      oldKey = response[0]['key'];
    }
    return await syncRepo.updateLocalSyncKey(key, oldKey);
  }

  emptyLocalDatabase() async {
    await syncRepo.emptyDatabase();
    getAllStatsData();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nhealth/controllers/health_report_controller.dart';
import 'package:nhealth/controllers/observation_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/helpers/functions.dart';
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

import 'assessment_controller.dart';

var bloodPressures = [];

class SyncController extends GetxController {
  var isPoorNetwork = false.obs;
  var isConnected = false.obs;
  var isSyncing = false.obs;
  var isSyncingToLive = false.obs;
  var isSyncingToLocal = false.obs;

  var syncs = [].obs;
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

    var allLocalPatients = await patientController.getAllLocalPatients();
    var allLocalAssessments = await assessmentController.getAllLocalAssessments();
    var allLocalObservations = await observationController.getAllLocalObservations();
    var allLocalCareplans = await careplanRepoLocal.getAllCareplans();
    var allLocalHealthReports = await healthReportController.getAllLocalHealthReports();

    var allLivePatients = await patientRepo.getPatients();

    if (isNotNull(allLivePatients) && isNotNull(allLivePatients['data'])) {
      print('allLivePatients');
      print(allLivePatients);
      livePatientsAll.value = allLivePatients['data'];
    }

    localPatientsAll.value = allLocalPatients;
    localAssessmentsAll.value = allLocalAssessments;
    localObservationsAll.value = allLocalObservations;
    localCareplansAll.value = allLocalCareplans;
    localHealthReportsAll.value = allLocalHealthReports;

    print('here');
  }

  getLocalNotSyncedPatient() async {
    var response = await patientRepoLocal.getNotSyncedPatients();

    print('not synced patient response');
    print(response);

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

    print('not synced assessment response');
    print(response);

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

    print('not synced observations response');
    print(response);

    if (isNotNull(response)) {
      localNotSyncedObservations.value = [];

      response.forEach((item) {
        var parsedData = jsonDecode(item['data']);
        print('parsedDataObs $parsedData');
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
    print('localNotSyncedObservations $localNotSyncedObservations');
  }

  getLocalNotSyncedReferrals() async {
    
    var response = await referralRepoLocal.getNotSyncedReferrals();

    print('not synced referral response');
    print(response);

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
    print(localNotSyncedCareplans);
    var response = await careplanRepoLocal.getNotSyncedCareplans();

    print('not synced careplan response');
    print(response);

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
    print(localNotSyncedHealthReports);
    var response = await healthReportRepoLocal.getNotSyncedHealthReports();

    print('not synced health reports response');
    print(response);

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
    print('checkConnection');
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      print('connected');
      isConnected.value = true;
      await initializeSync();
    } else {
      isConnected.value = false;
      print('not connected');
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

  initializeSync() async {
    // retryForStableNetwork();
  print('initializeSync');
  print(isSyncing.value);
    if (!isSyncing.value) {
      print('sync started');
      isSyncing.value = true;
      await checkLocationData();
      await checkCenterData();
      await getLocalSyncKey();

      //sync to live
      // if (!isPoorNetwork.value) {

      await Future.delayed(const Duration(seconds: 2));
      await syncLivePatientsToLocal();
      await Future.delayed(const Duration(seconds: 2));
      // await syncLocalPatientsToLive();
      await syncLocalDataToLive();
      isSyncing.value = false;
    }
    else {
      print('initSync in else');
      isSyncing.value = false;
      initializeSync();
    }

    // }
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
    print('syncing local data');
    print('p ${localNotSyncedPatients.value.length}');
    print('a ${localNotSyncedAssessments.value.length}');
    print('o ${localNotSyncedObservations.value.length}');
    print('r ${localNotSyncedReferrals.value.length}');
    print('c ${localNotSyncedCareplans.value.length}');
    // return;
    var syncedPatients = 0, syncedAssessments = 0, syncedObservations = 0, syncedReferrals = 0, syncedCareplans = 0;
    if (localNotSyncedPatients.value.isEmpty
        && localNotSyncedAssessments.value.isEmpty
        && localNotSyncedObservations.value.isEmpty
        && localNotSyncedReferrals.value.isEmpty
        && localNotSyncedCareplans.value.isEmpty) {
      return;
    }
    print('syncing to live initiated');
    isSyncingToLive.value = true;
    print(localNotSyncedPatients);
    isSyncing.value = true;
    for (var patient in localNotSyncedPatients) {
      patient['meta']['is_synced'] = false;
      print('local patient $patient');
      var data = {
        'id': patient['id'],
        'body': patient['data'],
        'meta': patient['meta']
      };
      var existingPatient = await PatientController().getPatient(patient['id']);    
      print('existingPatient $existingPatient');  
      // return;
      // Check new patient or existing
      var response;
      if(isNotNull(existingPatient) && existingPatient.isNotEmpty && isNotNull(existingPatient['error']) && !existingPatient['error']) {
        print('updating patient sync status');
        response = await patientRepo.updateSyncStatus(patient['id'], false);
        print('patient sync resposne');
        print(response);
      } else {
        print('creating patient');
        response = await patientRepo.create(data);
        print('patient create resposne');
        print(response);
      }

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        retryForStableNetwork();
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          print('hi there');
          syncedPatients++;
          // await patientRepoLocal.updateLocalStatus(patient['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
        }
      } else {
        print('patient not synced');
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }

    var localAssessments = [...localNotSyncedAssessments.value];
    for (var assessment in localAssessments) {
      print('local assessments $assessment');
      var data = {
        'id': assessment['id'],
        'body': assessment['data'],
        'meta': assessment['meta']
      };

      var response = await assessmentRepo.create(data);
      print('assessment create resposne');
      print(response);

      // check slow network
      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        retryForStableNetwork();
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
        print('assessment not synced');
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
      }
    }
    //TODO: attach each observations to corresponding assessments
    var localObservations = [...localNotSyncedObservations.value];
    for (var observation in localObservations) {
      print('into local observations $observation');
      var data = {
        'id': observation['id'],
        'body': observation['data'],
        'meta': observation['meta']
      };

      var response = await observationRepo.create(data);
      print('observation create resposne');
      print(response);

      // TODO: check slow network

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        retryForStableNetwork();
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        print('observation created');
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedObservations++;
          await observationRepoLocal.updateLocalStatus(observation['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
          localNotSyncedObservations.remove(observation);
        }
      } else {
        print('observaton not synced');
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }
    var localReferrals = [...localNotSyncedReferrals.value];
    for (var referral in localReferrals) {
      print('into local referrals $referral');
      var data = {
        'id': referral['id'],
        'body': referral['body'],
        'meta': referral['meta']
      };

      var response = await referralRepo.create(data);
      print('referral create resposne');
      print(response);

      //TODO: check slow network

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        retryForStableNetwork();
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        print('referral created');
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedReferrals++;
          await referralRepoLocal.updateLocalStatus(referral['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
          localNotSyncedReferrals.remove(referral);
        }
      } else {
        print('referral not synced');
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }
    var localCareplans = [...localNotSyncedCareplans.value];
    for (var careplan in localCareplans) {
      print('into local careplans $careplan');
      var data = {
        'id': careplan['id'],
        'body': careplan['data'],
        'meta': careplan['meta']
      };

      var response = await careplanRepo.update(careplan['data'], careplan['data']['comment']);
      print('careplan update resposne');
      print(response);

      //TODO: check slow network

      if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
        isPoorNetwork.value = true;
        isSyncing.value = false;
        // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
        retryForStableNetwork();
        break;
      }

      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        print('careplan updated');
        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          syncedCareplans++;
          await careplanRepoLocal.updateLocalStatus(careplan['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
          localNotSyncedCareplans.remove(careplan);
        }
      } else {
        print('careplan not synced');
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }
    }

    await Future.delayed(const Duration(seconds: 5));
    print('p $syncedPatients ${localNotSyncedPatients.value.length}');
    print('a $syncedAssessments ${localAssessments.length}');
    print('o $syncedObservations ${localObservations.length}');
    print('r $syncedReferrals ${localReferrals.length}');
    print('c $syncedReferrals ${localCareplans.length}');
    
    if(syncedPatients == localNotSyncedPatients.value.length
    && syncedAssessments == localAssessments.length
    && syncedObservations == localObservations.length
    && syncedReferrals == localReferrals.length
    && syncedReferrals == localCareplans.length) {
      print('$syncedPatients ${localNotSyncedPatients.value.length}');
      var localPatients = [...localNotSyncedPatients.value];
      for(var patient in localPatients) {
        print('local patient $patient');
        print('updating patient sync status');
        var response = await patientRepo.updateSyncStatus(patient['id'], true);
        print('patient sync resposne');
        print(response);

        if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
          isPoorNetwork.value = true;
          isSyncing.value = false;
          // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
          retryForStableNetwork();
          break;
        }

        if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
          if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
            await patientRepoLocal.updateLocalStatus(patient['id'], 1);
            await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
            localNotSyncedPatients.remove(patient);
            print('remove $localNotSyncedPatients');
          }
        } else {
          print('patient not synced');
          if (isNotNull(response) && response['message'] == 'Unauthorized') {
            showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
          }
        }
      }
    }
    isSyncing.value = false;
    print('syncing to live complete');
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
      print(timer);
      print('retrying at ' + TimeOfDay.now().toString());
      print('retrying count $count');
      try {
        var response = await syncRepo.getLatestSyncInfo({'key': 'test'});
        if (isNotNull(response) && isNotNull(response['error'])) {
          isPoorNetwork.value = false;
          isConnected.value = true;
          initializeSync();
          timer.cancel();
        } else if (isNotNull(response) && isNotNull(response['exception'] && response['type'] == 'no_internet')) {
          // isPoorNetwork.value = false;
          isConnected.value = false;
          // timer.cancel();
        }
        if (count == retryCount) {
          timer.cancel();
        }
      } catch (error) {
        print('error');
        print(error);
        timer.cancel();
      }
    });
    return;
    for (var i = 0; i <= retryCount; i++) {
      print('retrying');

      // var response = await syncRepo.getLatestSyncInfo({ 'key': 'test'});
      // if (isNotNull(response) && isNotNull(response['error'])) {
      //   isPoorNetwork.value = false;
      // }
      // else if(isNotNull(response) && isNotNull(response['exception'] && response['type'] == 'no_internet')) {
      //   isPoorNetwork.value = false;
      //   isConnected.value = false;
      //   break;
      // }

      // await Future.delayed(const Duration(seconds: 5));
    }
  }

  syncLivePatientsToLocal() async {
    print('syncLivePatientsToLocal');
    if (syncs.value.isEmpty) {
      return;
    }

    if (isPoorNetwork.value) {
      return;
    }
    var tempSyncs = [...syncs.value];

    var removeItems = [];

    for (var item in tempSyncs) {
      print('syncing to local initiated');
      isSyncingToLocal.value = true;

      if (item['collection'] == 'patients') {
        if (item['action'] == 'create') {
          var patient = await PatientController().getPatient(item['document_id']);
          print('patient $patient');
          if (isNotNull(patient) && isNotNull(patient['error']) && !patient['error'] && isNotNull(patient['data'])) {
            var existingLocalPatient = await PatientReposioryLocal().getPatientById(patient['data']['id']);
            //Patient already exists in local, needs to be updated
            var localPatient;
            if(isNotNull(existingLocalPatient) && existingLocalPatient.isNotEmpty) {
              print('updating local patient');
              localPatient = await PatientReposioryLocal().updateFromLive(patient['data']['id'], patient['data']);
            } else {
              print('creating local patient');
              localPatient = await PatientReposioryLocal().createFromLive(patient['data']['id'], patient['data']);
            }

            if (isNotNull(localPatient)) {
              print('updating synnc key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
              print(item['key']);
              print(updateSync);
              if (isNotNull(updateSync)) {
                syncs.remove(item);
              }
            }
          } else if (isNotNull(patient['message']) && patient['message'] == "No such document!") {
            syncs.remove(item);
          }
        }
      }

      //TODO: refactor this repeated process
      else if (item['collection'] == 'assessments') {
        if (item['action'] == 'create') {
          var assessment =
              await assessmentController.getAssessmentById(item['document_id']);
          print('assessment');
          print(assessment);
          if (isNotNull(assessment) && isNotNull(assessment['error']) && !assessment['error'] && isNotNull(assessment['data'])) {
            // print('creating local assessment');
            // var localAssessment = await assessmentRepoLocal.createLocalAssessment(assessment['data']['id'], assessment['data'], true);
            // print('after creating local assessment');
            var existingLocalAssessment = await assessmentRepoLocal.getAssessmentById(assessment['data']['id']);
            //Assessment already exists in local, needs to be updated
            var localAssessment;
            if(isNotNull(existingLocalAssessment) && existingLocalAssessment.isNotEmpty) {
              print('updating local assessment');
              localAssessment = await assessmentRepoLocal.updateLocalAssessment(assessment['data']['id'], assessment['data'], true);
            } else {
              print('creating local assessment');
              localAssessment = await assessmentRepoLocal.createLocalAssessment(assessment['data']['id'], assessment['data'], true);
            }
            if (isNotNull(localAssessment)) {
              print('updating sync key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
              print(item['key']);
              print(updateSync);
              if (isNotNull(updateSync)) {
                syncs.remove(item);
              }
            }
          } else if (isNotNull(assessment['message']) && assessment['message'] == "No such document!") {
            syncs.remove(item);
          }
        }
      } else if (item['collection'] == 'observations') {
        if (item['action'] == 'create') {
          var observation = await observationController.getLiveObservationsById(item['document_id']);
          print('observations');
          print(observation);
          if (isNotNull(observation) && isNotNull(observation['error']) && !observation['error'] && isNotNull(observation['data'])) {
            // print('creating local observation');
            // var localObservation = await observationRepoLocal.create(
            //     observation['data']['id'], observation['data'], true);
            // print('after creating local observation');
            var existingLocalObservation = await observationRepoLocal.getObservationById(observation['data']['id']);
            //Observation already exists in local, needs to be updated
            var localObservation;
            if(isNotNull(existingLocalObservation) && existingLocalObservation.isNotEmpty) {
              print('updating local observation');
              localObservation = await observationRepoLocal.update(observation['data']['id'], observation['data'], true);
            } else {
              print('creating local observation');
              localObservation = await observationRepoLocal.create(observation['data']['id'], observation['data'], true);
            }
            if (isNotNull(localObservation)) {
              print('updating sync key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
              print(item['key']);
              print(updateSync);
              if (isNotNull(updateSync)) {
                syncs.remove(item);
              }
            }
          } else if (isNotNull(observation['message']) && observation['message'] == "No such document!") {
            syncs.remove(item);
          }
        }
      } else if (item['collection'] == 'referrals') {
        if (item['action'] == 'create') {
          var referral = await referralRepo.getReferralById(item['document_id']);
          print('referrals');
          print(referral);
          if (isNotNull(referral) && isNotNull(referral['error']) && !referral['error'] && isNotNull(referral['data'])) {
            // print('creating local referral');
            // var localReferral = await referralRepoLocal.create(
            //     referral['data']['id'], referral['data'], true);
            // print('after creating local observation');
            var existingLocalReferral = await referralRepoLocal.getReferralById(referral['data']['id']);
            //Referral already exists in local, needs to be updated
            var localReferral;
            if(isNotNull(existingLocalReferral) && existingLocalReferral.isNotEmpty) {
              print('updating local referral');
              localReferral = await referralRepoLocal.update(referral['data']['id'], referral['data'], true);
            } else {
              print('creating local referral');
              localReferral = await referralRepoLocal.create(referral['data']['id'], referral['data'], true);
            }

            if (isNotNull(localReferral)) {
              print('updating sync key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
              print(item['key']);
              print(updateSync);
              if (isNotNull(updateSync)) {
                syncs.remove(item);
              }
            }
          } else if (isNotNull(referral['message']) && referral['message'] == "No such document!") {
            syncs.remove(item);
          }
        }
      } else if (item['collection'] == 'care_plans') {
        if (item['action'] == 'create') {
          var careplan = await careplanRepo.getCarePlanById(item['document_id']);
          print('careplan');
          print(careplan);
          if (isNotNull(careplan) && isNotNull(careplan['error']) && !careplan['error'] && isNotNull(careplan['data'])) {
            print('creating local referral');
            // var localCareplan = await careplanRepoLocal.create(
            //     careplan['data']['id'], careplan['data'], true);
            // print('after creating local careplan');
            var existingLocalCareplan = await careplanRepoLocal.getCareplanById(careplan['data']['id']);
            //Careplan already exists in local, needs to be updated
            var localCareplan;
            if(isNotNull(existingLocalCareplan) && existingLocalCareplan.isNotEmpty) {
              print('updating local careplan');
              localCareplan = await careplanRepoLocal.update(careplan['data']['id'], careplan['data'], true);
            } else {
              print('creating local careplan');
              localCareplan = await careplanRepoLocal.create(careplan['data']['id'], careplan['data'], true);
            }

            if (isNotNull(localCareplan)) {
              print('updating sync key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
              print(item['key']);
              print(updateSync);
              if (isNotNull(updateSync)) {
                syncs.remove(item);
              }
            }
          } else if (isNotNull(careplan['message']) && careplan['message'] == "No such document!") {
            syncs.remove(item);
          }
        }
      } else if (item['collection'] == 'health_reports') {
        if (item['action'] == 'create') {
          var healthReport = await healthReportRepo.getHealthReportById(item['document_id']);
          print('healthReports $healthReport');
          if (isNotNull(healthReport) && isNotNull(healthReport['error']) && !healthReport['error'] && isNotNull(healthReport['data'])) {
            // print('creating local healthReport');
            // var localHealthReport = await healthReportRepoLocal.create(healthReport['data']['id'], healthReport['data'], true);
            // print('after creating local healthReport');
            var existingLocalHealthReport = await healthReportRepoLocal.getHealthReportById(healthReport['data']['id']);
            //HealthReport already exists in local, needs to be updated
            var localHealthReport;
            if(isNotNull(existingLocalHealthReport) && existingLocalHealthReport.isNotEmpty) {
              print('updating local healthReport');
              localHealthReport = await healthReportRepoLocal.update(healthReport['data']['id'], healthReport['data'], true);
            } else {
              print('creating local healthReport');
              localHealthReport = await healthReportRepoLocal.create(healthReport['data']['id'], healthReport['data'], true);
            }
            if (isNotNull(localHealthReport)) {
              print('updating sync key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
              print(item['key']);
              print(updateSync);
              if (isNotNull(updateSync)) {
                syncs.remove(item);
              }
            }
          } else if (isNotNull(healthReport['message']) && healthReport['message'] == "No such document!") {
            syncs.remove(item);
          }
        }
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    print('syncing to local complete');
    isSyncingToLocal.value = false;
    getAllStatsData();
  }

  getLocalSyncKey() async {
    var response = await syncRepo.getLocalSyncKey();

    print('local key response');

    var key = '';
    if (isNotNull(response) && response.isNotEmpty) {
      key = response[0]['key'];
    }

    await getLatestSyncInfo(key);
  }

  getLocalAssessments() async {
    var response = await assessmentController.getAllLocalAssessments();
    print('local assessments');
    print(response);
  }

  checkLocationData() async {
    var response = await syncRepo.checkLocalLocationData();
    if (isNotNull(response) && response.isNotEmpty) {
      return;
    }
    syncLocationData();
  }

  syncLocationData() async {
    var response = await PatientController().getLocations();

    if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
      createLocations(response['data']);
    }
  }

  createLocations(data) async {
    var response = await syncRepo.createLocation(data);
    print(response);
  }

  checkCenterData() async {
    var response = await syncRepo.checkLocalCenterData();
    if (isNotNull(response) && response.isNotEmpty) {
      return;
    }
    syncCenterData();
  }
  syncCenterData() async {
    var response = await PatientController().getCenter();

    if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
      createCenters(response['data']);
    }
  }

  createCenters(data) async {
    var response = await syncRepo.createCenter(data);
    print(response);
  }

  getLatestSyncInfo(key) async {
    var data = {};

    if (key != '') {
      data['key'] = key;
    }

    print('sync key ' + key);

    var response = await syncRepo.getLatestSyncInfo(data);
    if (isNotNull(response['exception']) && response['type'] == 'poor_network') {
      isPoorNetwork.value = true;
      isSyncing.value = false;
      // isConnected.value = false;
      // showErrorSnackBar('Error', 'Poor Network. Cannot sync now');
      retryForStableNetwork();
      return;
    } else if (isNotNull(response['exception']) && response['type'] == 'no_network') {
      // isPoorNetwork.value = true;
      isSyncing.value = false;
      isConnected.value = false;
      showErrorSnackBar('Error', 'No Internet. Cannot sync now');
      // retryForStableNetwork();
      return;
    }
    print('getLatestSyncInfo');
    print(response);
    if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
      syncs.value = response['data'];
      print('syncs');
      print(syncs.value);

      // sync from live
      // syncLivePatientsToLocal();
    } else if (isNotNull(response) && isNotNull(response['message']) && response['message'] == 'Unauthorized') {
      isSyncing.value = false;
      showErrorSnackBar('Error', 'Session Expired.');
      return;
    }
    print('syncs.length');
    print(syncs.length);
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

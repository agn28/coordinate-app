import 'dart:convert';

import 'package:get/get.dart';
import 'package:connectivity/connectivity.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'package:nhealth/repositories/patient_repository.dart';
import 'package:nhealth/repositories/sync_repository.dart';

import 'assessment_controller.dart';

var bloodPressures = [];

class SyncController extends GetxController {
  var syncs = [].obs;
  var localNotSyncedPatients = [].obs;
  var livePatientsAll = [].obs;
  var localPatientsAll = [].obs;
  var localAssessments = [].obs;
  var syncRepo = SyncRepository();
  var patientRepoLocal = PatientReposioryLocal();
  var patientRepo = PatientRepository();
  var patientController = PatientController();
  var assessmentController = AssessmentController();

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  create(type, screening_type, comment) async {}

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  createOnlyAssessment(type, screening_type, comment) async {}

  getLocalNotSyncedPatient() async {
    print('into not synce patient info');
    print(localNotSyncedPatients);
    var response = await patientRepoLocal.getNotSyncedPatients();
    var allLocalPatients = await patientController.getAllLocalPatients();
    var allLivePatients = await patientRepo.getPatients();
    

    if (isNotNull(allLivePatients) && isNotNull(allLivePatients['data'])) {
      livePatientsAll.value = allLivePatients['data'];
    }
    
    localPatientsAll.value = allLocalPatients;
    print(localPatientsAll);

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

  checkConnection(result) {
    print('connection status');
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      print('connected');
      getLocalSyncKey();
      checkLocationData();

      syncPatientsToLive();
    } else {
      print('not connected');
    }
  }

  syncPatientsToLive() async {
    print('syncing local patient');
    print(localNotSyncedPatients);
    localNotSyncedPatients.forEach( (patient) async {

      print(localNotSyncedPatients);

      print('local patient');
      print(patient['data']);
      print(patient['meta']);
      var data = {
        'id': patient['id'],
        'body': patient['data'],
        'meta': patient['meta']
      };

      var response = await patientRepo.create(data);
      print('patient create resposne');
      print(response);
      
      if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
        print('patient created');

        if (isNotNull(response['data']['sync']) && isNotNull(response['data']['sync']['key'])) {
          await patientRepoLocal.updateLocalStatus(patient['id'], 1);
          await syncRepo.updateLatestLocalSyncKey(response['data']['sync']['key']);
        }

        // patientRepoLocal.updateLocalStatus(patient['id'], true);
        // syncRepo.updateLatestLocalSyncKey(key);

      } else {
        print('patient not synced');
        print(response);
        if (isNotNull(response) && response['message'] == 'Unauthorized') {
          showWarningSnackBar('Error', 'Session is expired. Login again to sync data');
        }
      }

    });

    getLocalNotSyncedPatient();
  }

  getLocalSyncKey() async {
    var response = await syncRepo.getLocalSyncKey();

    print('local key response');

    var key = '';
    if (isNotNull(response) && response.isNotEmpty) {
      key = response[0]['key'];
    }

    getLatestSyncInfo(key);
  }

  getLocalAssessments() async {
    var response = await assessmentController.getAssessmentsByPatients([]);

    print('local key response');

    var key = '';
    if (isNotNull(response) && response.isNotEmpty) {
      key = response[0]['key'];
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
    var response = await PatientController().getLocations();

    if (isNotNull(response) &&
        isNotNull(response['error']) &&
        !response['error']) {
      createLocations(response['data']);
    }
  }

  createLocations(data) async {
    var response = await syncRepo.createLocation(data);
    print(response);
  }

  getLatestSyncInfo(key) async {
    var data = {};

    if (key != '') {
      data['key'] = key;
    }

    print('sync key ' + key);

    var response = await syncRepo.getLatestSyncInfo(data);
    print('getLatestSyncInfo');
    print(response);
    if (isNotNull(response) &&
        isNotNull(response['error']) &&
        !response['error']) {
      syncs.value = response['data'];
      print('syncs');
      print(syncs.value);
      updateLocalDataFromLive();
    }
    print('syncs.length');
    print(syncs.length);
  }

  updateLocalDataFromLive() async {
    var tempSyncs = syncs.value;

    tempSyncs.forEach((item) async {
      if (item['collection'] == 'patients') {
        if (item['action'] == 'create') {
          var patient =
              await PatientController().getPatient(item['document_id']);
          print('patient');
          print(patient);
          if (isNotNull(patient) &&
              isNotNull(patient['error']) &&
              !patient['error'] &&
              isNotNull(patient['data'])) {
            print('creating local patient');
            var localPatient = await PatientReposioryLocal()
                .createFromLive(patient['data']['id'], patient['data']);
            print('after creating local patient');

            if (isNotNull(localPatient)) {
              print('updating synnc key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
              print(item['key']);
              print(updateSync);
              if (isNotNull(updateSync)) {
                print(syncs.value.length);
                syncs.removeAt(tempSyncs.indexOf(item));
                print('removing sync');
                print(syncs.value.length);
              }
            }
          }
        }
      }
    });
  }

  updateLocalSyncKey(key) async {
    var response = await syncRepo.getLocalSyncKey();

    var oldKey = '';
    if (isNotNull(response) && response.isNotEmpty) {
      oldKey = response[0]['key'];
    }
    return await syncRepo.updateLocalSyncKey(key, oldKey);
  }
}

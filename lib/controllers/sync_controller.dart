import 'dart:convert';

import 'package:get/get.dart';
import 'package:connectivity/connectivity.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'package:nhealth/repositories/sync_repository.dart';

var bloodPressures = [];

class SyncController extends GetxController{
  var syncs = [].obs;
  var localPatients = [].obs;
  var syncRepo = SyncRepository();
  var patientRepoLocal = PatientReposioryLocal();

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  create(type, screening_type, comment) async {

    
  }

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  createOnlyAssessment(type, screening_type, comment) async {

  }

  getLocalNotSyncedPatient() async {
    var response = await patientRepoLocal.getNotSyncedPatients();

    if (isNotNull(response)) {
      response.forEach((patient) {
        var parsedData = jsonDecode(patient['data']);
        localPatients.add({
          'uuid': patient['uuid'],
          'data': parsedData['body'],
          'meta': parsedData['meta']
        });
      });
    }
  }

  checkConnection(result) {
    print('connection status');
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      print('connected');
      getLocalSyncKey();
      checkLocationData();
    } else {
      print('not connected');
    }
  }

  getLocalSyncKey() async {
    var response = await syncRepo.getLocalSyncKey();

    print('local key response');
    print(response);

    var key = '';
    if (isNotNull(response) && response.isNotEmpty) {
      key = response[0]['key'];
    }

    getLatestSyncInfo(key);
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

  getLatestSyncInfo(key) async {
    var data = {};

    if (key != '') {
      data['key'] = key;
    }

    var response = await syncRepo.getLatestSyncInfo(data);
    print('getLatestSyncInfo');
    if (isNotNull(response) && isNotNull(response['error']) && !response['error']) {
      syncs.value = response['data'];
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
          var patient = await PatientController().getPatient(item['document_id']);
          print('patient');
          print(patient);
          if (isNotNull(patient) && isNotNull(patient['error']) && !patient['error'] && isNotNull(patient['data'])) {
            print('creating local patient');
            var localPatient = await PatientReposioryLocal().createFromLive(patient['data']['id'], patient['data']);
            print('after creating local patient');

            if (isNotNull(localPatient)) {
              print('updating synnc key');
              var updateSync = await updateLocalSyncKey(item['key']);
              print('after updating sync key');
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

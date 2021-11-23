import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import 'package:nhealth/services/api_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:uuid/uuid.dart';
import '../constants/constants.dart';
import 'dart:convert';

import 'local/database_creator.dart';

class SyncRepository {
  http.Client client = HttpClientWithInterceptor.build(interceptors: [
    ApiInterceptor(),
  ]);
  login(email, password) async {

  }

  create(data) async {
    var authData = await Auth().getStorageAuth();
    var token = authData['accessToken'];
    var api = ApiService();

    var response;

    try {
      response = await client
      .post(apiUrl + 'syncs/patient',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
          },
          body: json.encode(data))
      .timeout(Duration(seconds: httpRequestTimeout));

      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);

      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  getLatestSyncInfo(data) async {  
    var authData = await Auth().getStorageAuth() ;
    var token = authData['accessToken'];
    var  api = ApiService();


    var response;

    try {
      response =  await http.post(
        apiUrl + 'syncs/verify',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
        body: json.encode(data)
      ).timeout(Duration(seconds: 120));

      return json.decode(response.body);
      
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      return {
        'exception': true,
        'type': 'no_internet',
        'message': 'No internet'
      };
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      return {
        'exception': true,
        'type': 'poor_network',
        'message': 'Slow internet'
      };
    } on Error catch(err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  fetchLatestSyncs() async {  
    var authData = await Auth().getStorageAuth() ;

    var response;

    try {
      response =  await http.get(
        apiUrl + 'syncs/fetch/'+authData['deviceId'],
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + authData['accessToken']
        },
      ).timeout(Duration(seconds: 300));
      return json.decode(response.body);
    } on SocketException {
      return {
        'exception': true,
        'type': 'no_internet',
        'message': 'No internet'
      };
    } on TimeoutException {
      return {
        'exception': true,
        'type': 'poor_network',
        'message': 'Slow internet'
      };
    } on Error catch(err) {
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  checkLocalLocationData() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.locationTable}''';
    var response;
    try {
      response = await db.rawQuery(sql);
    } on DatabaseException catch (error) {

    }
    return response;
  }

  checkLocalCenterData() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.centerTable}''';
    var response;
    try {
      response = await db.rawQuery(sql);
    } on DatabaseException catch (error) {

    }
    return response;
  }

  getLocalSyncKey() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.syncTable}''';
    var response;
    try {
      response = await db.rawQuery(sql);
    } on DatabaseException catch (error) {

    }
    return response;
  }

  updateLatestLocalSyncKey(key) async {
    final updateSql = '''UPDATE ${DatabaseCreator.syncTable}
    SET key = ?''';
    List<dynamic> params = [key];
    var updateResponse;

    try {
      updateResponse = await db.rawUpdate(updateSql, params);

    } catch (error) {

      return;
    }
    return updateResponse;
  }
  
  getTempSyncs(collection, size) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.latestSyncTable} WHERE is_synced=0 AND collection="$collection" LIMIT $size''';
    try {
      return await db.rawQuery(sql);
    } on DatabaseException catch (error) {
      return;
    }
  }

  getTempSyncsCount() async {
    final sql = '''SELECT count(*) FROM ${DatabaseCreator.latestSyncTable} WHERE is_synced=0''';
    try {
      return await db.rawQuery(sql);
    } on DatabaseException catch (error) {
      return;
    }
  }

  checkTempSyncsCount() async {
    final sql = '''SELECT COUNT(*) FROM ${DatabaseCreator.latestSyncTable} WHERE is_synced=0''';
    try {
      return Sqflite.firstIntValue(await db.rawQuery(sql));
    } on DatabaseException catch (error) {
      return 0;
    }
  }

  updateDeviceIds(ids) async {
    var authData = await Auth().getStorageAuth();

    var response;

    try {
      response = await client
      .post(apiUrl + 'syncs/update',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + authData['accessToken']
          },
          body: json.encode({
            "ids": ids,
            "deviceId": authData['deviceId']
          }))
      .timeout(Duration(seconds: httpRequestTimeout));

      return json.decode(response.body);
    } on SocketException {
      showErrorSnackBar('Error', 'socketError');
      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      showErrorSnackBar('Error', 'timeoutError');
      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {
      showErrorSnackBar('Error', 'unknownError');
      return {
        'exception': true,
        'type': 'unknown',
        'message': 'Something went wrong'
      };
    }
  }

  createTempSyncs(tempSyncs) async {
    var batchSize = 0;
    var syncIds = [];
    Batch batch = db.batch();
    final sql = '''INSERT OR REPLACE INTO ${DatabaseCreator.latestSyncTable}
    (id, document_id, collection, action, key, created_at, is_synced)
    VALUES (?, ?, ?, ?, ?, ?, ?)''';
    for (var item in tempSyncs) {
      if (batchSize == 1000) { 
        try {
          await batch.commit(noResult: true);
        } catch (error) {
          //TODO: create log here
          print('error $error');
        } finally {
          //TODO: insert ids in an array and send req to API to update device_ids
          print('final $syncIds');
          await updateDeviceIds(syncIds);
          syncIds = [];
          batchSize = 0;
        }
        print('batch inserted');
      } else {
        // try {
          if(isNotNull(item['id']) && isNotNull(item['document_id']) && isNotNull(item['collection_name'])) {
            syncIds.add(item['id']);
            List<dynamic> params = [item['id'], item['document_id'], item['collection_name'], item['action'], item['key'], item['created_at'], 0];
            await batch.rawInsert(sql, params);
            batchSize++;
          }
        // } 
        // catch (error) {
        //   //TODO: create log here
        //   print('error $error');
        // } finally {
        //   //TODO: insert ids in an array and send req to API to update device_ids
        //   print('final');
        // }
      }
    }
    if (batchSize > 0) { 
      try {
        await batch.commit(noResult: true);
      } catch (error) {
        //TODO: create log here
        print('error $error');
      } finally {
        print('final $syncIds');
        await updateDeviceIds(syncIds);
        syncIds = [];
      }
      print('batch inserted');
    }
  }

  deleteTempSyncs(id) async {
    try {  
      return await db.rawDelete('DELETE FROM ${DatabaseCreator.latestSyncTable} WHERE id = ?', [id]);
    } on DatabaseException catch (error) {

      return;
    }
  }
  updateSyncStatus(documentIds, isSynced) async {
    var ids = documentIds.map((item){
      if(item != null) {
        return "'" + item + "'";
      }
    }).join(",");
    final sql = '''UPDATE ${DatabaseCreator.latestSyncTable} SET is_synced = ? WHERE document_id IN (${ids})''';
    
    List<dynamic> params = [isSynced];
    var response;
    try {
      response = await db.rawUpdate(sql, params);
      return response;
    } catch(error) {
      return;
    }
  }
  clearTempSyncs() async {
    await db.transaction((txn) async {
      final batch = txn.batch();
      try {
      await batch.rawDelete('DELETE FROM ${DatabaseCreator.latestSyncTable}');
      } on DatabaseException catch (error) {
        print('error $error');
      } finally {
        print('${DatabaseCreator.latestSyncTable} cleared');
      }
      await batch.commit();
    });
  }

  updateLocalSyncKey(newKey, oldKey) async {

    if (oldKey != '') {
      final updateSql = '''UPDATE ${DatabaseCreator.syncTable}
      SET key = ?
      WHERE key = ?''';
      List<dynamic> params = [newKey, oldKey];
      var updateResponse;

      try {
        updateResponse = await db.rawUpdate(updateSql, params);

      } catch (error) {
        return;
      }
      return updateResponse;
    }

    String id = Uuid().v4();
    final createSql = '''INSERT INTO ${DatabaseCreator.syncTable}
    (
      id,
      key
    )
    VALUES (?,?)''';
    List<dynamic> params = [id, newKey];
    var createResponse;
    try {
      createResponse = await db.rawInsert(createSql, params);
    } catch(error) {
      return;
    }
    DatabaseCreator.databaseLog('Create sync key', createSql, null, createResponse, params);
    return createResponse;
  }

  createLocation(data) async {
    String id = Uuid().v4();
    final sql = '''INSERT INTO ${DatabaseCreator.locationTable}
    (
      id,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [id, jsonEncode(data), ''];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add locations', sql, null, result, params);

  }

  createCenter(data) async {
    String id = Uuid().v4();
    final sql = '''INSERT INTO ${DatabaseCreator.centerTable}
    (
      id,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [id, jsonEncode(data), ''];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add centers', sql, null, result, params);

  }

  emptyDatabase() async {
    final patient = await db.rawQuery('''DELETE FROM ${DatabaseCreator.patientTable}''');
    final syncs = await db.rawQuery('''DELETE FROM ${DatabaseCreator.syncTable}''');
    final assessments = await db.rawQuery('''DELETE FROM ${DatabaseCreator.assessmentTable}''');
    final observations = await db.rawQuery('''DELETE FROM ${DatabaseCreator.observationTable}''');
    final referrals = await db.rawQuery('''DELETE FROM ${DatabaseCreator.referralTable}''');
    final care_plans = await db.rawQuery('''DELETE FROM ${DatabaseCreator.careplanTable}''');
    final health_reports = await db.rawQuery('''DELETE FROM ${DatabaseCreator.healthReportTable}''');
  }
}

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/api_interceptor.dart';
import 'package:nhealth/services/api_service.dart';
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

    print('data ${json.encode(data)}');

    var response;

    print(apiUrl + 'syncs/patient');

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

      print(response.body);
      return json.decode(response.body);
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      print('socket exception');
      return {'exception': true, 'message': 'No internet'};
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      print('timeout error');
      return {'exception': true, 'type': 'poor_network', 'message': 'Slow internet'};
    } on Error catch (err) {
      print('test error');
      print(err);
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
    print('getLatestSyncInfo Data');
    print(data);

    var response;

    print(apiUrl + 'syncs/verify');

    try {
      response =  await client.post(
        apiUrl + 'syncs/verify',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
        body: json.encode(data)
      ).timeout(Duration(seconds: httpRequestTimeout));

      print(response.body);
      return json.decode(response.body);
      
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      print('socket exception');
      return {
        'exception': true,
        'type': 'no_internet',
        'message': 'No internet'
      };
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      print('timeout error');
      return {
        'exception': true,
        'type': 'poor_network',
        'message': 'Slow internet'
      };
    } on Error catch(err) {
      print('test error');
      print(err);
      // showErrorSnackBar('Error', 'unknownError'.tr);
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
      print('error');
      print(error);
    }
    return response;
  }

  checkLocalCenterData() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.centerTable}''';
    var response;
    try {
      response = await db.rawQuery(sql);
    } on DatabaseException catch (error) {
      print('error');
      print(error);
    }
    return response;
  }

  getLocalSyncKey() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.syncTable}''';
    var response;
    try {
      response = await db.rawQuery(sql);
      print('sync response $response');
    } on DatabaseException catch (error) {
      print('error');
      print(error);
    }
    return response;
  }

  updateLatestLocalSyncKey(key) async {
    print('into update sync key');
    final updateSql = '''UPDATE ${DatabaseCreator.syncTable}
    SET key = ?''';
    List<dynamic> params = [key];
    var updateResponse;

    try {
      updateResponse = await db.rawUpdate(updateSql, params);
      print('update sync response');
      print(updateResponse);
    } catch (error) {
      print('error');
      print(error);
      return;
    }
    return updateResponse;
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
        print('error');
        print(error);
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
    print('patient table deleted: ' + patient.toString());
    print('sync table deleted: ' + syncs.toString());
    print('assessments table deleted: ' + assessments.toString());
    print('observations table deleted: ' + observations.toString());
    print('referrals table deleted: ' + referrals.toString());
    print('care_plans table deleted: ' + care_plans.toString());
    print('health_reports table deleted: ' + health_reports.toString());

  }
}

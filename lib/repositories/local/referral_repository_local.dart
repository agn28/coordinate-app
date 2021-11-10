import 'dart:convert';

import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:sqflite/sqflite.dart';

class ReferralRepositoryLocal {
  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(id, data, isSynced, {localStatus:''}) async {
    
    final sql = '''INSERT INTO ${DatabaseCreator.referralTable}
    (
      id,
      data,
      patient_id,
      status,
      is_synced,
      local_status
    )
    VALUES (?,?,?,?,?,?)''';
    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['meta']['patient_id'],
      '',
      isSynced, 
      localStatus
    ];
    var response;

    try {
      response = await db.rawInsert(sql, params);

    } catch (error) {

    }
    return response;
  }

  syncFromLive(tempSyncs, isSynced, {localStatus:''}) async {
    Batch batch = db.batch();
    final sql = '''INSERT OR REPLACE INTO ${DatabaseCreator.referralTable}
    (
      id,
      data,
      patient_id,
      status,
      is_synced,
      local_status
    )
    VALUES (?,?,?,?,?,?)''';
    for (var item in tempSyncs) {
      List<dynamic> params = [item['id'], jsonEncode(item), item['meta']['patient_id'], '', isSynced, localStatus];
      await batch.rawInsert(sql, params);
      print('rawInsert');
    }
    try {
      await batch.commit(noResult: true);
      print('commit');
    } catch (error) {
      //TODO: create log here
      print('error $error');
    } finally {
      print('subReferrals batch inserted');
    }
  }

  update(id, data, isSynced, {localStatus:''}) async {
    final sql = '''UPDATE ${DatabaseCreator.referralTable} SET
      data = ? , 
      patient_id = ?,
      status = ?,
      is_synced = ?,
      local_status = ?
      WHERE id = ?''';
    List<dynamic> params = [jsonEncode(data), data['meta']['patient_id'],
      data['meta']['status'], isSynced, localStatus, id];

    var response;

    try {
      response = await db.rawUpdate(sql, params);
    } catch(error) {

    }
    DatabaseCreator.databaseLog('Update referral', sql, null, response, params);
    return response;
    
  }

  getAllReferrals() async {
    final sqlObservations =
        '''SELECT * FROM ${DatabaseCreator.referralTable}''';
    final observations = await db.rawQuery(sqlObservations);

    return observations;
  }

  getNotSyncedReferrals() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.referralTable} WHERE (is_synced=0) AND (local_status!='incomplete')''';
    var response = await db.rawQuery(sql);

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

      return;
    }

    return response;
  }

  getReferralsByPatient(patientId) async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.referralTable} WHERE patient_id="$patientId"''';
    var response;

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

      return;
    }
    return response;
  }

  getReferralById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.referralTable} WHERE id = "$id"''';
    var referral;

    try {
      referral = await db.rawQuery(sql);

    } catch (error) {

      return;
    }
    return referral;
  }

  Future<void> updateLocalStatus(uuid, isSynced) async {


    final sql = '''UPDATE ${DatabaseCreator.referralTable} SET
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [isSynced, uuid];
    var response;

    try {
      response = await db.rawUpdate(sql, params);

    } catch (error) {

      return;
    }
    return response;
  }
}

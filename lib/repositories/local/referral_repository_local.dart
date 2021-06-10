import 'dart:convert';

import 'package:nhealth/repositories/local/database_creator.dart';

class ReferralRepositoryLocal {
  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(id, data, isSynced) async {
    print('into local referral create');

    final sql = '''INSERT INTO ${DatabaseCreator.referralTable}
    (
      id,
      data,
      patient_id,
      status,
      is_synced
    )
    VALUES (?,?,?,?,?)''';
    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['meta']['patient_id'],
      '',
      isSynced
    ];
    var response;

    try {
      response = await db.rawInsert(sql, params);
      print(response);
    } catch (error) {
      print('local referral create error');
      print(error);
    }
    return response;
  }

  update(id, data, isSynced) async {
    print('into local referral update');
    final sql = '''UPDATE ${DatabaseCreator.referralTable} SET
      data = ? , 
      patient_id = ?,
      status = ?,
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [jsonEncode(data), data['meta']['patient_id'],
      data['meta']['status'], isSynced, id];
    print('sql $sql');
    var response;

    try {
      response = await db.rawUpdate(sql, params);
      print(response);
    } catch(error) {
      print('local referral update error');
      print(error);
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
        '''SELECT * FROM ${DatabaseCreator.referralTable} WHERE is_synced=0''';
    var response = await db.rawQuery(sql);

    try {
      response = await db.rawQuery(sql);
    } catch (error) {
      print('error');
      print(error);
      return;
    }

    return response;
  }

  getReferralsByPatient(patientId) async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.referralTable} WHERE patient_id="$patientId"''';
    var response = await db.rawQuery(sql);

    try {
      response = await db.rawQuery(sql);
    } catch (error) {
      print('error');
      print(error);
      return;
    }

    return response;
  }

  getReferralById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.referralTable} WHERE id = "$id"''';
    var referral;

    try {
      referral = await db.rawQuery(sql);
      print('referralbyId $referral');
    } catch (error) {
      print('error');
      print(error);
      return;
    }
    return referral;
  }

  Future<void> updateLocalStatus(uuid, isSynced) async {
    print('into updating referral status');
    print('uuid ' + uuid);

    final sql = '''UPDATE ${DatabaseCreator.referralTable} SET
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [isSynced, uuid];
    var response;

    try {
      response = await db.rawUpdate(sql, params);
      print('update local response');
      print(response);
    } catch (error) {
      print('error');
      print(error);
      return;
    }
    return response;
  }
}

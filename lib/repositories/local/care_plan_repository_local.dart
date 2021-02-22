import 'dart:convert';

import 'package:nhealth/repositories/local/database_creator.dart';

class CarePlanRepositoryLocal {
  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(id, data, isSynced) async {
    print('into local careplan create');

    final sql = '''INSERT INTO ${DatabaseCreator.careplanTable}
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
      data['body']['patient_id'],
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

  getAllCareplans() async {
    final sqlCareplans = '''SELECT * FROM ${DatabaseCreator.careplanTable}''';
    final careplans = await db.rawQuery(sqlCareplans);

    return careplans;
  }

  getNotSyncedObservations() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.observationTable} WHERE is_synced=0''';
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

  Future<void> updateLocalStatus(uuid, isSynced) async {
    print('into updating observation status');
    print('uuid ' + uuid);

    final sql = '''UPDATE ${DatabaseCreator.observationTable} SET
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

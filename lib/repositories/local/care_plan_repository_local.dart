import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nhealth/models/patient.dart';
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
      print('local careplan create error');
      print(error);
    }
    return response;
  }

  update(id, data, isSynced) async {
    final sql = '''UPDATE ${DatabaseCreator.careplanTable} SET
      data = ? , 
      patient_id = ?,
      status = ?,
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['body']['patient_id'],
      'completed',
      isSynced
    ];
    var response;
    try {
      response = await db.rawUpdate(sql, params);
      print('sql $response');
    } catch (error) {
      print('local careplan update error');
      print(error);
    }
    DatabaseCreator.databaseLog('Update careplan', sql, null, response, params);
    return response;
  }

  completeLocalCarePlan(id, data, comment, isSynced) async {
    print(data['meta']);
    data['body']['comment'] = comment;
    data['meta']['status'] = 'completed';
    data['meta']['completed_at'] = DateFormat('y-MM-d').format(DateTime.now());
    final sql = '''UPDATE ${DatabaseCreator.careplanTable} SET
      data = ? , 
      patient_id = ?,
      status = ?,
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [
      jsonEncode(data),
      data['body']['patient_id'],
      'completed',
      isSynced,
      id
    ];
    var response;
    try {
      response = await db.rawUpdate(sql, params);
      print('sql $response');
    } catch (error) {
      print('local careplan update error');
      print(error);
    }
    DatabaseCreator.databaseLog('Update careplan', sql, null, response, params);
    return response;
  }

  getAllCareplans() async {
    final sqlCareplans = '''SELECT * FROM ${DatabaseCreator.careplanTable}''';
    final careplans = await db.rawQuery(sqlCareplans);

    return careplans;
  }
  getCareplanByPatient() async {
    var patientId = Patient().getPatient()['id'];
    final sqlCareplans = '''SELECT * FROM ${DatabaseCreator.careplanTable} WHERE patient_id="$patientId"''';
    final careplans = await db.rawQuery(sqlCareplans);

    return careplans;
  }

  getNotSyncedCareplans() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.careplanTable} WHERE is_synced=0''';
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

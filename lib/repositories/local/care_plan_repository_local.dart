import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/database_creator.dart';

class CarePlanRepositoryLocal {
  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(id, data, isSynced) async {

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

    } catch (error) {

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
      data['meta']['status'],
      isSynced
    ];
    try {
      return await db.rawUpdate(sql, params);
    } catch (error) {

      return;
    }
  }

  completeLocalCarePlan(id, data, comment, isSynced) async {

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

    } catch (error) {

    }
    DatabaseCreator.databaseLog('Update careplan', sql, null, response, params);
    return response;
  }

  getAllCareplans() async {
    final sqlCareplans = '''SELECT * FROM ${DatabaseCreator.careplanTable}''';
    final careplans = await db.rawQuery(sqlCareplans);

    return careplans;
  }
  getCareplanByPatient(patientId) async {
    final sqlCareplans = '''SELECT * FROM ${DatabaseCreator.careplanTable} WHERE patient_id="$patientId"''';
    final careplans = await db.rawQuery(sqlCareplans);

    return careplans;
  }

  getCareplanById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.careplanTable} WHERE id = "$id"''';
    var careplan;

    try {
      careplan = await db.rawQuery(sql);

    } catch (error) {

      return;
    }
    return careplan;
  }

  getNotSyncedCareplans() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.careplanTable} WHERE is_synced=0''';
    var response = await db.rawQuery(sql);

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

      return;
    }

    return response;
  }

  Future<void> updateLocalStatus(uuid, isSynced) async {


    final sql = '''UPDATE ${DatabaseCreator.observationTable} SET
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

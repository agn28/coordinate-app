import 'dart:convert';

import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:sqflite/sqflite.dart';

class HealthReportRepositoryLocal {
  create(id, data, isSynced) async {

    final sql = '''INSERT INTO ${DatabaseCreator.healthReportTable}
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

  syncFromLive(tempSyncs, isSynced) async {
    Batch batch = db.batch();
    final sql = '''INSERT OR REPLACE INTO ${DatabaseCreator.healthReportTable}
    (
      id,
      data,
      patient_id,
      status,
      is_synced
    )
    VALUES (?,?,?,?,?)''';
    for (var item in tempSyncs) {
      List<dynamic> params = [item['id'], jsonEncode(item), item['body']['patient_id'], '', isSynced];
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
      print('subHealthReports batch inserted');
    }
  }

  update(id, data, isSynced) async {
    final sql = '''UPDATE ${DatabaseCreator.healthReportTable} SET
      data = ? , 
      patient_id = ?,
      status = ?,
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['body']['patient_id'],
      '',
      isSynced
    ];
    var response;
    try {
      response = await db.rawUpdate(sql, params);

    } catch (error) {

    }
    DatabaseCreator.databaseLog('Update health report', sql, null, response, params);
    return response;
  }

  getAllHealthReports() async {
    final sqlHealthReports = '''SELECT * FROM ${DatabaseCreator.healthReportTable}''';
    final healthReports = await db.rawQuery(sqlHealthReports);

    return healthReports;
  }

  getHealthReportByPatient() async {
    var patientId = Patient().getPatient()['id'];
    final sqlHealthReports = '''SELECT * FROM ${DatabaseCreator.healthReportTable} WHERE patient_id="$patientId"''';
    final healthReports = await db.rawQuery(sqlHealthReports);

    return healthReports;
  }

  getHealthReportById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.healthReportTable} WHERE id = "$id"''';
    var healthReport;

    try {
      healthReport = await db.rawQuery(sql);

    } catch (error) {

      return;
    }
    return healthReport;
  }

  getLastReport(patientId) async {
    final sqlHealthReports = '''SELECT * FROM ${DatabaseCreator.healthReportTable} WHERE patient_id="$patientId" ORDER BY created_at DESC LIMIT 1''';
    var healthReport;
    try{
      healthReport = await db.rawQuery(sqlHealthReports);
    } catch(error){
      return;
    }
    return healthReport;
  }

  getNotSyncedHealthReports() async {
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

}

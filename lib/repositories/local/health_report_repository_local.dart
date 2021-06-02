import 'dart:convert';

import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/database_creator.dart';

class HealthReportRepositoryLocal {
  create(id, data, isSynced) async {
    print('into local healthreport create');

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
      print(response);
    } catch (error) {
      print('local health report create error');
      print(error);
    }
    return response;
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
      'completed',
      isSynced
    ];
    var response;
    try {
      response = await db.rawUpdate(sql, params);
      print('sql $response');
    } catch (error) {
      print('local health report update error');
      print(error);
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

  getLastReport(patientId) async {
    final sqlHealthReports = '''SELECT * FROM ${DatabaseCreator.healthReportTable} WHERE patient_id="$patientId" ORDER BY created_atx DESC LIMIT 1''';
    final healthReport = await db.rawQuery(sqlHealthReports);

    return healthReport;
  }

}

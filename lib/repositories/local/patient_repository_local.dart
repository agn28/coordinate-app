import 'dart:convert';

import 'package:nhealth/models/patient.dart';

import './database_creator.dart';
import 'package:uuid/uuid.dart';

class PatientReposioryLocal {

  /// Get all patietns
  getAllPatients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable}''';
    final data = await db.rawQuery(sql);
    
    return data;
  }

  /// Create a patient.
  /// Patient [data] is required as parameter.
  Future<void> create(data) async {
    var uuid = Uuid().v4();

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      uuid,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [uuid, jsonEncode(data), 'not synced'];
    final result = await db.rawInsert(sql, params);

    var patient = {
      'uuid': uuid,
      'data': data['body'],
      'meta': data['meta']
    };

    await Patient().setPatient(patient);
    DatabaseCreator.databaseLog('Add patient', sql, null, result, params);
  }

  Future<void> update(data) async {
    var uuid = Patient().getPatient()['uuid'];

    final sql = '''UPDATE ${DatabaseCreator.patientTable} SET
      data = ?
      WHERE uuid = ?''';
    List<dynamic> params = [jsonEncode(data), uuid];
    final result = await db.rawUpdate(sql, params);

    var patient = {
      'uuid': uuid,
      'data': data['body'],
      'meta': data['meta']
    };

    await Patient().setPatient(patient);
    DatabaseCreator.databaseLog('Update patient', sql, null, result, params);
  }

}

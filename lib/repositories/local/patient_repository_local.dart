import 'dart:convert';

import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/patient_repository.dart';

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
  create(data, synced) async {
    var uuid = Uuid().v4();

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      uuid,
      data,
      status,
      synced
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [uuid, jsonEncode(data), 'not synced', synced];
    final result = await db.rawInsert(sql, params);

    var patient = {
      'uuid': uuid,
      'data': data['body'],
      'meta': data['meta']
    };

    data['id'] = uuid;

    print('live patient create');

    // var response = await PatientRepository().create(data);

    await Patient().setPatient(patient);
    DatabaseCreator.databaseLog('Add patient', sql, null, result, params);
    return result;
  }

  Future<void> update(data) async {
    var uuid = Patient().getPatient()['uuid'];

    // final sql = '''UPDATE ${DatabaseCreator.patientTable} SET
    //   data = ?
    //   WHERE uuid = ?''';
    // List<dynamic> params = [jsonEncode(data), uuid];
    // final result = await db.rawUpdate(sql, params);

    var patient = {
      'uuid': uuid,
      'data': data['body'],
      'meta': data['meta']
    };

    // data['id'] = uuid;

    PatientRepository().update(data);

    await Patient().setPatient(patient);
  }

}

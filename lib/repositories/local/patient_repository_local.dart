import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/patient_repository.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:sqflite/sqflite.dart';
import './database_creator.dart';
import 'package:uuid/uuid.dart';
import '../../app_localizations.dart';

class PatientReposioryLocal {
  /// Get all patietns
  getAllPatients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable}''';
    final data = await db.rawQuery(sql);

    return data;
  }

  getNewPatients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable}''';
    final data = await db.rawQuery(sql);

    return data;
  }

  getNotSyncedPatients() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE is_synced=0''';
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

  getReferralPatients() async {
    final referralSql = '''SELECT * FROM ${DatabaseCreator.referralTable}''';

    var referrals;
    var patients;

    try {
      referrals = await db.rawQuery(referralSql);
    } catch (error) {
      print('error');
      print(error);
      return;
    }

    if (isNotNull(referrals) && referrals.isNotEmpty) {
      var patientIds = referrals.map((item) => '"${item['patient_id']}"').toList();

      final patientSql = '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE id IN (${patientIds.join(', ')})''';
      print(patientSql);

      try {
        patients = await db.rawQuery(patientSql);
      } catch (error) {
        print('error');
        print(error);
        return;
      }

      if (isNotNull(patients) && patients.isNotEmpty) {
        var responseData = [];
        var tempPatients = patients;

        for(var patient in patients) {
          print(patients.indexOf(patient));
          print(patient);
          print('patient loop');
          var matchedReferral = referrals.where((ref) => ref['patient_id'] == patient['id']).first;
          var copyPatient = new Map.from(patient);
          var parsedPatientData = jsonDecode(copyPatient['data']);
          var patientData = {
            'id': copyPatient['id'],
            'body': parsedPatientData['body'],
            'meta': parsedPatientData['meta']
          };
          var parsedData = json.decode(matchedReferral['data']);
          patientData['body']['pending_referral'] = {
            'id': matchedReferral['id'],
            'body': parsedData['body'],
            'meta': parsedData['meta']
          };
          responseData.add(patientData);
        }
        // tempPatients.forEach((patient, index) {
        //   var matchedReferral = referrals.where((ref) => ref['patient_id'] == patient['id']).first;
        //   var data = patients[index];
        //   var parsedData = json.decode(matchedReferral['data']);
        //   data['pending_referral'] = {
        //     'id': matchedReferral['id'],
        //     'body': parsedData['body'],
        //     'meta': parsedData['meta']
        //   };
        //   responseData.add(data);
        // });

        print('response data');
        print(responseData);

        return {
          'data': responseData
        };
      } 


    }

    return [];
  }

  /// Create a patient.
  /// Patient [data] is required as parameter.
  create(context, id, data, synced) async {

    var allPatients = await getAllPatients();
    print(allPatients);

    if (!synced) {
      print('not synced');
      print(data);
      final sql =
          '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE nid="${data['body']['nid']}"''';
      var existingPatient;

      try {
        existingPatient = await db.rawQuery(sql);
        print('existingPatient');
        print(existingPatient);
        print(sql);
      } catch (err) {
        print(err);
        return;
      }

      print(existingPatient);

      if (isNotNull(existingPatient) && existingPatient.isNotEmpty) {
        // await delete(existingPatient[0]['id']);
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Error: ${AppLocalizations.of(context).translate('nidValidation')}"),
          backgroundColor: kPrimaryRedColor,
        ));
        return;
      }
    }

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      id,
      data,
      nid,
      status,
      is_synced
    )
    VALUES (?,?,?,?,?)''';
    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['body']['nid'],
      '',
      synced
    ];
    var response;

    try {
      response = await db.rawInsert(sql, params);
    } catch (err) {
      print(err);

      return;
    }

    if (isNull(response)) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
        backgroundColor: kPrimaryRedColor,
      ));
      return;
    }

    print('result 1');
    print(response);
    var patient = {'id': id, 'data': data['body'], 'meta': data['meta']};

    data['id'] = id;
    print('result 2');
    await Patient().setPatient(patient);
    print('result 3');
    print(response);
    // DatabaseCreator.databaseLog('Add patient', sql, null, response, params);
    return 'success';
  }

  createFromLive(id, data) async {
    var allPatients = await getAllPatients();
    print(allPatients);

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      id,
      data,
      nid,
      status,
      is_synced
    )
    VALUES (?,?,?,?,?)''';
    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['body']['nid'],
      '',
      true
    ];
    var response;

    try {
      response = await db.rawInsert(sql, params);
    } on DatabaseException catch(error) {
      print('error');
      print(error);
      error.isUniqueConstraintError();
      if (error.isUniqueConstraintError()) {
        return {
          'exception': true,
          'type': 'uniqueConstraint'
        };
      }
      return;
    }

    return response;
  }

  Future<void> update(data) async {
    var uuid = Patient().getPatient()['id'];

    // final sql = '''UPDATE ${DatabaseCreator.patientTable} SET
    //   data = ?
    //   WHERE uuid = ?''';
    // List<dynamic> params = [jsonEncode(data), uuid];
    // final result = await db.rawUpdate(sql, params);

    var patient = {'id': uuid, 'data': data['body'], 'meta': data['meta']};

    // data['id'] = uuid;

    PatientRepository().update(data);

    await Patient().setPatient(patient);
  }

  Future<void> updateLocalStatus(uuid, isSynced) async {
    print('into updating patient status');
    print('uuid ' + uuid);

    final sql = '''UPDATE ${DatabaseCreator.patientTable} SET
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [isSynced, uuid];
    var response;

    try {
      response = await db.rawUpdate(sql, params);
      print('update local response');
      print(response);
    } catch(error) {
      print('error');
      print(error);
      return;
    }
    return response;

  }

  delete(id) async {
    var response;

    try {
      response = await db.rawQuery(
          'DELETE FROM ${DatabaseCreator.patientTable} WHERE uuid = ?', [id]);
    } catch (err) {
      print(err);
      return;
    }

    print(response);
    return response;
  }

  getLocations() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.locationTable}''';
    var response;

    try {
      response = await db.rawQuery(sql);
    } catch (error) {
      print('error');
      print(error);
      return;
    }

    return response;
  }
}

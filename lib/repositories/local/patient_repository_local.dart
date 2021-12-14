import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';

import 'package:intl/intl.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'package:nhealth/repositories/patient_repository.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:sqflite/sqflite.dart';

import '../assessment_repository.dart';
import './database_creator.dart';
import 'package:uuid/uuid.dart';
import '../../app_localizations.dart';

class PatientReposioryLocal {
  /// Get all patietns
  getAllPatients() async {
    try {
      return await db.rawQuery('''SELECT * FROM ${DatabaseCreator.patientTable}''');
    } catch (error) {

      return;
    }
  }
  
  getPatientsWithAssesments() async {
    var authData = await Auth().getStorageAuth();
    try {
      return await db.rawQuery('''SELECT p.*, a.id as assessment_id, a.type as assessment_type, a.screening_type as assessment_screening_type, a.status as assessment_status, a.local_status as assessment_local_status, a.created_at as assessment_created_at FROM ${DatabaseCreator.patientTable} AS p 
      INNER JOIN (SELECT * FROM ${DatabaseCreator.assessmentTable} ORDER BY datetime(created_at) DESC) as a
      ON p.id = a.patient_id
      WHERE p.district = "${authData['address']['district']}"
      GROUP BY a.patient_id''');
    } catch (error) {
      print('catch error');
      return;
    }
  }

  getNewPatients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable}''';
    final data = await db.rawQuery(sql);

    return data;
  }

  getPatientById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE id = "$id"''';
    var patient;

    try {
      patient = await db.rawQuery(sql);

    } catch (error) {

      return;
    }
    return patient;
  }

  getNotSyncedPatients() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE is_synced=0''';
    var response = await db.rawQuery(sql);

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

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

      return;
    }

    if (isNotNull(referrals) && referrals.isNotEmpty) {
      var patientIds = referrals.map((item) => '"${item['patient_id']}"').toList();

      final patientSql = '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE id IN (${patientIds.join(', ')})''';


      try {
        patients = await db.rawQuery(patientSql);
      } catch (error) {

        return;
      }

      if (isNotNull(patients) && patients.isNotEmpty) {
        var responseData = [];
        var tempPatients = patients;

        for(var patient in patients) {

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


        return {
          'data': responseData
        };
      }


    }

    return [];
  }

  syncFromLive(tempSyncs) async {
    Batch batch = db.batch();
    final sql = '''INSERT OR REPLACE INTO ${DatabaseCreator.patientTable}
    (id, data, nid, district, status, is_synced) VALUES (?,?,?,?,?,?)''';
    for (var item in tempSyncs) {
      List<dynamic> params = [item['id'], jsonEncode(item), item['body']['nid'], item['body']['address']['district'], '', true];
      await batch.rawInsert(sql, params);
    }
    try {
      await batch.commit(noResult: true);
    } catch (error) {
      //TODO: create log here
      print('error $error');
    } finally {
      print('patient batch inserted');
    }
  }

  createNew(context, id, data, synced) async {

    var allPatients = await getAllPatients();

    // if (!synced) {
    //   final sql = '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE nid="${data['body']['nid']}"''';
    //   var existingPatient;
    //   try {
    //     existingPatient = await db.rawQuery(sql);
    //     print('existingPatient $existingPatient');
    //   } catch (err) {
    //     print(err);
    //     return;
    //   }

    //   if (isNotNull(existingPatient) && existingPatient.isNotEmpty) {
    //     Scaffold.of(context).showSnackBar(SnackBar(
    //       content: Text(
    //           "Error: ${AppLocalizations.of(context).translate('nidValidation')}"),
    //       backgroundColor: kPrimaryRedColor,
    //     ));
    //     return;
    //   }
    // }

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      id,
      data,
      nid,
      district,
      status,
      is_synced
    )
    VALUES (?,?,?,?,?,?)''';
    List<dynamic> params = [
      id,
      jsonEncode(data),
      data['body']['nid'],
      data['body']['address']['district'],
      '',
      synced
    ];

    var response;

    try {
      response = await db.rawInsert(sql, params);
    } catch (err) {

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
    var assessmentData = _prepareAssessmentData('registration', 'registration', data['meta']['created_at'], id);
    var assessment = await AssessmentRepositoryLocal().createLocalAssessment(assessmentData['id'], assessmentData, synced, localStatus:'complete');
    if (isNull(assessment)) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            "Error: ${AppLocalizations.of(context).translate('somethingWrong')}"),
        backgroundColor: kPrimaryRedColor,
      ));
      return;
    }
    var patient = {'id': id, 'data': data['body'], 'meta': data['meta']};
    data['id'] = id;

    await Patient().setPatient(patient);

    // DatabaseCreator.databaseLog('Add patient', sql, null, response, params);
    return 'success';
  }

  /// Create a patient.
  /// Patient [data] is required as parameter.
  create(context, id, data, synced) async {

    var allPatients = await getAllPatients();

    if (!synced) {

      final sql =
          '''SELECT * FROM ${DatabaseCreator.patientTable} WHERE nid="${data['body']['nid']}"''';
      var existingPatient;

      try {
        existingPatient = await db.rawQuery(sql);

      } catch (err) {

        return;
      }


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
    var assessmentData = _prepareAssessmentData('registration', 'registration', data['meta']['created_at'], id);
    await AssessmentRepositoryLocal().createLocalAssessment(assessmentData['id'], assessmentData, synced);

    var patient = {'id': id, 'data': data['body'], 'meta': data['meta']};

    data['id'] = id;
    await Patient().setPatient(patient);
    // DatabaseCreator.databaseLog('Add patient', sql, null, response, params);
    return 'success';
  }

  _prepareAssessmentData(type, screening_type, createdAt, patientId) {

    var assessmentId = Uuid().v4();

    var data = {
      "id": assessmentId,
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": createdAt
      },
      "body": {
        "type": type == 'In-clinic Screening' ? 'in-clinic' : type,
        "screening_type": screening_type,
        "comment": "",
        "performed_by": Auth().getAuth()['uid'],
        "assessment_date": DateFormat('y-MM-dd').format(DateTime.parse(createdAt)),
        "patient_id": patientId
      }
    };

    return data;
  }

  createFromLive(id, data) async {
    var allPatients = await getAllPatients();


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
  
  updateFromLive(id, data) async {

    final sql = '''UPDATE ${DatabaseCreator.patientTable} SET
      data = ?, is_synced = ? WHERE id = ?''';
    List<dynamic> params = [jsonEncode(data), true, id];
    var response;

    try {
      response = await db.rawUpdate(sql, params);

    } catch(error) {

      return;
    }
    return response;

  }

  Future<void> updateLocalStatus(uuid, isSynced) async {


    final sql = '''UPDATE ${DatabaseCreator.patientTable} SET
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [isSynced, uuid];
    var response;

    try {
      response = await db.rawUpdate(sql, params);

    } catch(error) {

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

      return;
    }

    return response;
  }

  getAllLocalPatients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable}''';
    var response;

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

      return;
    }

    return response;
  }

  getLocations() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.locationTable}''';
    var response;

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

      return;
    }

    return response;
  }
  getCenters() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.centerTable}''';
    var response;

    try {
      response = await db.rawQuery(sql);
    } catch (error) {

      return;
    }

    return response;
  }
}

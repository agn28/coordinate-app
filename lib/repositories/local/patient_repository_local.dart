import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/patient_repository.dart';

import '../assessment_repository.dart';
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
  create(data) async {
    var uuid = Uuid().v4();

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      uuid,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [uuid, jsonEncode(data), 'not synced'];
    // final result = await db.rawInsert(sql, params);

    var patient = {
      'uuid': uuid,
      'data': data['body'],
      'meta': data['meta']
    };

    data['id'] = uuid;

    print('live patient create');

    var response = await PatientRepository().create(data);

    var assessmentData = _prepareAssessmentData('registration', 'registration', '', uuid);

    AssessmentRepository().createOnlyAssessment(assessmentData);

    await Patient().setPatient(patient);
    DatabaseCreator.databaseLog('Add patient', sql, null, null, params);
    return response;
  }

  _prepareAssessmentData(type, screening_type, comment, patientId) {

    var assessmentId = Uuid().v4();

    var data = {
      "id": assessmentId,
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateTime.now().toString()
      },
      "body": {
        "type": type == 'In-clinic Screening' ? 'in-clinic' : type,
        "screening_type": screening_type,
        "comment": comment,
        "performed_by": Auth().getAuth()['uid'],
        "assessment_date": DateFormat('y-MM-dd').format(DateTime.now()),
        "patient_id": patientId
      }
    };

    return data;
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

import 'package:nhealth/repositories/local/database_creator.dart';
import 'dart:convert';

class ObservationRepositoryLocal {
  

  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(id, data, isSynced) async {

    print('into local observation create');

    final sql = '''INSERT INTO ${DatabaseCreator.observationTable}
    (
      id,
      data,
      patient_id,
      status,
      is_synced
    )
    VALUES (?,?,?,?,?)''';
    List<dynamic> params = [id, jsonEncode(data), data['body']['patient_id'], '', isSynced];
    var response;

    try {
      response = await db.rawInsert(sql, params);
      print('obs $response');
    } catch(error) {
      print('local observation create error');
      print(error);
    }
    return response;
    
  }

  update(id, data, isSynced) async {
    print('into local observation update');
    print('upobs $data');
    final sql = '''UPDATE ${DatabaseCreator.observationTable} SET
      data = ? , 
      patient_id = ?,
      status = ?,
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [jsonEncode(data), data['body']['patient_id'],
      data['body']['status'], isSynced, id];
    print('sql $sql');
    var response;

    try {
      response = await db.rawUpdate(sql, params);
      print('resobs $response');
    } catch(error) {
      print('local observation update error');
      print(error);
    }
    DatabaseCreator.databaseLog('Update observation', sql, null, response, params);
    return response;
    
  }

  getAllObservations() async {
    final sqlObservations = '''SELECT * FROM ${DatabaseCreator.observationTable}''';
    final observations = await db.rawQuery(sqlObservations);

    return observations;
  }

  getObservationsByPatient(patientId) async {
    final sqlObservations = '''SELECT * FROM ${DatabaseCreator.observationTable} WHERE patient_id="$patientId"''';
    final observations = await db.rawQuery(sqlObservations);

    return observations;
  }

  getObservationById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.observationTable} WHERE id = "$id"''';
    var observation;

    try {
      observation = await db.rawQuery(sql);
      print('observationbyId $observation');
    } catch (error) {
      print('error');
      print(error);
      return;
    }
    return observation;
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
    } catch(error) {
      print('error');
      print(error);
      return;
    }
    return response;

  }
}
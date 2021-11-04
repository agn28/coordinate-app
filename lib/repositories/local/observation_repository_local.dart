import 'package:nhealth/repositories/local/database_creator.dart';
import 'dart:convert';

class ObservationRepositoryLocal {
  

  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(id, data, isSynced, {localStatus:''}) async {

    print('into local observation create');

    final sql = '''INSERT INTO ${DatabaseCreator.observationTable}
    (
      id,
      data,
      patient_id,
      status,
      is_synced,
      local_status
    )
    VALUES (?,?,?,?,?,?)''';
    List<dynamic> params = [id, jsonEncode(data), data['body']['patient_id'], '', isSynced, localStatus];
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

  update(id, data, isSynced, {localStatus:''}) async {
    print('into local observation update');
    print('upobs $data');
    final sql = '''UPDATE ${DatabaseCreator.observationTable} SET
      data = ? , 
      patient_id = ?,
      status = ?,
      is_synced = ?,
      local_status = ?
      WHERE id = ?''';
    List<dynamic> params = [jsonEncode(data), data['body']['patient_id'],
      data['body']['status'], isSynced, localStatus, id];
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

  deleteLocalObservation(id) async {
    var response;
    final sql = '''DELETE FROM ${DatabaseCreator.observationTable} WHERE id = "$id"''';
    try {
      response = await db.rawQuery(sql);
      print('delete $response');
    } catch (err) {
      print(err);
      return;
    }
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

    try {
      return await db.rawQuery(sql);
    } catch (error) {
      print(error);
      return;
    }
  }

  getNotSyncedObservations() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.observationTable} WHERE (is_synced=0) AND (local_status!='incomplete')''';
    try {
      return await db.rawQuery(sql);
    } catch (error) {
      print(error);
      return;
    }
  }

  Future<void> updateLocalStatus(uuid, isSynced) async {

    final sql = '''UPDATE ${DatabaseCreator.observationTable} SET
      is_synced = ?
      WHERE id = ?''';
    List<dynamic> params = [isSynced, uuid];

    try {
      return await db.rawUpdate(sql, params);
    } catch(error) {
      print(error);
      return;
    }

  }
}

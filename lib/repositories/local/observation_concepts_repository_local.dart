import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class ObservationConceptsRepositoryLocal {

  getConceptByObservation(type) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.observationConceptsTable} WHERE type = "${type.toString()}"''';
    var concept = await db.rawQuery(sql);
    return concept.isNotEmpty ? concept.first : null;
  }
  

  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(data) async {
    String uuid = Uuid().v4();
    final sql = '''INSERT INTO ${DatabaseCreator.observationConceptsTable}
    (
      id,
      type,
      concept_id
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [uuid, data['type'], data['concept_id']];
    final result = await db.rawInsert(sql, params);

    DatabaseCreator.databaseLog('Add Concepts', sql, null, result, params);

    return 'success';
    
  }

  
}

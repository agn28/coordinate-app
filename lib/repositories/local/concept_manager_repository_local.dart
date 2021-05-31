import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class ConceptManagerRepositoryLocal {
  getConceptById(id) async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.conceptManagerTable} WHERE id = "${id.toString()}"''';

    try {
      var concept = await db.rawQuery(sql);
      return concept.isNotEmpty ? concept.first : null;
    } catch (error) {
      print('error');
      print(error);
      return;
    }
  }

  /// Create an assessment with observations.
  /// observations [data] is required as parameter.
  create(data) async {
    final sql = '''INSERT INTO ${DatabaseCreator.conceptManagerTable}
    (
      id,
      codings,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [data['id'], jsonEncode(data['codings']), 'synced'];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add Concepts', sql, null, result, params);

    return 'success';
  }
}

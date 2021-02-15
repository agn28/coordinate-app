import 'package:nhealth/repositories/local/database_creator.dart';
import 'dart:convert';

class ConceptManagerRepositoryLocal {

  getConceptById(id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.conceptManagerTable} WHERE uuid = "${id.toString()}"''';
    var concept = await db.rawQuery(sql);
    return concept.isNotEmpty ? concept.first : null;
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

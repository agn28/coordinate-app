import './database_creator.dart';
import 'package:uuid/uuid.dart';

class LocalPatientReposiory {

  static Future<void> getAllPatients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable}''';
    final data = await db.rawQuery(sql);

    print(data);
  }

  static Future<void> create(data, status) async {
    var uuid = Uuid();

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      uuid,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [uuid.v4(), data, status];
    final result = await db.rawInsert(sql, params);
    print('result ' + result.toString());
    DatabaseCreator.databaseLog('Add patient', sql, null, result, params);
  }

}

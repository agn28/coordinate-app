import './database_creator.dart';
import 'package:uuid/uuid.dart';

class PatientReposioryLocal {

  getAllPatients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.patientTable}''';
    final data = await db.rawQuery(sql);
    return data;
  }

  Future<void> create(data) async {
    var uuid = Uuid().v4();

    final sql = '''INSERT INTO ${DatabaseCreator.patientTable}
    (
      uuid,
      data,
      status
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [uuid, data, 'not synced'];
    final result = await db.rawInsert(sql, params);
    print('result ' + result.toString());
    DatabaseCreator.databaseLog('Add patient', sql, null, result, params);
  }

}

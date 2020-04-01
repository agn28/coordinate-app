import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;
bool isDbCreated = false;

class DatabaseCreator {
  static const patientTable = 'patients';
  static const assessmentTable = 'assessments';
  static const observationTable = 'observations';
  static const conceptManagerTable = 'concept_manager';
  static const observationConceptsTable = 'observation_concepts';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult, int insertAndUpdateQueryResult, List<dynamic> params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createPatientsTable(Database db) async {
    final sql = '''CREATE TABLE $patientTable
    (
      uuid TEXT PRIMARY KEY,
      data TEXT,
      status TEXT
    )''';

    await db.execute(sql);
  }

  Future<void> createAssessmentsTable(Database db) async {
    final sql = '''CREATE TABLE $assessmentTable
    (
      uuid TEXT PRIMARY KEY,
      data TEXT,
      status TEXT
    )''';

    await db.execute(sql);
  }

  Future<void> createObservationsTable(Database db) async {
    final sql = '''CREATE TABLE $observationTable
    (
      uuid TEXT PRIMARY KEY,
      data TEXT,
      status TEXT
    )''';

    await db.execute(sql);
  }

  Future<void> createConceptManagerTable(Database db) async {
    final sql = '''CREATE TABLE $conceptManagerTable
    (
      uuid TEXT PRIMARY KEY,
      codings TEXT,
      status TEXT
    )''';

    await db.execute(sql);
  }

  Future<void> createObservationConceptsTable(Database db) async {
    final sql = '''CREATE TABLE $observationConceptsTable
    (
      uuid TEXT PRIMARY KEY,
      type TEXT,
      concept_id TEXT NULL
    )''';

    await db.execute(sql);

  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
      // await deleteDatabase(path);
      // isDbCreated = true;
    } else {
      print('db created');
      isDbCreated = true;
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('coordinate_db');
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    isDbCreated = true;
    await createPatientsTable(db);
    await createAssessmentsTable(db);
    await createObservationsTable(db);
    await createConceptManagerTable(db);
    await createObservationConceptsTable(db);
  }

  dBCreatedStatusChange(status) {
    isDbCreated = status;
  }

  dBCreatedStatus() {
    return isDbCreated;
  }
}

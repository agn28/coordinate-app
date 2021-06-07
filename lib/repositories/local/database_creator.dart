import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;
bool isDbCreated = false;

class DatabaseCreator {
  static const patientTable = 'patients';
  static const assessmentTable = 'assessments';
  static const observationTable = 'observations';
  static const referralTable = 'referrals';
  static const careplanTable = 'care_plans';
  static const healthReportTable = 'health_reports';
  static const conceptManagerTable = 'concept_manager';
  static const observationConceptsTable = 'observation_concepts';
  static const syncTable = 'syncs';
  static const locationTable = 'locations';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult, int insertAndUpdateQueryResult, List<dynamic> params]) {
    if (params != null) {
      
    }
    if (selectQueryResult != null) {
      
    } else if (insertAndUpdateQueryResult != null) {
      
    }
  }

  Future<void> createPatientsTable(Database db) async {
    final sql = '''CREATE TABLE $patientTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      nid,
      status TEXT,
      is_synced BOOLEAN
    )''';

    await db.execute(sql);
    print('${patientTable} table created');
  }

  Future<void> createAssessmentsTable(Database db) async {
    final sql = '''CREATE TABLE $assessmentTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
    print('${assessmentTable} table created');
  }

  Future<void> createReferralsTable(Database db) async {
    final sql = '''CREATE TABLE $referralTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
    print('${referralTable} table created');
  }

  Future<void> createcareplansTable(Database db) async {
    final sql = '''CREATE TABLE $careplanTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
    print('${careplanTable} table created');
  }

  Future<void> createHealthReportsTable(Database db) async {
    final sql = '''CREATE TABLE $healthReportTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
    print('${healthReportTable} table created');
  }

  Future<void> createObservationsTable(Database db) async {
    final sql = '''CREATE TABLE $observationTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
    print('${observationTable} table created');
  }

  Future<void> createSyncsTable(Database db) async {
    final sql = '''CREATE TABLE $syncTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      key TEXT,
      status TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
    print('${syncTable} table created');
  }

  Future<void> createLocationsTable(Database db) async {
    final sql = '''CREATE TABLE $locationTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      status TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
    print('${locationTable} table created');
  }

  Future<void> createConceptManagerTable(Database db) async {
    final sql = '''CREATE TABLE $conceptManagerTable
    (
      id TEXT PRIMARY KEY,
      codings TEXT,
      status TEXT
    )''';

    await db.execute(sql);
    print('${conceptManagerTable} table created');
  }

  Future<void> createObservationConceptsTable(Database db) async {
    final sql = '''CREATE TABLE $observationConceptsTable
    (
      id TEXT PRIMARY KEY,
      type TEXT,
      concept_id TEXT NULL
    )''';

    await db.execute(sql);
    print('${observationConceptsTable} table created');

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
    await createSyncsTable(db);
    await createLocationsTable(db);
    await createReferralsTable(db);
    await createcareplansTable(db);
    await createConceptManagerTable(db);
    await createObservationConceptsTable(db);
    await createHealthReportsTable(db);
  }

  dBCreatedStatusChange(status) {
    isDbCreated = status;
  }

  dBCreatedStatus() {
    return isDbCreated;
  }
}



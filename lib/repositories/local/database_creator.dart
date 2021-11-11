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
  static const latestSyncTable = 'latest_syncs';
  static const locationTable = 'locations';
  static const centerTable = 'centers';

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

  }

  Future<void> createAssessmentsTable(Database db) async {
    final sql = '''CREATE TABLE $assessmentTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      local_status TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);

  }

  Future<void> createReferralsTable(Database db) async {
    final sql = '''CREATE TABLE $referralTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      local_status TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);

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
  }

  Future<void> createObservationsTable(Database db) async {
    final sql = '''CREATE TABLE $observationTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      patient_id TEXT,
      status TEXT,
      is_synced BOOLEAN,
      local_status TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);

  }

  Future<void> createSyncsTable(Database db) async {
    final sql = '''CREATE TABLE $syncTable
    (
      id TEXT PRIMARY KEY,
      document_id TEXT,
      collection TEXT,
      action TEXT,
      key TEXT,
      status TEXT,
      is_synced BOOLEAN,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
  }

  Future<void> createLatestSyncsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS $latestSyncTable
    (
      id TEXT PRIMARY KEY,
      document_id TEXT,
      collection TEXT,
      action TEXT,
      key TEXT,
      status TEXT,
      is_synced BOOLEAN ,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
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

  }

  Future<void> createCentersTable(Database db) async {
    final sql = '''CREATE TABLE $centerTable
    (
      id TEXT PRIMARY KEY,
      data TEXT,
      status TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''';

    await db.execute(sql);
  }

  Future<void> createConceptManagerTable(Database db) async {
    final sql = '''CREATE TABLE $conceptManagerTable
    (
      id TEXT PRIMARY KEY,
      codings TEXT,
      status TEXT
    )''';

    await db.execute(sql);
  }

  Future<void> createObservationConceptsTable(Database db) async {
    final sql = '''CREATE TABLE $observationConceptsTable
    (
      id TEXT PRIMARY KEY,
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
      isDbCreated = true;
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('coordinate_db');
    db = await openDatabase(path, version: 6, onCreate: onCreate, onUpgrade: _onUpgrade);
  }

  // UPGRADE DATABASE TABLES
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      
    }
  }

  Future<void> onCreate(Database db, int version) async {
    isDbCreated = true;
    await createPatientsTable(db);
    await createAssessmentsTable(db);
    await createObservationsTable(db);
    await createSyncsTable(db);
    await createLatestSyncsTable(db);
    await createLocationsTable(db);
    await createReferralsTable(db);
    await createcareplansTable(db);
    await createConceptManagerTable(db);
    await createObservationConceptsTable(db);
    await createHealthReportsTable(db);
    await createCentersTable(db);
  }

  dBCreatedStatusChange(status) {
    isDbCreated = status;
  }

  dBCreatedStatus() {
    return isDbCreated;
  }
}



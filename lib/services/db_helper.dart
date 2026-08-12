import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'acp_local_storage.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE registration_draft (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            email TEXT,
            dob TEXT,
            fiscalCode TEXT,
            gender TEXT,
            phone TEXT,
            passport TEXT,
            idCard TEXT,
            permesso TEXT,
            cittadinanza TEXT,
            pakPhone TEXT,
            italyAddress TEXT,
            comuneProvincia TEXT,
            pakAddress TEXT,
            fatherName TEXT,
            membershipType TEXT,
            familyJson TEXT,
            updatedAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS registration_draft');
          await db.execute('''
            CREATE TABLE registration_draft (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              fullName TEXT,
              email TEXT,
              dob TEXT,
              fiscalCode TEXT,
              gender TEXT,
              phone TEXT,
              passport TEXT,
              idCard TEXT,
              permesso TEXT,
              cittadinanza TEXT,
              pakPhone TEXT,
              italyAddress TEXT,
              comuneProvincia TEXT,
              pakAddress TEXT,
              fatherName TEXT,
              membershipType TEXT,
              familyJson TEXT,
              updatedAt TEXT
            )
          ''');
        }
      },
    );
  }
}
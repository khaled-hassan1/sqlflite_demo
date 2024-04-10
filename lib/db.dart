import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteDatabase {
  late Database _database;

  Future<Database> getDatabaseInstance() async {
    if (_database.isOpen) {
      return _database;
    } else {
      _database = await _initializeDatabase();
      return _database;
    }
  }

  Future<Database> _initializeDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'sqflite.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int _) async {
    await db.execute(
      'CREATE TABLE person(id INTEGER PRIMARY KEY, title TEXT, description TEXT)',
    );
    debugPrint('Database created');
  }

  Future<List<Map<String, dynamic>>> query(String sqlTxt) async {
    Database db = await getDatabaseInstance();
    return await db.rawQuery(sqlTxt);
  }

  Future<int> insert(String sqlTxt, List<dynamic> values) async {
    Database db = await getDatabaseInstance();
    return await db.rawInsert(sqlTxt, values);
  }

  Future<int> update(String sqlTxt) async {
    Database db = await getDatabaseInstance();
    return await db.rawUpdate(sqlTxt);
  }

  Future<int> delete(String sqlTxt) async {
    Database db = await getDatabaseInstance();
    return await db.rawDelete(sqlTxt);
  }
}





















// class SqliteHelper {
//   static Database? _db;

//   Future<Database?> get getInstance async {
//     _db ??= await instance();
//     return _db;
//   }

//   instance() async {
//     String dataBasePath = await getDatabasesPath();
//     String path = join(dataBasePath, 'sqflite.db');
//     Database database = await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute('''
// CREATE TABLE test_1 (id INTEGER PRIMARY KEY, name TEXT, age INTEGER);
// CREATE TABLE test_2 (id INTEGER PRIMARY KEY, name TEXT, age INTEGER);
// ''');

//       },
//     );
//     return database;
//   }
// }

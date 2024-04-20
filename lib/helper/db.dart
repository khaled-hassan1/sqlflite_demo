import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_demo/model/person.dart';

class SqfliteDatabase {
  Database? _database;

  Future<Database> getDatabaseInstance() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    } else {
      _database = await _initializeDatabase();
      return _database!;
    }
  }

  Future<Database> _initializeDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'sqflite.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    debugPrint('Database initialized');
    return _database!;
  }

  Future<void> _onCreate(Database db, int _) async {
    try {
      await db.execute(
        '''CREATE TABLE person
        (id TEXT PRIMARY KEY NOT NULL, title TEXT NOT NULL, description TEXT NOT NULL)''',
      );
      debugPrint('Database created');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> query(String sqlTxt) async {
    Database db = await getDatabaseInstance();
    List<Map<String, dynamic>> result = await db.query(sqlTxt);
    return result;
  }

  Future<int> insert(String tableName, Person person) async {
    Database db = await getDatabaseInstance();
    Map<String, dynamic> values = Person.toMap(person);
    return await db.insert(tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(
      String sqlTxt, Map<String, dynamic> person, String id) async {
    Database db = await getDatabaseInstance();
    return await db.update(sqlTxt, person, where: 'id =  ?', whereArgs: [id]);
  }

  Future<int> delete(String sqlTxt, String id) async {
    Database db = await getDatabaseInstance();
    return await db.delete(sqlTxt, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      debugPrint('Database connection closed');
    }
  }
}

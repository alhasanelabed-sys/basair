import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'snapshot.dart';

class LibraryStore {
  LibraryStore._(this.database);
  final Database database;

  static Future<LibraryStore> open() async {
    final root = await getDatabasesPath();
    final database = await openDatabase(
      p.join(root, 'basair-library.sqlite'),
      version: 1,
      onCreate: (db, version) => db.execute('CREATE TABLE library (id INTEGER PRIMARY KEY, body TEXT NOT NULL)'),
    );
    return LibraryStore._(database);
  }

  Future<String?> readRaw() async {
    final rows = await database.query('library', where: 'id = ?', whereArgs: [1]);
    return rows.isEmpty ? null : rows.first['body'] as String;
  }

  Future<Map<String, dynamic>?> read() async {
    final rows = await database.query('library', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;
    // A corrupt record raises an error; it is never silently overwritten.
    return validateSnapshot(jsonDecode(rows.first['body'] as String));
  }

  Future<void> save(dynamic input) async {
    final snapshot = validateSnapshot(input);
    await database.transaction((txn) async {
      await txn.insert('library', {'id': 1, 'body': jsonEncode(snapshot)}, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> close() => database.close();
}

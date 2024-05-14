// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uid TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL,
          name TEXT NOT NULL,
          isModified INTEGER NOT NULL DEFAULT 0
        );
      ''');
      await db.execute('''
        CREATE TABLE farms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uid TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          locations TEXT NOT NULL,
          user_id INTEGER,
          isModified INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users (id)
        );
      ''');
      await db.execute('''
       CREATE TABLE trees (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uid TEXT NOT NULL UNIQUE,
          label TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          farm_id INTEGER NOT NULL,
          isModified INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (farm_id) REFERENCES farms (id)
        );
      ''');
    } catch (e) {
      showToast(message: "Failed to create local cache: $e");
    }
  }

  Future<int> insertOrUpdate(
      String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> markAsUnmodified(String tableName, String uid) async {
    final db = await database;
    return await db.update(tableName, {'isModified': 0},
        where: 'uid = ?', whereArgs: [uid]);
  }

  Future<List<Map<String, dynamic>>> getModified(String tableName) async {
    final db = await database;
    return await db.query(tableName, where: 'isModified = ?', whereArgs: [1]);
  }

  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {
    var db = await database;
    await db.insert('users', userData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrUpdateFarm(Map<String, dynamic> farmData) async {
    var db = await database;
    await db.insert('farms', farmData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrUpdateTree(Map<String, dynamic> treeData) async {
    var db = await database;
    await db.insert('trees', treeData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>> getUser(String uid) async {
    final db = await database;
    List<Map<String, dynamic>> users =
        await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    if (users.isNotEmpty) {
      return users.first;
    }
    throw Exception('User not found!');
  }

  Future<Map<String, dynamic>?> getFarm(int farmId) async {
    final db = await database;
    List<Map> farms =
        await db.query('farms', where: 'id = ?', whereArgs: [farmId]);
    if (farms.isNotEmpty) {
      return farms.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> userData) async {
    final db = await database;
    return db.update('users', userData,
        where: 'uid = ?', whereArgs: [userData['uid']]);
  }

  Future<void> clearUserData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('farms');
    await db.delete('trees');
  }

  Future<void> updateTreeLabel(String newLabel, String treeId) async {
    final db = await database;
    await db.update('trees', {'label': newLabel, 'isModified': 1},
        where: 'uid = ?', whereArgs: [treeId]);
  }

  Future<void> addTree(
      String label, double latitude, double longitude, String farmid) async {
    final db = await database;
    String newId = const Uuid().v4();
    await db.insert('trees', {
      'uid': newId,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'farm_id': farmid,
      'isModified': 1
    });
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}

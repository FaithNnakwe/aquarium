import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'aquarium.db');
    return openDatabase(path, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE aquarium_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fish_count INTEGER,
          speed REAL,
          color TEXT
        )
      ''');
    }, version: 1);
  }

  // Save aquarium settings
  Future<void> saveSettings(int fishCount, double speed, String color) async {
    final db = await database;
    await db.insert(
      'aquarium_settings',
      {'fish_count': fishCount, 'speed': speed, 'color': color},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Load aquarium settings
  Future<Map<String, dynamic>?> loadSettings() async {
    final db = await database;
    final result = await db.query('aquarium_settings', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Clear aquarium settings
  Future<void> clearSettings() async {
    final db = await database;
    await db.delete('aquarium_settings');
  }
}

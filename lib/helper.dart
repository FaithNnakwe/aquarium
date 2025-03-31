import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'aquarium_settings.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fish_count INTEGER,
            speed REAL,
            color TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveSettings(int fishCount, double speed, String color) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'fish_count': fishCount, 'speed': speed, 'color': color},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    final db = await instance.database;
    final result = await db.query('settings', limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> clearSettings() async {
    final db = await instance.database;
    await db.delete('settings');
  }
}

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 🔥 STREAM CONTROLLER (REAL-TIME UPDATE)
  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notifyDataChanged() {
    _controller.add(null);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('usage_history.db');
    return _database!;
  }

  Stream<void> get onDataChanged => _controller.stream;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        date TEXT PRIMARY KEY,
        wifi INTEGER,
        mobile INTEGER
      )
    ''');
  }

  Future<void> insertOrUpdate(String date, int wifi, int mobile) async {
    final db = await instance.database;

    await db.insert(
      'history',
      {
        'date': date,
        'wifi': wifi,
        'mobile': mobile,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 🔥 PENTING: kasih sinyal ke HomePage
    notifyDataChanged();
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'date DESC');
  }

  // optional: cleanup
  void dispose() {
    _controller.close();
  }
}
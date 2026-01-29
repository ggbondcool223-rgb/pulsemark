import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'db_pulse_mark_entity.dart';

class PulseMarkDatabase {
  static final PulseMarkDatabase _instance = PulseMarkDatabase._internal();
  static Database? _database;

  factory PulseMarkDatabase() => _instance;
  PulseMarkDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'pulsemark.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE watermark_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        watermark_text TEXT,
        watermark_position TEXT DEFAULT 'bottom-right',
        watermark_opacity REAL DEFAULT 0.5,
        watermark_size REAL DEFAULT 24.0,
        watermark_color TEXT DEFAULT '#FFFFFFFF',
        text_content TEXT,
        text_size REAL DEFAULT 32.0,
        text_color TEXT DEFAULT '#FFFFFFFF',
        is_bold INTEGER DEFAULT 0,
        is_italic INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_watermark_created_at 
      ON watermark_history(created_at DESC)
    ''');

    await db.execute('''
      CREATE TABLE grid_cut_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        grid_mode TEXT NOT NULL,
        rows INTEGER NOT NULL,
        cols INTEGER NOT NULL,
        file_paths TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_grid_cut_created_at 
      ON grid_cut_history(created_at DESC)
    ''');

    await _insertDefaultSettings(db);
  }

  Future<void> _insertDefaultSettings(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.insert('app_settings', {
      'key': 'first_launch',
      'value': 'true',
      'updated_at': now,
    });
    await db.insert('app_settings', {
      'key': 'default_text_color',
      'value': '#000000',
      'updated_at': now,
    });
    await db.insert('app_settings', {
      'key': 'app_version',
      'value': '1.0.0',
      'updated_at': now,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE grid_cut_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          grid_mode TEXT NOT NULL,
          rows INTEGER NOT NULL,
          cols INTEGER NOT NULL,
          file_paths TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_grid_cut_created_at 
        ON grid_cut_history(created_at DESC)
      ''');
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('watermark_history');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

class AppSettingsDao {
  final PulseMarkDatabase _dbHelper = PulseMarkDatabase();

  Future<String?> get(String key) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'];
  }

  Future<void> set(String key, String value) async {
    final db = await _dbHelper.database;
    final setting = AppSetting(
      key: key,
      value: value,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.insert(
      'app_settings',
      setting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> delete(String key) async {
    final db = await _dbHelper.database;
    return await db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
  }

  Future<Map<String, String>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('app_settings');
    return {for (var m in maps) m['key']: m['value']};
  }
}

class WatermarkHistoryDao {
  final PulseMarkDatabase _dbHelper = PulseMarkDatabase();

  Future<int> insert(WatermarkHistory history) async {
    final db = await _dbHelper.database;
    return await db.insert('watermark_history', history.toMap());
  }

  Future<List<WatermarkHistory>> getRecent(int limit) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watermark_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((m) => WatermarkHistory.fromMap(m)).toList();
  }

  Future<WatermarkHistory?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watermark_history',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return WatermarkHistory.fromMap(maps.first);
  }

  Future<int> update(WatermarkHistory history) async {
    final db = await _dbHelper.database;
    return await db.update(
      'watermark_history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'watermark_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('watermark_history');
  }

  Future<List<WatermarkHistory>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watermark_history',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => WatermarkHistory.fromMap(m)).toList();
  }
}

class GridCutHistoryDao {
  final PulseMarkDatabase _dbHelper = PulseMarkDatabase();

  Future<int> insert(GridCutHistory history) async {
    final db = await _dbHelper.database;
    return await db.insert('grid_cut_history', history.toMap());
  }

  Future<List<GridCutHistory>> getRecent(int limit) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grid_cut_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((m) => GridCutHistory.fromMap(m)).toList();
  }

  Future<List<GridCutHistory>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grid_cut_history',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => GridCutHistory.fromMap(m)).toList();
  }

  Future<GridCutHistory?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grid_cut_history',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return GridCutHistory.fromMap(maps.first);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'grid_cut_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('grid_cut_history');
  }
}

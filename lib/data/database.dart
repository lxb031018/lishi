import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// 封装 SQLite 打开 + 表结构。
///
/// 测试场景下可以注入 [databaseFactory] (e.g. sqflite_common_ffi) 来跑在内存里。
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  /// 已打开的数据库实例, 避免反复打开。
  Database? _db;

  /// 测试入口: 注入自定义 [factory] 和 [path], 可以跑纯内存测试。
  Future<void> openForTest({
    required DatabaseFactory factory,
    String path = inMemoryDatabasePath,
  }) async {
    _db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'lishi.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE commits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        desc TEXT NOT NULL,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        start_at INTEGER NOT NULL,
        end_at INTEGER NOT NULL,
        duration_sec INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_commits_date ON commits(date)',
    );
    await db.execute(
      'CREATE INDEX idx_commits_start_at ON commits(start_at)',
    );
  }
}

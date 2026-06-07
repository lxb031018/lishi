import 'package:sqflite/sqflite.dart';

import '../models/commit_record.dart';
import 'database.dart';

/// 提交记录的仓库: 提供 CRUD + 查询接口。
///
/// 所有方法都接收 [Database] 而不是自己 new, 这样测试可以传入内存库。
class CommitRepository {
  CommitRepository(this._appDb);

  final AppDatabase _appDb;

  Future<Database> get _db => _appDb.database;

  /// 插入一条新记录, 返回带 id 的对象。
  Future<CommitRecord> insert(CommitRecord record) async {
    final db = await _db;
    final map = record.toMap()..remove('id');
    final id = await db.insert('commits', map);
    return record.copyWith(id: id);
  }

  /// 查询某一天的全部记录, 按 [CommitRecord.startAt] 倒序 (最新在前)。
  Future<List<CommitRecord>> findByDate(String date) async {
    final db = await _db;
    final rows = await db.query(
      'commits',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'start_at DESC',
    );
    return rows.map(CommitRecord.fromMap).toList();
  }

  /// 查询全部记录 (按 start_at 倒序)。
  Future<List<CommitRecord>> findAll() async {
    final db = await _db;
    final rows = await db.query('commits', orderBy: 'start_at DESC');
    return rows.map(CommitRecord.fromMap).toList();
  }

  /// 删除一条记录, 返回受影响行数 (0 或 1)。
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('commits', where: 'id = ?', whereArgs: [id]);
  }
}

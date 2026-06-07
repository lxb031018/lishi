import 'package:flutter_test/flutter_test.dart';
import 'package:lishi/data/commit_repository.dart';
import 'package:lishi/data/database.dart';
import 'package:lishi/models/commit_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDb;
  late CommitRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    appDb = AppDatabase.instance;
    await appDb.openForTest(factory: databaseFactoryFfi);
    repo = CommitRepository(appDb);
    // 清空表 (因为 AppDatabase.instance 是单例, 测试间要清理)
    final db = await appDb.database;
    await db.delete('commits');
  });

  tearDown(() async {
    await appDb.close();
  });

  CommitRecord make({
    String desc = '读书',
    String date = '2026-06-08',
    int durationSec = 1500,
  }) {
    final start = DateTime(2026, 6, 8, 14, 30);
    final end = start.add(Duration(seconds: durationSec));
    return CommitRecord(
      desc: desc,
      date: date,
      startTime: '14:30',
      endTime: '14:55',
      startAt: start,
      endAt: end,
      durationSec: durationSec,
    );
  }

  group('CommitRepository', () {
    test('insert 后返回带 id 的对象', () async {
      final inserted = await repo.insert(make());
      expect(inserted.id, isNotNull);
      expect(inserted.id, greaterThan(0));
    });

    test('findByDate 只返回当天的, 按 start_at DESC', () async {
      await repo.insert(make(desc: '早上', date: '2026-06-08'));
      await repo.insert(
        make(
          desc: '下午',
          date: '2026-06-08',
        ).copyWith(
          startAt: DateTime(2026, 6, 8, 16, 0),
          durationSec: 1800,
        ),
      );
      await repo.insert(make(desc: '昨天', date: '2026-06-07'));

      final today = await repo.findByDate('2026-06-08');
      expect(today.length, 2);
      expect(today[0].desc, '下午'); // 较新的在前
      expect(today[1].desc, '早上');
    });

    test('findAll 按 start_at DESC 返回全部', () async {
      await repo.insert(make(desc: 'A'));
      await repo.insert(
        make(desc: 'B').copyWith(startAt: DateTime(2026, 6, 8, 18, 0)),
      );
      await repo.insert(
        make(desc: 'C', date: '2026-06-07')
            .copyWith(startAt: DateTime(2026, 6, 7, 10, 0)),
      );
      final all = await repo.findAll();
      expect(all.length, 3);
      expect(all.map((r) => r.desc), ['B', 'A', 'C']);
    });

    test('delete 删指定 id', () async {
      final a = await repo.insert(make(desc: 'A'));
      final b = await repo.insert(make(desc: 'B'));
      final deleted = await repo.delete(a.id!);
      expect(deleted, 1);
      final left = await repo.findAll();
      expect(left.length, 1);
      expect(left.first.id, b.id);
    });
  });
}

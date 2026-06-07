import 'package:flutter_test/flutter_test.dart';
import 'package:lishi/models/commit_record.dart';

void main() {
  group('CommitRecord', () {
    final start = DateTime(2026, 6, 8, 14, 30, 0);
    final end = DateTime(2026, 6, 8, 14, 55, 0);
    final record = CommitRecord(
      id: 1,
      desc: '读《原子习惯》第三章',
      date: '2026-06-08',
      startTime: '14:30',
      endTime: '14:55',
      startAt: start,
      endAt: end,
      durationSec: 1500,
    );

    test('toMap / fromMap roundtrip 保持字段一致', () {
      final map = record.toMap();
      final back = CommitRecord.fromMap(map);
      expect(back, equals(record));
    });

    test('toMap 不带 id 时为 null (供 insert 使用)', () {
      final fresh = CommitRecord(
        desc: record.desc,
        date: record.date,
        startTime: record.startTime,
        endTime: record.endTime,
        startAt: record.startAt,
        endAt: record.endAt,
        durationSec: record.durationSec,
      );
      final map = fresh.toMap();
      expect(map['id'], isNull);
    });

    test('insert 用的 map 应能 toMap 后 remove id 干净重建', () {
      final map = record.toMap()..remove('id');
      expect(map.containsKey('id'), isFalse);
      expect(map['desc'], record.desc);
    });

    test('copyWith 只覆盖传入字段', () {
      final updated = record.copyWith(durationSec: 9999);
      expect(updated.durationSec, 9999);
      expect(updated.desc, record.desc);
      expect(updated.startTime, record.startTime);
    });

    test('equality 按全部字段比较', () {
      final clone = CommitRecord.fromMap(record.toMap());
      expect(clone, equals(record));
      expect(clone.hashCode, record.hashCode);
    });
  });
}

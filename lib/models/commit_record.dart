/// 一次"提交"的记录 —— 等价于 git 的一个 commit。
///
/// 灵感来自 git: 用户写好要做的事 → 开始计时 → 做完提交 → 记录时间段 + 时长。
class CommitRecord {
  /// 数据库自增 id
  final int? id;

  /// 用户写下的事
  final String desc;

  /// 归属日期 (YYYY-MM-DD, 当地时间), 用于按天分组
  final String date;

  /// 开始时间 (HH:mm, 当地时间), 用于显示
  final String startTime;

  /// 结束时间 (HH:mm, 当地时间)
  final String endTime;

  /// 实际开始时间戳 (epoch millis, 当地时间), 用于排序和精确计算
  final DateTime startAt;

  /// 实际结束时间戳
  final DateTime endAt;

  /// 时长 (秒)
  final int durationSec;

  const CommitRecord({
    this.id,
    required this.desc,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.startAt,
    required this.endAt,
    required this.durationSec,
  });

  /// 复制并可选地替换部分字段。
  CommitRecord copyWith({
    int? id,
    String? desc,
    String? date,
    String? startTime,
    String? endTime,
    DateTime? startAt,
    DateTime? endAt,
    int? durationSec,
  }) {
    return CommitRecord(
      id: id ?? this.id,
      desc: desc ?? this.desc,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      durationSec: durationSec ?? this.durationSec,
    );
  }

  /// 序列化成数据库行。
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'desc': desc,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'start_at': startAt.millisecondsSinceEpoch,
      'end_at': endAt.millisecondsSinceEpoch,
      'duration_sec': durationSec,
    };
  }

  /// 从数据库行反序列化。
  factory CommitRecord.fromMap(Map<String, Object?> map) {
    return CommitRecord(
      id: map['id'] as int?,
      desc: map['desc'] as String,
      date: map['date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      startAt: DateTime.fromMillisecondsSinceEpoch(map['start_at'] as int),
      endAt: DateTime.fromMillisecondsSinceEpoch(map['end_at'] as int),
      durationSec: map['duration_sec'] as int,
    );
  }

  @override
  String toString() =>
      'CommitRecord(id: $id, desc: "$desc", date: $date, '
      'startTime: $startTime, endTime: $endTime, durationSec: $durationSec)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommitRecord &&
        other.id == id &&
        other.desc == desc &&
        other.date == date &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.startAt == startAt &&
        other.endAt == endAt &&
        other.durationSec == durationSec;
  }

  @override
  int get hashCode => Object.hash(
        id,
        desc,
        date,
        startTime,
        endTime,
        startAt,
        endAt,
        durationSec,
      );
}

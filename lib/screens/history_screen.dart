import 'package:flutter/material.dart';

import '../data/commit_repository.dart';
import '../data/database.dart';
import '../models/commit_record.dart';
import '../theme.dart';
import '../utils/format.dart';

/// 历史页: 打开时自己从数据库读全部记录, 按日期分组倒序展示。
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repository = CommitRepository(AppDatabase.instance);

  late Future<List<CommitRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.findAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repository.findAll();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('提交记录')),
      body: FutureBuilder<List<CommitRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          final records = snapshot.data ?? const [];
          if (records.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _RecordsList(records: records),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Text('🌱', style: TextStyle(fontSize: 56)),
              SizedBox(height: 12),
              Text(
                '还没有提交记录\n开始你的第一粒时间吧',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordsList extends StatelessWidget {
  const _RecordsList({required this.records});
  final List<CommitRecord> records;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final groups = <String, List<CommitRecord>>{};
    for (final r in records) {
      groups.putIfAbsent(r.date, () => []).add(r);
    }
    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: dates.length,
      itemBuilder: (context, idx) {
        final date = dates[idx];
        final items = groups[date]!;
        final parts = date.split('-').map(int.parse).toList();
        final dt = DateTime(parts[0], parts[1], parts[2]);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                AppFormat.dateLabel(today, dt),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...items.map(_HistoryItem.new),
          ],
        );
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem(this.record);
  final CommitRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.startTime} - ${record.endTime}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppFormat.duration(record.durationSec),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

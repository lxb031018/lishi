import 'package:flutter/material.dart';

import '../models/commit_record.dart';
import '../theme.dart';
import '../utils/format.dart';

/// 主页 (空闲态):
/// 1. 顶部 logo + 历史按钮
/// 2. 提示卡 "现在想做点什么嘛"
/// 3. 输入卡 (输入框 + 开始按钮 + 快速建议 chips)
/// 4. 今日摘要 (timeline)
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.todayRecords,
    required this.onStart,
    required this.onOpenHistory,
  });

  /// 今天的提交记录 (从 Repository 拉取, 由父组件传入)。
  final List<CommitRecord> todayRecords;

  /// 用户输入了文字并点击开始, 回调带 desc。
  final void Function(String desc) onStart;

  /// 点击右上角历史按钮。
  final VoidCallback onOpenHistory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();

  static const _suggestions = <String>[
    '📖 读书',
    '🏃 运动',
    '🧹 做家务',
    '🧘 冥想放松',
    '🎯 学习新技能',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _handleStart() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      _inputFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✏️ 请写下你想做的事情'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    widget.onStart(text);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayRecords = widget.todayRecords;
    final recent = todayRecords.take(5).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 顶部 logo + 历史按钮 ──
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '粒',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '粒时',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                _HistoryButton(
                  badge: todayRecords.length,
                  onTap: widget.onOpenHistory,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── 提示卡片 ──
            _PromptCard(),

            const SizedBox(height: 16),

            // ── 输入卡 ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            focusNode: _inputFocus,
                            textInputAction: TextInputAction.go,
                            onSubmitted: (_) => _handleStart(),
                            maxLength: 60,
                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: '比如: 读 30 页书、跑 3 公里、整理书架...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFC4B8A8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StartButton(onTap: _handleStart),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions
                          .map((s) => _SuggestionChip(
                                text: s,
                                onTap: () {
                                  _inputController.text = s.replaceAll(
                                    RegExp(r'^.\s'),
                                    '',
                                  );
                                  _inputController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _inputController.text.length,
                                    ),
                                  );
                                  _inputFocus.requestFocus();
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 今日摘要 ──
            _TodaySummary(today: today, records: recent),
          ],
        ),
      ),
    );
  }
}

/// 提示卡 "现在想做点什么嘛"
class _PromptCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            const Text('💡', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            const Text(
              '粒时',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '现在想做点什么嘛',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '在完全属于你的时间里，立即开始',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 输入框旁的开始按钮
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

/// 快速建议 chip
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFAF5EE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 顶部右侧历史按钮 (带 badge)
class _HistoryButton extends StatelessWidget {
  const _HistoryButton({required this.badge, required this.onTap});
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.card,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: const Text('📋', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFE07050),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.bg, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$badge',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 今日摘要 (timeline)
class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.today, required this.records});
  final DateTime today;
  final List<CommitRecord> records;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  '🌿 今日提交',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${records.length} 件事',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text('🌱', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 6),
                    Text(
                      '今天还没有提交记录\n做点什么吧',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...records.map(_TimelineRow.new),
          ],
        ),
      ),
    );
  }
}

/// 单条 timeline
class _TimelineRow extends StatelessWidget {
  const _TimelineRow(this.record);
  final CommitRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

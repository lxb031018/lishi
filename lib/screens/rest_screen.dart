import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/format.dart';

/// 休息页: 5 分钟倒计时, 进度条, 跳过按钮, 倒计时结束弹"开始新的一件事"。
class RestScreen extends StatefulWidget {
  const RestScreen({super.key, required this.onFinish});

  /// 倒计时结束 (或跳过) 时回调
  final VoidCallback onFinish;

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  static const _totalSeconds = 5 * 60; // 5 分钟

  late int _left;
  Timer? _ticker;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _left = _totalSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _left -= 1;
        if (_left <= 0) {
          _ticker?.cancel();
          _left = 0;
          _finished = true;
        }
      });
      if (_finished) _showEndModal();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _showEndModal() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🌟 休息时间到'),
        content: const Text('准备好开始下一件\n有意义的事情了吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('开始新的事情'),
          ),
        ],
      ),
    );
    widget.onFinish();
  }

  void _skip() {
    _ticker?.cancel();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_totalSeconds - _left) / _totalSeconds;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.restBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.restBorder, width: 2),
              ),
              child: Column(
                children: [
                  const Text('🍃', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 8),
                  const Text(
                    '休息一下',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '起身活动，什么都不要做',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppFormat.restTimer(_left),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: AppColors.restAccent,
                      letterSpacing: 3,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.restBorder,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.restAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _skip,
              child: const Text(
                '跳过休息 →',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/format.dart';

/// 计时页: 大计时器, 实时刷新, 完成后回调 [onSubmit]。
class TimingScreen extends StatefulWidget {
  const TimingScreen({
    super.key,
    required this.thing,
    required this.onSubmit,
    required this.onCancel,
  });

  /// 用户输入要做的事
  final String thing;

  /// 提交回调 (带实际时长, 单位秒)
  final void Function(int durationSec) onSubmit;

  /// 放弃回调
  final VoidCallback onCancel;

  @override
  State<TimingScreen> createState() => _TimingScreenState();
}

class _TimingScreenState extends State<TimingScreen> {
  late final Stopwatch _stopwatch;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确定要放弃这次计时吗？'),
        content: const Text('这件事不会被记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('继续计时'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFC05050)),
            child: const Text('放弃'),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed.inSeconds;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '● 专注中',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.thing,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 28),
            _TimerRing(
              seconds: elapsed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormat.timer(elapsed),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: AppColors.text,
                      letterSpacing: 3,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$elapsed 秒',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => widget.onSubmit(elapsed),
                icon: const Text('✨', style: TextStyle(fontSize: 18)),
                label: const Text('提交这件事'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _confirmCancel,
              child: const Text(
                '放弃计时',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 圆形 ring 容器 (外圈有渐变动画环), 内部 child 居中。
class _TimerRing extends StatefulWidget {
  const _TimerRing({required this.seconds, required this.child});
  final int seconds;
  final Widget child;

  @override
  State<_TimerRing> createState() => _TimerRingState();
}

class _TimerRingState extends State<_TimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 3),
            ),
          ),
          // 旋转的进度指示
          RotationTransition(
            turns: _controller,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.transparent,
                  width: 3,
                ),
              ),
              child: CustomPaint(
                painter: _RingPainter(),
                size: const Size(220, 220),
              ),
            ),
          ),
          Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFDFAF5),
            ),
            alignment: Alignment.center,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final inset = 1.5;
    final innerRect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );
    canvas.drawArc(innerRect, -1.57, 1.8, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/commit_repository.dart';
import 'data/database.dart';
import 'models/commit_record.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/rest_screen.dart';
import 'screens/timing_screen.dart';
import 'theme.dart';
import 'utils/format.dart';
import 'widgets/agreement_dialog.dart';

void main() {
  runApp(const LishiApp());
}

class LishiApp extends StatefulWidget {
  const LishiApp({super.key});

  @override
  State<LishiApp> createState() => _LishiAppState();
}

enum AppState { idle, timing, resting }

class _LishiAppState extends State<LishiApp> {
  final _repository = CommitRepository(AppDatabase.instance);

  AppState _state = AppState.idle;
  String _thing = '';
  List<CommitRecord> _todayRecords = const [];

  /// null = 协议状态还没查完 (启动瞬间)
  /// true = 已同意, 直接进首页
  /// false = 还没同意, 显示弹窗
  bool? _agreementAccepted;

  @override
  void initState() {
    super.initState();
    _checkAgreement();
  }

  Future<void> _checkAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(AgreementDialog.prefsKey) ?? false;
    if (!mounted) return;
    setState(() => _agreementAccepted = accepted);
  }

  Future<void> _handleAgreementResult(bool agreed) async {
    if (agreed) {
      setState(() => _agreementAccepted = true);
      await _refreshToday();
    } else {
      // 用户拒绝, 退出 App
      await SystemNavigator.pop();
    }
  }

  Future<void> _refreshToday() async {
    final today = AppFormat.dateOnly(DateTime.now());
    final records = await _repository.findByDate(today);
    if (mounted) setState(() => _todayRecords = records);
  }

  void _startTiming(String desc) {
    setState(() {
      _thing = desc;
      _state = AppState.timing;
    });
  }

  Future<void> _submit(int durationSec) async {
    if (durationSec <= 0) return;
    final now = DateTime.now();
    final record = CommitRecord(
      desc: _thing,
      date: AppFormat.dateOnly(now),
      startTime: AppFormat.time(now.subtract(Duration(seconds: durationSec))),
      endTime: AppFormat.time(now),
      startAt: now.subtract(Duration(seconds: durationSec)),
      endAt: now,
      durationSec: durationSec,
    );
    await _repository.insert(record);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ 已记录: $_thing · ${AppFormat.duration(durationSec)}'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _thing = '';
      _state = AppState.resting;
    });
  }

  void _cancelTiming() {
    setState(() {
      _thing = '';
      _state = AppState.idle;
    });
  }

  Future<void> _finishResting() async {
    await _refreshToday();
    if (mounted) {
      setState(() => _state = AppState.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌟 可以开始新的事情了'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '粒时',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    // 1) 协议状态未知 → 加载中
    if (_agreementAccepted == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 2) 未同意 → 显示协议弹窗 (不可关闭, 不可返回)
    if (!_agreementAccepted!) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final result = await AgreementDialog.show(context);
        if (mounted) await _handleAgreementResult(result);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 3) 已同意 → 正常显示
    return Scaffold(
      body: switch (_state) {
        AppState.idle => HomeScreen(
            todayRecords: _todayRecords,
            onStart: _startTiming,
            onOpenHistory: _openHistory,
          ),
        AppState.timing => TimingScreen(
            thing: _thing,
            onSubmit: _submit,
            onCancel: _cancelTiming,
          ),
        AppState.resting => RestScreen(onFinish: _finishResting),
      },
    );
  }
}

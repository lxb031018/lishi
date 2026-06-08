import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

/// 首次启动"用户协议 + 隐私政策"同意弹窗。
///
/// 行为:
/// - 用户必须勾选"我已阅读并同意"才能点击"同意并继续"
/// - 点击"同意并继续": 写入 SharedPreferences, 弹窗关闭, [show] 返回 true
/// - 点击"不同意并退出": 弹窗关闭, [show] 返回 false (调用方应退出 App)
/// - 弹窗外不可关闭 (barrierDismissible: false)
/// - 返回键不可关闭 (WillPopScope / PopScope 拦截)
class AgreementDialog extends StatefulWidget {
  const AgreementDialog({super.key});

  /// SharedPreferences 的 key, 标记用户是否同意过。
  static const String prefsKey = 'lishi.agreement_accepted_v1';

  /// 显示弹窗, 返回 `true` 表示同意, `false` 表示拒绝。
  ///
  /// 用法: `final agreed = await AgreementDialog.show(context);`
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AgreementDialog(),
    );
    return result ?? false;
  }

  @override
  State<AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<AgreementDialog> {
  bool _agreed = false;
  bool _saving = false;

  Future<void> _onAgree() async {
    if (!_agreed || _saving) return;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AgreementDialog.prefsKey, true);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _onReject() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
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
                      '欢迎使用粒时',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '在开始之前, 请阅读并同意以下协议。本应用是一款离线工具, '
                  '不会收集你的任何个人信息, 你的所有数据都只保存在本机。',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // 协议卡片
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: const [
                        _DocCard(
                          title: '《粒时用户协议》',
                          summary: '约定你与开发者之间就使用本应用的权利和义务。',
                        ),
                        SizedBox(height: 10),
                        _DocCard(
                          title: '《粒时隐私政策》',
                          summary: '说明本应用如何处理你的信息。本应用不收集任何信息。',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 勾选
                Row(
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                      activeColor: AppColors.accent,
                    ),
                    const Expanded(
                      child: Text(
                        '我已阅读并同意上述协议',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _saving ? null : _onReject,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('不同意并退出'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: (_agreed && !_saving) ? _onAgree : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('同意并继续'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 单个协议卡 (标题 + 摘要)
class _DocCard extends StatelessWidget {
  const _DocCard({required this.title, required this.summary});
  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 粒时 配色: 暖色调, 灵感来自 demo 的 #faf7f2 底色 + #c77d4b 强调色。
/// 强调"做让自己舒服的事"那种柔和、克制的氛围。
class AppColors {
  AppColors._();

  // 背景 / 卡片
  static const bg = Color(0xFFFAF7F2);
  static const card = Colors.white;
  static const border = Color(0xFFE8E0D5);

  // 文字
  static const text = Color(0xFF2C2416);
  static const textSecondary = Color(0xFF6B5E4F);
  static const textMuted = Color(0xFF9B8D7C);

  // 强调 (橘色, 用于"开始"、"提交"等主动作)
  static const accent = Color(0xFFC77D4B);
  static const accentDeep = Color(0xFFA55D2E);
  static const accentLight = Color(0xFFE8C9A8);

  // 绿色 (用于"已完成"标记, 休息)
  static const green = Color(0xFF6B8F5E);
  static const greenLight = Color(0xFFD4E6CC);

  // 休息主题
  static const restBg = Color(0xFFFDF6EF);
  static const restAccent = Color(0xFFE0A86E);
  static const restBorder = Color(0xFFF0E0CC);
}

/// 全局 [ThemeData]: Material 3, 暖色调, 圆角 16。
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    surface: AppColors.bg,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'PingFang SC',
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFDFCFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}

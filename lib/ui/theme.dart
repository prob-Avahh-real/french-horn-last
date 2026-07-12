import 'package:flutter/material.dart';

/// 90/00 年代小学音乐课本视觉主题
final gameTheme = ThemeData(
  // 课本封面暖色调
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFE57373), // 小红花红
    primary: const Color(0xFFD32F2F), // 奖状红
    secondary: const Color(0xFF66BB6A), // 绿黑板
    surface: const Color(0xFFFFF8E1), // 课本纸黄
    onPrimary: Colors.white, // 奖状金字
    onSecondary: Colors.white,
    onSurface: const Color(0xFF3E2723), // 深棕文字
  ),

  scaffoldBackgroundColor: const Color(0xFFFFF8E1), // 课本纸黄

  // 使用老宋体风格
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 1,
    ),
  ),

  // 按钮样式 - 卡带录音机风格
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD32F2F),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFB71C1C), width: 2),
      ),
    ),
  ),
);

/// Game-specific colors
class GameColors {
  // 小红花
  static const flowerRed = Color(0xFFD32F2F);
  static const flowerYellow = Color(0xFFFFD600);

  // 课本纸张
  static const paperYellow = Color(0xFFFFF8E1);
  static const paperDark = Color(0xFFF5E6C8);

  // 黑板绿
  static const blackboardGreen = Color(0xFF2E7D32);
  static const chalkWhite = Color(0xFFF5F5F5);

  // 卡带灰
  static const cassetteGray = Color(0xFF616161);
  static const cassetteLight = Color(0xFF9E9E9E);

  // 红领巾红
  static const scarfRed = Color(0xFFC62828);

  // 奖状金
  static const awardGold = Color(0xFFFFD600);

  // Windows XP 蓝
  static const xpBlue = Color(0xFF245EDC);
  static const xpTaskbar = Color(0xFF235FDA);
  static const xpGreen = Color(0xFF3C9A00);

  // 判定文字颜色
  static const perfectColor = Color(0xFFFFD600); // 金色
  static const greatColor = Color(0xFF4CAF50); // 绿色
  static const goodColor = Color(0xFF2196F3); // 蓝色
  static const okColor = Color(0xFFFF9800); // 橙色
  static const missColor = Color(0xFF757575); // 灰色
}

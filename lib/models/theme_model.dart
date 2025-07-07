import 'package:flutter/material.dart';

/// 主题配置模型
class ThemeConfig {
  final String name;
  final String displayName;
  final MaterialColor primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final bool isDark;

  const ThemeConfig({
    required this.name,
    required this.displayName,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    this.isDark = false,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'backgroundColor': backgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'textColor': textColor.value,
      'isDark': isDark,
    };
  }

  /// 从JSON创建
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      name: json['name'],
      displayName: json['displayName'],
      primaryColor: MaterialColor(json['primaryColor'], const <int, Color>{}),
      accentColor: Color(json['accentColor']),
      backgroundColor: Color(json['backgroundColor']),
      surfaceColor: Color(json['surfaceColor']),
      textColor: Color(json['textColor']),
      isDark: json['isDark'] ?? false,
    );
  }
}

/// 主题管理器
class ThemeManager {
  /// 提供六套可选主题色（符合Flutter设计规范文档要求）
  static const List<ThemeConfig> availableThemes = [
    // 深蓝色主题 (基于截图风格)
    ThemeConfig(
      name: 'deep_sea',
      displayName: '深海蓝',
      primaryColor: MaterialColor(0xFF1A237E, <int, Color>{
        50: Color(0xFFE8EAF6),
        100: Color(0xFFC5CAE9),
        200: Color(0xFF9FA8DA),
        300: Color(0xFF7986CB),
        400: Color(0xFF5C6BC0),
        500: Color(0xFF3F51B5),
        600: Color(0xFF3949AB),
        700: Color(0xFF303F9F),
        800: Color(0xFF165CF6),
        900: Color(0xFF1A237E),
        1000: Color(0xFFD10D0D),
      }),
      accentColor: Color(0xFF3F51B5), // 靛蓝色
      backgroundColor: Color(0xFF0D1B2A), // 深蓝色背景
      surfaceColor: Color(0xFF333333), // 深蓝色表面 (100%不透明度)
      textColor: Colors.white, // 白色文字
      isDark: true,
    ),

    // 蓝色主题
    ThemeConfig(
      name: 'blue',
      displayName: '天空蓝',
      primaryColor: Colors.blue,
      accentColor: Color(0xFF1976D2),
      backgroundColor: Color(0xFFE3F2FD), // 淡蓝色背景
      surfaceColor: Color(0xFFF3F9FF),
      textColor: Colors.black87,
    ),

    // 青色主题
    ThemeConfig(
      name: 'cyan',
      displayName: '青绿色',
      primaryColor: Colors.cyan,
      accentColor: Color(0xFF00ACC1),
      backgroundColor: Color(0xFFE0F7FA), // 淡青色背景
      surfaceColor: Color(0xFFF0FDFF),
      textColor: Colors.black87,
    ),

    // 蓝绿色主题
    ThemeConfig(
      name: 'teal',
      displayName: '蓝绿色',
      primaryColor: Colors.teal,
      accentColor: Color(0xFF00695C),
      backgroundColor: Color(0xFFE0F2F1), // 淡蓝绿色背景
      surfaceColor: Color(0xFFF0FFF4),
      textColor: Colors.black87,
    ),

    // 红色主题
    ThemeConfig(
      name: 'red',
      displayName: '活力红',
      primaryColor: Colors.red,
      accentColor: Color(0xFFD32F2F),
      backgroundColor: Color(0xFFFFEBEE), // 淡红色背景
      surfaceColor: Color(0xFFFFF5F5),
      textColor: Colors.black87,
    ),
  ];

  /// 获取主题配置根据名称
  static ThemeConfig? getThemeByName(String name) {
    try {
      return availableThemes.firstWhere((theme) => theme.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 获取主题配置根据索引
  static ThemeConfig getThemeByIndex(int index) {
    if (index >= 0 && index < availableThemes.length) {
      return availableThemes[index];
    }
    return availableThemes[0]; // 默认返回第一个主题
  }

  /// 根据主题配置生成Flutter ThemeData
  static ThemeData generateThemeData(
    ThemeConfig config, {
    bool isDark = false,
  }) {
    final colorScheme =
        isDark
            ? ColorScheme.dark(
              primary: config.primaryColor,
              secondary: config.accentColor,
              background: const Color(0xFF121212),
              surface: const Color(0xFF1E1E1E),
            )
            : ColorScheme.light(
              primary: config.primaryColor,
              secondary: config.accentColor,
              background: config.backgroundColor,
              surface: config.surfaceColor,
            );

    return ThemeData(
      colorScheme: colorScheme,
      primarySwatch: config.primaryColor,
      useMaterial3: true,

      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // 卡片主题
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: config.primaryColor, width: 2),
        ),
      ),

      // FloatingActionButton主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

import '../states/state_manager.dart';
import '../states/user_state.dart';
import '../states/chat_state.dart';
import '../states/app_state.dart';
import '../models/theme_model.dart';
import 'package:flutter/material.dart';

/// 全局状态访问类
/// 保持向后兼容的同时提供新的状态管理方式
class Global {
  /// 状态管理器实例
  static StateManager get stateManager => StateManager();
  
  /// 用户状态
  static UserState get userState => StateManager().user;
  

  
  /// 聊天状态
  static ChatState get chatState => StateManager().chat;
  
  /// 应用状态
  static AppState get appState => StateManager().app;
  
  /// 提供五套可选主题色（向后兼容）
  static List<MaterialColor> get themes => [
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.red,
  ];

  /// 获取当前主题配置
  static ThemeConfig get currentTheme => appState.currentThemeConfig;
  
  /// 获取当前主题数据
  static ThemeData get currentThemeData => appState.currentThemeData;
  
  /// 获取可用主题列表
  static List<ThemeConfig> get availableThemes => ThemeManager.availableThemes;

  /// 初始化全局状态
  static Future<void> initialize() async {
    await StateManager().initialize();
    // 加载应用设置（包括主题设置）
    await appState.loadSettingsFromLocal();
  }
  
  /// 用户登录后初始化
  static Future<void> initializeUserData() async {
    await StateManager().initializeUserData();
  }
  
  /// 清理用户数据
  static void clearUserData() {
    StateManager().clearUserData();
  }
  
  /// 刷新所有数据
  static Future<void> refreshAll() async {
    await StateManager().refreshAll();
  }
  
  /// 重置所有状态
  static void resetAll() {
    StateManager().resetAll();
  }
  
  // === 便捷访问方法 ===
  
  /// 用户相关便捷访问
  static bool get isLoggedIn => userState.isLoggedIn;
  static String get userName => userState.userName;
  static Map<String, dynamic> get userInfo => userState.userInfo;
  

  
  /// 应用相关便捷访问
  static int get currentTabIndex => appState.currentIndex;
  static bool get isDarkMode => appState.isDarkMode;
  static bool get isOnline => appState.isOnline;
  
  /// 主题相关便捷访问
  static int get currentThemeIndex => appState.currentThemeIndex;
  static Color get currentTextColor => currentTheme.textColor;
  static void setTheme(int themeIndex) => appState.setTheme(themeIndex);
  static void setThemeByName(String themeName) => appState.setThemeByName(themeName);
  static void switchToNextTheme() => appState.switchToNextTheme();
  
  /// 聊天相关便捷访问
  static int get messageCount => chatState.messages.length;
  static bool get isAITyping => chatState.isTyping;
}

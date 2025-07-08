import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/theme_model.dart';

/// 应用全局状态管理类
/// 负责管理导航、主题、网络状态等全局状态
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // 导航相关
  int _currentIndex = 0;
  PageController? _pageController;
  
  // 主题相关
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;
  int _currentThemeIndex = 0; // 当前主题索引，默认为深蓝色主题
  ThemeConfig _currentThemeConfig = ThemeManager.availableThemes[0];
  
  // 网络状态
  bool _isOnline = true;
  String _networkStatus = '网络连接正常';
  
  // 加载状态
  bool _isAppLoading = false;
  String _loadingMessage = '';
  
  // 应用设置
  Map<String, dynamic> _appSettings = {
    'notifications_enabled': true,
    'sound_enabled': true,
    'vibration_enabled': true,
    'language': 'zh-CN',
    'font_size': 'medium',
    'theme_index': 0, // 默认深蓝色主题
  };

  // Getters
  int get currentIndex => _currentIndex;
  PageController? get pageController => _pageController;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isOnline => _isOnline;
  String get networkStatus => _networkStatus;
  bool get isAppLoading => _isAppLoading;
  String get loadingMessage => _loadingMessage;
  Map<String, dynamic> get appSettings => Map.from(_appSettings);
  
  // 主题相关Getters
  int get currentThemeIndex => _currentThemeIndex;
  ThemeConfig get currentThemeConfig => _currentThemeConfig;
  List<ThemeConfig> get availableThemes => ThemeManager.availableThemes;
  ThemeData get currentThemeData => ThemeManager.generateThemeData(_currentThemeConfig, isDark: _isDarkMode);
  
  // 具体设置项的便捷访问
  bool get notificationsEnabled => _appSettings['notifications_enabled'] ?? true;
  bool get soundEnabled => _appSettings['sound_enabled'] ?? true;
  bool get vibrationEnabled => _appSettings['vibration_enabled'] ?? true;

  String get language => _appSettings['language'] ?? 'zh-CN';
  String get fontSize => _appSettings['font_size'] ?? 'medium';

  /// 设置页面控制器
  void setPageController(PageController controller) {
    _pageController = controller;
  }

  /// 更新当前导航索引
  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  /// 导航到指定页面
  void navigateToPage(int index) {
    if (_pageController != null && index != _currentIndex) {
      _currentIndex = index;
      _pageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// 切换主题模式
  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    notifyListeners();
  }

  /// 更新网络状态
  void updateNetworkStatus(bool isOnline, [String? status]) {
    _isOnline = isOnline;
    _networkStatus = status ?? (isOnline ? '网络连接正常' : '网络连接异常');
    notifyListeners();
  }

  /// 设置应用加载状态
  void setAppLoading(bool loading, [String message = '']) {
    _isAppLoading = loading;
    _loadingMessage = message;
    notifyListeners();
  }

  /// 更新应用设置
  void updateSetting(String key, dynamic value) {
    _appSettings[key] = value;
    notifyListeners();
    
    // TODO: 保存到本地存储
    _saveSettingsToLocal();
  }

  /// 批量更新设置
  void updateSettings(Map<String, dynamic> settings) {
    _appSettings.addAll(settings);
    notifyListeners();
    
    // TODO: 保存到本地存储
    _saveSettingsToLocal();
  }

  /// 切换通知开关
  void toggleNotifications() {
    updateSetting('notifications_enabled', !notificationsEnabled);
  }

  /// 切换声音开关
  void toggleSound() {
    updateSetting('sound_enabled', !soundEnabled);
  }

  /// 切换震动开关
  void toggleVibration() {
    updateSetting('vibration_enabled', !vibrationEnabled);
  }



  /// 设置语言
  void setLanguage(String languageCode) {
    updateSetting('language', languageCode);
  }

  /// 设置字体大小
  void setFontSize(String size) {
    updateSetting('font_size', size);
  }

  /// 设置主题色
  void setTheme(int themeIndex) {
    if (themeIndex >= 0 && themeIndex < ThemeManager.availableThemes.length) {
      _currentThemeIndex = themeIndex;
      _currentThemeConfig = ThemeManager.availableThemes[themeIndex];
      updateSetting('theme_index', themeIndex);
      notifyListeners();
    }
  }

  /// 根据名称设置主题
  void setThemeByName(String themeName) {
    final theme = ThemeManager.getThemeByName(themeName);
    if (theme != null) {
      final index = ThemeManager.availableThemes.indexOf(theme);
      setTheme(index);
    }
  }

  /// 切换到下一个主题
  void switchToNextTheme() {
    final nextIndex = (_currentThemeIndex + 1) % ThemeManager.availableThemes.length;
    setTheme(nextIndex);
  }

  /// 从本地存储加载设置
  Future<void> loadSettingsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');
      
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _appSettings.addAll(settingsMap);
        
        // 加载主题设置
        final themeIndex = _appSettings['theme_index'] ?? 0;
        if (themeIndex >= 0 && themeIndex < ThemeManager.availableThemes.length) {
          _currentThemeIndex = themeIndex;
          _currentThemeConfig = ThemeManager.availableThemes[themeIndex];
        }
        
        notifyListeners();
      }
      
      print('设置已从本地存储加载');
    } catch (e) {
      print('加载设置失败: $e');
    }
  }

  /// 保存设置到本地存储
  Future<void> _saveSettingsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', json.encode(_appSettings));
      
      print('设置已保存到本地存储');
    } catch (e) {
      print('保存设置失败: $e');
    }
  }

  /// 重置所有设置为默认值
  void resetSettings() {
    _appSettings = {
      'notifications_enabled': true,
      'sound_enabled': true,
      'vibration_enabled': true,
      'language': 'zh-CN',
      'font_size': 'medium',
      'theme_index': 0,
    };
    
    // 重置主题到默认蓝色主题
    _currentThemeIndex = 0;
    _currentThemeConfig = ThemeManager.availableThemes[0];
    
    notifyListeners();
    _saveSettingsToLocal();
  }

  /// 获取字体大小数值
  double getFontSizeValue() {
    switch (fontSize) {
      case 'small':
        return 0.8;
      case 'large':
        return 1.2;
      case 'extra_large':
        return 1.4;
      default: // medium
        return 1.0;
    }
  }

  /// 重置状态
  void reset() {
    _currentIndex = 0;
    _pageController = null;
    _themeMode = ThemeMode.light;
    _isDarkMode = false;
    _isOnline = true;
    _networkStatus = '网络连接正常';
    _isAppLoading = false;
    _loadingMessage = '';
    resetSettings();
  }

  /// 释放资源
  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }
} 
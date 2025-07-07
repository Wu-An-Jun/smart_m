// lib/core/constants/app_constants.dart
/// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = '智能管家';
  static const String appVersion = '1.0.0';
  
  // 图片资源路径
  static const String imgPath = 'imgs/';
  
  // API相关
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // 本地存储键名
  static const String userInfoKey = 'user_info';
  static const String deviceListKey = 'device_list';
  static const String themeKey = 'theme_mode';
  
  // 页面跳转动画时长
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  // 默认分页大小
  static const int defaultPageSize = 20;
}

/// 图片资源路径常量
class ImageAssets {
  static const String _basePath = 'imgs/';
  
  // 导航图标
  static const String navHome = '${_basePath}nav_home.svg';
  static const String navDevice = '${_basePath}nav_device.svg';
  static const String navProfile = '${_basePath}nav_profile.svg';
  static const String navBack = '${_basePath}nav_back.svg';
  
  // 设备相关
  static const String bluetoothDevice = '${_basePath}bluetooth_device.svg';
  static const String deviceCard = '${_basePath}device_card_icon.svg';
  static const String deviceMatchSuccess = '${_basePath}device_match_success.svg';
  
  // 功能图标
  static const String actionScan = '${_basePath}action_scan.svg';
  static const String actionManual = '${_basePath}action_manual.svg';
  static const String scanQrBind = '${_basePath}scan_qr_bind.svg';
  
  // 用户头像
  static const String userAvatar = '${_basePath}user_avatar.jpeg';
  
  // 登录相关
  static const String loginBg = '${_basePath}login_bg.png';
  static const String loginIcon = '${_basePath}login_icon.png';
}

/// 颜色常量
class AppColors {
  // 主色调
  static const int primaryBlue = 0xFF3B82F6;
  static const int primaryGreen = 0xFF10B981;
  static const int primaryRed = 0xFFEF4444;
  
  // 灰色系
  static const int gray50 = 0xFFF9FAFB;
  static const int gray100 = 0xFFF3F4F6;
  static const int gray200 = 0xFFE5E7EB;
  static const int gray300 = 0xFFD1D5DB;
  static const int gray400 = 0xFF9CA3AF;
  static const int gray500 = 0xFF6B7280;
  static const int gray600 = 0xFF4B5563;
  static const int gray700 = 0xFF374151;
  static const int gray800 = 0xFF1F2937;
  static const int gray900 = 0xFF111827;
}

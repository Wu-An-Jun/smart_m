// lib/core/config/app_config.dart
/// 应用配置类
class AppConfig {
  // 环境配置
  static const bool isDebug = true;
  static const bool enableLogging = true;
  
  // API配置
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  
  // 高德地图配置
  static const String amapApiKey = 'your_amap_api_key';
  
  // Dify AI配置
  static const String difyApiKey = 'your_dify_api_key';
  static const String difyBaseUrl = 'https://api.dify.ai';
  
  // 获取完整API地址
  static String get fullApiUrl => '$baseUrl/$apiVersion';
  
  // 获取环境名称
  static String get environmentName => isDebug ? 'Development' : 'Production';
}

/// 功能开关配置
class FeatureFlags {
  // AI助手功能
  static const bool enableAiAssistant = true;
  
  // 地理围栏功能
  static const bool enableGeofence = true;
  
  // 设备自动化功能
  static const bool enableAutomation = true;
  
  // 视频播放功能
  static const bool enableVideoPlayer = true;
  
  // 语音识别功能
  static const bool enableVoiceRecognition = false;
  
  // 推送通知功能
  static const bool enablePushNotification = true;
}

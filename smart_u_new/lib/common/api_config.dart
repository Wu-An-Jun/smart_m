/// API 配置类
/// 包含所有API密钥和配置信息
class ApiConfig {
  // 高德地图 Web API Key (JS API - 用于WebView中的地图)
  static const String amapWebApiKey = '0ec49d3ec6aafff4bc085f06c1f1ba9a';
  
  // 高德地图移动端 API Key (移动端SDK - 用于原生定位等功能)
  static const String amapMobileApiKey = '4d5cd92071b56445e2e2d25db4d32e93';
  
  // 高德地图安全密钥 (从控制台获取)
  static const String amapSecurityCode = '2c9ee61b57457dd9453f6e9675ae5bcd';
  
  /// 检查API密钥是否已配置
  static bool get isAmapConfigured {
    return amapWebApiKey != 'your_amap_web_api_key_here' &&
           amapMobileApiKey != 'your_amap_mobile_api_key_here' &&
           amapWebApiKey.isNotEmpty &&
           amapMobileApiKey.isNotEmpty;
  }
  
  /// 获取配置状态描述
  static String get configStatus {
    if (isAmapConfigured) {
      return '高德地图API已配置 (Web+Mobile)';
    } else {
      return '请配置高德地图API密钥';
    }
  }
} 
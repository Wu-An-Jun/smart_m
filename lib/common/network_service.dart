import 'package:dio/dio.dart';

class NetworkService {
  static const String _testUrl = 'https://dashscope.aliyuncs.com';
  
  /// 检查网络连接状态
  static Future<bool> checkNetworkConnection() async {
    try {
      // 尝试连接到API服务器
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.options.validateStatus = (status) => status != null && status < 500; // 允许4xx状态码
      
      final response = await dio.get(_testUrl);
      return response.statusCode != null && response.statusCode! < 500; // 小于500都算连通
    } on DioException catch (e) {
      print('网络检查错误: ${e.message}');
      return false;
    } catch (e) {
      print('网络检查未知错误: $e');
      return false;
    }
  }
  
  /// 获取网络状态描述
  static Future<String> getNetworkStatus() async {
    try {
      final hasConnection = await checkNetworkConnection();
      if (hasConnection) {
        return '网络连接正常';
      } else {
        return '网络连接异常，请检查网络设置';
      }
    } catch (e) {
      return '无法检测网络状态';
    }
  }
} 
// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// 日志工具类
class Logger {
  static const String _tag = 'SmartU';
  
  /// 调试日志
  static void d(String message, [String? tag]) {
    if (AppConfig.enableLogging && kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }
  
  /// 信息日志
  static void i(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      print('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }
  
  /// 警告日志
  static void w(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      print('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }
  
  /// 错误日志
  static void e(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      print('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
}

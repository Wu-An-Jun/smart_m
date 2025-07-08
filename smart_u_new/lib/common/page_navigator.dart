import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

/// 页面导航工具类
/// 根据AI返回的页面编号进行跳转
class PageNavigator {
  /// 页面编号映射表
  static const Map<int, String> _pageRoutes = {
    // 首页相关 (10-19)
    10: AppRoutes.home,
    11: AppRoutes.main,
    
    // 设备管理 (20-29)
    20: AppRoutes.deviceManagement,
    21: AppRoutes.deviceList,
    22: AppRoutes.addDevice,
    
    // 智能生活 (30-39)
    30: AppRoutes.smartLife,
    31: AppRoutes.smartHomeAutomation,
    
    // 自动化规则 (40-49)
    40: AppRoutes.automationCreation,
    41: AppRoutes.smartLife,
    42: AppRoutes.smartLife,
    43: AppRoutes.smartLife,
    
    // AI助手 (50-59)
    50: AppRoutes.aiAssistant,
    51: AppRoutes.aiAssistantTest,
    52: AppRoutes.assistant,
    
    // 服务页面 (60-69)
    60: AppRoutes.service,
    
    // 地图定位 (70-79)
    70: AppRoutes.map,
    
    // 个人中心 (80-89)
    80: AppRoutes.profile,
    
    // 登录认证 (90-99)
    90: AppRoutes.login,
  };

  /// 页面名称映射表
  static const Map<int, String> _pageNames = {
    // 首页相关
    10: '首页',
    11: '主页面',
    
    // 设备管理
    20: '设备管理',
    21: '设备列表',
    22: '添加设备',
    
    // 智能生活
    30: '智能生活',
    31: '智能家居自动化',
    
    // 自动化规则
    40: '自动化创建',
    41: '时间条件设置',
    42: '环境条件设置',
    43: '任务设置',
    
    // AI助手
    50: 'AI助手',
    51: 'AI助手测试',
    52: '智能助手',
    
    // 服务页面
    60: '服务',
    
    // 地图定位
    70: '地图',
    
    // 个人中心
    80: '个人资料',
    
    // 登录认证
    90: '登录',
  };

  /// 根据页面编号跳转页面
  /// [pageCode] AI返回的页面编号
  /// [showSnackbar] 是否显示跳转提示
  /// 返回是否跳转成功
  static bool navigateToPage(int pageCode, {bool showSnackbar = true}) {
    final route = _pageRoutes[pageCode];
    final pageName = _pageNames[pageCode];

    if (route == null) {
      if (showSnackbar) {
        Get.snackbar(
          '跳转失败',
          '未找到对应页面 (编号: $pageCode)',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
      return false;
    }

    try {
      Get.toNamed(route);
      
      if (showSnackbar) {
        Get.snackbar(
          '页面跳转',
          '正在为您打开「$pageName」',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      }
      
      return true;
    } catch (e) {
      if (showSnackbar) {
        Get.snackbar(
          '跳转失败',
          '打开「$pageName」失败: $e',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
      return false;
    }
  }

  /// 获取页面名称
  static String? getPageName(int pageCode) {
    return _pageNames[pageCode];
  }

  /// 获取页面路由
  static String? getPageRoute(int pageCode) {
    return _pageRoutes[pageCode];
  }

  /// 检查页面编号是否有效
  static bool isValidPageCode(int pageCode) {
    return _pageRoutes.containsKey(pageCode);
  }

  /// 获取所有可用的页面编号
  static List<int> getAllPageCodes() {
    return _pageRoutes.keys.toList()..sort();
  }

  /// 根据页面名称搜索编号
  static List<int> searchPagesByName(String name) {
    final results = <int>[];
    _pageNames.forEach((code, pageName) {
      if (pageName.contains(name)) {
        results.add(code);
      }
    });
    return results;
  }

  /// 创建跳转按钮Widget
  /// [pageCode] 页面编号
  /// [buttonText] 按钮文字，为空时使用页面名称
  /// [style] 按钮样式
  static Widget createNavigationButton(
    int pageCode, {
    String? buttonText,
    ButtonStyle? style,
  }) {
    final pageName = _pageNames[pageCode];
    if (pageName == null) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: () => navigateToPage(pageCode),
      style: style ?? ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B4DFF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_forward, size: 16),
          const SizedBox(width: 4),
          Text(
            buttonText ?? pageName,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 处理AI返回的导航JSON
  /// [aiResponse] AI返回的JSON字符串或Map
  static bool handleAINavigation(dynamic aiResponse) {
    try {
      Map<String, dynamic> response;
      
      if (aiResponse is String) {
        // 如果是JSON字符串，尝试解析
        response = Get.find<dynamic>().fromJson(aiResponse);
      } else if (aiResponse is Map<String, dynamic>) {
        response = aiResponse;
      } else {
        return false;
      }

      // 检查是否是导航操作
      if (response['action'] != 'navigate') {
        return false;
      }

      final pageCode = response['page_code'];
      if (pageCode is! int) {
        return false;
      }

      return navigateToPage(pageCode);
    } catch (e) {
      print('处理AI导航失败: $e');
      return false;
    }
  }
}

/// AI导航响应模型
class AINavigationResponse {
  final String action;
  final int pageCode;
  final String pageName;
  final String reason;

  const AINavigationResponse({
    required this.action,
    required this.pageCode,
    required this.pageName,
    required this.reason,
  });

  factory AINavigationResponse.fromJson(Map<String, dynamic> json) {
    return AINavigationResponse(
      action: json['action'] ?? '',
      pageCode: json['page_code'] ?? 0,
      pageName: json['page_name'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'page_code': pageCode,
      'page_name': pageName,
      'reason': reason,
    };
  }

  /// 执行导航
  bool navigate({bool showSnackbar = true}) {
    return PageNavigator.navigateToPage(pageCode, showSnackbar: showSnackbar);
  }
} 
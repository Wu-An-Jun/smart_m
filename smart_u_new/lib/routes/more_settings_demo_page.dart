import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/smart_home_layout.dart';
import '../widgets/more_settings_dialog.dart';
import '../widgets/center_popup.dart';
import '../common/Global.dart';

/// 更多设置演示页面
class MoreSettingsDemoPage extends StatefulWidget {
  const MoreSettingsDemoPage({super.key});

  @override
  State<MoreSettingsDemoPage> createState() => _MoreSettingsDemoPageState();
}

class _MoreSettingsDemoPageState extends State<MoreSettingsDemoPage> {
  @override
  Widget build(BuildContext context) {
    return SmartHomeLayout(
      title: '更多设置演示',
      showBackButton: true,
      child: Container(
        color: Global.currentTheme.backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 功能介绍卡片
              _buildIntroCard(),
              
              const SizedBox(height: 20),
              
              // 演示区域
              _buildDemoSection(),
              
              const SizedBox(height: 20),
              
              // 原始按钮样式演示
              _buildOriginalButtonDemo(),
              
              const SizedBox(height: 20),
              
              // 标准按钮演示
              _buildStandardButtonDemo(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建功能介绍卡片
  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Global.currentTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings,
                  color: Global.currentTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '更多设置弹窗',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '这是一个智能设备的更多设置弹窗组件，包含三个主要功能：',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem('一键重启', '快速重启设备，解决常见问题', Icons.restart_alt, Colors.grey),
          _buildFeatureItem('远程唤醒', '远程唤醒处于休眠状态的设备', Icons.notifications, Colors.red),
          _buildFeatureItem('恢复出厂设置', '将设备恢复到初始状态（需确认）', Icons.refresh, Colors.blue),
        ],
      ),
    );
  }

  /// 构建功能项
  Widget _buildFeatureItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建演示区域
  Widget _buildDemoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '点击演示',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '点击下面的按钮体验更多设置弹窗功能：',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _showMoreSettingsDialog,
              icon: const Icon(Icons.settings),
              label: const Text('显示更多设置'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Global.currentTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建原始按钮样式演示
  Widget _buildOriginalButtonDemo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '原始按钮样式',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '这是您提供的原始按钮样式：',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: _buildOriginalButton(),
          ),
        ],
      ),
    );
  }

  /// 构建原始按钮
  Widget _buildOriginalButton() {
    return GestureDetector(
      onTap: _showMoreSettingsDialog,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Global.currentTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: Global.currentTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '更多设置',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Global.currentTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标准按钮演示
  Widget _buildStandardButtonDemo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '标准按钮样式',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '也可以使用标准的按钮样式：',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: _showMoreSettingsDialog,
                icon: const Icon(Icons.settings),
                label: const Text('设置'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Global.currentTheme.primaryColor,
                  side: BorderSide(color: Global.currentTheme.primaryColor),
                ),
              ),
              FilledButton.icon(
                onPressed: _showMoreSettingsDialog,
                icon: const Icon(Icons.settings),
                label: const Text('设置'),
                style: FilledButton.styleFrom(
                  backgroundColor: Global.currentTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示更多设置弹窗
  void _showMoreSettingsDialog() {
    MoreSettingsDialog.show(
      context,
      onOneKeyRestart: () {
        _handleOneKeyRestart();
      },
      onRemoteWakeup: () {
        _handleRemoteWakeup();
      },
      onFactoryReset: () {
        _handleFactoryReset();
      },
    );
  }

  /// 处理一键重启
  void _handleOneKeyRestart() {
    CenterPopup.show(context, '正在重启设备...', duration: const Duration(seconds: 3));
    
    // 模拟重启过程
    Future.delayed(const Duration(seconds: 3), () {
      CenterPopup.show(context, '设备重启成功！', duration: const Duration(seconds: 2));
    });
  }

  /// 处理远程唤醒
  void _handleRemoteWakeup() {
    CenterPopup.show(context, '正在唤醒设备...', duration: const Duration(seconds: 2));
    
    // 模拟唤醒过程
    Future.delayed(const Duration(seconds: 2), () {
      CenterPopup.show(context, '设备已成功唤醒！', duration: const Duration(seconds: 2));
    });
  }

  /// 处理恢复出厂设置
  void _handleFactoryReset() {
    CenterPopup.show(context, '正在恢复出厂设置...', duration: const Duration(seconds: 4));
    
    // 模拟恢复过程
    Future.delayed(const Duration(seconds: 4), () {
      CenterPopup.show(context, '出厂设置恢复完成！', duration: const Duration(seconds: 2));
    });
  }
} 
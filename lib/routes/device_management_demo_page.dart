import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../common/Global.dart';

/// 设备管理演示页面 - 用于展示两种状态
class DeviceManagementDemoPage extends StatefulWidget {
  const DeviceManagementDemoPage({super.key});

  @override
  State<DeviceManagementDemoPage> createState() => _DeviceManagementDemoPageState();
}

class _DeviceManagementDemoPageState extends State<DeviceManagementDemoPage> {
  final DeviceController controller = Get.find<DeviceController>();

  @override
  void initState() {
    super.initState();
    // 默认先清空设备，展示空状态
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.clearAllDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor, // 使用全局主题背景色
      appBar: AppBar(
        title: const Text('设备管理演示'),
        backgroundColor: const Color(0xFFE6E7F0),
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          // 状态切换按钮
          Obx(() {
            final hasDevices = controller.devices.isNotEmpty;
            return TextButton(
              onPressed: hasDevices ? _clearDevices : _addMockDevices,
              child: Text(
                hasDevices ? '清空设备' : '添加设备',
                style: const TextStyle(color: Colors.blue),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStateIndicator(),
            Expanded(
              child: Obx(() {
                final hasDevices = controller.devices.isNotEmpty;
                
                if (controller.isLoading) {
                  return _buildLoadingState();
                }
                
                return Container(
                  margin: const EdgeInsets.all(16),
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
                  child: hasDevices ? _buildDeviceListState() : _buildEmptyState(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 状态指示器
  Widget _buildStateIndicator() {
    return Obx(() {
      final hasDevices = controller.devices.isNotEmpty;
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasDevices ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDevices ? Colors.green : Colors.orange,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasDevices ? Icons.check_circle : Icons.info,
              color: hasDevices ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              hasDevices 
                ? '当前状态：我的设备页面（有 ${controller.devices.length} 个设备）'
                : '当前状态：设备管理页面（无设备）',
              style: TextStyle(
                color: hasDevices ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 无设备空状态界面
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 顶部标题
          const Text(
            '设备管理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          
          // 空状态提示
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '暂无设备，请先绑定设备！',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                
                // 绑定按钮
                GestureDetector(
                  onTap: _addMockDevices,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6), // 紫色按钮
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '绑定',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 有设备时的列表状态
  Widget _buildDeviceListState() {
    return Column(
      children: [
        // 顶部标题
        Container(
          padding: const EdgeInsets.all(20),
          child: const Row(
            children: [
              Text(
                '我的设备',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        
        // 设备列表
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildDeviceGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 设备网格布局
  Widget _buildDeviceGrid() {
    return Obx(() {
      final devices = controller.devices;
      
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildDeviceItem(devices[index]);
        },
      );
    });
  }

  /// 设备项
  Widget _buildDeviceItem(DeviceModel device) {
    return Container(
      padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
      child: Row(
        children: [
          // 设备图标
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB366), // 橙色图标背景
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 设备信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.description ?? '深圳市万象城',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // 连接状态图标
          Icon(
            device.isOnline ? Icons.wifi : Icons.wifi_off,
            color: device.isOnline ? Colors.green : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  /// 获取设备图标
  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.camera:
        return Icons.videocam;
      case DeviceType.map:
        return Icons.map;
      case DeviceType.petTracker:
        return Icons.location_on;
      case DeviceType.smartSwitch:
        return Icons.toggle_on;
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.router:
        return Icons.router;
    }
  }

  /// 加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
          SizedBox(height: 16),
          Text('加载设备中...', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  /// 添加模拟设备
  void _addMockDevices() {
    controller.loadDevices();
  }

  /// 清空设备
  Future<void> _clearDevices() async {
    await controller.clearAllDevices();
  }
} 
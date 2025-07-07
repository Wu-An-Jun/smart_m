import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/device_model.dart';
import '../controllers/device_controller.dart';
import 'video_player_widget.dart';
import 'map_widget.dart';
import 'device_card.dart';

/// 主页设备区域组件
class HomeDeviceSection extends StatelessWidget {
  const HomeDeviceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeviceController>(
      init: DeviceController(),
      builder: (controller) {
        // 获取摄像头和地图设备
        final cameraDevice = controller.devices
            .where((device) => device.type == DeviceType.camera)
            .where((device) => device.isOnline)
            .firstOrNull;
            
        final mapDevice = controller.devices
            .where((device) => device.type == DeviceType.map)
            .where((device) => device.isOnline)
            .firstOrNull;
            
        // 获取其他设备
        final otherDevices = controller.devices
            .where((device) => 
                device.type != DeviceType.camera && 
                device.type != DeviceType.map)
            .toList();

        // 状态1: 没有设备
        if (controller.devices.isEmpty) {
          return _buildEmptyState();
        }

        // 状态2: 只有摄像头或地图设备
        if ((cameraDevice != null || mapDevice != null) && otherDevices.isEmpty) {
          return _buildMainDeviceOnly(cameraDevice, mapDevice);
        }

        // 状态3: 有摄像头/地图设备 + 其他设备
        if ((cameraDevice != null || mapDevice != null) && otherDevices.isNotEmpty) {
          return _buildMainDeviceWithOthers(cameraDevice, mapDevice, otherDevices);
        }

        // 默认: 只有其他设备
        return _buildOtherDevicesOnly(otherDevices);
      },
    );
  }

  /// 状态1: 空状态 - 没有设备
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无设备',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加您的第一个设备',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/device-management'),
            icon: const Icon(Icons.add),
            label: const Text('添加设备'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 状态2: 只有摄像头或地图设备
  Widget _buildMainDeviceOnly(DeviceModel? cameraDevice, DeviceModel? mapDevice) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('我的设备'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: cameraDevice != null
                  ? _buildCameraWidget(cameraDevice)
                  : _buildMapWidget(mapDevice!),
            ),
          ),
        ],
      ),
    );
  }

  /// 状态3: 有摄像头/地图设备 + 其他设备
  Widget _buildMainDeviceWithOthers(
    DeviceModel? cameraDevice,
    DeviceModel? mapDevice,
    List<DeviceModel> otherDevices,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('我的设备'),
          const SizedBox(height: 12),
          
          // 主设备 (摄像头或地图)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: cameraDevice != null
                  ? _buildCameraWidget(cameraDevice)
                  : _buildMapWidget(mapDevice!),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 其他设备
          _buildOtherDevicesGrid(otherDevices),
        ],
      ),
    );
  }

  /// 只有其他设备的情况
  Widget _buildOtherDevicesOnly(List<DeviceModel> devices) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('我的设备'),
          const SizedBox(height: 12),
          _buildOtherDevicesGrid(devices),
        ],
      ),
    );
  }

  /// 构建区域标题
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed('/device-management'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '管理',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Color(0xFF6366F1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建摄像头组件
  Widget _buildCameraWidget(DeviceModel device) {
    return Stack(
      children: [
        VideoPlayerWidget(
          videoUrl: device.videoUrl,
          autoPlay: false,
          showControls: true,
        ),
        // 设备信息叠加层
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  device.isOnline ? Icons.videocam : Icons.videocam_off,
                  color: device.isOnline ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建地图组件
  Widget _buildMapWidget(DeviceModel device) {
    return Stack(
      children: [
        MapWidget(
          latitude: 39.9042,
          longitude: 116.4074,
          locationName: device.name,
        ),
        // 设备信息叠加层
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  device.isOnline ? Icons.map : Icons.map_outlined,
                  color: device.isOnline ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建其他设备网格
  Widget _buildOtherDevicesGrid(List<DeviceModel> devices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (devices.isNotEmpty) ...[
          const Text(
            '其他设备',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return DeviceCard(
              device: devices[index],
              onTap: () => _onDeviceTap(devices[index]),
            );
          },
        ),
      ],
    );
  }

  /// 设备点击处理
  void _onDeviceTap(DeviceModel device) {
    // 可以根据设备类型跳转到不同的详情页面
    switch (device.type) {
      case DeviceType.petTracker:
        Get.toNamed('/map-page', arguments: device);
        break;
      case DeviceType.smartSwitch:
      case DeviceType.router:
      case DeviceType.light:
        // 显示设备控制面板
        _showDeviceControlPanel(device);
        break;
      default:
        Get.toNamed('/device-management');
    }
  }

  /// 显示设备控制面板
  void _showDeviceControlPanel(DeviceModel device) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              device.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // 这里可以添加具体的设备控制界面
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }
} 
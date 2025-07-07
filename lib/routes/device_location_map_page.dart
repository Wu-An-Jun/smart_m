import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../common/Global.dart';
import '../models/device_model.dart';
import '../widgets/geofence_map_widget.dart';

/// 设备定位地图页面控制器
class DeviceLocationMapController extends GetxController {
  final RxString currentAddress = '正在获取位置...'.obs;
  final RxString currentCoordinates = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool locationEnabled = false.obs;
  final RxList<String> tasks = <String>["宠物离开小区时给我发消息", "每天10点以后关闭定位"].obs;
  
  // 设备信息
  String? deviceId;
  String? deviceName;
  String? deviceType;
  
  @override
  void onInit() {
    super.onInit();
    // 获取传递的设备参数
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      deviceId = arguments['deviceId'];
      deviceName = arguments['deviceName'];
      deviceType = arguments['deviceType'];
    }
    getCurrentLocation();
  }

  /// 移除任务
  void removeTask(String task) {
    tasks.remove(task);
  }

  /// 获取当前位置
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      
      // 检查位置权限
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress.value = '位置服务未开启';
        Get.snackbar('错误', '位置服务未开启，请在设置中开启位置服务');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress.value = '位置权限被拒绝';
          Get.snackbar('错误', '位置权限被拒绝，无法获取位置信息');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress.value = '位置权限被永久拒绝';
        Get.snackbar('错误', '位置权限被永久拒绝，请在设置中手动开启位置权限');
        return;
      }

      locationEnabled.value = true;
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentCoordinates.value = '纬度: ${position.latitude.toStringAsFixed(6)}, 经度: ${position.longitude.toStringAsFixed(6)}';

      // 获取地址信息
      await getAddressFromCoordinates(position.latitude, position.longitude);

    } catch (e) {
      currentAddress.value = '获取位置失败: $e';
      Get.snackbar('错误', '获取位置失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 根据坐标获取地址
  Future<void> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value = 
          '${place.country ?? ''} ${place.administrativeArea ?? ''} ${place.locality ?? ''} ${place.street ?? ''}';
      } else {
        currentAddress.value = '无法获取地址信息';
      }
    } catch (e) {
      currentAddress.value = '地址解析失败: $e';
      print('获取地址失败: $e');
    }
  }
}

/// 设备定位地图详情页面
class DeviceLocationMapPage extends StatelessWidget {
  const DeviceLocationMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DeviceLocationMapController controller = Get.put(DeviceLocationMapController());

    return Scaffold(
      backgroundColor: const Color(0xFF808080), // 外层背景色
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          decoration: BoxDecoration(
            color: const Color(0xFFEAE6F0),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // 状态栏
              _buildStatusBar(),
              
              // 标题栏
              _buildHeader(),
              
              // 主要内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // 地图区域
                      _buildMapSection(),
                      
                      const SizedBox(height: 24),
                      
                      // 功能列表
                      _buildFunctionList(),
                      
                      const SizedBox(height: 24),
                      
                      // 智能管家
                      _buildSmartButler(controller),
                      
                      const SizedBox(height: 100), // 底部导航栏空间
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildBottomNavigation(),
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '12:00',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              // 信号图标
              Container(
                width: 17,
                height: 11,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(5.5),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // WiFi图标
              Container(
                width: 16,
                height: 11,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // 电池图标
              Container(
                width: 25,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 4,
                      margin: const EdgeInsets.only(left: 1),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const Text(
            '猫咪定位器',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地图区域
  Widget _buildMapSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 地图占位背景
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  '地图占位区域',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // 可以在这里放置实际的地图组件
            // GeofenceMapWidget(...),
            
            // 位置标记
            const Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 外层圆圈
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0x4D2196F3),
                  ),
                  // 内层圆点
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: Color(0xFF2196F3),
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能列表
  Widget _buildFunctionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '功能列表',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFunctionButton(
                icon: Icons.toggle_off_outlined,
                label: '远程开关',
                onTap: () {},
              ),
              _buildFunctionButton(
                icon: Icons.fence_outlined,
                label: '电子围栏',
                onTap: () {},
              ),
              _buildFunctionButton(
                icon: Icons.location_on_outlined,
                label: '定位模式',
                onTap: () {},
              ),
              _buildFunctionButton(
                icon: Icons.settings_outlined,
                label: '更多设置',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建功能按钮
  Widget _buildFunctionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建智能管家
  Widget _buildSmartButler(DeviceLocationMapController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '智能管家',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.tasks.map((task) => _buildTaskChip(task, controller)).toList(),
          )),
        ),
      ],
    );
  }

  /// 构建任务芯片
  Widget _buildTaskChip(String task, DeviceLocationMapController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
            child: Text(
              task,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.removeTask(task),
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigation() {
    return Container(
      width: 390,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 导航内容
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: '智能管家',
                  isActive: false,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.monitor_outlined,
                  label: '设备管理',
                  isActive: true,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: '我的',
                  isActive: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          // 底部指示器
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              width: 128,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建导航项
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? const Color(0xFF9C27B0) : Colors.grey[500],
                ),
                if (isActive)
                  Positioned(
                    bottom: -8,
                    child: Container(
                      width: 32,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF9C27B0) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
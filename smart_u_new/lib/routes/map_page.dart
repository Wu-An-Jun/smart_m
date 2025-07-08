import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapController extends GetxController {
  final RxString currentAddress = '正在获取位置...'.obs;
  final RxString currentCoordinates = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool locationEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
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

      currentCoordinates.value = '纬度: ${position.latitude.toStringAsFixed(6)}\n经度: ${position.longitude.toStringAsFixed(6)}';

      // 获取地址信息
      await getAddressFromCoordinates(position.latitude, position.longitude);

      Get.snackbar('成功', '位置信息获取成功', backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);

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

  /// 打开位置设置
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// 打开应用设置
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MapController controller = Get.put(MapController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('地图定位'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.getCurrentLocation,
            tooltip: '刷新位置',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 地图占位符
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '地图功能',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请配置Google Maps API Key来启用完整地图功能',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 位置信息卡片
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '当前位置',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 地址信息
                    Obx(() => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '地址:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.currentAddress.value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: 12),
                    
                    // 坐标信息
                    Obx(() => controller.currentCoordinates.value.isNotEmpty 
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '坐标:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.currentCoordinates.value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // 底部操作栏
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => controller.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!controller.locationEnabled.value) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.openLocationSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('打开位置设置'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.openAppSettings,
                          icon: const Icon(Icons.app_settings_alt),
                          label: const Text('应用权限设置'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('重新定位'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            '提示', 
                            '更多地图功能正在开发中...\n\n当前支持:\n• 位置定位\n• 地址解析\n• 权限管理',
                            duration: const Duration(seconds: 4),
                          );
                        },
                        icon: const Icon(Icons.more_horiz),
                        label: const Text('更多功能'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ),
      ),
    );
  }
} 
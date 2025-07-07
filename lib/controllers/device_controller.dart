import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/device_model.dart';
import '../repositories/device_repository.dart';
import '../data/device_local_data_source.dart';
import '../data/device_remote_data_source.dart';

/// 设备管理控制器
class DeviceController extends GetxController {
  // 响应式变量
  final RxList<DeviceModel> _devices = <DeviceModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isScanning = false.obs;
  final RxBool _isBluetoothScanning = false.obs;

  final DeviceRepository repository = DeviceRepository(
    localDataSource: DeviceLocalDataSource(),
    remoteDataSource: DeviceRemoteDataSource(),
  );

  // Getters
  List<DeviceModel> get devices => _devices.toList();
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  int get deviceCount => _devices.length;
  int get onlineDeviceCount => _devices.where((d) => d.isOnline).length;
  bool get isScanning => _isScanning.value;
  bool get isBluetoothScanning => _isBluetoothScanning.value;

  @override
  void onInit() {
    super.onInit();
    _initializeDevices();
  }

  /// 初始化设备数据
  Future<void> _initializeDevices() async {
    await DeviceLocalDataSource.initialize();
    _loadDevicesFromRepository();
  }

  /// 从Repository加载设备
  void _loadDevicesFromRepository() {
    final devices = repository.getAllDevices();
    _devices.assignAll(devices);
  }

  /// 加载设备列表
  @override
  Future<void> loadDevices() async {
    _loadDevicesFromRepository();
  }

  /// 添加设备
  @override
  Future<void> addDevice(DeviceModel device) async {
    try {
      _setLoading(true);
      _clearError();
      if (_devices.any((d) => d.id == device.id)) {
        throw Exception('设备已存在');
      }
      await repository.saveDevice(device);
      _loadDevicesFromRepository();
      Get.snackbar(
        '成功',
        '设备添加成功',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _setError(e.toString());
      Get.snackbar(
        '错误',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 更新设备信息
  @override
  Future<void> updateDevice(String deviceId, DeviceModel updatedDevice) async {
    try {
      _setLoading(true);
      _clearError();
      final index = _devices.indexWhere((d) => d.id == deviceId);
      if (index == -1) {
        throw Exception('设备不存在');
      }
      await repository.saveDevice(updatedDevice);
      _loadDevicesFromRepository();
      Get.snackbar(
        '成功',
        '设备信息已更新',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _setError(e.toString());
      Get.snackbar(
        '错误',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 删除设备
  @override
  Future<void> deleteDevice(String deviceId) async {
    try {
      _setLoading(true);
      _clearError();
      await repository.deleteDevice(deviceId);
      _loadDevicesFromRepository();
      Get.snackbar(
        '成功',
        '设备已删除',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _setError(e.toString());
      Get.snackbar(
        '错误',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 清空所有设备
  Future<void> clearAllDevices() async {
    try {
      _setLoading(true);
      _clearError();
      await repository.clearAllDevices();
      _loadDevicesFromRepository();
      Get.snackbar(
        '成功',
        '所有设备已清空',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _setError(e.toString());
      Get.snackbar(
        '错误',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 更新设备在线状态
  void updateDeviceStatus(String deviceId, bool isOnline) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now(),
      );
    }
  }

  /// 获取特定类型的设备
  List<DeviceModel> getDevicesByType(DeviceType type) {
    return _devices.where((d) => d.type == type).toList();
  }

  /// 获取特定分类的设备
  List<DeviceModel> getDevicesByCategory(DeviceCategory category) {
    return _devices.where((d) => d.category == category).toList();
  }

  /// 获取在线设备
  List<DeviceModel> getOnlineDevices() {
    return _devices.where((d) => d.isOnline).toList();
  }

  /// 刷新设备列表
  Future<void> refreshDevices() async {
    await loadDevices();
  }

  /// 开始扫描设备
  Future<void> startScanning(BuildContext context, void Function(DeviceModel) onDeviceFound) async {
    try {
      _setScanning(true);
      _clearError();
      // 模拟扫描过程
      await Future.delayed(const Duration(seconds: 3));
      // 模拟发现新设备
      final discoveredDevice = DeviceModel(
        id: 'discovered_${DateTime.now().millisecondsSinceEpoch}',
        name: '发现的设备',
        type: DeviceType.smartSwitch,
        category: DeviceCategory.living,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '扫描发现的设备',
      );
      onDeviceFound(discoveredDevice);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setScanning(false);
    }
  }

  /// 停止扫描设备
  void stopScanning() {
    _setScanning(false);
  }

  /// 清除错误
  void clearError() {
    _clearError();
  }

  // 私有方法
  void _setLoading(bool loading) {
    if (_isLoading.value != loading) {
      _isLoading.value = loading;
    }
  }

  void _setScanning(bool scanning) {
    if (_isScanning.value != scanning) {
      _isScanning.value = scanning;
    }
  }

  void _setError(String error) {
    _error.value = error;
  }

  void _clearError() {
    if (_error.value.isNotEmpty) {
      _error.value = '';
    }
  }
}

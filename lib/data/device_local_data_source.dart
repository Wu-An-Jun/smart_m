import 'package:hive/hive.dart';
import '../models/device_model.dart';

/// 设备本地数据源，负责本地持久化操作
class DeviceLocalDataSource {
  static const String deviceBoxName = 'device_box';

  /// 初始化Hive及注册Adapter
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DeviceTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DeviceCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DeviceModelAdapter());
    }
    await Hive.openBox<DeviceModel>(deviceBoxName);
  }

  /// 获取所有设备
  List<DeviceModel> getAllDevices() {
    final box = Hive.box<DeviceModel>(deviceBoxName);
    return box.values.toList();
  }

  /// 根据ID获取设备
  DeviceModel? getDeviceById(String id) {
    final box = Hive.box<DeviceModel>(deviceBoxName);
    try {
      return box.values.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 添加或更新设备
  Future<void> saveDevice(DeviceModel device) async {
    final box = Hive.box<DeviceModel>(deviceBoxName);
    await box.put(device.id, device);
  }

  /// 删除设备
  Future<void> deleteDevice(String id) async {
    final box = Hive.box<DeviceModel>(deviceBoxName);
    await box.delete(id);
  }

  /// 清空所有设备
  Future<void> clearAllDevices() async {
    final box = Hive.box<DeviceModel>(deviceBoxName);
    await box.clear();
  }
} 
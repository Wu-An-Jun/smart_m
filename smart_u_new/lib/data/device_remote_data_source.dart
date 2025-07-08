import '../models/device_model.dart';

/// 设备远程数据源，预留后端API对接接口
class DeviceRemoteDataSource {
  /// 获取所有设备（预留，暂返回空列表）
  Future<List<DeviceModel>> fetchAllDevices() async {
    // TODO: 实现API请求
    return [];
  }

  /// 根据ID获取设备（预留，暂返回null）
  Future<DeviceModel?> fetchDeviceById(String id) async {
    // TODO: 实现API请求
    return null;
  }

  /// 上传或更新设备（预留，无实际操作）
  Future<void> uploadDevice(DeviceModel device) async {
    // TODO: 实现API请求
  }

  /// 删除设备（预留，无实际操作）
  Future<void> deleteDevice(String id) async {
    // TODO: 实现API请求
  }
} 
import '../models/device_model.dart';
import '../data/device_local_data_source.dart';
import '../data/device_remote_data_source.dart';

/// 设备仓库，统一管理本地与远程数据
class DeviceRepository {
  final DeviceLocalDataSource localDataSource;
  final DeviceRemoteDataSource remoteDataSource;

  DeviceRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// 获取所有设备，优先本地，后续可加同步逻辑
  List<DeviceModel> getAllDevices() {
    return localDataSource.getAllDevices();
  }

  /// 根据ID获取设备
  DeviceModel? getDeviceById(String id) {
    return localDataSource.getDeviceById(id);
  }

  /// 添加或更新设备（本地+预留远程同步）
  Future<void> saveDevice(DeviceModel device) async {
    await localDataSource.saveDevice(device);
    // TODO: 可在此调用remoteDataSource.uploadDevice(device)实现同步
  }

  /// 删除设备（本地+预留远程同步）
  Future<void> deleteDevice(String id) async {
    await localDataSource.deleteDevice(id);
    // TODO: 可在此调用remoteDataSource.deleteDevice(id)实现同步
  }

  /// 同步远程数据到本地（预留）
  Future<void> syncFromRemote() async {
    // TODO: 拉取远程数据并保存到本地
    final remoteDevices = await remoteDataSource.fetchAllDevices();
    for (final device in remoteDevices) {
      await localDataSource.saveDevice(device);
    }
  }

  /// 清空所有设备（本地+预留远程同步）
  Future<void> clearAllDevices() async {
    await localDataSource.clearAllDevices();
    // TODO: 可在此调用remoteDataSource.clearAllDevices()实现同步
  }
} 
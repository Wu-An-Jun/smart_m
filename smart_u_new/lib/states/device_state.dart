import 'package:flutter/foundation.dart';

/// 设备信息模型
class DeviceInfo {
  final String id;
  final String name;
  final String type;
  final bool isOnline;
  final DateTime lastSeen;

  DeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.isOnline,
    required this.lastSeen,
  });

  DeviceInfo copyWith({
    String? id,
    String? name,
    String? type,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return DeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      isOnline: json['isOnline'],
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }
}

/// 设备状态管理
class DeviceState extends ChangeNotifier {
  List<DeviceInfo> _devices = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DeviceInfo> get devices => List.unmodifiable(_devices);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get deviceCount => _devices.length;
  int get onlineDeviceCount => _devices.where((d) => d.isOnline).length;

  /// 添加设备
  Future<void> addDevice(DeviceInfo device) async {
    try {
      _setLoading(true);
      _clearError();
      
      // 检查设备是否已存在
      if (_devices.any((d) => d.id == device.id)) {
        throw Exception('设备已存在');
      }
      
      _devices.add(device);
      notifyListeners();
      
      // 这里可以添加网络请求来同步设备信息
      await _syncToServer();
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 更新设备信息
  Future<void> updateDevice(String deviceId, DeviceInfo updatedDevice) async {
    try {
      _setLoading(true);
      _clearError();
      
      final index = _devices.indexWhere((d) => d.id == deviceId);
      if (index == -1) {
        throw Exception('设备不存在');
      }
      
      _devices[index] = updatedDevice;
      notifyListeners();
      
      await _syncToServer();
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 删除设备
  Future<void> removeDevice(String deviceId) async {
    try {
      _setLoading(true);
      _clearError();
      
      _devices.removeWhere((d) => d.id == deviceId);
      notifyListeners();
      
      await _syncToServer();
      
    } catch (e) {
      _setError(e.toString());
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
      notifyListeners();
    }
  }

  /// 获取特定类型的设备
  List<DeviceInfo> getDevicesByType(String type) {
    return _devices.where((d) => d.type == type).toList();
  }

  /// 获取在线设备
  List<DeviceInfo> getOnlineDevices() {
    return _devices.where((d) => d.isOnline).toList();
  }

  /// 刷新设备列表
  Future<void> refreshDevices() async {
    try {
      _setLoading(true);
      _clearError();
      
      // 这里可以添加从服务器获取设备列表的逻辑
      await _loadFromServer();
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 清除错误
  void clearError() {
    _clearError();
  }

  // 私有方法
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// 模拟从服务器加载设备信息
  Future<void> _loadFromServer() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟数据
    _devices = [
      DeviceInfo(
        id: 'mn123ffw2025',
        name: '智能摄像头',
        type: 'camera',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
    ];
    
    notifyListeners();
  }

  /// 模拟同步到服务器
  Future<void> _syncToServer() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 这里添加实际的网络请求逻辑
  }

  /// 初始化设备状态
  Future<void> initialize() async {
    await refreshDevices();
  }
} 
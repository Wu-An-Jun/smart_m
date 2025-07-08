import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_amap/fl_amap.dart';
import '../common/amap_geofence_service.dart';
import '../models/geofence_model.dart';

/// 高德地图围栏测试页面
class AMapGeofenceTestPage extends StatefulWidget {
  const AMapGeofenceTestPage({Key? key}) : super(key: key);

  @override
  State<AMapGeofenceTestPage> createState() => _AMapGeofenceTestPageState();
}

class _AMapGeofenceTestPageState extends State<AMapGeofenceTestPage> {
  // 围栏服务
  final AMapGeofenceService _geofenceService = AMapGeofenceService();
  
  // 定位信息
  AMapLocation? _location;
  
  // 围栏事件列表
  final List<GeofenceEvent> _events = [];
  
  // 围栏事件订阅
  StreamSubscription<GeofenceEvent>? _eventSubscription;
  
  // 初始化状态
  bool _isInitialized = false;
  bool _isLoading = false;
  String _statusMessage = '准备初始化...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _geofenceService.dispose();
    super.dispose();
  }

  /// 初始化
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在初始化...';
    });
    
    try {
      // 初始化定位
      final locationResult = await FlAMapLocation().initialize();
      if (locationResult) {
        _statusMessage = '定位初始化成功';
      } else {
        _statusMessage = '定位初始化失败';
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // 获取当前位置
      _location = await FlAMapLocation().getLocation();
      if (_location == null) {
        _statusMessage = '获取位置失败';
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // 初始化围栏服务
      final geofenceResult = await _geofenceService.initialize();
      if (!geofenceResult) {
        _statusMessage = '围栏服务初始化失败';
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // 订阅围栏事件
      _eventSubscription = _geofenceService.events.listen(_onGeofenceEvent);
      
      // 创建测试围栏
      if (_location != null) {
        await _geofenceService.createTestGeofences(
          _location!.latitude ?? 0, 
          _location!.longitude ?? 0
        );
      }
      
      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _statusMessage = '初始化成功，已创建测试围栏';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '初始化错误: $e';
      });
    }
  }

  /// 围栏事件回调
  void _onGeofenceEvent(GeofenceEvent event) {
    setState(() {
      _events.insert(0, event);
      if (_events.length > 20) {
        _events.removeLast();
      }
    });
  }

  /// 刷新位置
  Future<void> _refreshLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在获取位置...';
    });
    
    try {
      _location = await FlAMapLocation().getLocation();
      setState(() {
        _isLoading = false;
        _statusMessage = '位置已更新';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '获取位置错误: $e';
      });
    }
  }

  /// 创建测试围栏
  Future<void> _createTestGeofences() async {
    if (_location == null) {
      setState(() {
        _statusMessage = '无法创建围栏：位置未知';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _statusMessage = '正在创建测试围栏...';
    });
    
    try {
      await _geofenceService.createTestGeofences(
        _location!.latitude ?? 0, 
        _location!.longitude ?? 0
      );
      
      setState(() {
        _isLoading = false;
        _statusMessage = '测试围栏已创建';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '创建围栏错误: $e';
      });
    }
  }

  /// 清空围栏
  Future<void> _clearGeofences() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在清空围栏...';
    });
    
    try {
      await _geofenceService.clearGeofences();
      
      setState(() {
        _isLoading = false;
        _statusMessage = '围栏已清空';
        _events.clear();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '清空围栏错误: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高德地图围栏测试'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // 状态信息
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('状态: $_statusMessage'),
              if (_location != null) ...[
                const SizedBox(height: 8),
                Text('当前位置: ${_location!.latitude}, ${_location!.longitude}'),
                Text('地址: ${_location!.address}'),
              ],
            ],
          ),
        ),
        
        // 按钮区域
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _refreshLocation,
                child: const Text('刷新位置'),
              ),
              ElevatedButton(
                onPressed: _createTestGeofences,
                child: const Text('创建测试围栏'),
              ),
              ElevatedButton(
                onPressed: _clearGeofences,
                child: const Text('清空围栏'),
              ),
            ],
          ),
        ),
        
        // 围栏列表
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('围栏列表:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('共 ${_geofenceService.geofences.length} 个围栏'),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: _geofenceService.geofences.length,
            itemBuilder: (context, index) {
              final fence = _geofenceService.geofences[index];
              return ListTile(
                title: Text(fence.name),
                subtitle: Text(fence.type == GeofenceType.circle
                    ? '圆形围栏，半径: ${fence.radius}米'
                    : '多边形围栏，${fence.vertices.length}个顶点'),
                leading: Icon(
                  fence.type == GeofenceType.circle
                      ? Icons.circle_outlined
                      : Icons.pentagon_outlined,
                  color: Colors.blue,
                ),
              );
            },
          ),
        ),
        
        // 事件列表
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('围栏事件:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('共 ${_events.length} 个事件'),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return ListTile(
                title: Text(event.geofenceName),
                subtitle: Text(
                  '${event.status.displayName} - ${event.timestamp.hour}:${event.timestamp.minute}:${event.timestamp.second}',
                ),
                leading: Icon(
                  event.status == GeofenceStatus.enter
                      ? Icons.login
                      : event.status == GeofenceStatus.exit
                          ? Icons.logout
                          : event.status == GeofenceStatus.inside
                              ? Icons.home
                              : Icons.public,
                  color: event.status == GeofenceStatus.enter
                      ? Colors.green
                      : event.status == GeofenceStatus.exit
                          ? Colors.red
                          : event.status == GeofenceStatus.inside
                              ? Colors.blue
                              : Colors.grey,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 
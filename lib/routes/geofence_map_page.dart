import 'package:flutter/material.dart';
import '../widgets/geofence_map_widget.dart';
import '../common/geofence_service.dart';
import '../models/geofence_model.dart';

/// 完整的地理围栏地图页面
/// 主要用于主页地图卡片点击后的全屏显示
class GeofenceMapPage extends StatefulWidget {
  const GeofenceMapPage({super.key});

  @override
  State<GeofenceMapPage> createState() => _GeofenceMapPageState();
}

class _GeofenceMapPageState extends State<GeofenceMapPage> {
  final GeofenceService _geofenceService = GeofenceService();
  String _statusText = '正在初始化地图...';
  int _totalGeofences = 0;
  int _eventsCount = 0;
  VoidCallback? _redrawMapCallback;
  VoidCallback? _clearMapCallback;
  
  @override
  void initState() {
    super.initState();
    _initializeGeofenceService();
  }

  /// 初始化地理围栏服务
  void _initializeGeofenceService() {
    // 监听地理围栏事件
    _geofenceService.events.listen((event) {
      setState(() {
        _eventsCount++;
        _statusText = '${event.status.name}: ${event.geofenceName}';
      });
      
      // 显示事件通知
      _showEventSnackBar(event);
    });
    
    // 更新围栏统计
    _updateGeofenceStats();
  }

  /// 更新地理围栏统计信息
  void _updateGeofenceStats() {
    setState(() {
      _totalGeofences = _geofenceService.geofences.length;
    });
  }

  /// 显示事件通知
  void _showEventSnackBar(GeofenceEvent event) {
    IconData iconData;
    Color color;
    String message;
    
    switch (event.status) {
      case GeofenceStatus.enter:
        iconData = Icons.login;
        color = Colors.green;
        message = '进入围栏: ${event.geofenceName}';
        break;
      case GeofenceStatus.exit:
        iconData = Icons.logout;
        color = Colors.red;
        message = '离开围栏: ${event.geofenceName}';
        break;
      case GeofenceStatus.inside:
        iconData = Icons.check_circle;
        color = Colors.blue;
        message = '在围栏内: ${event.geofenceName}';
        break;
      case GeofenceStatus.outside:
        iconData = Icons.radio_button_unchecked;
        color = Colors.grey;
        message = '在围栏外: ${event.geofenceName}';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// 处理状态变化
  void _onStatusChanged(String status) {
    setState(() {
      _statusText = status;
    });
  }

  /// 构建地图组件
  Widget _buildMapWidget() {
    return GeofenceMapWidget(
      config: const GeofenceMapConfig(
        title: '地理围栏地图',
        showLegend: true,
        show3D: false,
        height: double.infinity,
      ),
      onStatusChanged: _onStatusChanged,
      onGeofenceEvent: (event) {
        setState(() {
          _eventsCount++;
          _statusText = '${event.status.displayName}: ${event.geofenceName}';
        });
        // 显示事件通知
        _showEventSnackBar(event);
      },
      onMapReady: (redrawCallback, clearCallback) {
        // 保存地图操作回调
        _redrawMapCallback = redrawCallback;
        _clearMapCallback = clearCallback;
      },
    );
  }

  /// 添加测试围栏
  void _addTestGeofences() {
    // 添加圆形测试围栏
    final circleGeofence = GeofenceModel.circle(
      id: 'test_circle_${DateTime.now().millisecondsSinceEpoch}',
      name: '测试圆形围栏',
      center: const LocationPoint(latitude: 39.9087, longitude: 116.3975), // 北京天安门
      radius: 500.0,
    );
    
    // 添加多边形测试围栏
    final polygonGeofence = GeofenceModel.polygon(
      id: 'test_polygon_${DateTime.now().millisecondsSinceEpoch}',
      name: '测试多边形围栏',
      vertices: [
        const LocationPoint(latitude: 39.910, longitude: 116.395),
        const LocationPoint(latitude: 39.910, longitude: 116.400),
        const LocationPoint(latitude: 39.906, longitude: 116.400),
        const LocationPoint(latitude: 39.906, longitude: 116.395),
      ],
    );

    // 添加到服务
    _geofenceService.addGeofence(circleGeofence);
    _geofenceService.addGeofence(polygonGeofence);
    
    // 同步到地图
    _redrawMapCallback?.call();
    
    _updateGeofenceStats();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已添加测试围栏'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 清空所有围栏
  void _clearAllGeofences() {
    // 清空服务中的围栏
    _geofenceService.clearGeofences();
    
    // 清空地图上的围栏
    _clearMapCallback?.call();
    
    _updateGeofenceStats();
    setState(() {
      _eventsCount = 0;
      _statusText = '已清空所有围栏';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已清空所有围栏'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 手动测试围栏检测
  void _testGeofenceDetection() {
    // 模拟在北京天安门附近的位置
    final testLocation1 = LocationPoint(latitude: 39.9087, longitude: 116.3975);
    final testLocation2 = LocationPoint(latitude: 39.9100, longitude: 116.4000);
    
    // 触发位置检查
    _geofenceService.checkLocation(testLocation1.latitude, testLocation1.longitude);
    
    // 延迟后再检查另一个位置
    Future.delayed(const Duration(seconds: 2), () {
      _geofenceService.checkLocation(testLocation2.latitude, testLocation2.longitude);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧪 正在测试围栏检测...'),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '地理围栏地图',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF6B4DFF),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 统计信息
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '围栏: $_totalGeofences | 事件: $_eventsCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6B4DFF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 地图区域
          Expanded(
            child: Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildMapWidget(),
              ),
            ),
          ),

          // 底部控制栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // 添加测试围栏按钮
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addTestGeofences,
                      icon: const Icon(Icons.add_location),
                      label: const Text('添加测试围栏'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4DFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 测试围栏按钮
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testGeofenceDetection,
                      icon: const Icon(Icons.science),
                      label: const Text('测试围栏'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 清空围栏按钮
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearAllGeofences,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('清空围栏'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _geofenceService.dispose();
    super.dispose();
  }
} 
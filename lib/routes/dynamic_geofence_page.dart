import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fl_amap/fl_amap.dart';
import 'dart:async';
import '../common/api_config.dart';
import '../models/geofence_model.dart' as geo;
import '../common/geofence_service.dart';

class DynamicGeofencePage extends StatefulWidget {
  const DynamicGeofencePage({super.key});

  @override
  State<DynamicGeofencePage> createState() => _DynamicGeofencePageState();
}

class _DynamicGeofencePageState extends State<DynamicGeofencePage> {
  late final WebViewController _controller;
  late final GeofenceService _geofenceService;
  bool _isLoading = true;
  String _statusText = '正在加载地图...';
  AMapLocation? _currentLocation;
  StreamSubscription<geo.GeofenceEvent>? _geofenceSubscription;
  final List<geo.GeofenceEvent> _recentEvents = [];

  @override
  void initState() {
    super.initState();
    _geofenceService = GeofenceService();
    _initializeMap();
    _subscribeToGeofenceEvents();
  }

  @override
  void dispose() {
    _geofenceSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToGeofenceEvents() {
    _geofenceSubscription = _geofenceService.events.listen((event) {
      if (mounted) {
        setState(() {
          _recentEvents.insert(0, event);
          if (_recentEvents.length > 10) {
            _recentEvents.removeLast();
          }
          _statusText = '${event.geofenceName}: ${event.statusText}';
        });
        
        // 在地图上高亮显示触发的围栏
        _highlightGeofence(event.geofenceId);
      }
    });
  }

  void _initializeMap() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _statusText = '正在加载地图... $progress%';
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _statusText = '开始加载地图...';
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _statusText = '地图加载完成';
            });
            _getCurrentLocation();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _statusText = '地图加载失败: ${error.description}';
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterGeofence',
        onMessageReceived: (JavaScriptMessage message) {
          print('从地图接收消息: ${message.message}');
          _handleMapMessage(message.message);
        },
      )
      ..loadHtmlString(_generateMapHtml());
  }

  void _handleMapMessage(String message) {
    setState(() {
      _statusText = '地图消息: $message';
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      await FlAMap().setAMapKey(
        iosKey: ApiConfig.amapMobileApiKey,
        androidKey: ApiConfig.amapMobileApiKey,
      );

      await FlAMapLocation().initialize();
      AMapLocation? location = await FlAMapLocation().getLocation();
      
      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
          _statusText = '定位成功，正在创建测试围栏...';
        });
        
        // 创建测试围栏
        _geofenceService.createTestGeofences(location.latitude!, location.longitude!);
        
        // 将定位结果和围栏传递给WebView中的地图
        _updateMapWithGeofences(location.longitude!, location.latitude!);
        
        // 开始监听位置变化
        _startLocationMonitoring();
      }
    } catch (e) {
      setState(() {
        _statusText = '定位失败: $e';
      });
    }
  }

  void _startLocationMonitoring() {
    FlAMapLocation().addListener(
      onLocationChanged: (AMapLocation? location) {
        if (location != null) {
          setState(() {
            _currentLocation = location;
          });
          
          // 检查地理围栏
          _geofenceService.checkLocation(location.latitude!, location.longitude!);
          
          // 更新地图上的位置
          _updateMapLocation(location.longitude!, location.latitude!);
        }
      },
    );
  }

  void _updateMapWithGeofences(double lng, double lat) {
    final geofences = _geofenceService.geofences;
    final geofenceData = geofences.map((fence) => fence.toMap()).toList();
    
    final jsCode = '''
      if (typeof initializeMapWithGeofences === 'function') {
        initializeMapWithGeofences($lng, $lat, ${_listToJsArray(geofenceData)});
        FlutterGeofence.postMessage('地图已初始化，包含${geofences.length}个围栏');
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  void _updateMapLocation(double lng, double lat) {
    final jsCode = '''
      if (typeof updateCurrentLocation === 'function') {
        updateCurrentLocation($lng, $lat);
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  void _highlightGeofence(String geofenceId) {
    final jsCode = '''
      if (typeof highlightGeofence === 'function') {
        highlightGeofence('$geofenceId');
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  String _listToJsArray(List<Map<String, dynamic>> list) {
    final buffer = StringBuffer('[');
    for (int i = 0; i < list.length; i++) {
      if (i > 0) buffer.write(',');
      buffer.write(_mapToJsObject(list[i]));
    }
    buffer.write(']');
    return buffer.toString();
  }

  String _mapToJsObject(Map<String, dynamic> map) {
    final buffer = StringBuffer('{');
    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      if (i > 0) buffer.write(',');
      final key = entries[i].key;
      final value = entries[i].value;
      buffer.write('"$key":');
      if (value is String) {
        buffer.write('"$value"');
      } else if (value is List) {
        buffer.write(_listToJsArray(value.cast<Map<String, dynamic>>()));
      } else if (value is Map) {
        buffer.write(_mapToJsObject(value.cast<String, dynamic>()));
      } else {
        buffer.write(value);
      }
    }
    buffer.write('}');
    return buffer.toString();
  }

  String _generateMapHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>地理围栏动态地图</title>
    <style>
        body, html { 
            margin: 0; 
            padding: 0; 
            width: 100%; 
            height: 100%; 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        .map-container { 
            position: relative; 
            width: 100%; 
            height: 100%; 
            overflow: hidden; 
        }
        .map-title { 
            position: absolute; 
            top: 10px; 
            left: 10px; 
            right: 10px; 
            background: rgba(255,255,255,0.9); 
            padding: 10px; 
            border-radius: 8px; 
            text-align: center; 
            font-weight: bold; 
            z-index: 1000; 
            font-size: 16px;
            color: #333;
        }
        #map { 
            width: 100%; 
            height: 100%; 
        }
        .legend {
            position: absolute;
            bottom: 10px;
            left: 10px;
            background: rgba(255,255,255,0.9);
            padding: 10px;
            border-radius: 8px;
            z-index: 1001;
            font-size: 12px;
        }
        .legend-item {
            display: flex;
            align-items: center;
            margin: 4px 0;
        }
        .legend-color {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <div class="map-container">
        <div class="map-title">地理围栏测试 - 动态地图</div>
        <div class="legend">
            <div class="legend-item">
                <div class="legend-color" style="background: #ff4444;"></div>
                <span>圆形围栏</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #4444ff;"></div>
                <span>多边形围栏</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #44ff44;"></div>
                <span>当前位置</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #ffff44;"></div>
                <span>触发围栏</span>
            </div>
        </div>
        <div id="map"></div>
    </div>

    <script type="text/javascript">
        window._AMapSecurityConfig = {
            securityJsCode: '${ApiConfig.amapSecurityCode}',
        }
    </script>
    
    <script src="https://webapi.amap.com/maps?v=1.4.15&key=${ApiConfig.amapWebApiKey}"></script>
    
    <script>
        let map;
        let currentLocationMarker;
        let geofenceOverlays = {};
        let currentLocation = [116.397827, 39.909613];
        
        // 初始化地图和围栏
        function initializeMapWithGeofences(lng, lat, geofences) {
            currentLocation = [lng, lat];
            
            map = new AMap.Map("map", {
                pitch: 30,
                viewMode: '3D',
                rotateEnable: true,
                pitchEnable: true,
                zoom: 16,
                rotation: 0,
                zooms: [3, 20],
                center: currentLocation
            });

            // 添加地图控件
            addMapControls();
            
            // 绘制围栏
            drawGeofences(geofences);
            
            // 添加当前位置标记
            addCurrentLocationMarker(lng, lat);
            
            FlutterGeofence.postMessage('地图初始化完成');
        }

        function addMapControls() {
            // 添加缩放控件
            AMap.plugin('AMap.ControlBar', function () {
                map.addControl(new AMap.ControlBar({
                    showZoomBar: true,
                    showControlButton: true,
                    position: {
                        right: '15px',
                        bottom: '80px',
                    }
                }));
            });

            // 添加比例尺
            AMap.plugin(['AMap.Scale'], function () {
                var scale = new AMap.Scale();
                map.addControl(scale);
            });
        }

        function drawGeofences(geofences) {
            geofences.forEach(function(fence) {
                if (fence.type === 'circle') {
                    drawCircleGeofence(fence);
                } else if (fence.type === 'polygon') {
                    drawPolygonGeofence(fence);
                }
            });
        }

        function drawCircleGeofence(fence) {
            var circle = new AMap.Circle({
                center: [fence.center.longitude, fence.center.latitude],
                radius: fence.radius,
                fillColor: '#ff4444',
                fillOpacity: 0.2,
                strokeColor: '#ff4444',
                strokeWeight: 2,
                strokeOpacity: 0.8,
                map: map
            });
            
            // 添加标签
            var marker = new AMap.Marker({
                position: [fence.center.longitude, fence.center.latitude],
                content: '<div style="background: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; border: 1px solid #ff4444;">' + fence.name + '</div>',
                offset: new AMap.Pixel(-50, -30),
                map: map
            });
            
            geofenceOverlays[fence.id] = { circle: circle, marker: marker };
        }

        function drawPolygonGeofence(fence) {
            var path = fence.vertices.map(function(vertex) {
                return [vertex.longitude, vertex.latitude];
            });
            
            var polygon = new AMap.Polygon({
                path: path,
                fillColor: '#4444ff',
                fillOpacity: 0.2,
                strokeColor: '#4444ff',
                strokeWeight: 2,
                strokeOpacity: 0.8,
                map: map
            });
            
            // 计算中心点
            var center = calculatePolygonCenter(path);
            var marker = new AMap.Marker({
                position: center,
                content: '<div style="background: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; border: 1px solid #4444ff;">' + fence.name + '</div>',
                offset: new AMap.Pixel(-50, -30),
                map: map
            });
            
            geofenceOverlays[fence.id] = { polygon: polygon, marker: marker };
        }

        function calculatePolygonCenter(path) {
            var sumLng = 0, sumLat = 0;
            path.forEach(function(point) {
                sumLng += point[0];
                sumLat += point[1];
            });
            return [sumLng / path.length, sumLat / path.length];
        }

        function addCurrentLocationMarker(lng, lat) {
            if (currentLocationMarker) {
                currentLocationMarker.setMap(null);
            }
            
            currentLocationMarker = new AMap.Marker({
                position: [lng, lat],
                map: map,
                icon: new AMap.Icon({
                    image: "https://webapi.amap.com/theme/v1.3/markers/n/mark_g.png",
                    imageSize: new AMap.Size(32, 32)
                }),
                title: '当前位置'
            });
        }

        function updateCurrentLocation(lng, lat) {
            currentLocation = [lng, lat];
            if (currentLocationMarker) {
                currentLocationMarker.setPosition([lng, lat]);
            }
            // 地图中心跟随位置移动（可选）
            // map.setCenter([lng, lat]);
        }

        function highlightGeofence(geofenceId) {
            // 重置所有围栏样式
            Object.keys(geofenceOverlays).forEach(function(id) {
                var overlay = geofenceOverlays[id];
                if (overlay.circle) {
                    overlay.circle.setOptions({
                        fillColor: '#ff4444',
                        strokeColor: '#ff4444'
                    });
                } else if (overlay.polygon) {
                    overlay.polygon.setOptions({
                        fillColor: '#4444ff',
                        strokeColor: '#4444ff'
                    });
                }
            });
            
            // 高亮触发的围栏
            var overlay = geofenceOverlays[geofenceId];
            if (overlay) {
                if (overlay.circle) {
                    overlay.circle.setOptions({
                        fillColor: '#ffff44',
                        strokeColor: '#ffaa00'
                    });
                } else if (overlay.polygon) {
                    overlay.polygon.setOptions({
                        fillColor: '#ffff44',
                        strokeColor: '#ffaa00'
                    });
                }
                
                // 延迟恢复正常颜色
                setTimeout(function() {
                    if (overlay.circle) {
                        overlay.circle.setOptions({
                            fillColor: '#ff4444',
                            strokeColor: '#ff4444'
                        });
                    } else if (overlay.polygon) {
                        overlay.polygon.setOptions({
                            fillColor: '#4444ff',
                            strokeColor: '#4444ff'
                        });
                    }
                }, 2000);
            }
        }
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态地图地理围栏'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: '重新定位',
          ),
        ],
      ),
      body: Column(
        children: [
          // 地图区域
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在加载地理围栏地图...'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // 状态和事件显示区域
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 当前状态
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '状态: $_statusText',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (_currentLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '位置: ${_currentLocation!.longitude?.toStringAsFixed(6)}, ${_currentLocation!.latitude?.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                        Text(
                          '围栏数量: ${_geofenceService.geofences.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 最近事件
                  const Text(
                    '最近事件:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  
                  Expanded(
                    child: _recentEvents.isEmpty 
                        ? const Center(
                            child: Text(
                              '暂无围栏事件\n移动位置触发围栏检测',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _recentEvents.length,
                            itemBuilder: (context, index) {
                              final event = _recentEvents[index];
                              final statusColor = _getStatusColor(event.status);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  border: Border.all(color: statusColor.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getStatusIcon(event.status),
                                      color: statusColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.geofenceName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            event.statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

  Color _getStatusColor(geo.GeofenceStatus status) {
    switch (status) {
      case geo.GeofenceStatus.enter:
        return Colors.green;
      case geo.GeofenceStatus.exit:
        return Colors.red;
      case geo.GeofenceStatus.inside:
        return Colors.blue;
      case geo.GeofenceStatus.outside:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(geo.GeofenceStatus status) {
    switch (status) {
      case geo.GeofenceStatus.enter:
        return Icons.login;
      case geo.GeofenceStatus.exit:
        return Icons.logout;
      case geo.GeofenceStatus.inside:
        return Icons.check_circle;
      case geo.GeofenceStatus.outside:
        return Icons.radio_button_unchecked;
    }
  }
} 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fl_amap/fl_amap.dart';

import '../models/geofence_model.dart';
import '../common/geofence_service.dart';
import '../common/api_config.dart';
import '../common/Global.dart';
import 'amap_web/amap_html_template.dart';

/// 地理围栏地图配置类
class GeofenceMapConfig {
  final String title;
  final bool showLegend;
  final bool show3D;
  final bool enableTestFences;
  final double height;
  final bool showStatus;
  final bool showEvents;
  final int maxEventCount;

  const GeofenceMapConfig({
    this.title = '地理围栏地图',
    this.showLegend = true,
    this.show3D = true,
    this.enableTestFences = true,
    this.height = 400.0,
    this.showStatus = true,
    this.showEvents = true,
    this.maxEventCount = 5,
  });
}

/// 地理围栏地图Widget
/// 可复用的地理围栏地图组件，支持自定义配置
class GeofenceMapWidget extends StatefulWidget {
  final GeofenceMapConfig config;
  final Function(GeofenceEvent)? onGeofenceEvent;
  final Function(String)? onStatusChanged;
  final List<GeofenceModel>? customGeofences;
  final Function(VoidCallback redrawCallback, VoidCallback clearCallback)? onMapReady;

  const GeofenceMapWidget({
    super.key,
    this.config = const GeofenceMapConfig(),
    this.onGeofenceEvent,
    this.onStatusChanged,
    this.customGeofences,
    this.onMapReady,
  });

  @override
  State<GeofenceMapWidget> createState() => _GeofenceMapWidgetState();

  /// 获取当前状态（用于外部调用地图功能）
  static _GeofenceMapWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<_GeofenceMapWidgetState>();
  }
}

class _GeofenceMapWidgetState extends State<GeofenceMapWidget> {
  late final WebViewController _controller;
  late final GeofenceService _geofenceService;
  bool _isLoading = true;
  String _statusText = '正在加载地图...';
  AMapLocation? _currentLocation;
  StreamSubscription<GeofenceEvent>? _geofenceSubscription;
  final List<GeofenceEvent> _recentEvents = [];
  Timer? _locationCheckTimer;
  DateTime? _lastLocationCheck;
  static const Duration _locationCheckInterval = Duration(seconds: 2); // 2秒检查间隔

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
    _locationCheckTimer?.cancel();
    _geofenceService.dispose();
    super.dispose();
  }

  /// 订阅地理围栏事件
  void _subscribeToGeofenceEvents() {
    _geofenceSubscription = _geofenceService.events.listen((event) {
      if (mounted) {
        setState(() {
          _recentEvents.insert(0, event);
          if (_recentEvents.length > widget.config.maxEventCount) {
            _recentEvents.removeLast();
          }
          _statusText = '${event.geofenceName}: ${event.statusText}';
        });
        
        // 在地图上高亮显示触发的围栏
        _highlightGeofence(event.geofenceId);
        
        // 回调事件
        widget.onGeofenceEvent?.call(event);
      }
    });
  }

  /// 初始化地图
  void _initializeMap() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _updateStatus('正在加载地图... $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _updateStatus('开始加载地图...');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _updateStatus('地图加载完成');
            _getCurrentLocation();
            
            // 通知外部地图已准备就绪，提供操作回调
            widget.onMapReady?.call(
              () => redrawMapGeofences(), // 重绘围栏回调
              () => clearMapGeofences(),  // 清空围栏回调
            );
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            _updateStatus('地图加载失败: ${error.description}');
            print('WebView资源错误: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // 允许高德地图相关的请求
            if (request.url.contains('amap.com') || 
                request.url.contains('autonavi.com') ||
                request.url.startsWith('data:') ||
                request.url.startsWith('about:')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterGeofence',
        onMessageReceived: (JavaScriptMessage message) {
          _handleMapMessage(message.message);
        },
      )
      ..loadHtmlString(_generateMapHtml(), baseUrl: 'https://webapi.amap.com');
  }

  /// 更新状态文本
  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _statusText = status;
      });
      widget.onStatusChanged?.call(status);
    }
  }

  /// 处理来自地图的消息
  void _handleMapMessage(String message) {
    _updateStatus('地图消息: $message');
    
    // 处理特定的消息类型
    if (message == 'request_location') {
      _refreshCurrentLocation(); // 使用专门的刷新方法
    } else if (message.startsWith('地图初始化完成')) {
      _updateStatus('地图初始化完成，正在定位...');
    }
  }

  /// 生成地图HTML
  String _generateMapHtml() {
    return AmapHtmlTemplate.generateMapHtml(
      title: widget.config.title,
      showLegend: widget.config.showLegend,
      show3D: widget.config.show3D,
    );
  }

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      if (!ApiConfig.isAmapConfigured) {
        _updateStatus('请先配置高德地图API密钥');
        return;
      }

      await FlAMap().setAMapKey(
        iosKey: ApiConfig.amapMobileApiKey,
        androidKey: ApiConfig.amapMobileApiKey,
      );

      await FlAMapLocation().initialize();
      AMapLocation? location = await FlAMapLocation().getLocation();
      
      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
        });
        _updateStatus('定位成功，正在创建围栏...');
        
        // 使用自定义围栏或创建测试围栏
        if (widget.customGeofences != null) {
          _setupCustomGeofences(widget.customGeofences!);
        } else if (widget.config.enableTestFences) {
          _geofenceService.createTestGeofences(location.latitude!, location.longitude!);
        }
        
        // 将定位结果和围栏传递给WebView中的地图
        _updateMapWithGeofences(location.longitude!, location.latitude!);
        
        // 开始监听位置变化
        _startLocationMonitoring();
      }
    } catch (e) {
      _updateStatus('定位失败: $e');
    }
  }

  /// 刷新当前位置（仅更新位置，不重新初始化地图）
  Future<void> _refreshCurrentLocation() async {
    try {
      _updateStatus('正在刷新位置...');
      
      AMapLocation? location = await FlAMapLocation().getLocation();
      
      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
        });
        _updateStatus('位置刷新成功');
        
        // 只更新地图上的位置标记，不重新初始化地图
        _updateMapLocation(location.longitude!, location.latitude!);
      }
    } catch (e) {
      _updateStatus('位置刷新失败: $e');
    }
  }

  /// 设置自定义围栏
  void _setupCustomGeofences(List<GeofenceModel> geofences) {
    _geofenceService.clearGeofences();
    for (final geofence in geofences) {
      _geofenceService.addGeofence(geofence);
    }
  }

  /// 开始位置监听
  void _startLocationMonitoring() {
    FlAMapLocation().addListener(
      onLocationChanged: (AMapLocation? location) {
        if (location != null && mounted) {
          setState(() {
            _currentLocation = location;
          });
          
          // 使用节流机制检查地理围栏，避免过度频繁的检查
          _throttledGeofenceCheck(location.latitude!, location.longitude!);
          
          // 更新地图上的位置
          _updateMapLocation(location.longitude!, location.latitude!);
        }
      },
    );
  }

  /// 节流的地理围栏检查
  void _throttledGeofenceCheck(double latitude, double longitude) {
    final now = DateTime.now();
    
    // 如果上次检查时间不存在或者已经超过间隔时间，则进行检查
    if (_lastLocationCheck == null || 
        now.difference(_lastLocationCheck!) >= _locationCheckInterval) {
      _lastLocationCheck = now;
      _geofenceService.checkLocation(latitude, longitude);
    } else {
      // 取消之前的定时器
      _locationCheckTimer?.cancel();
      
      // 设置新的定时器，在间隔时间后执行检查
      final remainingTime = _locationCheckInterval - now.difference(_lastLocationCheck!);
      _locationCheckTimer = Timer(remainingTime, () {
        if (mounted) {
          _lastLocationCheck = DateTime.now();
          _geofenceService.checkLocation(latitude, longitude);
        }
      });
    }
  }

  /// 更新地图围栏和位置
  void _updateMapWithGeofences(double lng, double lat) {
    // 验证坐标
    if (lng.isNaN || lat.isNaN || lng.isInfinite || lat.isInfinite) {
      print('警告：传递了无效坐标到地图 lng: $lng, lat: $lat');
      // 使用默认坐标（北京天安门）
      lng = 116.397827;
      lat = 39.909613;
    }
    
    final geofences = _geofenceService.geofences;
    final geofenceData = geofences.map((fence) => fence.toMap()).toList();
    
    final jsCode = '''
      if (typeof initializeMapWithGeofences === 'function') {
        initializeMapWithGeofences($lng, $lat, ${_listToJsArray(geofenceData)});
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  /// 更新地图位置
  void _updateMapLocation(double lng, double lat) {
    // 验证坐标
    if (lng.isNaN || lat.isNaN || lng.isInfinite || lat.isInfinite) {
      print('警告：传递了无效坐标到地图 lng: $lng, lat: $lat');
      // 使用默认坐标（北京天安门）
      lng = 116.397827;
      lat = 39.909613;
    }
    
    final jsCode = '''
      if (typeof updateCurrentLocation === 'function') {
        updateCurrentLocation($lng, $lat);
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  /// 高亮围栏
  void _highlightGeofence(String geofenceId) {
    final jsCode = '''
      if (typeof highlightGeofence === 'function') {
        highlightGeofence('$geofenceId');
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  /// 清空地图上的所有围栏
  void clearMapGeofences() {
    final jsCode = '''
      if (typeof clearAllGeofences === 'function') {
        clearAllGeofences();
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  /// 重新绘制地图围栏
  void redrawMapGeofences() {
    try {
      final geofences = _geofenceService.geofences;
      final geofenceData = geofences.map((fence) => fence.toMap()).toList();
      
      final jsCode = '''
        try {
          if (typeof redrawGeofences === 'function') {
            redrawGeofences(${_listToJsArray(geofenceData)});
          } else {
            FlutterGeofence.postMessage('重新绘制围栏时出错：redrawGeofences函数未定义');
          }
        } catch (error) {
          console.error('重新绘制围栏JavaScript错误:', error);
          FlutterGeofence.postMessage('重新绘制围栏时出错：' + error.message);
        }
      ''';
      _controller.runJavaScript(jsCode);
    } catch (e) {
      _updateStatus('重新绘制围栏时出错：$e');
      print('重绘围栏Dart错误: $e');
    }
  }

  /// 添加单个围栏到地图
  void addSingleGeofenceToMap(GeofenceModel geofence) {
    final geofenceData = geofence.toMap();
    
    final jsCode = '''
      if (typeof addSingleGeofence === 'function') {
        addSingleGeofence(${_mapToJsObject(geofenceData)});
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  /// 将List转换为JavaScript数组字符串
  String _listToJsArray(List<Map<String, dynamic>> list) {
    final buffer = StringBuffer('[');
    for (int i = 0; i < list.length; i++) {
      if (i > 0) buffer.write(',');
      buffer.write(_mapToJsObject(list[i]));
    }
    buffer.write(']');
    return buffer.toString();
  }

  /// 将Map转换为JavaScript对象字符串
  String _mapToJsObject(Map<String, dynamic> map) {
    final buffer = StringBuffer('{');
    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      if (i > 0) buffer.write(',');
      final key = entries[i].key;
      final value = entries[i].value;
      buffer.write('"$key":');
      
      if (value == null) {
        buffer.write('null');
      } else if (value is String) {
        // 转义字符串中的特殊字符
        final escapedValue = value.replaceAll('"', '\\"').replaceAll('\n', '\\n');
        buffer.write('"$escapedValue"');
      } else if (value is List) {
        if (value.isEmpty) {
          buffer.write('[]');
        } else {
          buffer.write(_listToJsArray(value.cast<Map<String, dynamic>>()));
        }
      } else if (value is Map) {
        buffer.write(_mapToJsObject(value.cast<String, dynamic>()));
      } else if (value is num) {
        // 检查数值是否有效
        if (value.isNaN || value.isInfinite) {
          buffer.write('null');
        } else {
          buffer.write(value);
        }
      } else if (value is bool) {
        buffer.write(value.toString());
      } else {
        buffer.write('"$value"');
      }
    }
    buffer.write('}');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.config.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Global.currentTheme.isDark ? Colors.grey.shade600 : Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // 地图区域
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Container(
                      color: Global.currentTheme.surfaceColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Global.currentTheme.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '正在加载地理围栏地图...',
                              style: TextStyle(color: Global.currentTextColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // 状态和事件显示区域
            if (widget.config.showStatus || widget.config.showEvents)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Global.currentTheme.isDark ? Global.currentTheme.surfaceColor : Colors.grey[50],
                  border: Border(top: BorderSide(color: Global.currentTheme.isDark ? Colors.grey.shade600 : Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 状态信息
                    if (widget.config.showStatus) ...[
                      _buildStatusInfo(),
                      if (widget.config.showEvents) const SizedBox(height: 8),
                    ],
                    
                    // 事件列表
                    if (widget.config.showEvents) _buildEventsList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建状态信息
  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Global.currentTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Global.currentTheme.isDark ? Colors.grey.shade600 : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '状态: $_statusText',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Global.currentTextColor),
          ),
                     if (_currentLocation != null) ...[
             const SizedBox(height: 4),
             Text(
               '位置: ${_currentLocation!.longitude?.toStringAsFixed(6)}, ${_currentLocation!.latitude?.toStringAsFixed(6)}',
               style: TextStyle(fontSize: 10, color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey),
             ),
           ],
          Text(
            '围栏数量: ${_geofenceService.geofences.length}',
            style: TextStyle(fontSize: 10, color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 构建事件列表
  Widget _buildEventsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近事件:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Global.currentTextColor),
        ),
        const SizedBox(height: 4),
        
        SizedBox(
          height: 100,
          child: _recentEvents.isEmpty 
              ? Center(
                  child: Text(
                    '暂无围栏事件',
                    style: TextStyle(color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey, fontSize: 10),
                  ),
                )
              : ListView.builder(
                  itemCount: _recentEvents.length,
                  itemBuilder: (context, index) {
                    final event = _recentEvents[index];
                    final statusColor = _getStatusColor(event.status);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.all(6),
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
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.geofenceName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Global.currentTextColor,
                                  ),
                                ),
                                Text(
                                  event.statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 8,
                              color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(GeofenceStatus status) {
    switch (status) {
      case GeofenceStatus.enter:
        return Colors.green;
      case GeofenceStatus.exit:
        return Colors.red;
      case GeofenceStatus.inside:
        return Colors.blue;
      case GeofenceStatus.outside:
        return Colors.grey;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(GeofenceStatus status) {
    switch (status) {
      case GeofenceStatus.enter:
        return Icons.login;
      case GeofenceStatus.exit:
        return Icons.logout;
      case GeofenceStatus.inside:
        return Icons.check_circle;
      case GeofenceStatus.outside:
        return Icons.radio_button_unchecked;
    }
  }
} 
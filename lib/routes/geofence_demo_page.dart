import 'package:flutter/material.dart';
import '../models/geofence_model.dart';
import '../widgets/geofence_map_widget.dart';
import '../widgets/geofence_map_card.dart';

/// 地理围栏演示页面
/// 展示各种地理围栏组件的使用方法
class GeofenceDemoPage extends StatefulWidget {
  const GeofenceDemoPage({super.key});

  @override
  State<GeofenceDemoPage> createState() => _GeofenceDemoPageState();
}

class _GeofenceDemoPageState extends State<GeofenceDemoPage> with TickerProviderStateMixin {
  final List<GeofenceEvent> _allEvents = [];
  int _selectedTabIndex = 0;
  
  // 自定义围栏示例
  late final List<GeofenceModel> _customGeofences;

  @override
  void initState() {
    super.initState();
    _initializeCustomGeofences();
  }

  /// 初始化自定义围栏
  void _initializeCustomGeofences() {
    _customGeofences = [
      GeofenceModel.circle(
        id: 'custom_home',
        name: '家庭围栏',
        center: const LocationPoint(latitude: 39.9042, longitude: 116.4074),
        radius: 100.0,
      ),
      GeofenceModel.circle(
        id: 'custom_office',
        name: '办公室围栏',
        center: const LocationPoint(latitude: 39.9052, longitude: 116.4084),
        radius: 150.0,
      ),
      GeofenceModel.polygon(
        id: 'custom_school',
        name: '学校围栏',
        vertices: const [
          LocationPoint(latitude: 39.9062, longitude: 116.4064),
          LocationPoint(latitude: 39.9072, longitude: 116.4074),
          LocationPoint(latitude: 39.9067, longitude: 116.4084),
          LocationPoint(latitude: 39.9057, longitude: 116.4074),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地理围栏演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: '查看说明',
          ),
        ],
      ),
      body: Column(
        children: [
          // 选项卡导航
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: TabController(
                length: 4,
                vsync: this,
                initialIndex: _selectedTabIndex,
              ),
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              tabs: const [
                Tab(text: '卡片展示', icon: Icon(Icons.credit_card)),
                Tab(text: '完整地图', icon: Icon(Icons.map)),
                Tab(text: '自定义围栏', icon: Icon(Icons.edit_location)),
                Tab(text: '事件日志', icon: Icon(Icons.event_note)),
              ],
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
            ),
          ),
          
          // 内容区域
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildCardDemoTab(),
                _buildFullMapTab(),
                _buildCustomGeofenceTab(),
                _buildEventLogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建卡片演示标签页
  Widget _buildCardDemoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '地理围栏卡片组件演示',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '以下展示了不同配置的地理围栏卡片组件，适合在首页或设备列表中使用。',
            style: TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 20),
          
          // 标准卡片
          GeofenceMapCard(
            cardConfig: const GeofenceCardConfig(
              title: '宠物定位器',
              subtitle: '监控宠物位置状态',
              icon: Icons.pets,
              height: 280,
            ),
            onGeofenceEvent: _handleGeofenceEvent,
            onTap: () => _showFullMapDialog(context, '宠物定位器'),
          ),
          
          // 紧凑卡片
          GeofenceMapCard(
            cardConfig: const GeofenceCardConfig(
              title: '车辆监控',
              subtitle: '实时追踪车辆位置',
              icon: Icons.directions_car,
              height: 240,
              compactMode: true,
            ),
            mapConfig: const GeofenceMapConfig(
              showLegend: false,
              show3D: false,
              height: 160,
            ),
            onGeofenceEvent: _handleGeofenceEvent,
            onTap: () => _showFullMapDialog(context, '车辆监控'),
          ),
          
          // 自定义样式卡片
          GeofenceMapCard(
            cardConfig: GeofenceCardConfig(
              title: '家庭安防',
              subtitle: '监控家庭成员位置',
              icon: Icons.home_outlined,
              backgroundColor: Colors.blue.shade50,
              height: 260,
            ),
            customGeofences: _customGeofences,
            onGeofenceEvent: _handleGeofenceEvent,
            onTap: () => _showFullMapDialog(context, '家庭安防'),
          ),
        ],
      ),
    );
  }

  /// 构建完整地图标签页
  Widget _buildFullMapTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '完整地理围栏地图',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '包含状态信息和事件列表的完整地图组件。',
            style: TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: GeofenceMapWidget(
              config: const GeofenceMapConfig(
                title: '智能家居地理围栏系统',
                showLegend: true,
                show3D: true,
                showStatus: true,
                showEvents: true,
                maxEventCount: 8,
              ),
              onGeofenceEvent: _handleGeofenceEvent,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建自定义围栏标签页
  Widget _buildCustomGeofenceTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '自定义地理围栏',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '使用预定义的自定义围栏替代默认测试围栏。',
            style: TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 16),
          
          // 围栏信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前围栏列表:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._customGeofences.map((fence) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          fence.type == GeofenceType.circle 
                              ? Icons.radio_button_unchecked 
                              : Icons.crop_square,
                          size: 16,
                          color: fence.type == GeofenceType.circle 
                              ? Colors.red 
                              : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fence.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          fence.type.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: GeofenceMapWidget(
              config: const GeofenceMapConfig(
                title: '自定义围栏演示',
                enableTestFences: false,
                showLegend: true,
                showStatus: true,
                showEvents: true,
              ),
              customGeofences: _customGeofences,
              onGeofenceEvent: _handleGeofenceEvent,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建事件日志标签页
  Widget _buildEventLogTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '地理围栏事件日志',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _allEvents.clear();
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '共 ${_allEvents.length} 个事件',
            style: const TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: _allEvents.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '暂无事件记录',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '切换到其他标签页操作地图以生成事件',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _allEvents.length,
                    itemBuilder: (context, index) {
                      final event = _allEvents[index];
                      final color = _getEventColor(event.status);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.2),
                            child: Icon(
                              _getEventIcon(event.status),
                              color: color,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            event.geofenceName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.statusText),
                              const SizedBox(height: 2),
                              Text(
                                '位置: ${event.currentLocation.longitude.toStringAsFixed(6)}, ${event.currentLocation.latitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 处理地理围栏事件
  void _handleGeofenceEvent(GeofenceEvent event) {
    setState(() {
      _allEvents.insert(0, event);
      // 保持最多100个事件
      if (_allEvents.length > 100) {
        _allEvents.removeLast();
      }
    });
  }

  /// 显示全屏地图对话框
  void _showFullMapDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GeofenceMapWidget(
                  config: GeofenceMapConfig(
                    title: '$title - 详细视图',
                    showLegend: true,
                    show3D: true,
                    showStatus: true,
                    showEvents: true,
                  ),
                  onGeofenceEvent: _handleGeofenceEvent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示信息对话框
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('地理围栏演示说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('本演示展示了地理围栏系统的各种功能：'),
              SizedBox(height: 12),
              Text('📍 卡片展示: 适合在首页显示的紧凑卡片组件'),
              SizedBox(height: 8),
              Text('🗺️ 完整地图: 包含所有功能的完整地图组件'),
              SizedBox(height: 8),
              Text('⚙️ 自定义围栏: 演示如何使用自定义围栏配置'),
              SizedBox(height: 8),
              Text('📋 事件日志: 查看所有地理围栏触发事件'),
              SizedBox(height: 12),
              Text(
                '注意: 使用前请在 lib/common/api_config.dart 中配置高德地图API密钥。',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  /// 获取事件颜色
  Color _getEventColor(GeofenceStatus status) {
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

  /// 获取事件图标
  IconData _getEventIcon(GeofenceStatus status) {
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

/// 简单的TabBar控制器扩展
class _TabController extends TabController {
  _TabController({
    required int length,
    required TickerProvider vsync,
    int initialIndex = 0,
  }) : super(length: length, vsync: vsync, initialIndex: initialIndex);
} 
import 'package:flutter/material.dart';
import '../models/geofence_model.dart';
import '../common/Global.dart';
import 'geofence_map_widget.dart';

/// 地理围栏卡片配置
class GeofenceCardConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final double height;
  final bool showControls;
  final bool compactMode;

  const GeofenceCardConfig({
    this.title = '地理围栏',
    this.subtitle = '监控设备位置',
    this.icon = Icons.location_on,
    this.backgroundColor,
    this.height = 280.0,
    this.showControls = true,
    this.compactMode = false,
  });
}

/// 地理围栏地图卡片
/// 紧凑的卡片形式展示地理围栏地图，适合在首页或列表中使用
class GeofenceMapCard extends StatefulWidget {
  final GeofenceCardConfig cardConfig;
  final GeofenceMapConfig mapConfig;
  final Function(GeofenceEvent)? onGeofenceEvent;
  final VoidCallback? onTap;
  final List<GeofenceModel>? customGeofences;

  const GeofenceMapCard({
    super.key,
    this.cardConfig = const GeofenceCardConfig(),
    GeofenceMapConfig? mapConfig,
    this.onGeofenceEvent,
    this.onTap,
    this.customGeofences,
  }) : mapConfig = mapConfig ?? const GeofenceMapConfig(
          showStatus: false,
          showEvents: false,
          showLegend: false,
          height: 200.0,
        );

  @override
  State<GeofenceMapCard> createState() => _GeofenceMapCardState();
}

class _GeofenceMapCardState extends State<GeofenceMapCard> {
  String _currentStatus = '初始化中...';
  int _eventCount = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      color: widget.cardConfig.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: widget.cardConfig.height,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 卡片头部
              _buildCardHeader(),
              
              const SizedBox(height: 12),
              
              // 地图区域
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GeofenceMapWidget(
                    config: widget.mapConfig,
                    onGeofenceEvent: _handleGeofenceEvent,
                    onStatusChanged: _handleStatusChanged,
                    customGeofences: widget.customGeofences,
                  ),
                ),
              ),
              
              // 底部状态栏（紧凑模式）
              if (widget.cardConfig.compactMode) ...[
                const SizedBox(height: 8),
                _buildCompactStatus(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建卡片头部
  Widget _buildCardHeader() {
    return Row(
      children: [
        // 图标
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Global.currentTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.cardConfig.icon,
            color: Global.currentTheme.primaryColor,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 标题和副标题
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cardConfig.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Global.currentTextColor,
                ),
              ),
              if (widget.cardConfig.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  widget.cardConfig.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // 控制按钮
        if (widget.cardConfig.showControls)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 事件计数徽章
              if (_eventCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_eventCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
              const SizedBox(width: 8),
              
              // 更多按钮
              IconButton(
                onPressed: widget.onTap,
                icon: const Icon(Icons.more_vert),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// 构建紧凑状态栏
  Widget _buildCompactStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Global.currentTheme.isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_searching,
            size: 16,
            color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child:             Text(
              _currentStatus,
              style: TextStyle(
                fontSize: 10,
                color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_eventCount > 0) ...[
            const SizedBox(width: 8),
            Text(
              '事件: $_eventCount',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 处理地理围栏事件
  void _handleGeofenceEvent(GeofenceEvent event) {
    setState(() {
      _eventCount++;
    });
    widget.onGeofenceEvent?.call(event);
  }

  /// 处理状态变化
  void _handleStatusChanged(String status) {
    setState(() {
      _currentStatus = status;
    });
  }
}

/// 简化的地理围栏指示器Widget
/// 用于显示围栏状态的小组件
class GeofenceIndicator extends StatelessWidget {
  final GeofenceStatus status;
  final String text;
  final double size;

  const GeofenceIndicator({
    super.key,
    required this.status,
    required this.text,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: size * 0.6,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

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
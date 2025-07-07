import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../common/Global.dart';

/// 设备卡片组件
class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback? onTap;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showDeviceDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (Global.currentTheme.isDark ? Colors.white : Colors.black).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 设备图标
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: _getIconBorderRadius(),
                ),
                child: Icon(
                  _getDeviceIcon(),
                  color: _getIconColor(),
                  size: 18,
                ),
              ),
              
              const SizedBox(height: 6),
              
              // 设备名称
              Text(
                device.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Global.currentTextColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 1),
              
              // 设备描述
              Text(
                device.description ?? _getDefaultDescription(),
                style: TextStyle(
                  fontSize: 9,
                  color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // 在线状态指示器
              if (device.isOnline) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Global.currentTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '在线',
                    style: TextStyle(
                      fontSize: 7,
                      color: Global.currentTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 获取设备图标
  IconData _getDeviceIcon() {
    switch (device.type) {
      case DeviceType.camera:
        return Icons.videocam;
      case DeviceType.map:
        return Icons.map;
      case DeviceType.petTracker:
        return Icons.location_on;
      case DeviceType.smartSwitch:
        return Icons.toggle_on;
      case DeviceType.router:
        return Icons.router;
      case DeviceType.light:
        return Icons.lightbulb;
    }
  }

  /// 获取图标背景颜色
  Color _getIconBackgroundColor() {
    switch (device.type) {
      case DeviceType.camera:
        return Global.currentTheme.primaryColor;
      case DeviceType.map:
        return Global.currentTheme.accentColor;
      case DeviceType.petTracker:
        return Color.lerp(Global.currentTheme.primaryColor, Colors.black, 0.2) ?? Global.currentTheme.primaryColor;
      case DeviceType.smartSwitch:
        return Color.lerp(Global.currentTheme.accentColor, Colors.black, 0.2) ?? Global.currentTheme.accentColor;
      case DeviceType.router:
        return Color.lerp(Global.currentTheme.primaryColor, Colors.black, 0.3) ?? Global.currentTheme.primaryColor;
      case DeviceType.light:
        return Color.lerp(Global.currentTheme.accentColor, Colors.black, 0.3) ?? Global.currentTheme.accentColor;
    }
  }

  /// 获取图标颜色
  Color _getIconColor() {
    return Colors.white;
  }

  /// 获取图标边框半径
  BorderRadius _getIconBorderRadius() {
    switch (device.type) {
      case DeviceType.petTracker:
        return BorderRadius.circular(24); // 圆形
      case DeviceType.smartSwitch:
      case DeviceType.router:
      case DeviceType.light:
        return BorderRadius.circular(8); // 圆角矩形
      default:
        return BorderRadius.circular(12);
    }
  }

  /// 获取默认描述
  String _getDefaultDescription() {
    switch (device.type) {
      case DeviceType.camera:
        return '智能摄像头';
      case DeviceType.map:
        return '地图设备';
      case DeviceType.petTracker:
        return '宠物定位';
      case DeviceType.smartSwitch:
        return '智能插座';
      case DeviceType.router:
        return '智能路由器';
      case DeviceType.light:
        return '智能灯具';
    }
  }

  /// 显示设备详情
  void _showDeviceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Global.currentTheme.isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(),
                          borderRadius: _getIconBorderRadius(),
                        ),
                        child: Icon(
                          _getDeviceIcon(),
                          color: _getIconColor(),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Global.currentTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              device.type.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: device.isOnline 
                                        ? Colors.green 
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  device.isOnline ? '在线' : '离线',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: device.isOnline 
                                        ? Colors.green 
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '设备信息',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Global.currentTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('设备ID', device.id),
                  _buildInfoRow('设备类型', device.type.displayName),
                  _buildInfoRow('设备分类', device.category.displayName),
                  _buildInfoRow('最后活跃', _formatLastSeen()),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('关闭'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 跳转到设备控制页面
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Global.currentTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('控制设备'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Global.currentTheme.isDark ? Colors.grey[400] : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Global.currentTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化最后活跃时间
  String _formatLastSeen() {
    final now = DateTime.now();
    final difference = now.difference(device.lastSeen);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }
} 
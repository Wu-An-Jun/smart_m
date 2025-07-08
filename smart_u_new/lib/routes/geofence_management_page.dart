import 'package:flutter/material.dart';

import '../common/Global.dart';
import '../common/amap_geofence_service.dart';
import '../models/geofence_model.dart';
import 'geofence_creation_page.dart';

/// 电子围栏管理页面
/// 参考参考应用的设计风格，提供移动端友好的界面
class GeofenceManagementPage extends StatefulWidget {
  final String? deviceId;
  final String? deviceName;

  const GeofenceManagementPage({super.key, this.deviceId, this.deviceName});

  @override
  State<GeofenceManagementPage> createState() => _GeofenceManagementPageState();
}

class _GeofenceManagementPageState extends State<GeofenceManagementPage> {
  final AMapGeofenceService _geofenceService = AMapGeofenceService();
  List<GeofenceModel> _geofences = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  /// 初始化围栏服务
  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
    });

    if (!_isInitialized) {
      // 初始化高德地图围栏服务
      final result = await _geofenceService.initialize();
      if (result) {
        _isInitialized = true;
        print('🏠 高德地图围栏服务初始化成功');
      } else {
        print('🏠 高德地图围栏服务初始化失败');
      }
    }

    _loadGeofences();
  }

  /// 加载围栏列表
  void _loadGeofences() {
    setState(() {
      _isLoading = true;
    });

    // 从高德地图围栏服务加载数据
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final loadedGeofences = _geofenceService.geofences;
        print('📱 管理页面加载围栏: 共${loadedGeofences.length}个');
        for (final fence in loadedGeofences) {
          print('   - ${fence.name} (${fence.type.name})');
        }
        setState(() {
          _geofences = loadedGeofences;
          _isLoading = false;
        });
      }
    });
  }

  /// 删除围栏
  void _deleteGeofence(GeofenceModel geofence) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white, // 使用全局主题背景色
            title: const Text('删除围栏'),
            content: Text('确定要删除围栏 "${geofence.name}" 吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final result = await _geofenceService.removeGeofence(geofence.id);
                  if (result) {
                    _loadGeofences();
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已删除围栏 "${geofence.name}"'),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('删除围栏失败'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Global.currentTheme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (Navigator.canPop(context))
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.chevron_left, size: 24, color: Colors.white),
              )
            else
              Icon(
                Icons.electric_bolt,
                size: 24,
                color: Global.currentTheme.primaryColor,
              ),
            const Spacer(),
            Text(
              '电子围栏',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 24), // 平衡布局
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.currentTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 450, // 增加高度从300到450
        padding: const EdgeInsets.all(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fence_outlined,
              size: 80, // 增加图标大小从64到80
              color: Colors.white,
            ),
            const SizedBox(height: 24), // 增加间距从16到24
            Text(
              '暂无电子围栏',
              style: TextStyle(
                fontSize: 18, // 增加字体大小从16到18
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12), // 增加间距从8到12
            Text(
              '创建围栏来监控设备位置',
              style: TextStyle(
                fontSize: 16, // 增加字体大小从14到16
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建围栏列表项
  Widget _buildGeofenceItem(GeofenceModel geofence) {
    IconData typeIcon;
    Color typeColor;
    String typeText;

    switch (geofence.type) {
      case GeofenceType.circle:
        typeIcon = Icons.radio_button_unchecked;
        typeColor = const Color(0xFF6D28D9);
        typeText = '圆形围栏';
        break;
      case GeofenceType.polygon:
        typeIcon = Icons.crop_square;
        typeColor = const Color(0xFF059669);
        typeText = '多边形围栏';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Global.currentTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Global.currentTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeIcon, color: Colors.white, size: 24),
        ),
        title: Text(
          geofence.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              typeText,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (geofence.type == GeofenceType.circle) ...[
              const SizedBox(height: 2),
              Text(
                '半径: ${geofence.radius.toInt()}米',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 12,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  '报警: ${geofence.alertType.displayName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  geofence.isActive ? Icons.check_circle : Icons.pause_circle,
                  size: 12,
                  color: geofence.isActive ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  geofence.isActive ? '已启用' : '已暂停',
                  style: TextStyle(
                    fontSize: 12,
                    color: geofence.isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                // TODO: 实现编辑功能
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('编辑功能开发中...')));
                break;
              case 'toggle':
                // TODO: 实现启用/禁用功能
                setState(() {
                  // 这里应该调用服务方法来切换状态
                });
                break;
              case 'delete':
                _deleteGeofence(geofence);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text('编辑', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        geofence.isActive ? Icons.pause : Icons.play_arrow,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        geofence.isActive ? '暂停' : '启用',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  /// 构建围栏列表
  Widget _buildGeofenceList() {
    if (_isLoading) {
      return Container(
        height: 300,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6D28D9)),
        ),
      );
    }

    if (_geofences.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                '已创建的围栏',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6D28D9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_geofences.length}个',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: _geofences.length,
            itemBuilder: (context, index) {
              return _buildGeofenceItem(_geofences[index]);
            },
          ),
        ),
      ],
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Global.currentTheme.backgroundColor,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => GeofenceCreationPage(
                        deviceId: widget.deviceId,
                        deviceName: widget.deviceName,
                      ),
                ),
              );

              if (result == true) {
                _loadGeofences();
              }
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              '添加',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildGeofenceList()),
          _buildBottomButton(),
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

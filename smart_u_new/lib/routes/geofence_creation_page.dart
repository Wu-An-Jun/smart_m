import 'package:flutter/material.dart';
import '../common/Global.dart';
import '../models/geofence_model.dart';
import '../common/amap_geofence_service.dart';
import '../widgets/geofence_map_widget.dart';
import '../widgets/simple_map_widget.dart';

/// 电子围栏创建页面
/// 参考参考应用的设计风格，支持创建圆形和多边形围栏
class GeofenceCreationPage extends StatefulWidget {
  final String? deviceId;
  final String? deviceName;

  const GeofenceCreationPage({
    super.key,
    this.deviceId,
    this.deviceName,
  });

  @override
  State<GeofenceCreationPage> createState() => _GeofenceCreationPageState();
}

class _GeofenceCreationPageState extends State<GeofenceCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final AMapGeofenceService _geofenceService = AMapGeofenceService();
  
  GeofenceType _selectedType = GeofenceType.circle;
  String _selectedAlert = 'both'; // enter, exit, both
  double _radius = 500.0;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // 地图相关状态
  String _mapStatus = '正在加载地图...';
  VoidCallback? _mapRedrawCallback;
  VoidCallback? _mapClearCallback;
  LocationPoint? _selectedCenter; // 选中的围栏中心点
  List<LocationPoint> _polygonVertices = []; // 多边形顶点
  bool _useSimpleMap = true; // 是否使用简化地图

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  /// 初始化围栏服务
  Future<void> _initializeService() async {
    if (!_isInitialized) {
      // 初始化高德地图围栏服务
      final result = await _geofenceService.initialize();
      if (result) {
        setState(() {
          _isInitialized = true;
        });
        print('🏠 高德地图围栏服务初始化成功');
      } else {
        print('🏠 高德地图围栏服务初始化失败');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 获取选择的报警类型
  GeofenceAlertType _getSelectedAlertType() {
    switch (_selectedAlert) {
      case 'enter':
        return GeofenceAlertType.enter;
      case 'exit':
        return GeofenceAlertType.exit;
      case 'both':
      default:
        return GeofenceAlertType.both;
    }
  }

  /// 保存围栏
  Future<void> _saveGeofence() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请填写围栏名称'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 创建围栏模型
      GeofenceModel geofence;
      if (_selectedType == GeofenceType.circle) {
        // 检查是否选择了中心点
        if (_selectedCenter == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请先在地图上选择围栏中心点'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        geofence = GeofenceModel.circle(
          id: 'geofence_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          center: _selectedCenter!,
          radius: _radius,
          alertType: _getSelectedAlertType(),
        );
      } else {
        // 检查多边形顶点
        if (_polygonVertices.length < 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('多边形围栏至少需要3个顶点'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        geofence = GeofenceModel.polygon(
          id: 'geofence_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          vertices: _polygonVertices,
          alertType: _getSelectedAlertType(),
        );
      }

      // 添加到服务
      final result = await _geofenceService.addGeofence(geofence);
      
      if (!result) {
        throw Exception('添加围栏失败');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('围栏 "${geofence.name}" 创建成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF0F2F8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.chevron_left,
                size: 24,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            Text(
              '创建围栏',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            const SizedBox(width: 24), // 平衡布局
          ],
        ),
      ),
    );
  }

  /// 构建设置卡片
  Widget _buildSettingsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 围栏类型
            const Text(
              '围栏类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    GeofenceType.circle,
                    Icons.radio_button_unchecked,
                    '圆形围栏',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeOption(
                    GeofenceType.polygon,
                    Icons.crop_square,
                    '多边形围栏',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 围栏名称
            const Text(
              '围栏名称',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '请输入围栏名称',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 报警设置
            const Text(
              '报警设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAlertOption('enter', '进入围栏'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAlertOption('exit', '离开围栏'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAlertOption('both', '进出围栏'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建类型选项
  Widget _buildTypeOption(GeofenceType type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // 清除之前的选择
          _selectedCenter = null;
          _polygonVertices.clear();
          _mapStatus = type == GeofenceType.circle ? '切换到圆形围栏模式' : '切换到多边形围栏模式';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF6D28D9) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFF6D28D9).withOpacity(0.05) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6D28D9) : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6D28D9) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建报警选项
  Widget _buildAlertOption(String value, String label) {
    final isSelected = _selectedAlert == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAlert = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF6D28D9) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isSelected ? const Color(0xFF6D28D9).withOpacity(0.05) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6D28D9) : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// 构建地图卡片
  Widget _buildMapCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 地图组件（根据选择显示不同类型）
            if (_useSimpleMap)
              SimpleMapWidget(
                geofenceType: _selectedType,
                center: _selectedCenter,
                radius: _radius,
                polygonVertices: _polygonVertices,
                onLocationTap: (location) {
                  setState(() {
                    _selectedCenter = location;
                    _mapStatus = '已选择中心点: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
                  });
                },
                onPolygonComplete: (vertices) {
                  setState(() {
                    _polygonVertices = vertices;
                    _mapStatus = '多边形已完成，共 ${vertices.length} 个顶点';
                  });
                },
              )
            else
              GeofenceMapWidget(
                config: const GeofenceMapConfig(
                  title: '围栏创建地图',
                  height: 300,
                  showLegend: false,
                  show3D: false,
                  enableTestFences: false,
                  showStatus: false,
                  showEvents: false,
                ),
                onMapReady: (redrawCallback, clearCallback) {
                  // 保存地图操作回调
                  setState(() {
                    _mapRedrawCallback = redrawCallback;
                    _mapClearCallback = clearCallback;
                    _mapStatus = '地图已准备就绪';
                  });
                  print('围栏创建地图已准备就绪');
                },
                onStatusChanged: (status) {
                  // 更新地图状态
                  setState(() {
                    _mapStatus = status;
                  });
                  print('地图状态: $status');
                },
              ),
            
            // 地图顶部工具栏
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedType == GeofenceType.circle 
                        ? Icons.radio_button_unchecked 
                        : Icons.crop_square,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedType == GeofenceType.circle ? '圆形围栏模式' : '多边形围栏模式',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _useSimpleMap = !_useSimpleMap;
                              _mapStatus = _useSimpleMap ? '切换到简化地图' : '切换到真实地图';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              _useSimpleMap ? Icons.map : Icons.grid_view,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // 点击定位到当前位置
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('正在定位当前位置...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 地图底部信息栏
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _mapStatus.contains('加载') ? Icons.hourglass_empty : Icons.check_circle_outline,
                          color: _mapStatus.contains('失败') ? Colors.red : Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _mapStatus,
                            style: TextStyle(
                              color: _mapStatus.contains('失败') ? Colors.red : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_mapStatus.contains('加载'))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getMapInstructionText(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建半径设置卡片（仅圆形围栏显示）
  Widget _buildRadiusCard() {
    if (_selectedType != GeofenceType.circle) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '半径',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _radius.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '米',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_radius > 50) {
                      setState(() {
                        _radius -= 50;
                      });
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF6D28D9),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: const Color(0xFF6D28D9),
                        overlayColor: const Color(0xFF6D28D9).withOpacity(0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: _radius,
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        onChanged: (value) {
                          setState(() {
                            _radius = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_radius < 1000) {
                      setState(() {
                        _radius += 50;
                      });
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建多边形工具卡片（仅多边形围栏显示）
  Widget _buildPolygonToolsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF0F2F8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _polygonVertices.clear();
                    _selectedCenter = null;
                    _mapStatus = '已清除所有顶点';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已清除所有顶点')),
                  );
                },
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('清除顶点'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_polygonVertices.isNotEmpty) {
                    setState(() {
                      _polygonVertices.removeLast();
                      _mapStatus = '已撤销上一个顶点，剩余 ${_polygonVertices.length} 个';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已撤销上一个顶点')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('没有可撤销的顶点')),
                    );
                  }
                },
                icon: const Icon(Icons.undo, size: 20),
                label: const Text('撤销操作'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部保存按钮
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF0F2F8),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveGeofence,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 获取地图指引文本
  String _getMapInstructionText() {
    if (_selectedType == GeofenceType.circle) {
      if (_selectedCenter != null) {
        return '已选择中心点，请调整半径后保存';
      } else {
        return '点击地图设置围栏中心点，再调整半径';
      }
    } else {
      if (_polygonVertices.isNotEmpty) {
        return '已绘制 ${_polygonVertices.length} 个顶点，继续添加或保存';
      } else {
        return '点击地图绘制多边形顶点，至少需要3个点';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSettingsCard(),
                  _buildMapCard(),
                  _buildRadiusCard(),
                  const SizedBox(height: 16), // 减少底部空间
                ],
              ),
            ),
          ),
          // 将多边形工具按钮移到底部保存按钮上方
          if (_selectedType == GeofenceType.polygon) _buildPolygonToolsCard(),
          _buildBottomButton(),
        ],
      ),
    );
  }
} 
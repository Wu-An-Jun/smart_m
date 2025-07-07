import 'package:flutter/material.dart';

/// 地图组件
class MapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const MapWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 模拟地图背景
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF4CAF50),
                  Color(0xFF66BB6A),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.map,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
          
          // 位置标记
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.locationName ?? '当前位置',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 控制按钮
          Positioned(
            bottom: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  icon: Icons.fullscreen,
                  onTap: () => _showFullscreenMap(context),
                ),
                const SizedBox(height: 8),
                _buildControlButton(
                  icon: Icons.my_location,
                  onTap: () => _centerToCurrentLocation(),
                ),
              ],
            ),
          ),
          
          // 加载状态或错误处理
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black12,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Colors.white70,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '地图模式',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showFullscreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(widget.locationName ?? '地图'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: MapWidget(
            latitude: widget.latitude,
            longitude: widget.longitude,
            locationName: widget.locationName,
          ),
        ),
      ),
    );
  }

  void _centerToCurrentLocation() {
    // 实现定位到当前位置的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在定位当前位置...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 
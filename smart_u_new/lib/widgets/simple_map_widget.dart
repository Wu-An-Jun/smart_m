import 'package:flutter/material.dart';
import '../models/geofence_model.dart';

/// 简化的地图组件用于测试布局和交互
class SimpleMapWidget extends StatefulWidget {
  final Function(LocationPoint)? onLocationTap;
  final Function(List<LocationPoint>)? onPolygonComplete;
  final GeofenceType geofenceType;
  final LocationPoint? center;
  final double? radius;
  final List<LocationPoint> polygonVertices;

  const SimpleMapWidget({
    super.key,
    this.onLocationTap,
    this.onPolygonComplete,
    this.geofenceType = GeofenceType.circle,
    this.center,
    this.radius,
    this.polygonVertices = const [],
  });

  @override
  State<SimpleMapWidget> createState() => _SimpleMapWidgetState();
}

class _SimpleMapWidgetState extends State<SimpleMapWidget> {
  LocationPoint? _tapLocation;
  final List<LocationPoint> _tempVertices = [];

  @override
  void initState() {
    super.initState();
    _tempVertices.addAll(widget.polygonVertices);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _handleMapTap(details.localPosition);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade300,
              Colors.green.shade400,
              Colors.green.shade500,
            ],
          ),
        ),
        child: Stack(
          children: [
            // 地图网格背景
            _buildMapGrid(),
            
            // 地理位置标记
            _buildLocationMarkers(),
            
            // 围栏显示
            if (widget.geofenceType == GeofenceType.circle)
              _buildCircleGeofence(),
            
            if (widget.geofenceType == GeofenceType.polygon)
              _buildPolygonGeofence(),
            
            // 点击位置指示器
            if (_tapLocation != null)
              _buildTapIndicator(),
            
            // 地图中心指示器
            _buildCenterIndicator(),
          ],
        ),
      ),
    );
  }

  /// 构建地图网格背景
  Widget _buildMapGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: MapGridPainter(),
    );
  }

  /// 构建位置标记
  Widget _buildLocationMarkers() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 14),
            SizedBox(width: 4),
            Text(
              '北京市中心',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建圆形围栏
  Widget _buildCircleGeofence() {
    if (widget.center == null || widget.radius == null) return const SizedBox();
    
    return Positioned.fill(
      child: CustomPaint(
        painter: CircleGeofencePainter(
          center: _locationToOffset(widget.center!),
          radius: _metersToPixels(widget.radius!),
        ),
      ),
    );
  }

  /// 构建多边形围栏
  Widget _buildPolygonGeofence() {
    if (_tempVertices.length < 2) return const SizedBox();
    
    return Positioned.fill(
      child: CustomPaint(
        painter: PolygonGeofencePainter(
          vertices: _tempVertices.map(_locationToOffset).toList(),
        ),
      ),
    );
  }

  /// 构建点击位置指示器
  Widget _buildTapIndicator() {
    final offset = _locationToOffset(_tapLocation!);
    return Positioned(
      left: offset.dx - 10,
      top: offset.dy - 10,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  /// 构建地图中心指示器
  Widget _buildCenterIndicator() {
    return const Positioned.fill(
      child: Center(
        child: Icon(
          Icons.add,
          color: Colors.white70,
          size: 24,
        ),
      ),
    );
  }

  /// 处理地图点击
  void _handleMapTap(Offset localPosition) {
    final location = _offsetToLocation(localPosition);
    
    setState(() {
      _tapLocation = location;
    });

    if (widget.geofenceType == GeofenceType.circle) {
      // 圆形围栏：设置中心点
      widget.onLocationTap?.call(location);
    } else {
      // 多边形围栏：添加顶点
      setState(() {
        _tempVertices.add(location);
      });
      
      if (_tempVertices.length >= 3) {
        widget.onPolygonComplete?.call(_tempVertices);
      }
    }
  }

  /// 将地理坐标转换为屏幕偏移
  Offset _locationToOffset(LocationPoint location) {
    // 简化的坐标转换（实际应用中需要使用真实的地图投影）
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    
    final size = renderBox.size;
    
    // 以北京为中心的简化转换
    const centerLat = 39.9087;
    const centerLng = 116.3975;
    
    final x = (location.longitude - centerLng) * 10000 + size.width / 2;
    final y = (centerLat - location.latitude) * 10000 + size.height / 2;
    
    return Offset(x, y);
  }

  /// 将屏幕偏移转换为地理坐标
  LocationPoint _offsetToLocation(Offset offset) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return const LocationPoint(latitude: 39.9087, longitude: 116.3975);
    
    final size = renderBox.size;
    
    // 以北京为中心的简化转换
    const centerLat = 39.9087;
    const centerLng = 116.3975;
    
    final lng = (offset.dx - size.width / 2) / 10000 + centerLng;
    final lat = centerLat - (offset.dy - size.height / 2) / 10000;
    
    return LocationPoint(latitude: lat, longitude: lng);
  }

  /// 将米转换为像素
  double _metersToPixels(double meters) {
    return meters / 10; // 简化的转换比例
  }
}

/// 地图网格绘制器
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;

    // 绘制网格
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 圆形围栏绘制器
class CircleGeofencePainter extends CustomPainter {
  final Offset center;
  final double radius;

  CircleGeofencePainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制填充圆形
    canvas.drawCircle(center, radius, paint);
    
    // 绘制边框
    canvas.drawCircle(center, radius, borderPaint);
    
    // 绘制中心点
    final centerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 多边形围栏绘制器
class PolygonGeofencePainter extends CustomPainter {
  final List<Offset> vertices;

  PolygonGeofencePainter({required this.vertices});

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.length < 2) return;

    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(vertices.first.dx, vertices.first.dy);
    
    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    
    if (vertices.length >= 3) {
      path.close();
      canvas.drawPath(path, paint);
    }
    
    canvas.drawPath(path, borderPaint);
    
    // 绘制顶点
    final vertexPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;
      
    for (final vertex in vertices) {
      canvas.drawCircle(vertex, 4, vertexPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 
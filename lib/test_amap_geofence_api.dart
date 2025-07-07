import 'package:fl_amap/fl_amap.dart';

/// 测试 fl_amap 地理围栏 API
void testAMapGeofenceApi() {
  // 初始化地理围栏
  FlAMapGeoFence().initialize(GeoFenceActivateAction.stayed);
  
  // 添加监听器
  FlAMapGeoFence().addGeoFenceListener(
    onGeoFenceCreated: (result) {
      print('围栏创建结果: ${result.toMap()}');
    },
    onGeoFenceStatusChanged: (result) {
      print('围栏状态变化: ${result.toMap()}');
      print('围栏ID: ${result.customId}');
      print('围栏状态: ${result.status}');
      print('经度: ${result.longitude}');
      print('纬度: ${result.latitude}');
    },
  );
  
  // 添加圆形围栏
  FlAMapGeoFence().addCircle(
    latLng: LatLng(39.908692, 116.397477),
    radius: 300,
    customId: 'circle_1',
  );
  
  // 添加多边形围栏
  FlAMapGeoFence().addCustom(
    latLngs: [
      LatLng(39.933921, 116.372927),
      LatLng(39.907261, 116.376532),
      LatLng(39.900611, 116.418161),
      LatLng(39.941949, 116.435497),
    ],
    customId: 'polygon_1',
  );
  
  // 移除围栏
  FlAMapGeoFence().remove(customId: 'circle_1');
  
  // 暂停围栏监听
  FlAMapGeoFence().pause(customId: 'polygon_1');
  
  // 开始围栏监听
  FlAMapGeoFence().start(customId: 'polygon_1');
  
  // 获取所有围栏
  FlAMapGeoFence().getAll().then((fences) {
    for (var fence in fences) {
      print('围栏ID: ${fence.customId}');
    }
  });
  
  // 销毁
  FlAMapGeoFence().dispose();
} 
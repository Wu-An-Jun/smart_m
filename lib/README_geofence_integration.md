# 地理围栏系统集成指南

## 概述

本项目成功集成了高德地图的动态地理围栏功能，提供了可复用的Widget组件，支持自定义配置和多种展示方式。

## 功能特性

- ✅ **电子围栏**: 支持圆形和多边形围栏
- ✅ **测试选项**: 内置测试围栏和自定义围栏配置
- ✅ **组件化设计**: 可复用的Widget，而非页面形式
- ✅ **自定义展示**: 多种配置选项和展示组件
- ✅ **代码规范**: 遵循项目文件夹结构和命名规范
- ✅ **Web代码分离**: 独立的Web代码文件夹

## 文件结构

```
lib/
├── common/
│   ├── api_config.dart              # API配置 (新增)
│   └── geofence_service.dart        # 地理围栏服务 (新增)
├── models/
│   └── geofence_model.dart          # 地理围栏模型 (新增)
├── widgets/
│   ├── amap_web/                    # Web代码文件夹 (新增)
│   │   └── amap_html_template.dart  # HTML模板
│   ├── geofence_map_widget.dart     # 地理围栏地图组件 (新增)
│   └── geofence_map_card.dart       # 地理围栏卡片组件 (新增)
└── routes/
    └── geofence_demo_page.dart      # 演示页面 (新增)
```

## 使用方法

### 1. 配置API密钥

在 `lib/common/api_config.dart` 中配置高德地图API密钥：

```dart
class ApiConfig {
  // 替换为你的高德地图 Web API Key
  static const String amapWebApiKey = 'your_actual_web_api_key';
  
  // 替换为你的高德地图移动端 API Key  
  static const String amapMobileApiKey = 'your_actual_mobile_api_key';
  
  // 替换为你的高德地图安全码
  static const String amapSecurityCode = 'your_actual_security_code';
}
```

### 2. 基础地图组件使用

```dart
import 'package:flutter/material.dart';
import '../widgets/geofence_map_widget.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GeofenceMapWidget(
        config: GeofenceMapConfig(
          title: '我的地理围栏',
          showLegend: true,
          show3D: true,
          height: 400.0,
        ),
        onGeofenceEvent: (event) {
          print('围栏事件: ${event.geofenceName} - ${event.statusText}');
        },
      ),
    );
  }
}
```

### 3. 卡片组件使用

```dart
import '../widgets/geofence_map_card.dart';

GeofenceMapCard(
  cardConfig: GeofenceCardConfig(
    title: '宠物定位器',
    subtitle: '监控宠物位置状态',
    icon: Icons.pets,
    height: 280,
  ),
  onGeofenceEvent: (event) {
    // 处理围栏事件
  },
  onTap: () {
    // 点击卡片处理
  },
)
```

### 4. 自定义围栏

```dart
// 创建自定义围栏
final customGeofences = [
  GeofenceModel.circle(
    id: 'home',
    name: '家庭围栏',
    center: LocationPoint(latitude: 39.9042, longitude: 116.4074),
    radius: 100.0,
  ),
  GeofenceModel.polygon(
    id: 'school',
    name: '学校围栏',
    vertices: [
      LocationPoint(latitude: 39.9062, longitude: 116.4064),
      LocationPoint(latitude: 39.9072, longitude: 116.4074),
      LocationPoint(latitude: 39.9067, longitude: 116.4084),
      LocationPoint(latitude: 39.9057, longitude: 116.4074),
    ],
  ),
];

// 使用自定义围栏
GeofenceMapWidget(
  customGeofences: customGeofences,
  config: GeofenceMapConfig(
    enableTestFences: false, // 禁用默认测试围栏
  ),
)
```

### 5. 事件处理

```dart
void _handleGeofenceEvent(GeofenceEvent event) {
  switch (event.status) {
    case GeofenceStatus.enter:
      print('进入围栏: ${event.geofenceName}');
      break;
    case GeofenceStatus.exit:
      print('离开围栏: ${event.geofenceName}');
      break;
    case GeofenceStatus.inside:
      print('在围栏内: ${event.geofenceName}');
      break;
    case GeofenceStatus.outside:
      print('在围栏外: ${event.geofenceName}');
      break;
  }
}
```

## 配置选项

### GeofenceMapConfig

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title | String | '地理围栏地图' | 地图标题 |
| showLegend | bool | true | 是否显示图例 |
| show3D | bool | true | 是否启用3D模式 |
| enableTestFences | bool | true | 是否启用测试围栏 |
| height | double | 400.0 | 组件高度 |
| showStatus | bool | true | 是否显示状态信息 |
| showEvents | bool | true | 是否显示事件列表 |
| maxEventCount | int | 5 | 最大事件数量 |

### GeofenceCardConfig

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title | String | '地理围栏' | 卡片标题 |
| subtitle | String | '监控设备位置' | 卡片副标题 |
| icon | IconData | Icons.location_on | 卡片图标 |
| backgroundColor | Color? | null | 背景颜色 |
| height | double | 280.0 | 卡片高度 |
| showControls | bool | true | 是否显示控制按钮 |
| compactMode | bool | false | 是否紧凑模式 |

## 权限配置

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>此应用需要位置权限来提供地理围栏功能</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>此应用需要位置权限来提供地理围栏功能</string>
```

## 依赖项

项目已自动添加以下依赖：

```yaml
dependencies:
  webview_flutter: ^4.4.2  # WebView支持
  fl_amap: ^1.0.2          # 高德地图Flutter插件
  geolocator: ^10.1.0      # 位置服务
```

## 测试功能

运行 `GeofenceDemoPage` 来测试各种功能：

1. **卡片展示**: 查看不同配置的卡片组件
2. **完整地图**: 体验完整功能的地图组件
3. **自定义围栏**: 测试自定义围栏配置
4. **事件日志**: 查看围栏触发事件记录

## 注意事项

1. **API密钥**: 使用前必须配置有效的高德地图API密钥
2. **位置权限**: 确保应用有位置访问权限
3. **网络连接**: 地图加载需要网络连接
4. **性能考虑**: 大量围栏可能影响性能，建议合理控制数量
5. **平台支持**: 主要支持Android和iOS，Web支持有限

## 扩展功能

如需添加更多功能，可以：

1. 在 `GeofenceService` 中添加新的围栏管理方法
2. 在 `GeofenceModel` 中扩展围栏属性
3. 在 `AmapHtmlTemplate` 中修改地图样式和功能
4. 创建新的Widget组件满足特定需求

## 技术架构

- **模型层**: `GeofenceModel` 定义数据结构
- **服务层**: `GeofenceService` 处理业务逻辑
- **视图层**: Widget组件提供UI展示
- **Web层**: HTML模板处理地图渲染
- **配置层**: API配置和常量管理

这种分层架构确保了代码的可维护性和可扩展性。 
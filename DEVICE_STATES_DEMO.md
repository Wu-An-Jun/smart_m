# 主页设备管理功能 - 三种状态实现

## 功能概述

主页的"我的设备"区域现在支持三种不同的显示状态，根据用户拥有的设备类型和数量自动调整UI布局。

## 三种状态

### 状态1: 无设备状态
**触发条件**: 用户没有任何设备
**显示内容**:
- 设备图标 (Icons.devices_other)
- "暂无设备" 标题
- "点击下方按钮添加您的第一个设备" 提示文字
- "添加设备" 按钮，点击跳转到设备管理页面

**UI特点**:
- 灰色调设计，突出空状态
- 清晰的引导操作
- 圆角容器设计

### 状态2: 单一主设备状态
**触发条件**: 
- 只有一个摄像头设备（在线状态）
- 或只有一个地图设备（在线状态）
- 没有其他类型的设备

**显示内容**:
- "我的设备" 标题和"管理"按钮
- 大尺寸设备展示区域（200px高度）

**摄像头设备时**:
- 集成VideoPlayerWidget显示视频流
- 设备名称和在线状态叠加层
- 视频控制功能

**地图设备时**:
- 集成MapWidget显示地图界面
- 位置标记和控制按钮
- 设备名称和在线状态叠加层

### 状态3: 主设备+其他设备状态
**触发条件**: 
- 有摄像头或地图设备（在线）
- 同时还有其他类型的设备

**显示内容**:
- "我的设备" 标题和"管理"按钮
- 主设备展示区域（摄像头/地图）
- "其他设备" 标题
- 4列网格布局的设备卡片列表

**设备卡片特点**:
- 紧凑的设计（80px高度比例）
- 设备图标、名称、描述
- 在线状态指示器
- 点击响应和交互

## 技术实现

### 核心组件

1. **HomeDeviceSection** (`lib/widgets/home_device_section.dart`)
   - 主要的状态管理组件
   - 根据设备数据自动切换显示状态
   - 集成GetX状态管理

2. **MapWidget** (`lib/widgets/map_widget.dart`)
   - 地图设备的展示组件
   - 模拟地图界面和控制功能
   - 支持全屏模式

3. **VideoPlayerWidget** (`lib/widgets/video_player_widget.dart`)
   - 摄像头设备的视频播放组件
   - 支持网络视频流
   - 集成Chewie播放器

4. **DeviceCard** (`lib/widgets/device_card.dart`)
   - 设备卡片组件
   - 支持多种设备类型
   - 统一的设计风格

### 设备类型支持

扩展了设备模型以支持地图设备：

```dart
enum DeviceType {
  camera('camera', '摄像头'),
  map('map', '地图设备'),      // 新增
  petTracker('pet_tracker', '宠物定位器'),
  smartSwitch('smart_switch', '智能开关'),
  router('router', '路由器'),
  light('light', '灯光');
}

enum DeviceCategory {
  pet('pet', '宠物类家居'),
  living('living', '生活类家居'),
  security('security', '安全监控'),
  navigation('navigation', '导航定位'),  // 新增
}
```

### 状态判断逻辑

```dart
// 获取在线的摄像头和地图设备
final cameraDevice = controller.devices
    .where((device) => device.type == DeviceType.camera)
    .where((device) => device.isOnline)
    .firstOrNull;
    
final mapDevice = controller.devices
    .where((device) => device.type == DeviceType.map)
    .where((device) => device.isOnline)
    .firstOrNull;

// 获取其他设备
final otherDevices = controller.devices
    .where((device) => 
        device.type != DeviceType.camera && 
        device.type != DeviceType.map)
    .toList();

// 状态判断
if (controller.devices.isEmpty) {
  return _buildEmptyState();  // 状态1
}

if ((cameraDevice != null || mapDevice != null) && otherDevices.isEmpty) {
  return _buildMainDeviceOnly(cameraDevice, mapDevice);  // 状态2
}

if ((cameraDevice != null || mapDevice != null) && otherDevices.isNotEmpty) {
  return _buildMainDeviceWithOthers(cameraDevice, mapDevice, otherDevices);  // 状态3
}
```

## 用户交互

### 设备点击事件
- **宠物追踪器**: 跳转到地图页面
- **智能开关/路由器/灯光**: 显示设备控制面板
- **其他设备**: 跳转到设备管理页面

### 导航功能
- "管理"按钮: 跳转到设备管理页面 (`/device-management`)
- "添加设备"按钮: 跳转到设备管理页面
- 设备控制面板: 底部抽屉式展示

## 测试覆盖

创建了完整的测试用例 (`test/widgets/home_device_section_test.dart`)：
- 空状态测试
- 单一摄像头设备测试
- 单一地图设备测试
- 混合设备状态测试
- 交互功能测试

## 设计特点

1. **响应式设计**: 根据设备状态自动调整布局
2. **视觉层次**: 明确的主次关系和视觉引导
3. **交互友好**: 清晰的点击区域和视觉反馈
4. **一致性**: 统一的设计语言和组件风格
5. **可扩展性**: 易于添加新的设备类型和状态

## 使用方式

在主页中简单集成：

```dart
// 替换原有的设备区域
const HomeDeviceSection(),
```

组件会自动：
- 从DeviceController获取设备数据
- 判断当前状态
- 渲染对应的UI
- 处理用户交互

## 性能优化

- 使用GetBuilder进行精确的状态更新
- 设备列表的懒加载和缓存
- 视频播放器的按需初始化
- 地图组件的轻量级实现 
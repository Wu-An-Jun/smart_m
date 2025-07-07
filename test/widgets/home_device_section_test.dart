import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../../lib/widgets/home_device_section.dart';
import '../../lib/controllers/device_controller.dart';
import '../../lib/models/device_model.dart';

void main() {
  group('HomeDeviceSection Widget Tests', () {
    late DeviceController mockDeviceController;

    setUp(() {
      // 初始化 GetX
      Get.testMode = true;
      mockDeviceController = DeviceController();
      Get.put(mockDeviceController);
    });

    tearDown(() {
      Get.reset();
    });

    Widget createTestWidget() {
      return GetMaterialApp(
        home: Scaffold(
          body: const HomeDeviceSection(),
        ),
      );
    }

    testWidgets('状态1: 显示空状态当没有设备时', (WidgetTester tester) async {
      // 设置无设备状态
      mockDeviceController.devices.clear();

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 验证空状态显示
      expect(find.text('暂无设备'), findsOneWidget);
      expect(find.text('点击下方按钮添加您的第一个设备'), findsOneWidget);
      expect(find.byIcon(Icons.devices_other), findsOneWidget);
      expect(find.text('添加设备'), findsOneWidget);
    });

    testWidgets('状态2: 显示摄像头设备当只有一个摄像头时', (WidgetTester tester) async {
      // 设置只有摄像头设备的状态
      final cameraDevice = DeviceModel(
        id: 'camera_001',
        name: '客厅摄像头',
        type: DeviceType.camera,
        category: DeviceCategory.security,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '智能摄像头',
        videoUrl: 'test_video_url',
      );

      mockDeviceController.devices.clear();
      mockDeviceController.devices.add(cameraDevice);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 验证摄像头设备显示
      expect(find.text('我的设备'), findsOneWidget);
      expect(find.text('管理'), findsOneWidget);
      // 摄像头组件会显示在VideoPlayerWidget中
      expect(find.text('客厅摄像头'), findsOneWidget);
    });

    testWidgets('状态2: 显示地图设备当只有一个地图设备时', (WidgetTester tester) async {
      // 设置只有地图设备的状态
      final mapDevice = DeviceModel(
        id: 'map_001',
        name: '家庭地图',
        type: DeviceType.map,
        category: DeviceCategory.navigation,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '智能地图',
      );

      mockDeviceController.devices.clear();
      mockDeviceController.devices.add(mapDevice);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 验证地图设备显示
      expect(find.text('我的设备'), findsOneWidget);
      expect(find.text('管理'), findsOneWidget);
      expect(find.text('家庭地图'), findsOneWidget);
    });

    testWidgets('状态3: 显示摄像头和其他设备', (WidgetTester tester) async {
      // 设置有摄像头和其他设备的状态
      final cameraDevice = DeviceModel(
        id: 'camera_001',
        name: '客厅摄像头',
        type: DeviceType.camera,
        category: DeviceCategory.security,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '智能摄像头',
        videoUrl: 'test_video_url',
      );

      final smartSwitch = DeviceModel(
        id: 'switch_001',
        name: '智能开关',
        type: DeviceType.smartSwitch,
        category: DeviceCategory.living,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '智能开关',
      );

      final petTracker = DeviceModel(
        id: 'pet_001',
        name: '小狗追踪器',
        type: DeviceType.petTracker,
        category: DeviceCategory.pet,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '宠物定位',
      );

      mockDeviceController.devices.clear();
      mockDeviceController.devices.addAll([cameraDevice, smartSwitch, petTracker]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 验证摄像头和其他设备显示
      expect(find.text('我的设备'), findsOneWidget);
      expect(find.text('其他设备'), findsOneWidget);
      expect(find.text('客厅摄像头'), findsOneWidget);
      expect(find.text('智能开关'), findsOneWidget);
      expect(find.text('小狗追踪器'), findsOneWidget);
    });

    testWidgets('点击管理按钮应该导航到设备管理页面', (WidgetTester tester) async {
      // 设置有设备的状态
      final device = DeviceModel(
        id: 'test_001',
        name: '测试设备',
        type: DeviceType.smartSwitch,
        category: DeviceCategory.living,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '测试设备',
      );

      mockDeviceController.devices.clear();
      mockDeviceController.devices.add(device);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 点击管理按钮
      await tester.tap(find.text('管理'));
      await tester.pump();

      // 验证导航（这里可能需要模拟路由）
      // 实际项目中可以使用路由测试的框架
    });
  });
} 
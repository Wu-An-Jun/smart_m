import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_rec/routes/app_pages.dart';
import 'package:test_rec/routes/app_routes.dart';
import 'package:test_rec/controllers/device_controller.dart';
import 'package:test_rec/controllers/user_controller.dart';
import 'package:test_rec/controllers/permission_controller.dart';
import 'package:test_rec/common/Global.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive
  await Hive.initFlutter();
  
  // 初始化全局状态
  await Global.initialize();
  
  // 注册依赖
  _initDependencies();
  
  runApp(const MyApp());
}

/// 初始化依赖
void _initDependencies() {
  // 注册UserController为全局单例，permanent: true保证不会被回收
  Get.put<UserController>(UserController(), permanent: true);
  // 注册设备控制器为全局单例，permanent: true保证不会被回收
  Get.put<DeviceController>(DeviceController(), permanent: true);
  // 注册PermissionController为全局单例，permanent: true保证不会被回收
  Get.put<PermissionController>(PermissionController(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Global.appState,
      builder: (context, child) {
        return GetMaterialApp(
          title: '智能管家',
          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
          theme: Global.currentThemeData,
          darkTheme: Global.currentThemeData,
          themeMode: Global.appState.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

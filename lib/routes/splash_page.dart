import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'app_routes.dart';

/// 启动页，自动判断登录态并跳转
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 确保UserController已初始化
    final userController = Get.find<UserController>();
    await Future.delayed(const Duration(milliseconds: 300)); // 可加启动动画
    if (userController.isLoggedIn) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Obx(() {
      if (userController.isInitializing) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      // 初始化完成后只跳转一次
      Future.microtask(() {
        if (userController.isLoggedIn) {
          Get.offAllNamed(AppRoutes.main);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    });
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_routes.dart';
import 'device_match_success_page.dart';
import 'package:get/get.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import 'dart:math';

/// 手动输入设备码页面
class AddDeviceManualPage extends StatefulWidget {
  const AddDeviceManualPage({Key? key}) : super(key: key);

  @override
  State<AddDeviceManualPage> createState() => _AddDeviceManualPageState();
}

class _AddDeviceManualPageState extends State<AddDeviceManualPage> {
  final TextEditingController _codeController = TextEditingController();
  static int _addCount = 0; // 静态变量，所有页面共享

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 绑定设备并跳转到主页面并切换到设备管理Tab，替换当前页面
  /// 如果设备码为空，弹出提示
  Future<void> _onBind() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入设备码')),
      );
      return;
    }
    final DeviceController controller = Get.find<DeviceController>();
    // 按顺序分配电量：绿80，黄40，红10
    final List<int> batteryLevels = [80, 40, 10];
    final int batteryLevel = batteryLevels[_addCount % batteryLevels.length];
    _addCount++;
    final newDevice = DeviceModel(
      id: code,
      name: code, // 名字默认为设备编号
      type: DeviceType.smartSwitch, // 默认类型，可根据实际需求调整
      category: DeviceCategory.living, // 默认分类
      isOnline: true,
      lastSeen: DateTime.now(),
      description: '手动输入添加的设备',
      properties: {'batteryLevel': batteryLevel},
    );
    await controller.addDevice(newDevice);
    // 优先pop回已有的主页面，并切换到设备管理Tab
    bool popped = false;
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == AppRoutes.main) {
        popped = true;
        return true;
      }
      return false;
    });
    if (!popped) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.main,
        arguments: {'selectedIndex': 1},
      );
    }
  }

  Future<void> _onScanQr() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.qrCodeScanner);
    if (result != null && result is String && result.isNotEmpty) {
      setState(() {
        _codeController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C1E),
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: 390,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 34),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      '输入设备码',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '请输入设备背面或包装上的设备码',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 33),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
                      child: TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '请输入设备码',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 10, 11.33, 12.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'imgs/device_code_info.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '设备码位置说明',
                                style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            '设备码通常印在设备背面或包装盒上，以"PET-"开头，后跟8位字母数字组合',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _onBind,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        alignment: Alignment.center,
                        child: const Text(
                          '确认绑定',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _onScanQr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'imgs/scan_qr_bind.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '扫描二维码绑定',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 左上角返回按钮
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../common/Global.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import 'app_routes.dart';

const String kImgPath = 'imgs/';

/// 添加设备视图（用于嵌入设备管理页）
class AddDeviceView extends StatelessWidget {
  final VoidCallback? onBack;
  const AddDeviceView({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = Get.find<DeviceController>();
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildBluetoothCard(controller),
                  const SizedBox(height: 22),
                  _buildActionRow(context, controller),
                  _buildCancelButton(controller),
                ],
              ),
            ),
          ),
        ),
        _buildProgressRow(),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56,
      color: const Color(0xFF0A0C1E),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            child: SvgPicture.asset(
              '${kImgPath}nav_back.svg',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 91),
          const Text(
            '添加宠物定位器',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothCard(DeviceController controller) {
    return Container(
      width: double.infinity,
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
        children: [
          const SizedBox(height: 24),
          const Text(
            '蓝牙自动搜索',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '请确保设备已开启并在附近',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildBluetoothCircle(),
          const SizedBox(height: 16),
          Obx(() {
            final isScanning = controller.isScanning;
            return Text(
              isScanning ? '正在搜索附近设备...' : '未检测到设备',
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 16),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBluetoothCircle() {
    return SizedBox(
      width: 246,
      height: 246,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 246,
            height: 246,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF93C5FD), width: 4),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 178,
            height: 178,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF60A5FA), width: 4),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 114,
            height: 114,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                '${kImgPath}bluetooth_device.svg',
                width: 64,
                height: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, DeviceController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildActionCard(
              svgUrl: 'action_scan.svg',
              title: '扫码绑定',
              subtitle: '扫描设备二维码',
              onTap: () async {
                final bool confirmed = await _showConfirmDialog(context, '扫码绑定');
                if (confirmed) {
                  _onQrCodeAdd(context, controller);
                }
              },
              bgColor: const Color(0xFFF3F4F6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              svgUrl: 'action_manual.svg',
              title: '手动输入',
              subtitle: '输入设备序列号',
              onTap: () async {
                final bool confirmed = await _showConfirmDialog(context, '手动输入');
                if (confirmed) {
                  _onManualAdd();
                }
              },
              bgColor: const Color(0x4DFA9015),
            ),
          ),
        ],
      ),
    );
  }

  /// 弹出二次确认对话框
  Future<bool> _showConfirmDialog(BuildContext context, String actionLabel) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.blue.shade400, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    '操作确认',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text('确定要执行【$actionLabel】操作吗？', style: const TextStyle(fontSize: 14)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('确定'),
                ),
              ],
            );
          },
        ) ?? false;
  }

  Widget _buildActionCard({
    required String svgUrl,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                '${kImgPath}${svgUrl}',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(DeviceController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: GestureDetector(
          onTap: () => controller.isScanning ? controller.stopScanning() : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
              borderRadius: BorderRadius.circular(9999),
              color: const Color(0xFF0A0C1E),
            ),
            child: const Text(
              '取消搜索',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SvgPicture.asset(
            '${kImgPath}progress_line.svg',
            width: 96,
            height: 2,
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                '${kImgPath}progress_arrow.svg',
                width: 16,
                height: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQrCodeAdd(BuildContext context, DeviceController controller) async {
    final result = await Get.toNamed(AppRoutes.qrCodeScanner);
    if (result != null && result is String && result.isNotEmpty) {
      _processQrCodeResult(context, controller, result);
    }
  }

  void _processQrCodeResult(BuildContext context, DeviceController controller, String qrData) {
    try {
      final newDevice = DeviceModel(
        id: 'qr_${DateTime.now().millisecondsSinceEpoch}',
        name: '扫码添加设备',
        type: DeviceType.smartSwitch,
        category: DeviceCategory.living,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '通过扫描二维码添加的设备\n二维码内容: $qrData',
      );
      controller.addDevice(newDevice);
      Get.snackbar(
        '添加成功',
        '已成功添加设备: ${newDevice.name}',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      if (onBack != null) onBack!();
    } catch (e) {
      Get.snackbar(
        '添加失败',
        '无法解析二维码数据: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _onManualAdd() {
    Get.snackbar(
      '功能开发中',
      '手动添加功能正在开发中...',
      backgroundColor: const Color(0xFF8B5CF6),
      colorText: Colors.white,
    );
  }
}

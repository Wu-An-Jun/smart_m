import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../routes/app_routes.dart';
import '../routes/device_match_success_page.dart';

const String kImgPath = 'imgs/';

/// 添加设备视图（用于嵌入设备管理页）
class AddDeviceView extends StatelessWidget {
  final VoidCallback? onBack;
  const AddDeviceView({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageContext = context;
    final DeviceController controller = Get.find<DeviceController>();
    return Column(
      children: [
        // const SizedBox(height: 24),
        _buildAppBar(pageContext),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Obx(() {
            final isScanning = controller.isScanning;
            final hasNewDevice = controller.devices.isNotEmpty;
            // 三态切换
            if (isScanning) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildBluetoothCard(controller),
                  const SizedBox(height: 0),
                  _buildActionRow(pageContext, controller),
                  _buildCancelButton(controller),
                ],
              );
            } else if (!isScanning && !hasNewDevice) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildBluetoothNotFoundCard(controller, pageContext),
                  const SizedBox(height: 0),
                  _buildActionRow(pageContext, controller),
                ],
              );
            } else {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildBluetoothIconButton(controller, pageContext),
                  const SizedBox(height: 0),
                  _buildActionRow(pageContext, controller),
                ],
              );
            }
          }),
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
          const SizedBox(height: 12),
          const Text(
            '蓝牙自动搜索',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            '请确保设备已开启并在附近',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const BluetoothWaveCircle(),
          Obx(() {
            final isScanning = controller.isScanning;
            return Text(
              isScanning ? '正在搜索附近设备...' : '未检测到设备',
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 16),
            );
          }),
          // const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, DeviceController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              svgUrl: 'action_scan.svg',
              title: '扫码绑定',
              subtitle: '扫描设备二维码',
              onTap: () => _onQrCodeAdd(context, controller),
              bgColor: const Color(0xFFF3F4F6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              svgUrl: 'action_manual.svg',
              title: '手动输入',
              subtitle: '输入设备序列号',
              onTap: () => Navigator.of(context).pushNamed('/add_device_manual'),
              bgColor: const Color(0x4DFA9015),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              svgUrl: 'device_card_icon.svg',
              title: '添加定位器',
              subtitle: '一键添加定位器',
              onTap: () => _onAddPetTracker(context, controller),
              bgColor: const Color(0xFFB3E5FC),
            ),
          ),
        ],
      ),
    );
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

  /// 蓝牙入口按钮（卡片包裹，风格统一）
  Widget _buildBluetoothIconButton(DeviceController controller, BuildContext pageContext) {
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
            '点击下方蓝牙图标开始搜索',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => controller.startScanning(
              pageContext,
              (device) => _onDeviceFound(pageContext, controller, device),
            ),
            child: Container(
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
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 蓝牙未发现设备卡片
  Widget _buildBluetoothNotFoundCard(DeviceController controller, BuildContext pageContext) {
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
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '蓝牙自动搜索',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(20),
            child: SvgPicture.asset(
              '${kImgPath}bluetooth_device.svg',
              width: 40,
              height: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '未发现设备',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '请确保设备已开启并在有效距离内',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => controller.startScanning(
              pageContext,
              (device) => _onDeviceFound(pageContext, controller, device),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(9999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: const Text(
                '重新搜索',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
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

  void _processQrCodeResult(
    BuildContext context,
    DeviceController controller,
    String qrData,
  ) {
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
      _onDeviceFound(context, controller, newDevice);
    } catch (e) {
      Get.snackbar(
        '添加失败',
        '无法解析二维码数据: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _onDeviceFound(BuildContext pageContext, DeviceController controller, DeviceModel device) async {
    if (pageContext is Element && !(pageContext as Element).mounted) return;
    await Navigator.of(pageContext).push(
      MaterialPageRoute(
        builder: (_) => DeviceMatchSuccessPage(
          deviceName: device.name,
          model: device.type.toString(), // 你可根据实际字段调整
          battery: 95, // 如有电量字段请替换
          onBindComplete: (String newName) async {
            final updatedDevice = device.copyWith(name: newName);
            await controller.addDevice(updatedDevice);
            if (onBack != null) onBack!(); // 只调用回调，不再pop
          },
        ),
      ),
    );
  }

  void _onAddPetTracker(BuildContext context, DeviceController controller) async {
    final newDevice = DeviceModel(
      id: 'pettracker_${DateTime.now().millisecondsSinceEpoch}',
      name: '定位器',
      type: DeviceType.petTracker,
      category: DeviceCategory.pet,
      isOnline: true,
      lastSeen: DateTime.now(),
      description: '测试用定位器设备',
    );
    await controller.addDevice(newDevice);
    Get.snackbar(
      '添加成功',
      '已成功添加定位器:  A0${newDevice.name}',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
    if (onBack != null) onBack!();
  }
}

/// 动态蓝牙波纹圆圈组件
class BluetoothWaveCircle extends StatefulWidget {
  const BluetoothWaveCircle({super.key});

  @override
  State<BluetoothWaveCircle> createState() => _BluetoothWaveCircleState();
}

class _BluetoothWaveCircleState extends State<BluetoothWaveCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double progress = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // 第一圈波纹
              _buildWaveCircle(246, progress, 0.0),
              // 第二圈波纹（延迟一半）
              _buildWaveCircle(246, (progress + 0.5) % 1.0, 0.3),
              // 蓝色实心圆+图标
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
          );
        },
      ),
    );
  }

  /// 构建动态波纹圆圈
  Widget _buildWaveCircle(
    double maxDiameter,
    double progress,
    double opacityOffset,
  ) {
    final double size = 114 + (maxDiameter - 114) * progress;
    final double opacity =
        (1.0 - progress).clamp(0.0, 1.0) * (1.0 - opacityOffset);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF60A5FA), width: 4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

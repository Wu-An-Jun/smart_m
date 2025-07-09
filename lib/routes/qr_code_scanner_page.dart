import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../common/Global.dart';
import '../controllers/device_controller.dart';
import '../widgets/qr_scanner_overlay.dart';

/// 二维码扫描页面
class QrCodeScannerPage extends StatefulWidget {
  const QrCodeScannerPage({super.key});

  @override
  State<QrCodeScannerPage> createState() => _QrCodeScannerPageState();
}

class _QrCodeScannerPageState extends State<QrCodeScannerPage>
    with WidgetsBindingObserver {
  late final MobileScannerController controller;
  final DeviceController deviceController = Get.find<DeviceController>();
  bool _isScanning = true;
  String? _lastScanned;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 初始化扫描控制器
    try {
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: [BarcodeFormat.qrCode],
      );

      // 启动扫描
      controller
          .start()
          .then((_) {
            if (mounted) {
              setState(() {
                _isScanning = true;
              });
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.toString();
              });
            }
          });
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 处理应用生命周期变化
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码'),
        backgroundColor: const Color(0xFF0A0C1E),
        foregroundColor: Colors.white,
        // 移除actions
      ),
      body:
          _hasError
              ? _buildErrorView()
              : Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error, child) {
                      return _buildErrorView(error.toString());
                    },
                  ),
                  QrScannerOverlay(
                    onToggleTorch: () => controller.toggleTorch(),
                    onManualInput: _onManualInput,
                    isTorchOn: controller.torchState.value == TorchState.on,
                  ),
                ],
              ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView([String? errorCode]) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            '相机初始化失败\n${errorCode ?? _errorMessage}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Get.back(), child: Text('返回')),
        ],
      ),
    );
  }

  /// 构建扫描叠加层
  Widget _buildOverlay() {
    // 已被QrScannerOverlay替换
    return const SizedBox.shrink();
  }

  /// 处理二维码检测
  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      // 防止重复扫描同一个码
      if (_lastScanned == barcode.rawValue) return;
      _lastScanned = barcode.rawValue;

      // 暂停扫描
      setState(() {
        _isScanning = false;
      });

      // 处理扫描结果
      _processQrCode(barcode.rawValue ?? '');
    }
  }

  /// 处理二维码数据
  void _processQrCode(String data) {
    // 播放成功声音
    // 可以使用 audioplayers 包添加声音效果

    // 显示扫描成功提示
    Get.snackbar(
      '扫描成功',
      '二维码内容: $data',
      backgroundColor: Global.currentTheme.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // 延迟后返回上一页并传递结果
    Future.delayed(const Duration(seconds: 2), () {
      Get.back(result: data);
    });
  }

  /// 手动输入二维码内容
  void _onManualInput() {
    // TODO: 跳转到手动输入页面或弹窗
    Get.snackbar(
      '手动输入',
      '请实现手动输入功能',
      backgroundColor: Global.currentTheme.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

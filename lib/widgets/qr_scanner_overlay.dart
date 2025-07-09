import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 扫码框叠加层组件，完全还原Miaoduo设计
class QrScannerOverlay extends StatelessWidget {
  final VoidCallback onToggleTorch;
  final VoidCallback onManualInput;
  final bool isTorchOn;

  const QrScannerOverlay({
    super.key,
    required this.onToggleTorch,
    required this.onManualInput,
    required this.isTorchOn,
  });

  @override
  Widget build(BuildContext context) {
    // 设计尺寸：390x680
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double scanBoxSize = width * 0.76; // 296/390
        final double scanBoxMarginH = (width - scanBoxSize) / 2;
        final double scanBoxMarginV = height * 0.054; // 37/680
        return Stack(
          children: [
            // 顶部遮罩
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: scanBoxMarginV,
              child: Container(color: const Color(0xFF0A0C1E)),
            ),
            // 底部遮罩
            Positioned(
              left: 0,
              right: 0,
              top: scanBoxMarginV + scanBoxSize,
              bottom: 0,
              child: Container(color: const Color(0xFF0A0C1E)),
            ),
            // 左侧遮罩
            Positioned(
              left: 0,
              top: scanBoxMarginV,
              width: scanBoxMarginH,
              height: scanBoxSize,
              child: Container(color: const Color(0xFF0A0C1E)),
            ),
            // 右侧遮罩
            Positioned(
              right: 0,
              top: scanBoxMarginV,
              width: scanBoxMarginH,
              height: scanBoxSize,
              child: Container(color: const Color(0xFF0A0C1E)),
            ),
            // 扫码框边角+横线
            Positioned(
              left: scanBoxMarginH,
              top: scanBoxMarginV,
              width: scanBoxSize,
              height: scanBoxSize,
              child: Stack(
                children: [
                  // 四角
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF3B82F6), width: 2),
                          left: BorderSide(color: Color(0xFF3B82F6), width: 2),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF3B82F6), width: 2),
                          right: BorderSide(color: Color(0xFF3B82F6), width: 2),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                          left: BorderSide(color: Color(0xFF3B82F6), width: 2),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                          right: BorderSide(color: Color(0xFF3B82F6), width: 2),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // 顶部横线
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 2,
                    child: SvgPicture.asset(
                      'imgs/qr_overlay_line.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
            // 提示文字
            Positioned(
              left: scanBoxMarginH + 2,
              right: scanBoxMarginH + 2,
              top: scanBoxMarginV + scanBoxSize + 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x4D000000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '请将设备二维码对准扫描框',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.43,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // 底部按钮
            Positioned(
              left: 0,
              right: 0,
              bottom: 204,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 闪光灯按钮
                  Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: onToggleTorch,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'imgs/qr_flash_icon.svg',
                                width: 24,
                                height: 24,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '闪光灯',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // 手动输入按钮
                  Padding(
                    padding: const EdgeInsets.only(right: 42),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: onManualInput,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'imgs/qr_input_icon.svg',
                                width: 24,
                                height: 24,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '手动输入',
                          style: TextStyle(
                            color: Color(0xFFE7E7E9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

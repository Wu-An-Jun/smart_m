import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/Global.dart';

/// 定位模式类型
enum PositioningMode { normal, powerSaving, superPowerSaving }

/// 定位模式选项
class ModeOption {
  final PositioningMode id;
  final String svgAsset;
  final Color gradientStart;
  final Color gradientEnd;
  final String title;
  final String description;
  final String? arrowAsset;

  const ModeOption({
    required this.id,
    required this.svgAsset,
    required this.gradientStart,
    required this.gradientEnd,
    required this.title,
    required this.description,
    this.arrowAsset,
  });
}

/// 定位模式选择器组件
class PositioningModeSelector extends StatefulWidget {
  final PositioningMode initialMode;
  final Function(PositioningMode)? onModeChanged;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const PositioningModeSelector({
    super.key,
    this.initialMode = PositioningMode.normal,
    this.onModeChanged,
    this.onCancel,
    this.onConfirm,
  });

  @override
  State<PositioningModeSelector> createState() =>
      _PositioningModeSelectorState();
}

class _PositioningModeSelectorState extends State<PositioningModeSelector> {
  late PositioningMode _selectedMode;

  /// 定位模式选项列表
  static const List<ModeOption> _modes = [
    ModeOption(
      id: PositioningMode.normal,
      svgAsset: 'imgs/mode_common.svg',
      gradientStart: Color(0xFFA855F7),
      gradientEnd: Color(0xFF2563EB),
      title: '常用模式',
      description: '经常使用',
      arrowAsset: 'imgs/mode_common_arrow.svg',
    ),
    ModeOption(
      id: PositioningMode.powerSaving,
      svgAsset: 'imgs/mode_power_save.svg',
      gradientStart: Color(0xFF60A5FA),
      gradientEnd: Color(0xFF2563EB),
      title: '省电模式',
      description: '省电省电省电',
    ),
    ModeOption(
      id: PositioningMode.superPowerSaving,
      svgAsset: 'imgs/mode_super_save.svg',
      gradientStart: Color(0xFFFB923C),
      gradientEnd: Color(0xFFEF4444),
      title: '超级省电模式',
      description: '待机待机待机',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 8, top: 24, bottom: 48),
        decoration: BoxDecoration(
          color: const Color(0x1A242B52), // rgba(36,43,82,0.10)
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeList(),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  /// 构建模式选择列表
  Widget _buildModeList() {
    return Column(
      children: _modes.asMap().entries.map((entry) {
        final index = entry.key;
        final mode = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            top: index == 0 ? 6 : 0,
            bottom: 6,
            left: 6,
            right: 6,
          ),
          child: _buildModeItem(mode, isFirst: index == 0),
        );
      }).toList(),
    );
  }

  /// 构建单个模式选项
  Widget _buildModeItem(ModeOption mode, {bool isFirst = false}) {
    final isSelected = _selectedMode == mode.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode.id;
        });
        widget.onModeChanged?.call(mode.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0x26FFFFFF) // 选中时高亮
              : const Color(0x0DFFFFFF), // 未选中时统一浅色
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mode.gradientStart, mode.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    mode.svgAsset,
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Alibaba PuHuiTi 3.0',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildSelectIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  /// 选中指示器
  Widget _buildSelectIndicator(bool isSelected, {double size = 24}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A73E8) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF1A73E8) : const Color(0x4DFFFFFF),
          width: 1.5,
        ),
        shape: BoxShape.circle,
      ),
      child: isSelected
          ? Icon(Icons.check, size: size * 0.67, color: Colors.white)
          : null,
    );
  }

  /// 构建按钮行
  Widget _buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onConfirm,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x333B82F6),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0x333B82F6),
                      blurRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                child: const Text(
                  '确定',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Alibaba PuHuiTi 3.0',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x33FFFFFF), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                child: const Text(
                  '取消',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Alibaba PuHuiTi 3.0',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

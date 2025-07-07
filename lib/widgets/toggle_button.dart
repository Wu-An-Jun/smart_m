import 'package:flutter/material.dart';
import '../common/Global.dart';

/// 切换按钮控件
/// 支持开关状态的视觉反馈和动画效果
class ToggleButton extends StatefulWidget {
  final IconData iconOn;
  final IconData iconOff;
  final String label;
  final bool initialValue;
  final Function(bool)? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double width;
  final double height;
  final bool showStatusIndicator;
  final String? activeText;
  final String? inactiveText;

  const ToggleButton({
    super.key,
    required this.iconOn,
    required this.iconOff,
    required this.label,
    this.initialValue = false,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.width = 70,
    this.height = 80,
    this.showStatusIndicator = true,
    this.activeText,
    this.inactiveText,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton>
    with SingleTickerProviderStateMixin {
  late bool _isOn;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialValue;
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 颜色过渡动画
    _colorAnimation = ColorTween(
      begin: widget.inactiveColor ?? Colors.grey.shade300,
      end: widget.activeColor ?? Global.currentTheme.primaryColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 如果初始状态为开启，立即设置动画到结束状态
    if (_isOn) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 切换状态
  void _toggle() {
    setState(() {
      _isOn = !_isOn;
    });

    // 播放动画
    if (_isOn) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    // 触觉反馈
    // HapticFeedback.lightImpact();

    // 回调通知
    widget.onChanged?.call(_isOn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // 按下时的缩放效果
        _animationController.forward();
      },
      onTapUp: (_) {
        // 松开时恢复
        Future.delayed(const Duration(milliseconds: 50), () {
          _animationController.reverse();
        });
      },
      onTapCancel: () {
        // 取消时恢复
        _animationController.reverse();
      },
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标容器
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _isOn
                          ? (widget.activeColor ?? Global.currentTheme.primaryColor)
                              .withOpacity(0.15)
                          : (widget.inactiveColor ?? Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isOn
                            ? (widget.activeColor ?? Global.currentTheme.primaryColor)
                            : Colors.grey.shade300,
                        width: _isOn ? 2 : 1,
                      ),
                      boxShadow: _isOn
                          ? [
                              BoxShadow(
                                color: (widget.activeColor ?? 
                                    Global.currentTheme.primaryColor)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isOn ? widget.iconOn : widget.iconOff,
                        key: ValueKey(_isOn),
                        size: 20,
                        color: _isOn
                            ? (widget.activeColor ?? Global.currentTheme.primaryColor)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 标签文字
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _isOn ? FontWeight.w600 : FontWeight.w500,
                      color: _isOn
                          ? Global.currentTextColor
                          : Global.currentTextColor.withOpacity(0.7),
                    ),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // 状态指示器（可选）
                  if (widget.showStatusIndicator) ...[
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isOn
                            ? (widget.activeColor ?? Global.currentTheme.primaryColor)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        boxShadow: _isOn
                            ? [
                                BoxShadow(
                                  color: (widget.activeColor ?? 
                                      Global.currentTheme.primaryColor)
                                      .withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                  
                  // 状态文字（可选）
                  if (widget.activeText != null || widget.inactiveText != null) ...[
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _isOn 
                            ? (widget.activeText ?? '已开启')
                            : (widget.inactiveText ?? '已关闭'),
                        key: ValueKey(_isOn),
                        style: TextStyle(
                          fontSize: 10,
                          color: _isOn
                              ? (widget.activeColor ?? Global.currentTheme.primaryColor)
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 预设的切换按钮样式
class ToggleButtonStyles {
  /// 远程开关样式
  static ToggleButton remoteSwitch({
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    return ToggleButton(
      iconOn: Icons.toggle_on,
      iconOff: Icons.toggle_off_outlined,
      label: '远程开关',
      initialValue: initialValue,
      onChanged: onChanged,
      activeColor: Global.currentTheme.primaryColor,
      inactiveColor: Colors.grey.shade300,
      activeText: '已开启',
      inactiveText: '已关闭',
    );
  }

  /// 电子围栏样式
  static ToggleButton geofence({
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    return ToggleButton(
      iconOn: Icons.fence,
      iconOff: Icons.fence_outlined,
      label: '电子围栏',
      initialValue: initialValue,
      onChanged: onChanged,
      activeColor: Colors.orange,
      inactiveColor: Colors.grey.shade300,
    );
  }

  /// 定位模式样式
  static ToggleButton locationMode({
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    return ToggleButton(
      iconOn: Icons.location_on,
      iconOff: Icons.location_on_outlined,
      label: '定位模式',
      initialValue: initialValue,
      onChanged: onChanged,
      activeColor: Colors.green,
      inactiveColor: Colors.grey.shade300,
    );
  }

  /// 智能音箱样式
  static ToggleButton smartSpeaker({
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    return ToggleButton(
      iconOn: Icons.speaker,
      iconOff: Icons.speaker_outlined,
      label: '智能音箱',
      initialValue: initialValue,
      onChanged: onChanged,
      activeColor: Colors.blue,
      inactiveColor: Colors.grey.shade300,
      activeText: '播放中',
      inactiveText: '已暂停',
    );
  }

  /// 智能灯光样式
  static ToggleButton smartLight({
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    return ToggleButton(
      iconOn: Icons.lightbulb,
      iconOff: Icons.lightbulb_outlined,
      label: '智能灯光',
      initialValue: initialValue,
      onChanged: onChanged,
      activeColor: Colors.amber,
      inactiveColor: Colors.grey.shade300,
    );
  }

  /// 空调样式
  static ToggleButton airConditioner({
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    return ToggleButton(
      iconOn: Icons.ac_unit,
      iconOff: Icons.ac_unit_outlined,
      label: '空调',
      initialValue: initialValue,
      onChanged: onChanged,
      activeColor: Colors.cyan,
      inactiveColor: Colors.grey.shade300,
      activeText: '制冷中',
      inactiveText: '已关闭',
    );
  }
} 
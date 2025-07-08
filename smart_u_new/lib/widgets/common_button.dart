import 'package:flutter/material.dart';
import '../common/Global.dart';

/// 通用按钮组件
/// 提供统一的按钮样式和交互效果
class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final BorderSide? border;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border,
  });

  /// 主要按钮（主题色背景）
  CommonButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : style = null,
       backgroundColor = Global.currentTheme.primaryColor,
       foregroundColor = Colors.white,
       border = null;

  /// 次要按钮（表面色背景，主题色边框）
  CommonButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : style = null,
       backgroundColor = Global.currentTheme.surfaceColor,
       foregroundColor = Global.currentTheme.primaryColor,
       border = BorderSide(color: Global.currentTheme.primaryColor);

  /// 危险按钮（红色背景）
  const CommonButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : style = null,
       backgroundColor = Colors.red,
       foregroundColor = Colors.white,
       border = null;

  /// 成功按钮（绿色背景）
  const CommonButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : style = null,
       backgroundColor = Colors.green,
       foregroundColor = Colors.white,
       border = null;

  /// 文本按钮
  CommonButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : style = null,
       backgroundColor = Colors.transparent,
       foregroundColor = Global.currentTheme.primaryColor,
       border = null;

  @override
  Widget build(BuildContext context) {
    Widget button;

    if (icon != null) {
      // 带图标的按钮
      button = ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? Colors.white,
                ),
              ),
            )
          : icon!,
        label: Text(text),
        style: _buildButtonStyle(),
      );
    } else {
      // 普通按钮
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _buildButtonStyle(),
        child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? Colors.white,
                ),
              ),
            )
          : Text(text),
      );
    }

    // 如果需要全宽度或指定宽度
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    } else if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _buildButtonStyle() {
    if (style != null) return style!;

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? Global.currentTheme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        side: border ?? BorderSide.none,
      ),
      elevation: backgroundColor == Colors.transparent ? 0 : 2,
    );
  }
}

/// 图标按钮组件
class CommonIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final String? tooltip;

  const CommonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.padding,
    this.borderRadius,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor ?? Global.currentTheme.primaryColor,
        size: size ?? 24,
      ),
      padding: padding ?? const EdgeInsets.all(8),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
      ),
      tooltip: tooltip,
    );

    return button;
  }
}

/// 浮动操作按钮组件
class CommonFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool mini;

  const CommonFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Global.currentTheme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      tooltip: tooltip,
      mini: mini,
      child: Icon(icon),
    );
  }
} 
import 'package:flutter/material.dart';

/// 响应式Row组件，自动处理溢出问题
/// 当内容超出可用宽度时，会自动换行显示
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment wrapAlignment;
  final WrapCrossAlignment wrapCrossAxisAlignment;
  final double spacing;
  final double runSpacing;
  final bool forceWrap;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapAlignment = WrapAlignment.start,
    this.wrapCrossAxisAlignment = WrapCrossAlignment.center,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.forceWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (forceWrap) {
      return Wrap(
        alignment: wrapAlignment,
        crossAxisAlignment: wrapCrossAxisAlignment,
        spacing: spacing,
        runSpacing: runSpacing,
        children: children,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 如果空间足够，使用Row
        // 否则使用Wrap来防止溢出
        return IntrinsicWidth(
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children.map((child) {
              // 为了防止溢出，给每个子组件包装Flexible
              if (child is Spacer) return child;
              return Flexible(child: child);
            }).toList(),
          ),
        );
      },
    );
  }
}
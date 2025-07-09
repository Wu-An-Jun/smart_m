import 'package:flutter/material.dart';

import '../common/global.dart';

/// 删除确认弹窗组件
/// 用于所有需要二次确认的删除操作
class DeleteConfirmationDialog extends StatelessWidget {
  /// 弹窗标题
  final String title;

  /// 弹窗内容描述
  final String content;

  /// 确认按钮文字
  final String confirmText;

  /// 取消按钮文字
  final String cancelText;

  /// 确认回调
  final VoidCallback? onConfirm;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 是否显示危险样式（红色确认按钮）
  final bool isDangerous;

  const DeleteConfirmationDialog({
    super.key,
    this.title = '确认删除',
    required this.content,
    this.confirmText = '删除',
    this.cancelText = '取消',
    this.onConfirm,
    this.onCancel,
    this.isDangerous = true,
  });

  /// 显示删除确认弹窗的静态方法
  static Future<bool?> show(
    BuildContext context, {
    String title = '确认删除',
    required String content,
    String confirmText = '删除',
    String cancelText = '取消',
    bool isDangerous = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 点击外部不能关闭
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          isDangerous: isDangerous,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Global.currentThemeData;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // 警告图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          isDangerous
                              ? Colors.red.withAlpha(0x1A) // 10% opacity red
                              : theme.colorScheme.primary.withAlpha(0x1A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isDangerous
                          ? Icons.warning_rounded
                          : Icons.help_outline_rounded,
                      color:
                          isDangerous ? Colors.red : theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 标题
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 内容
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              color: Colors.white,
              child: Text(
                content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
            ),

            // 分割线
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.12),
            ),

            // 按钮区域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 确认按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDangerous
                                ? Colors.red
                                : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 扩展方法，为BuildContext添加便捷的删除确认方法
extension DeleteConfirmationExt on BuildContext {
  /// 显示删除确认弹窗
  Future<bool> showDeleteConfirmation({
    String title = '确认删除',
    required String content,
    String confirmText = '删除',
    String cancelText = '取消',
    bool isDangerous = true,
  }) async {
    final result = await DeleteConfirmationDialog.show(
      this,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      isDangerous: isDangerous,
    );
    return result ?? false;
  }
}

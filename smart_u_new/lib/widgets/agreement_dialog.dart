import 'package:flutter/material.dart';

/// 用户协议弹窗组件
class AgreementDialog extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback? onCancel;

  const AgreementDialog({
    super.key,
    required this.onAgree,
    this.onCancel,
  });

  /// 显示用户协议弹窗的静态方法
  static void show(
    BuildContext context, {
    required VoidCallback onAgree,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return AgreementDialog(
          onAgree: onAgree,
          onCancel: onCancel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 200,
          height: 94,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 提示文本
              const Text(
                '请勾选并同意用户协议！',
                style: TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              // 按钮区域
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 同意按钮
                  _buildButton(
                    text: '同意',
                    backgroundColor: const Color(0xFF7B3FF2),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAgree();
                    },
                  ),
                  const SizedBox(width: 12),
                  // 取消按钮
                  _buildButton(
                    text: '取消',
                    backgroundColor: const Color(0xFFBDBDBD),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
} 
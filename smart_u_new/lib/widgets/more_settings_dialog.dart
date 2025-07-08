import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 更多设置弹窗组件
class MoreSettingsDialog extends StatelessWidget {
  final VoidCallback? onOneKeyRestart;
  final VoidCallback? onRemoteWakeup;
  final VoidCallback? onFactoryReset;

  const MoreSettingsDialog({
    super.key,
    this.onOneKeyRestart,
    this.onRemoteWakeup,
    this.onFactoryReset,
  });

  /// 显示更多设置弹窗的静态方法
  static void show(
    BuildContext context, {
    VoidCallback? onOneKeyRestart,
    VoidCallback? onRemoteWakeup,
    VoidCallback? onFactoryReset,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return MoreSettingsDialog(
          onOneKeyRestart: onOneKeyRestart,
          onRemoteWakeup: onRemoteWakeup,
          onFactoryReset: onFactoryReset,
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
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              _buildHeader(context),

              // 内容区域
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _buildActionButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 19, 0),
      child: Row(
        children: [
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
              height: 1.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'imgs/notification_setting_close.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 21.5, left: 20, right: 16.33),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildActionButton(
            context: context,
            svgAsset: 'imgs/notification_setting_wake.svg',
            label: '远程唤醒',
            backgroundColor: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.of(context).pop();
              onRemoteWakeup?.call();
            },
          ),
          const SizedBox(width: 14),
          _buildActionButton(
            context: context,
            svgAsset: 'imgs/notification_setting_restart.svg',
            label: '一键重启',
            backgroundColor: const Color(0xFF22C55E),
            onTap: () {
              Navigator.of(context).pop();
              onOneKeyRestart?.call();
            },
          ),
          const SizedBox(width: 14),
          _buildActionButton(
            context: context,
            svgAsset: 'imgs/notification_setting_reset.svg',
            label: '恢复出厂设置',
            backgroundColor: const Color(0xFFF97316),
            onTap: () {
              Navigator.of(context).pop();
              _showFactoryResetConfirm(context);
            },
          ),
        ],
      ),
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton({
    required BuildContext context,
    required String svgAsset,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                svgAsset,
                width: 28,
                height: 28,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              height: 1.5,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 显示恢复出厂设置确认对话框
  void _showFactoryResetConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade500, size: 24),
              const SizedBox(width: 8),
              const Text(
                '警告',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            '恢复出厂设置将清除所有用户数据和设置，此操作不可撤销。确定要继续吗？',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onFactoryReset?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '确定恢复',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}

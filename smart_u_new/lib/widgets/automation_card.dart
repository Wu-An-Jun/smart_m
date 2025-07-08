import 'package:flutter/material.dart';
import '../models/automation_model.dart';

/// 自动化规则卡片组件
class AutomationCard extends StatelessWidget {
  final AutomationModel automation;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggle;

  const AutomationCard({
    super.key,
    required this.automation,
    this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconData(),
              color: _getIconColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  automation.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  automation.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  automation.subText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          
          // 操作区域
          Column(
            children: [
              // 开关
              Switch(
                value: automation.isEnabled,
                onChanged: onToggle,
                activeColor: const Color(0xFF10B981),
                inactiveThumbColor: const Color(0xFFD1D5DB),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(height: 8),
              // 删除按钮
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取图标数据
  IconData _getIconData() {
    switch (automation.icon) {
      case 'home':
        return Icons.home_outlined;
      case 'welcome':
        return Icons.waving_hand_outlined;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'bell':
        return Icons.notifications_outlined;
      case 'power':
        return Icons.power_settings_new;
      default:
        return Icons.flash_on;
    }
  }

  /// 获取图标背景颜色
  Color _getIconBackgroundColor() {
    switch (automation.iconBg) {
      case 'red':
        return const Color(0xFFFEE2E2);
      case 'green':
        return const Color(0xFFD1FAE5);
      case 'blue':
        return const Color(0xFFDBEAFE);
      case 'orange':
        return const Color(0xFFFED7AA);
      case 'purple':
        return const Color(0xFFE9D5FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  /// 获取图标颜色
  Color _getIconColor() {
    switch (automation.iconColor) {
      case 'red':
        return const Color(0xFFDC2626);
      case 'white':
        return Colors.white;
      case 'green':
        return const Color(0xFF059669);
      case 'blue':
        return const Color(0xFF2563EB);
      case 'orange':
        return const Color(0xFFD97706);
      case 'purple':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF6B7280);
    }
  }
} 
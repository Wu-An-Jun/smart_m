import 'package:flutter/material.dart';
import 'delete_confirmation_dialog.dart';

/// 删除确认弹窗使用示例
/// 展示各种使用场景和自定义选项
class DeleteConfirmationUsageExample extends StatelessWidget {
  const DeleteConfirmationUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('删除确认弹窗示例'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 示例1：基本用法
            ElevatedButton(
              onPressed: () => _showBasicExample(context),
              child: const Text('基本删除确认'),
            ),
            
            const SizedBox(height: 16),
            
            // 示例2：自定义标题和内容
            ElevatedButton(
              onPressed: () => _showCustomExample(context),
              child: const Text('自定义标题和内容'),
            ),
            
            const SizedBox(height: 16),
            
            // 示例3：非危险操作（蓝色按钮）
            ElevatedButton(
              onPressed: () => _showNonDangerousExample(context),
              child: const Text('非危险操作确认'),
            ),
            
            const SizedBox(height: 16),
            
            // 示例4：使用扩展方法
            ElevatedButton(
              onPressed: () => _showExtensionExample(context),
              child: const Text('使用扩展方法'),
            ),
            
            const SizedBox(height: 32),
            
            // 代码示例说明
            const Text(
              '使用方法：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''// 方法1：使用静态方法
final result = await DeleteConfirmationDialog.show(
  context,
  title: '删除设备',
  content: '确定要删除设备吗？',
);

// 方法2：使用扩展方法（推荐）
final confirmed = await context.showDeleteConfirmation(
  title: '删除设备',
  content: '确定要删除设备吗？',
);

if (confirmed) {
  // 执行删除操作
}''',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 基本删除确认示例
  void _showBasicExample(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      content: '此操作无法撤销，确定要继续吗？',
    );
    
    if (confirmed == true) {
      _showResult(context, '已确认删除');
    } else {
      _showResult(context, '已取消操作');
    }
  }

  /// 自定义标题和内容示例
  void _showCustomExample(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: '删除聊天记录',
      content: '删除后聊天记录将无法恢复，包括所有消息、图片和文件。确定要删除吗？',
      confirmText: '永久删除',
      cancelText: '保留',
    );
    
    if (confirmed == true) {
      _showResult(context, '聊天记录已删除');
    } else {
      _showResult(context, '已保留聊天记录');
    }
  }

  /// 非危险操作示例
  void _showNonDangerousExample(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: '移除收藏',
      content: '确定要从收藏列表中移除这个项目吗？',
      confirmText: '移除',
      isDangerous: false,
    );
    
    if (confirmed == true) {
      _showResult(context, '已从收藏中移除');
    } else {
      _showResult(context, '已取消移除');
    }
  }

  /// 使用扩展方法示例
  void _showExtensionExample(BuildContext context) async {
    final confirmed = await context.showDeleteConfirmation(
      title: '清空购物车',
      content: '确定要清空购物车中的所有商品吗？',
      confirmText: '清空',
    );
    
    if (confirmed) {
      _showResult(context, '购物车已清空');
    } else {
      _showResult(context, '已保留购物车内容');
    }
  }

  /// 显示操作结果
  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 
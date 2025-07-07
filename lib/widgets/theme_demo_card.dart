import 'package:flutter/material.dart';
import '../common/Global.dart';

/// 主题演示卡片
/// 用于展示当前主题的各种颜色和组件效果
class ThemeDemoCard extends StatelessWidget {
  const ThemeDemoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Global.currentTheme;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '当前主题: ${theme.displayName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 颜色展示
            _buildColorRow('主色调', theme.primaryColor),
            const SizedBox(height: 8),
            _buildColorRow('强调色', theme.accentColor),
            const SizedBox(height: 8),
            _buildColorRow('背景色', theme.backgroundColor),
            const SizedBox(height: 8),
            _buildColorRow('表面色', theme.surfaceColor),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // 按钮示例
            const Text(
              '按钮示例',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('主要按钮'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('次要按钮'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('文本按钮'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 输入框示例
            const Text(
              '输入框示例',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              decoration: InputDecoration(
                labelText: '示例输入框',
                hintText: '请输入内容',
                prefixIcon: Icon(Icons.edit, color: theme.primaryColor),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 快速切换主题按钮
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Global.switchToNextTheme();
                },
                icon: const Icon(Icons.palette),
                label: const Text('切换到下一个主题'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '#${color.value.toRadixString(16).toUpperCase().substring(2)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
} 
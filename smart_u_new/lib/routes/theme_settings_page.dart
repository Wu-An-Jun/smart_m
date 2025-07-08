import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/Global.dart';
import '../models/theme_model.dart';
import '../widgets/theme_demo_card.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: AnimatedBuilder(
        animation: Global.appState,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 主题演示卡片
                const ThemeDemoCard(),
                
                // 主题选择区域
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '选择主题色',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 主题网格
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: Global.availableThemes.length,
                        itemBuilder: (context, index) {
                          final theme = Global.availableThemes[index];
                          final isSelected = Global.currentThemeIndex == index;
                          
                          return _buildThemeCard(theme, index, isSelected);
                        },
                      ),
                    ],
                  ),
                ),
                
                // 其他设置
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '其他设置',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 暗色模式开关
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '暗色模式',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '启用深色主题模式',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: Global.isDarkMode,
                            onChanged: (value) {
                              Global.appState.toggleThemeMode();
                              setState(() {});
                            },
                            activeColor: Global.currentTheme.primaryColor,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // 重置按钮
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _resetToDefault,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Global.currentTheme.primaryColor),
                            foregroundColor: Global.currentTheme.primaryColor,
                          ),
                          child: const Text('重置为默认主题'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 底部间距
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(ThemeConfig theme, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Global.setTheme(index);
        setState(() {});
        
        // 显示切换成功提示
        Get.snackbar(
          '主题已更新',
          '已切换到${theme.displayName}主题',
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          colorText: theme.primaryColor,
          duration: const Duration(seconds: 2),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 主题色圆圈
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            
            // 主题名称
            Text(
              theme.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.primaryColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 色彩预览条
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorDot(theme.primaryColor),
                const SizedBox(width: 4),
                _buildColorDot(theme.accentColor),
                const SizedBox(width: 4),
                _buildColorDot(theme.primaryColor.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  void _resetToDefault() {
    Global.setTheme(0); // 重置为蓝色主题
    Global.appState.setThemeMode(ThemeMode.light); // 重置为浅色模式
    setState(() {});
    
    Get.snackbar(
      '重置成功',
      '已重置为默认主题',
      backgroundColor: Global.currentTheme.primaryColor.withOpacity(0.1),
      colorText: Global.currentTheme.primaryColor,
    );
  }
} 
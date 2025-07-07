import 'package:flutter/material.dart';
import '../widgets/smart_home_layout.dart';
import '../models/task_model.dart';
import '../common/Global.dart';

/// 任务设置页面
class TaskSettingPage extends StatefulWidget {
  final Function(TaskModel) onTaskSet;

  const TaskSettingPage({
    super.key,
    required this.onTaskSet,
  });

  @override
  State<TaskSettingPage> createState() => _TaskSettingPageState();
}

class _TaskSettingPageState extends State<TaskSettingPage> {
  String _selectedDevice = '选择设备';
  String _selectedAction = '选择操作';
  String _selectedAppService = '发送短信通知';
  bool _isAppServiceSelected = true; // 默认选择应用服务

  @override
  Widget build(BuildContext context) {
    return SmartHomeLayout(
      title: '设置执行任务',
      showBackButton: true,
      child: Container(
        color: Global.currentTheme.backgroundColor,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: Global.currentTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '自动化设置',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 设备服务
                _buildSectionTitle('设备服务'),
                const SizedBox(height: 12),
                _buildDeviceServiceSection(),

                const SizedBox(height: 20),

                // 应用服务
                _buildSectionTitle('应用服务'),
                const SizedBox(height: 12),
                _buildAppServiceSection(),

                const SizedBox(height: 24),

                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Global.currentTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '确定',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.edit, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFF9CA3AF)),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
    );
  }

  /// 构建设备服务区域
  Widget _buildDeviceServiceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Global.currentTheme.accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedDevice,
              onChanged: (value) {
                setState(() {
                  _selectedDevice = value!;
                  _isAppServiceSelected = false;
                });
              },
              items: ['选择设备', '智能灯', '空调', '窗帘', '音响'].map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device),
                );
              }).toList(),
              underline: Container(),
              isExpanded: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedAction,
              onChanged: (value) {
                setState(() {
                  _selectedAction = value!;
                  _isAppServiceSelected = false;
                });
              },
              items: ['选择操作', '打开', '关闭', '调节亮度', '调节温度'].map((action) {
                return DropdownMenuItem(
                  value: action,
                  child: Text(action),
                );
              }).toList(),
              underline: Container(),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建应用服务区域
  Widget _buildAppServiceSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: _isAppServiceSelected,
            onChanged: (value) {
              setState(() {
                _isAppServiceSelected = value!;
              });
            },
            activeColor: const Color(0xFF3B82F6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const Expanded(
            child: Text(
              '发送短信通知',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理确认操作
  void _handleConfirm() {
    TaskModel task;
    
    if (_isAppServiceSelected) {
      // 应用服务
      final appSettings = AppServiceSettings(
        serviceType: _selectedAppService,
      );
      
      task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TaskType.app,
        title: '应用服务',
        description: _selectedAppService,
        settings: appSettings.toMap(),
      );
    } else {
      // 设备服务
      final deviceSettings = DeviceServiceSettings(
        selectedDevice: _selectedDevice != '选择设备' ? _selectedDevice : null,
        selectedAction: _selectedAction != '选择操作' ? _selectedAction : null,
      );
      
      if (deviceSettings.selectedDevice == null || deviceSettings.selectedAction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请完整选择设备和操作')),
        );
        return;
      }
      
      task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TaskType.device,
        title: '设备服务',
        description: '${deviceSettings.selectedDevice} - ${deviceSettings.selectedAction}',
        settings: deviceSettings.toMap(),
      );
    }

    widget.onTaskSet(task);
    Navigator.pop(context);
  }
} 
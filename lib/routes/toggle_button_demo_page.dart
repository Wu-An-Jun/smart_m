import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/Global.dart';
import '../widgets/toggle_button.dart';

/// 切换按钮演示页面
class ToggleButtonDemoPage extends StatefulWidget {
  const ToggleButtonDemoPage({super.key});

  @override
  State<ToggleButtonDemoPage> createState() => _ToggleButtonDemoPageState();
}

class _ToggleButtonDemoPageState extends State<ToggleButtonDemoPage> {
  // 各种设备的开关状态
  bool _remoteSwitchState = false;
  bool _geofenceState = true;
  bool _locationModeState = false;
  bool _smartSpeakerState = true;
  bool _smartLightState = false;
  bool _airConditionerState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('切换按钮演示'),
        backgroundColor: Global.currentTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Global.currentTextColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '智能设备控制',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Global.currentTextColor,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 预设样式演示
            _buildSectionTitle('预设样式'),
            const SizedBox(height: 16),
            
            // 第一行：远程开关、电子围栏、定位模式
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ToggleButtonStyles.remoteSwitch(
                  initialValue: _remoteSwitchState,
                  onChanged: (value) {
                    setState(() {
                      _remoteSwitchState = value;
                    });
                    _showStatusSnackBar('远程开关', value);
                  },
                ),
                
                ToggleButtonStyles.geofence(
                  initialValue: _geofenceState,
                  onChanged: (value) {
                    setState(() {
                      _geofenceState = value;
                    });
                    _showStatusSnackBar('电子围栏', value);
                  },
                ),
                
                ToggleButtonStyles.locationMode(
                  initialValue: _locationModeState,
                  onChanged: (value) {
                    setState(() {
                      _locationModeState = value;
                    });
                    _showStatusSnackBar('定位模式', value);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 第二行：智能音箱、智能灯光、空调
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ToggleButtonStyles.smartSpeaker(
                  initialValue: _smartSpeakerState,
                  onChanged: (value) {
                    setState(() {
                      _smartSpeakerState = value;
                    });
                    _showStatusSnackBar('智能音箱', value);
                  },
                ),
                
                ToggleButtonStyles.smartLight(
                  initialValue: _smartLightState,
                  onChanged: (value) {
                    setState(() {
                      _smartLightState = value;
                    });
                    _showStatusSnackBar('智能灯光', value);
                  },
                ),
                
                ToggleButtonStyles.airConditioner(
                  initialValue: _airConditionerState,
                  onChanged: (value) {
                    setState(() {
                      _airConditionerState = value;
                    });
                    _showStatusSnackBar('空调', value);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // 自定义样式演示
            _buildSectionTitle('自定义样式'),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 自定义样式1：紫色主题
                ToggleButton(
                  iconOn: Icons.wifi,
                  iconOff: Icons.wifi_off,
                  label: 'WiFi',
                  initialValue: true,
                  activeColor: Colors.purple,
                  inactiveColor: Colors.grey.shade300,
                  showStatusIndicator: false,
                  onChanged: (value) {
                    _showStatusSnackBar('WiFi', value);
                  },
                ),
                
                // 自定义样式2：红色主题，带状态文字
                ToggleButton(
                  iconOn: Icons.security,
                  iconOff: Icons.security_outlined,
                  label: '安全模式',
                  initialValue: false,
                  activeColor: Colors.red,
                  inactiveColor: Colors.grey.shade300,
                  activeText: '保护中',
                  inactiveText: '未启用',
                  onChanged: (value) {
                    _showStatusSnackBar('安全模式', value);
                  },
                ),
                
                // 自定义样式3：绿色主题，不同尺寸
                ToggleButton(
                  iconOn: Icons.battery_charging_full,
                  iconOff: Icons.battery_alert,
                  label: '省电模式',
                  initialValue: false,
                  activeColor: Colors.green,
                  inactiveColor: Colors.orange,
                  width: 80,
                  height: 90,
                  onChanged: (value) {
                    _showStatusSnackBar('省电模式', value);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // 网格布局演示
            _buildSectionTitle('网格布局演示'),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                ToggleButton(
                  iconOn: Icons.camera,
                  iconOff: Icons.camera_outlined,
                  label: '摄像头',
                  initialValue: true,
                  activeColor: Colors.indigo,
                  onChanged: (value) => _showStatusSnackBar('摄像头', value),
                ),
                
                ToggleButton(
                  iconOn: Icons.door_front_door,
                  iconOff: Icons.door_front_door_outlined,
                  label: '门锁',
                  initialValue: false,
                  activeColor: Colors.brown,
                  onChanged: (value) => _showStatusSnackBar('门锁', value),
                ),
                
                ToggleButton(
                  iconOn: Icons.thermostat,
                  iconOff: Icons.thermostat_outlined,
                  label: '温控器',
                  initialValue: true,
                  activeColor: Colors.deepOrange,
                  onChanged: (value) => _showStatusSnackBar('温控器', value),
                ),
                
                ToggleButton(
                  iconOn: Icons.sensor_window,
                  iconOff: Icons.sensor_window_outlined,
                  label: '窗户感应',
                  initialValue: false,
                  activeColor: Colors.teal,
                  onChanged: (value) => _showStatusSnackBar('窗户感应', value),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // 操作按钮区域
            _buildSectionTitle('批量操作'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _turnOnAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Global.currentTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('全部开启'),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _turnOffAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('全部关闭'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 构建节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Global.currentTextColor,
      ),
    );
  }

  /// 显示状态变化提示
  void _showStatusSnackBar(String deviceName, bool isOn) {
    Get.snackbar(
      deviceName,
      isOn ? '$deviceName 已开启' : '$deviceName 已关闭',
      backgroundColor: Global.currentTheme.primaryColor.withOpacity(0.1),
      colorText: Global.currentTheme.primaryColor,
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 全部开启
  void _turnOnAll() {
    setState(() {
      _remoteSwitchState = true;
      _geofenceState = true;
      _locationModeState = true;
      _smartSpeakerState = true;
      _smartLightState = true;
      _airConditionerState = true;
    });
    
    Get.snackbar(
      '批量操作',
      '所有设备已开启',
      backgroundColor: Global.currentTheme.primaryColor.withOpacity(0.1),
      colorText: Global.currentTheme.primaryColor,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 全部关闭
  void _turnOffAll() {
    setState(() {
      _remoteSwitchState = false;
      _geofenceState = false;
      _locationModeState = false;
      _smartSpeakerState = false;
      _smartLightState = false;
      _airConditionerState = false;
    });
    
    Get.snackbar(
      '批量操作',
      '所有设备已关闭',
      backgroundColor: Colors.grey.shade600.withOpacity(0.1),
      colorText: Colors.grey.shade600,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
} 
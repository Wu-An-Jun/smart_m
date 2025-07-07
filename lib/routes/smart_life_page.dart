import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmartLifePage extends StatefulWidget {
  const SmartLifePage({super.key});

  @override
  State<SmartLifePage> createState() => _SmartLifePageState();
}

class _SmartLifePageState extends State<SmartLifePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('智能生活'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 智能设备控制区域
            _buildDeviceControlSection(),
            const SizedBox(height: 20),
            
            // 场景模式区域
            _buildSceneModeSection(),
            const SizedBox(height: 20),
            
            // 智能家电区域
            _buildSmartApplianceSection(),
            const SizedBox(height: 20),
            
            // 环境监测区域
            _buildEnvironmentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControlSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设备控制',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildDeviceItem(
                icon: Icons.lightbulb_outline,
                label: '智能灯光',
                color: const Color(0xFFFFA726),
                isOn: true,
              ),
              _buildDeviceItem(
                icon: Icons.ac_unit,
                label: '空调',
                color: const Color(0xFF42A5F5),
                isOn: false,
              ),
              _buildDeviceItem(
                icon: Icons.camera_alt,
                label: '摄像头',
                color: const Color(0xFF66BB6A),
                isOn: true,
              ),
              _buildDeviceItem(
                icon: Icons.door_front_door,
                label: '智能门锁',
                color: const Color(0xFF8D6E63),
                isOn: true,
              ),
              _buildDeviceItem(
                icon: Icons.speaker,
                label: '音响',
                color: const Color(0xFFAB47BC),
                isOn: false,
              ),
              _buildDeviceItem(
                icon: Icons.window,
                label: '窗帘',
                color: const Color(0xFF26A69A),
                isOn: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isOn,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('设备控制', '$label${isOn ? "已关闭" : "已开启"}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isOn ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOn ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isOn ? color : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isOn ? color : Colors.grey.shade600,
                fontWeight: isOn ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOn ? Colors.green : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneModeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '场景模式',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSceneModeItem(
                  icon: Icons.home,
                  label: '回家模式',
                  color: const Color(0xFF6B4DFF),
                  isActive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSceneModeItem(
                  icon: Icons.bedtime,
                  label: '睡眠模式',
                  color: const Color(0xFF5B9EFF),
                  isActive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSceneModeItem(
                  icon: Icons.work,
                  label: '工作模式',
                  color: const Color(0xFF52C5A8),
                  isActive: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSceneModeItem(
                  icon: Icons.exit_to_app,
                  label: '离家模式',
                  color: const Color(0xFFFF9F40),
                  isActive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSceneModeItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('场景模式', '$label已${isActive ? "关闭" : "激活"}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? color : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? color : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartApplianceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '智能家电',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildApplianceItem(
            icon: Icons.kitchen,
            title: '智能冰箱',
            subtitle: '温度：2°C | 状态：正常',
            color: const Color(0xFF42A5F5),
          ),
          const SizedBox(height: 12),
          _buildApplianceItem(
            icon: Icons.local_laundry_service,
            title: '洗衣机',
            subtitle: '剩余时间：35分钟',
            color: const Color(0xFF66BB6A),
          ),
          const SizedBox(height: 12),
          _buildApplianceItem(
            icon: Icons.tv,
            title: '智能电视',
            subtitle: '正在播放：电影频道',
            color: const Color(0xFFAB47BC),
          ),
        ],
      ),
    );
  }

  Widget _buildApplianceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '环境监测',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentItem(
                  icon: Icons.thermostat,
                  label: '温度',
                  value: '22°C',
                  color: const Color(0xFFFF9F40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnvironmentItem(
                  icon: Icons.water_drop,
                  label: '湿度',
                  value: '65%',
                  color: const Color(0xFF42A5F5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentItem(
                  icon: Icons.air,
                  label: '空气质量',
                  value: '良好',
                  color: const Color(0xFF66BB6A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnvironmentItem(
                  icon: Icons.wb_sunny,
                  label: '光照',
                  value: '适中',
                  color: const Color(0xFFFFA726),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 
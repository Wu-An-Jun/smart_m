import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('服务'),
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
            // 常用服务区域
            _buildCommonServicesSection(),
            const SizedBox(height: 20),
            
            // 智能助手区域
            _buildAIServicesSection(),
            const SizedBox(height: 20),
            
            // 生活服务区域
            _buildLifeServicesSection(),
            const SizedBox(height: 20),
            
            // 其他服务区域
            _buildOtherServicesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonServicesSection() {
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
            '常用服务',
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
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildServiceItem(
                icon: Icons.camera_alt,
                label: '摄像头',
                color: const Color(0xFF6B4DFF),
              ),
              _buildServiceItem(
                icon: Icons.videocam,
                label: '录像',
                color: const Color(0xFF5B9EFF),
              ),
              _buildServiceItem(
                icon: Icons.screenshot,
                label: '截屏',
                color: const Color(0xFF52C5A8),
              ),
              _buildServiceItem(
                icon: Icons.security,
                label: '安防',
                color: const Color(0xFF7C5CFF),
              ),
              _buildServiceItem(
                icon: Icons.doorbell,
                label: '门铃',
                color: const Color(0xFFFF9F40),
              ),
              _buildServiceItem(
                icon: Icons.notifications,
                label: '通知',
                color: const Color(0xFFFF6B6B),
              ),
              _buildServiceItem(
                icon: Icons.cloud_sync,
                label: '同步',
                color: const Color(0xFF26A69A),
              ),
              _buildServiceItem(
                icon: Icons.backup,
                label: '备份',
                color: const Color(0xFFAB47BC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('服务', '$label 功能开发中');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAIServicesSection() {
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
            '智能助手',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildAIServiceItem(
            icon: Icons.smart_toy,
            title: 'AI聊天助手',
            subtitle: '智能对话，解答疑问',
            color: const Color(0xFF6B4DFF),
            onTap: () {
              Get.snackbar('智能助手', 'AI聊天助手功能开发中');
            },
          ),
          const SizedBox(height: 12),
          _buildAIServiceItem(
            icon: Icons.image_search,
            title: '图像识别',
            subtitle: '智能识别图片内容',
            color: const Color(0xFF52C5A8),
            onTap: () {
              Get.snackbar('智能助手', '图像识别功能开发中');
            },
          ),
          const SizedBox(height: 12),
          _buildAIServiceItem(
            icon: Icons.translate,
            title: '语言翻译',
            subtitle: '多语言实时翻译',
            color: const Color(0xFF5B9EFF),
            onTap: () {
              Get.snackbar('智能助手', '语言翻译功能开发中');
            },
          ),
          const SizedBox(height: 12),
          _buildAIServiceItem(
            icon: Icons.settings_applications,
            title: '更多设置演示',
            subtitle: '测试设备更多设置弹窗功能',
            color: const Color(0xFFFF6B6B),
            onTap: () {
              Get.toNamed('/more-settings-demo');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAIServiceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildLifeServicesSection() {
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
            '生活服务',
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
                child: _buildLifeServiceCard(
                  icon: Icons.payment,
                  title: '充值缴费',
                  color: const Color(0xFFFF9F40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLifeServiceCard(
                  icon: Icons.local_taxi,
                  title: '出行服务',
                  color: const Color(0xFF26A69A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLifeServiceCard(
                  icon: Icons.restaurant,
                  title: '美食外卖',
                  color: const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLifeServiceCard(
                  icon: Icons.home_repair_service,
                  title: '家政服务',
                  color: const Color(0xFFAB47BC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifeServiceCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('生活服务', '$title 功能开发中');
      },
      child: Container(
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
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherServicesSection() {
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
            '其他服务',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildOtherServiceItem(
            icon: Icons.headset_mic,
            title: '客服支持',
            subtitle: '7x24小时在线客服',
            color: const Color(0xFF42A5F5),
          ),
          const Divider(height: 24),
          _buildOtherServiceItem(
            icon: Icons.feedback,
            title: '意见反馈',
            subtitle: '您的建议是我们改进的动力',
            color: const Color(0xFF66BB6A),
          ),
          const Divider(height: 24),
          _buildOtherServiceItem(
            icon: Icons.help_outline,
            title: '帮助中心',
            subtitle: '常见问题解答',
            color: const Color(0xFFFFA726),
          ),
          const Divider(height: 24),
          _buildOtherServiceItem(
            icon: Icons.settings,
            title: '设置',
            subtitle: '个性化设置',
            color: const Color(0xFF8D6E63),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherServiceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('其他服务', '$title 功能开发中');
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
} 
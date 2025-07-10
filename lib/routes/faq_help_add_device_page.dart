import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../widgets/faq_related_questions.dart';

class FaqHelpAddDevicePage extends StatefulWidget {
  const FaqHelpAddDevicePage({Key? key}) : super(key: key);
  @override
  State<FaqHelpAddDevicePage> createState() => _FaqHelpAddDevicePageState();
}

class _FaqHelpAddDevicePageState extends State<FaqHelpAddDevicePage> {
  bool? isResolved;

  // FAQ问题列表
  static const List<Map<String, String>> allFaqs = [
    {'title': '无法添加设备，怎么办？', 'route': '/faq-help-add-device'},
    {'title': '不小心删除了设备应该怎么添加回来？', 'route': '/faq-help-deleted-device'},
    {'title': 'wifi无法连接成功是什么原因？', 'route': '/faq-help-wifi'},
    {'title': '如何更新设备固件？', 'route': '/faq-help-firmware'},
    {'title': '设备定位不准确怎么解决？', 'route': '/faq-help-location'},
  ];

  List<Map<String, String>> getRelatedFaqs() {
    final currentRoute = '/faq-help-add-device';
    final others = allFaqs.where((f) => f['route'] != currentRoute).toList();
    others.shuffle(Random());
    return others.take(2).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A101E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部返回和标题
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '常见问题',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 内容卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 29, 20.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '无法添加设备，怎么办？',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '当您在使用我们的宠物定位器时，如果遇到无法添加设备的问题，请按照以下步骤进行排查和解决。',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 解决方案卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.only(right: 20, bottom: 28.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 24),
                          const Text(
                            '解决方案',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      _FaqStepItem(
                        index: 1,
                        title: '检查设备电量',
                        content: '确保设备电量充足。如果电量过低，请先为设备充电至少10分钟后再尝试添加。',
                        tip: '提示：设备指示灯呈红色闪烁表示电量不足，请立即充电。',
                      ),
                      _FaqStepItem(
                        index: 2,
                        title: '确认设备处于配对模式',
                        content: '长按设备电源键5秒，直到指示灯呈蓝色快速闪烁，表示设备已进入配对模式。',
                        tip: '如果设备无法进入配对模式，请尝试重置设备：同时按住电源键和复位键10秒。',
                      ),
                      _FaqStepItem(
                        index: 3,
                        title: '检查网络连接',
                        content: '确保您的手机已连接到2.4GHz的WiFi网络。本设备不支持5GHz网络连接。',
                      ),
                      _FaqStepItem(
                        index: 4,
                        title: '重启应用并重新尝试',
                        content: '完全关闭应用后重新打开，然后点击"添加设备"按钮，按照屏幕提示操作。',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 问题是否已解决
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '问题是否已解决？',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isResolved == true ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB)),
                                backgroundColor: isResolved == true ? const Color(0xFF3B82F6).withOpacity(0.08) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isResolved = true;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('imgs/faq_yes.svg', width: 16, height: 16, color: isResolved == true ? const Color(0xFF3B82F6) : const Color(0xFF3B82F6)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '是',
                                    style: TextStyle(color: isResolved == true ? const Color(0xFF3B82F6) : const Color(0xFF3B82F6)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isResolved == false ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB)),
                                backgroundColor: isResolved == false ? const Color(0xFF3B82F6).withOpacity(0.08) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isResolved = false;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('imgs/faq_no.svg', width: 16, height: 16, color: isResolved == false ? const Color(0xFF3B82F6) : const Color(0xFF6B7280)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '否',
                                    style: TextStyle(color: isResolved == false ? const Color(0xFF3B82F6) : const Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 相关问题
              const FaqRelatedQuestions(currentRoute: '/faq-help-add-device'),
              const SizedBox(height: 16),
              // 联系人工客服
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _showCustomerServiceDialog,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            '联系人工客服',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('人工客服电话', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          content: const Text('18866668888', style: TextStyle(fontSize: 18, color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                const phone = '18866668888';
                final uri = Uri(scheme: 'tel', path: phone);
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('当前设备不支持拨号功能或未授权')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('拨号失败: \\${e.toString()}')),
                  );
                }
              },
              child: const Text('拨打电话', style: TextStyle(color: Color(0xFF3B82F6))),
            ),
          ],
        );
      },
    );
  }
}

class _FaqStepItem extends StatelessWidget {
  final int index;
  final String title;
  final String content;
  final String? tip;
  const _FaqStepItem({required this.index, required this.title, required this.content, this.tip});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              content,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          if (tip != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  tip!,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FaqRelatedItem extends StatelessWidget {
  final String title;
  const _FaqRelatedItem(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
} 
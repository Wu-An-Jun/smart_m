import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqRelatedQuestions extends StatelessWidget {
  final String currentRoute;

  // 全部FAQ问题及路由
  static const List<Map<String, String>> allFaqs = [
    {'title': '无法添加设备，怎么办？', 'route': '/faq-help-add-device'},
    {'title': '不小心删除了设备应该怎么添加回来？', 'route': '/faq-help-deleted-device'},
    {'title': 'wifi无法连接成功是什么原因？', 'route': '/faq-help-wifi'},
    {'title': '如何更新设备固件？', 'route': '/faq-help-firmware'},
    {'title': '设备定位不准确怎么解决？', 'route': '/faq-help-location'},
  ];

  const FaqRelatedQuestions({Key? key, required this.currentRoute}) : super(key: key);

  List<Map<String, String>> getRelatedFaqs() {
    final others = allFaqs.where((f) => f['route'] != currentRoute).toList();
    others.shuffle(Random());
    return others.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final relatedFaqs = getRelatedFaqs();
    return Padding(
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
              '相关问题',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            ...relatedFaqs.map((faq) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => Get.toNamed(faq['route']!),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Text(
                    faq['title']!,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
} 
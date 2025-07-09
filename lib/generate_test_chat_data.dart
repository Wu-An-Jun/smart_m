import 'package:flutter/material.dart';
import 'common/chat_history_service.dart';

/// 生成测试聊天历史数据的工具函数
/// 可以在调试时调用这个函数来快速生成测试数据
class ChatTestDataGenerator {
  static final ChatHistoryService _chatHistoryService = ChatHistoryService.instance;

  /// 生成测试聊天历史数据
  static Future<void> generateTestData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 清空现有数据
    await _chatHistoryService.clearAllHistory();

    // 今天的会话 (2条)
    await _createTestSession(
      id: 'today_1',
      title: 'AI智能家居App命名建议',
      lastMessage: '我需要为智能家居App想个好名字',
      lastMessageTime: today.add(const Duration(hours: 14, minutes: 30)),
    );

    await _createTestSession(
      id: 'today_2', 
      title: 'AI智能管家UI优化设计',
      lastMessage: '请帮我优化智能管家的用户界面',
      lastMessageTime: today.add(const Duration(hours: 10, minutes: 15)),
    );

    // 昨天的会话 (1条)
    await _createTestSession(
      id: 'yesterday_1',
      title: '智能插座省电应用场景和实现方案',
      lastMessage: '如何通过智能插座实现省电功能？',
      lastMessageTime: today.subtract(const Duration(days: 1, hours: -16)),
    );

    // 7天内的会话 (2条)
    await _createTestSession(
      id: 'week_1',
      title: '高级硬件工程师招聘JD撰写',
      lastMessage: '帮我写一个硬件工程师的招聘需求',
      lastMessageTime: today.subtract(const Duration(days: 3, hours: -10)),
    );

    await _createTestSession(
      id: 'week_2',
      title: '大模型训练过程中的query、key',
      lastMessage: '解释一下Transformer中的注意力机制',
      lastMessageTime: today.subtract(const Duration(days: 5, hours: -14)),
    );

    // 30天内的会话 (4条)
    await _createTestSession(
      id: 'month_1',
      title: 'DeepSeek-R1提示词差异原因分析',
      lastMessage: '分析不同提示词对模型输出的影响',
      lastMessageTime: today.subtract(const Duration(days: 15, hours: -12)),
    );

    await _createTestSession(
      id: 'month_2',
      title: '手机OTP的定义与安全性解析',
      lastMessage: '什么是OTP验证码？如何保证安全？',
      lastMessageTime: today.subtract(const Duration(days: 20, hours: -8)),
    );

    await _createTestSession(
      id: 'month_3',
      title: '射频工程师招聘JD拟定',
      lastMessage: '帮我起草射频工程师的职位描述',
      lastMessageTime: today.subtract(const Duration(days: 25, hours: -16)),
    );

    await _createTestSession(
      id: 'month_4',
      title: '射频工程师招聘职位描述',
      lastMessage: '进一步完善射频工程师的要求',
      lastMessageTime: today.subtract(const Duration(days: 28, hours: -11)),
    );

    // 历史月份的会话 (如果是1月份以后的月份，添加之前月份的数据)
    if (now.month > 1) {
      await _createTestSession(
        id: 'last_month_1',
        title: 'PCB设计入门与进阶指南',
        lastMessage: '学习PCB设计需要掌握哪些知识？',
        lastMessageTime: DateTime(now.year, now.month - 1, 15, 14, 30),
      );

      await _createTestSession(
        id: 'last_month_2',
        title: 'Flutter状态管理最佳实践',
        lastMessage: '如何选择合适的状态管理方案？',
        lastMessageTime: DateTime(now.year, now.month - 1, 8, 16, 20),
      );
    }

    // 如果当前年份大于2024，添加去年的数据
    if (now.year > 2024) {
      await _createTestSession(
        id: 'last_year_1',
        title: '2024年技术总结与展望',
        lastMessage: '回顾2024年的技术发展和未来趋势',
        lastMessageTime: DateTime(now.year - 1, 12, 25, 10, 30),
      );

      await _createTestSession(
        id: 'last_year_2',
        title: 'AI发展历程回顾',
        lastMessage: '总结AI技术的发展历程',
        lastMessageTime: DateTime(now.year - 1, 11, 18, 15, 45),
      );
    }

    print('✅ 测试聊天历史数据生成完成！');
    print('生成的数据包括：');
    print('- 今天：2条会话');
    print('- 昨天：1条会话');
    print('- 7天内：2条会话');  
    print('- 30天内：4条会话');
    if (now.month > 1) {
      print('- ${now.month - 1}月：2条会话');
    }
    if (now.year > 2024) {
      print('- ${now.year - 1}年：2条会话');
    }
  }

  /// 创建测试会话的辅助方法
  static Future<void> _createTestSession({
    required String id,
    required String title,
    required String lastMessage,
    required DateTime lastMessageTime,
  }) async {
    final session = ChatSessionData(
      id: id,
      title: title,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      createdTime: lastMessageTime,
      messageCount: 3 + (id.hashCode % 10), // 随机消息数量 3-12
    );

    await _chatHistoryService.saveChatSession(session);
  }
}

/// Flutter Widget用于在调试时生成测试数据
class ChatTestDataPage extends StatelessWidget {
  const ChatTestDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天测试数据生成'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.data_usage,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                '生成测试聊天数据',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '点击下方按钮生成测试的聊天历史数据\n用于验证时间分组功能',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ChatTestDataGenerator.generateTestData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('测试数据生成成功！'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('生成失败：$e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('生成测试数据'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ChatHistoryService.instance.clearAllHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('聊天历史已清空'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('清空失败：$e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('清空历史数据'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
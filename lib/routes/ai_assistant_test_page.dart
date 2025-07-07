import 'package:flutter/material.dart';

class AiAssistantTestPage extends StatefulWidget {
  const AiAssistantTestPage({super.key});

  @override
  State<AiAssistantTestPage> createState() => _AiAssistantTestPageState();
}

class _AiAssistantTestPageState extends State<AiAssistantTestPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> functionItems = [
    {
      'title': '我的设备',
      'icon': Icons.phone_android,
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
      ),
    },
    {
      'title': '智能生活',
      'icon': Icons.settings,
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF22D3EE), Color(0xFF0284C7)],
      ),
    },
    {
      'title': '服务',
      'icon': Icons.headset_mic,
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF60A5FA), Color(0xFF4338CA)],
      ),
    },
  ];

  final List<String> questions = [
    '怎么省电？有哪些小技巧？',
    '工作日每天9-18点天闭摄像头。',
    '打开客厅的摄像头。',
  ];

  final List<Map<String, dynamic>> navItems = [
    {'title': '智能管家', 'icon': Icons.home, 'active': true},
    {'title': '设备首页', 'icon': Icons.tablet_android, 'active': false},
    {'title': '智能生活', 'icon': Icons.auto_awesome, 'active': false},
    {'title': '我的', 'icon': Icons.person, 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF20F172A), // rgba(15, 23, 42, 0.95)
              Color(0xD90F172A), // rgba(15, 23, 42, 0.85)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 状态栏
              _buildStatusBar(),

              // 主内容区
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // 顶部菜单
                      _buildTopMenu(),

                      const SizedBox(height: 16),

                      // 欢迎语
                      _buildWelcomeMessage(),

                      const SizedBox(height: 24),

                      // 功能入口
                      _buildFunctionEntries(),

                      const SizedBox(height: 24),

                      // 猜你想问
                      _buildQuickQuestions(),

                      const SizedBox(height: 100), // 为底部输入框留空间
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 底部输入框
          _buildInputArea(),

          // 底部导航
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE60F172A), // bg-slate-900/90
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF0EA5E9).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '12:00',
            style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14),
          ),
          Row(
            children: const [
              Icon(
                Icons.signal_cellular_4_bar,
                color: Color(0xFF38BDF8),
                size: 16,
              ),
              SizedBox(width: 8),
              Icon(Icons.wifi, color: Color(0xFF38BDF8), size: 16),
              SizedBox(width: 8),
              Icon(Icons.battery_full, color: Color(0xFF38BDF8), size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMenuButton(Icons.menu),
        _buildMenuButton(Icons.add, isCircular: true),
      ],
    );
  }

  Widget _buildMenuButton(IconData icon, {bool isCircular = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withOpacity(0.2),
        borderRadius: BorderRadius.circular(isCircular ? 20 : 8),
        border: Border.all(
          color: const Color(0xFF38BDF8).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF38BDF8), size: 20),
    );
  }

  Widget _buildWelcomeMessage() {
    return RichText(
      text: const TextSpan(
        text: 'Hi, ',
        style: TextStyle(
          color: Color(0xFF38BDF8),
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        children: [
          TextSpan(text: '主人', style: TextStyle(color: Colors.white)),
          TextSpan(text: ', 请问有什么可以帮您的?'),
        ],
      ),
    );
  }

  Widget _buildFunctionEntries() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '您可以问我',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                functionItems.map((item) {
                  return Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: item['gradient'],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          item['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'],
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '猜你想问',
          style: TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...questions.map((question) => _buildQuestionCard(question)).toList(),
      ],
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFB923C).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Color(0xFFFB923C),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.chevron_right,
              color: Color(0xFF38BDF8),
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE60F172A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF0EA5E9).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic, color: Color(0xFF38BDF8)),
            iconSize: 20,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xCC1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0EA5E9).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '请输入消息...',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.sentiment_satisfied_alt,
              color: Color(0xFF38BDF8),
            ),
            iconSize: 20,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle, color: Color(0xFF38BDF8)),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xE60F172A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF0EA5E9).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children:
            navItems.map((nav) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      nav['icon'],
                      color:
                          nav['active']
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF6B7280),
                      size: 18,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nav['title'],
                      style: TextStyle(
                        color:
                            nav['active']
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF6B7280),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

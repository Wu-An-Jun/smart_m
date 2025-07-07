import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../common/dify_ai_service.dart';
import '../common/page_navigator.dart';
import '../widgets/geofence_map_card.dart';
import 'app_routes.dart';
import 'geofence_demo_page.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AINavigationResponse? navigationInfo;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.navigationInfo,
  }) : timestamp = timestamp ?? DateTime.now();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  final DifyAiService _aiService = DifyAiService();
  bool _isTyping = false;
  bool _autoScrollEnabled = true;

  // 设备展示状态
  bool _showDeviceSection = false;

  // 服务展开状态
  final Map<String, bool> _serviceExpandedStates = {
    '我的设备': false,
    '智能生活': false,
    '服务': false,
  };

  // 模拟设备数据
  List<Map<String, dynamic>> _mockDevices = [];

  @override
  void initState() {
    super.initState();

    // 设置系统UI样式为深色主题
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF1E293B),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatScrollController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F172A), // 深色背景
      resizeToAvoidBottomInset: true,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'hi，',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: '主人',
                            style: TextStyle(
                              color: Color(0xFF3B82F6), // 蓝色
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: '，请问有什么可以帮您的？',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // _buildYouCanAskMeTitle 是一个文本标题组件，显示"您可以问我"
                  _buildYouCanAskMeTitle(),
                  const SizedBox(height: 8),
                  // _buildServiceCards 构建三个服务卡片：我的设备、智能生活、服务
                  _buildServiceCards(),
                  // _buildExpandedServicesSection 根据选择的服务展示扩展内容区域
                  _buildExpandedServicesSection(),
                  // const SizedBox(height: 4),
                  if (_showDeviceSection) ...[
                    // _buildGeofenceStatusCard 展示地理围栏状态的卡片组件
                    _buildGeofenceStatusCard(),
                    const SizedBox(height: 32),
                  ],
                  // _buildGuessYouWantToAsk 猜你想问的问题列表
                  _buildGuessYouWantToAsk(),
                  const SizedBox(height: 16),
                  // _buildChatSection 构建AI聊天交互区域
                  _buildChatSection(),
                  const SizedBox(height: 100), // 为底部导航栏留出空间
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingInputBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// 构建顶部应用栏
  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const Spacer(),
            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF0F172A), size: 20),
                onPressed: () {
                  Get.toNamed('/device-management', arguments: {'showAddDevice': true});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建"您可以问我"标题
  Widget _buildYouCanAskMeTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '您可以问我',
        style: TextStyle(
          color: Color(0xFF64748B), // 灰色
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建服务卡片
  Widget _buildServiceCards() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D36), // 背景色 26, 29, 54
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                icon: SvgPicture.asset(
                  'imgs/my_devices_icon.svg',
                  width: 20,
                  height: 20,
                ),
                label: '我的设备',
                color: const Color(0xFF3B82F6), // 蓝色
                onTap: () => _handleServiceCardTap('我的设备'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceCard(
                icon: SvgPicture.asset(
                  'imgs/smart_life_icon.svg',
                  width: 20,
                  height: 20,
                ),
                label: '智能生活',
                color: const Color(0xFF10B981), // 绿色
                onTap: () => _handleServiceCardTap('智能生活'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceCard(
                icon: SvgPicture.asset(
                  'imgs/service_icon.svg',
                  width: 20,
                  height: 20,
                ),
                label: '服务',
                color: const Color(0xFF8B5CF6), // 紫色
                onTap: () => _handleServiceCardTap('服务'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个服务卡片
  Widget _buildServiceCard({
    required Widget icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isExpanded = _serviceExpandedStates[label] ?? false;

    // 设计稿风格的图标背景色
    Color getIconBgColor(String label) {
      switch (label) {
        case '我的设备':
          return const Color(0x334169E1); // rgba(65,105,225,0.2)
        case '智能生活':
          return const Color(0x3300C8B0); // rgba(0,200,176,0.2)
        case '服务':
          return const Color(0x337F3DFF); // rgba(127,61,255,0.2)
        default:
          return color.withOpacity(0.2);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(26, 29, 54, 1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color.fromRGBO(43, 52, 70, 1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: getIconBgColor(label),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 处理服务卡片点击
  void _handleServiceCardTap(String label) {
    setState(() {
      final isCurrentlyExpanded = _serviceExpandedStates[label] ?? false;

      // 关闭所有展开状态
      _serviceExpandedStates.updateAll((key, value) => false);

      // 如果当前项目没有展开，则展开它
      if (!isCurrentlyExpanded) {
        _serviceExpandedStates[label] = true;
      }
    });

    // 如果是我的设备，同时触发设备区域显示
    if (label == '我的设备') {
      _toggleDeviceSection();
    }
  }

  /// 构建展开服务区域
  Widget _buildExpandedServicesSection() {
    String? expandedService;
    for (String service in _serviceExpandedStates.keys) {
      if (_serviceExpandedStates[service] == true) {
        expandedService = service;
        break;
      }
    }

    if (expandedService == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: _buildExpandedServiceCard(expandedService),
    );
  }

  /// 构建展开的服务卡片
  Widget _buildExpandedServiceCard(String serviceLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: _buildServiceOptions(serviceLabel),
    );
  }

  /// 构建服务选项内容
  Widget _buildServiceOptions(String serviceLabel) {
    switch (serviceLabel) {
      case '我的设备':
        return Row(
          children: [
            Expanded(
              child: _buildServiceOption(
                icon: Icons.settings_applications,
                label: '设备管理',
                onTap: () => Get.toNamed('/device-management'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceOption(
                icon: Icons.add_circle_outline,
                label: '添加设备',
                onTap: () => Get.toNamed('/device-management', arguments: {'showAddDevice': true}),
              ),
            ),
          ],
        );
      case '智能生活':
        return Row(
          children: [
            Expanded(
              child: _buildServiceOption(
                icon: Icons.auto_awesome,
                label: '自动化服务',
                onTap: () => Get.toNamed('/smart-home-automation'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceOption(
                icon: Icons.settings,
                label: '功能设置',
                onTap: () => Get.toNamed('/smart-life'),
              ),
            ),
          ],
        );
      case '服务':
        return Row(
          children: [
            Expanded(
              child: _buildServiceOption(
                icon: Icons.support_agent,
                label: '客服支持',
                onTap: () => Get.toNamed('/service'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceOption(
                icon: Icons.help_outline,
                label: '帮助中心',
                onTap: () => Get.toNamed('/service'),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建单个服务选项
  Widget _buildServiceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建"猜你想问"区域
  Widget _buildGuessYouWantToAsk() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '猜你想问',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildQuestionItem('怎么省电？有哪些小技巧？'),
        const SizedBox(height: 12),
        _buildQuestionItem('工作日每天9-18点开启宠物定位器。'),
        const SizedBox(height: 12),
        _buildQuestionItem('我要查看定位器所在的位置。'),
      ],
    );
  }

  /// 构建问题项
  Widget _buildQuestionItem(String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          _sendMessage(question);
          // 滚动到聊天区域
          Future.delayed(const Duration(milliseconds: 500), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(26, 29, 54, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFEF4444), // 红色火焰图标
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建地理围栏状态卡片
  Widget _buildGeofenceStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GeofenceMapCard(
        cardConfig: GeofenceCardConfig(
          title: '地理围栏状态',
          subtitle: '实时位置监控',
          icon: Icons.location_on,
          backgroundColor: const Color(0xFF1E293B),
          height: 350,
          showControls: true,
          compactMode: false,
        ),
        onTap: () {
          Get.toNamed(
            '/device-management',
            arguments: {'showCatLocator': true},
          );
        },
      ),
    );
  }

  /// 构建聊天区域
  Widget _buildChatSection() {
    return Column(
      children: [
        // 如果有消息则显示聊天标题和清空按钮
        if (_messages.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI助手',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _messages.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('清空'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 聊天消息区域
        ...(_messages
            .map(
              (message) => Container(
                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: _buildWeChatMessage(message),
              ),
            )
            .toList()),

        // 显示正在输入状态
        if (_isTyping)
          Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: _buildWeChatTypingIndicator(),
          ),

        // 快速回复按钮区域
        if (_messages.isNotEmpty && _messages.last.isUser == false) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickReplyButton('继续'),
                _buildQuickReplyButton('详细说明'),
                _buildQuickReplyButton('举个例子'),
                _buildQuickReplyButton('相关问题'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// 构建微信样式的消息气泡
  Widget _buildWeChatMessage(ChatMessage message) {
    final bool isUser = message.isUser;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isUser
                      ? const Color(0xFF3B82F6) // 用户消息蓝色
                      : const Color(0xFF1E293B), // AI消息深色
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft:
                    isUser
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
                bottomRight:
                    isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
              ),
            ),
            child:
                isUser
                    ? Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                    : _buildAIMessageContent(message),
          ),
        ),
      ],
    );
  }

  /// 构建AI消息内容
  Widget _buildAIMessageContent(ChatMessage message) {
    if (message.navigationInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.text.isNotEmpty) ...[
            MarkdownBody(
              data: message.text,
              styleSheet: _getMarkdownStyleSheet(),
            ),
            const SizedBox(height: 12),
          ],
          PageNavigator.createNavigationButton(
            message.navigationInfo!.pageCode,
            buttonText: '打开${message.navigationInfo!.pageName}',
          ),
        ],
      );
    }

    return MarkdownBody(
      data: message.text,
      styleSheet: _getMarkdownStyleSheet(),
    );
  }

  /// 获取Markdown样式表
  MarkdownStyleSheet _getMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
      h1: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h2: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h3: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
      code: const TextStyle(
        fontFamily: 'Courier',
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
        color: Colors.white,
        fontSize: 14,
      ),
      codeblockDecoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquote: const TextStyle(
        color: Colors.white70,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.05),
        border: Border(left: BorderSide(color: Colors.white30, width: 4)),
      ),
      blockquotePadding: const EdgeInsets.all(8),
      listBullet: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 构建微信样式的打字指示器
  Widget _buildWeChatTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'AI正在思考...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建底部导航项
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建浮动输入栏
  Widget _buildFloatingInputBar() {
    return Container(
      // 高度和内边距严格参考设计稿
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 麦克风按钮
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: GestureDetector(
              onTap: () {
                Get.snackbar('提示', '语音功能开发中');
              },
              child: Center(
                child: SvgPicture.asset(
                  'imgs/input_mic_icon.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 输入框区域
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x12FFFFFF), // rgba(255,255,255,0.07)
                borderRadius: BorderRadius.circular(9999),
              ),
              padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  hintText: '请输入消息...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    height: 1.43,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.43,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 发送按钮
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  _sendMessage(_messageController.text.trim());
                }
              },
              child: Center(
                child: SvgPicture.asset(
                  'imgs/input_send_icon.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建侧边栏导航
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                const Text(
                  '主人',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home, '首页', () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(Icons.devices, '我的设备', () {
                  Navigator.pop(context);
                  _toggleDeviceSection();
                }),
                _buildDrawerItem(Icons.home_filled, '智能生活', () {
                  Navigator.pop(context);
                  Get.toNamed('/smart-life');
                }),
                _buildDrawerItem(Icons.room_service, '服务', () {
                  Navigator.pop(context);
                  Get.toNamed('/service');
                }),
                _buildDrawerItem(Icons.map, '地图', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.map);
                }),
                _buildDrawerItem(Icons.location_on, '地理围栏演示', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeofenceDemoPage(),
                    ),
                  );
                }),
                const Divider(color: Color(0xFF334155)),
                _buildDrawerItem(Icons.science, '智能管家测试', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.aiAssistantTest);
                }),
                _buildDrawerItem(Icons.devices, '设备管理演示', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.deviceManagementDemo);
                }),
                _buildDrawerItem(Icons.settings, '设置', () {
                  Navigator.pop(context);
                  Get.snackbar('提示', '设置功能开发中');
                }),
                _buildDrawerItem(Icons.help, '帮助', () {
                  Navigator.pop(context);
                  Get.snackbar('提示', '帮助功能开发中');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建抽屉菜单项
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  /// 构建快速回复按钮
  Widget _buildQuickReplyButton(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF334155)),
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1E293B),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ),
    );
  }

  /// 切换设备区域显示状态
  void _toggleDeviceSection() {
    setState(() {
      _showDeviceSection = !_showDeviceSection;
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _messageController.clear();
      _isTyping = true;
      _autoScrollEnabled = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomSmooth();
    });

    _simulateAIResponse(text.trim());
  }

  void _simulateAIResponse(String userMessage) {
    final aiMessageIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessage(text: '', isUser: false));
    });

    _aiService
        .sendMessageStream(userMessage)
        .listen(
          (fullText) {
            if (mounted) {
              setState(() {
                _isTyping = false;

                AINavigationResponse? navigationInfo = _parseNavigationResponse(
                  fullText,
                );

                if (aiMessageIndex < _messages.length) {
                  _messages[aiMessageIndex] = ChatMessage(
                    text:
                        navigationInfo != null
                            ? _extractTextFromResponse(fullText, navigationInfo)
                            : fullText,
                    isUser: false,
                    navigationInfo: navigationInfo,
                  );
                }
              });

              if (_autoScrollEnabled) {
                _scrollToBottomSmooth();
              }
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _isTyping = false;
                if (aiMessageIndex < _messages.length) {
                  _messages[aiMessageIndex] = ChatMessage(
                    text: '抱歉，AI服务暂时不可用：${error.toString()}',
                    isUser: false,
                  );
                }
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _isTyping = false;
              });

              if (_autoScrollEnabled) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            }
          },
        );
  }

  void _scrollToBottomSmooth() {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  AINavigationResponse? _parseNavigationResponse(String response) {
    try {
      final jsonRegex = RegExp(r'\{[^{}]*"action"\s*:\s*"navigate"[^{}]*\}');
      final match = jsonRegex.firstMatch(response);

      if (match != null) {
        final jsonString = match.group(0)!;
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        if (jsonData['action'] == 'navigate' &&
            jsonData['page_code'] != null &&
            jsonData['page_name'] != null) {
          return AINavigationResponse.fromJson(jsonData);
        }
      }
    } catch (e) {
      print('解析导航响应失败: $e');
    }
    return null;
  }

  String _extractTextFromResponse(
    String response,
    AINavigationResponse navigationInfo,
  ) {
    try {
      final jsonRegex = RegExp(r'\{[^{}]*"action"\s*:\s*"navigate"[^{}]*\}');
      String cleanText = response.replaceAll(jsonRegex, '').trim();

      if (cleanText.isEmpty) {
        return '我来帮您打开${navigationInfo.pageName}页面。${navigationInfo.reason}';
      }

      return cleanText;
    } catch (e) {
      return '我来帮您打开${navigationInfo.pageName}页面。';
    }
  }
}

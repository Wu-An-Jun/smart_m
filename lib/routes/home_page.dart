import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:vibration/vibration.dart';

import '../common/Global.dart';
import '../common/chat_history_service.dart';
import '../common/dify_ai_service.dart';
import '../common/page_navigator.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../widgets/geofence_map_card.dart';
import 'app_routes.dart';
import 'geofence_demo_page.dart';
import '../states/notification_state.dart';
import '../common/voice_input_service.dart';
import '../test_voice_input_demo.dart';

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
  final String? sessionId;
  const HomePage({Key? key, this.sessionId}) : super(key: key);

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
  final ChatHistoryService _chatHistoryService = ChatHistoryService.instance;
  String? _currentSessionId;
  bool _isTyping = false;
  bool _autoScrollEnabled = true; // 是否自动滚动到底部
  StreamSubscription<String>? _aiStreamSubscription; // AI流式输出订阅
  bool _isAIStreaming = false; // 是否AI正在流式输出

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

  final VoiceInputService _voiceInputService = VoiceInputService();
  bool _isRecording = false;
  String? _audioFilePath;

  final DeviceController _deviceController = Get.put(DeviceController());
  int _currentDevicePage = 0;
  final PageController _devicePageController = PageController();
  bool _hasAutoNavigated = false; // 标记本轮会话是否已自动跳转

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

    // 检查是否有 sessionId 参数，有则加载历史消息
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? sessionId = widget.sessionId;
      final args = Get.arguments;
      if (sessionId == null && args != null && args['sessionId'] != null) {
        sessionId = args['sessionId'] as String;
      }
      if (sessionId != null) {
        _currentSessionId = sessionId;
        final history = await _chatHistoryService.getChatMessages(
          _currentSessionId!,
        );
        setState(() {
          _messages.clear();
          _messages.addAll(
            history.map(
              (m) => ChatMessage(
                text: m.text,
                isUser: m.isUser,
                timestamp: m.timestamp,
              ),
            ),
          );
        });
        // 自动修正会话标题
        final sessions = await _chatHistoryService.getChatSessions();
        final session = sessions.firstWhereOrNull(
          (s) => s.id == _currentSessionId,
        );
        if (session != null && session.title == '新建对话' && history.isNotEmpty) {
          final firstUserMsg = history.firstWhereOrNull((m) => m.isUser);
          if (firstUserMsg != null && firstUserMsg.text.trim().isNotEmpty) {
            final shortTitle =
                firstUserMsg.text.length > 20
                    ? '${firstUserMsg.text.substring(0, 20)}...'
                    : firstUserMsg.text;
            await _chatHistoryService.updateSessionTitle(
              _currentSessionId!,
              shortTitle,
            );
          }
        }
      }
    });

    // 监听聊天滚动，用户上滑时关闭自动滚动
    _scrollController.addListener(() {
      // 如果用户滚动到不是底部，关闭自动滚动
      if (_scrollController.hasClients &&
          _scrollController.position.pixels <
              _scrollController.position.maxScrollExtent - 20) {
        if (_autoScrollEnabled) {
          setState(() {
            _autoScrollEnabled = false;
          });
        }
      }
      // 如果用户滑动回到底部，重新开启自动滚动
      if (_scrollController.hasClients &&
          (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 2)) {
        if (!_autoScrollEnabled) {
          setState(() {
            _autoScrollEnabled = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatScrollController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _devicePageController.dispose();
    // 释放语音输入服务资源
    _voiceInputService.dispose();
    _aiStreamSubscription?.cancel(); // 释放AI流式订阅
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
            // 聊天历史按钮
            Container(
              width: 35,
              height: 35,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1A73E8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.history, color: Colors.white, size: 20),
                onPressed: () {
                  Get.toNamed(AppRoutes.aiChatHistory);
                },
              ),
            ),
            // 添加设备按钮
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
                  // 先自动向AI发送“我要绑定设备”
                  _sendMessage('我要绑定设备');
                  // 跳转到设备管理页并传递参数，由设备管理页切换到添加设备界面
                  Get.toNamed(
                    '/device-management',
                    arguments: {'showAddDevice': true},
                  );
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
      margin: const EdgeInsets.only(left: 16, right: 16, top: 0),
      child: _buildExpandedServiceCard(expandedService),
    );
  }

  /// 构建展开的服务卡片
  Widget _buildExpandedServiceCard(String serviceLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
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
                onTap: () {
                  // 先自动向AI发送“我要绑定设备”
                  _sendMessage('我要绑定设备');
                  // 跳转到设备管理页并传递参数，由设备管理页切换到添加设备界面
                  Get.toNamed(
                    '/device-management',
                    arguments: {'showAddDevice': true},
                  );
                },
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

  /// 构建地理围栏状态卡片（多设备分页）
  Widget _buildGeofenceStatusCard() {
    final List<DeviceModel> petTrackers = _deviceController.getDevicesByType(
      DeviceType.petTracker,
    );
    if (petTrackers.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GeofenceMapCard(
          cardConfig: GeofenceCardConfig(
            title: '暂无定位器',
            subtitle: '请先绑定定位器设备',
            icon: Icons.location_on,
            backgroundColor: const Color(0xFF1E293B),
            height: 350,
            showControls: false,
            compactMode: false,
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 370,
            child: PageView.builder(
              controller: _devicePageController,
              itemCount: petTrackers.length,
              onPageChanged: (index) {
                setState(() {
                  _currentDevicePage = index;
                });
              },
              itemBuilder: (context, index) {
                final device = petTrackers[index];
                return GeofenceMapCard(
                  cardConfig: GeofenceCardConfig(
                    title: device.name,
                    subtitle: '实时位置监控',
                    icon: Icons.location_on,
                    backgroundColor: const Color(0xFF1E293B),
                    height: 350,
                    showControls: true,
                    compactMode: false,
                  ),
                  onHeaderTap: () {
                    _sendMessage('我要进入定位器详细界面');
                    DeviceTapHandler.handleDeviceTap(context, device);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildDevicePageIndicator(petTrackers.length, _currentDevicePage),
        ],
      ),
    );
  }

  /// 分页指示器（常规圆点）
  Widget _buildDevicePageIndicator(int count, int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index == current
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF64748B),
          ),
        );
      }),
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
                      _currentSessionId = null; // 重置会话ID，下次发送消息时会创建新会话
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
        // 显示正在输入状态和暂停按钮
        if (_isTyping || _isAIStreaming)
          Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Row(
              children: [
                _buildWeChatTypingIndicator(),
                if (_isAIStreaming)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ElevatedButton.icon(
                      onPressed: _pauseAIResponse,
                      icon: const Icon(Icons.pause, size: 16),
                      label: const Text('暂停AI对话'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64748B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
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
      // 如果未自动跳转过，自动执行导航
      if (!_hasAutoNavigated) {
        _hasAutoNavigated = true;
        // 延迟执行，确保UI渲染完成
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PageNavigator.navigateToPage(message.navigationInfo!.pageCode);
        });
      }
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
            buttonText: '打开 ${message.navigationInfo!.pageName}',
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
      // 提供背景色Global.currentTheme.backgroundColor
      //修复语法错误
      decoration: BoxDecoration(color: Global.currentTheme.backgroundColor),
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
              onLongPress: _startRecording,
              onLongPressUp: () => _stopRecordingAndRecognize(cancel: false),
              onLongPressCancel: () => _stopRecordingAndRecognize(cancel: true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRecording ? 48 : 40,
                height: _isRecording ? 48 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D35),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow:
                      _isRecording
                          ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                          : [],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'imgs/input_mic_icon.svg',
                    width: 20,
                    height: 20,
                    color: _isRecording ? Colors.blue : null,
                  ),
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
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
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
                _buildDrawerItem(Icons.chat_bubble_outline, 'AI聊天历史', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.aiChatHistory);
                }),
                // 新增生成测试通知数据按钮
                _buildDrawerItem(Icons.notifications_active, '生成测试通知数据', () {
                  Navigator.pop(context);
                  final notificationState = Get.isRegistered<NotificationState>()
                      ? Get.find<NotificationState>()
                      : Get.put(NotificationState());
                  notificationState.generateTestNotifications();
                  Get.snackbar('提示', '已生成测试通知数据');
                }),
                _buildDrawerItem(Icons.data_usage, '生成测试数据', () {
                  Navigator.pop(context);
                  Get.toNamed('/test-chat-data');
                }),
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
                // 新增：语音输入演示
                _buildDrawerItem(Icons.mic, '语音输入演示', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceInputDemoPage(),
                    ),
                  );
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

  /// 获取或创建当前聊天会话
  Future<String> _getCurrentSessionId() async {
    if (_currentSessionId == null) {
      final session = await _chatHistoryService.createNewSession();
      _currentSessionId = session.id;
    }
    return _currentSessionId!;
  }

  /// 保存聊天消息到历史记录
  Future<void> _saveChatMessage(
    String text,
    bool isUser, {
    String? navigationJson,
  }) async {
    try {
      final sessionId = await _getCurrentSessionId();
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      final message = ChatMessageData(
        id: messageId,
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
        navigationJson: navigationJson,
      );

      await _chatHistoryService.saveChatMessage(sessionId, message);

      // 如果是会话的第一条用户消息，使用它来更新会话标题
      if (isUser && _messages.length <= 2) {
        final shortTitle =
            text.length > 20 ? '${text.substring(0, 20)}...' : text;
        await _chatHistoryService.updateSessionTitle(sessionId, shortTitle);
      }
    } catch (e) {
      print('保存聊天消息失败: $e');
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    // 发送新消息时，取消上一次AI流式输出
    _pauseAIResponse();
    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _messageController.clear();
      _isTyping = true;
      _autoScrollEnabled = true;
      _hasAutoNavigated = false;
    });
    _saveChatMessage(text.trim(), true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomSmooth();
    });
    _simulateAIResponse(text.trim());
  }

  // 暂停AI流式输出
  void _pauseAIResponse() {
    _aiStreamSubscription?.cancel();
    _aiStreamSubscription = null;
    if (_isAIStreaming) {
      setState(() {
        _isAIStreaming = false;
        _isTyping = false;
      });
    }
  }

  void _simulateAIResponse(String userMessage) {
    final aiMessageIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessage(text: '', isUser: false));
      _isAIStreaming = true;
    });
    _aiStreamSubscription = _aiService
        .sendMessageStream(userMessage)
        .listen(
          (fullText) {
            if (mounted) {
              setState(() {
                _isTyping = false;
                _isAIStreaming = true;
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
                _isAIStreaming = false;
                if (aiMessageIndex < _messages.length) {
                  _messages[aiMessageIndex] = ChatMessage(
                    text: '抱歉，AI服务暂时不可用： ${error.toString()}',
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
                _isAIStreaming = false;
              });
              // 保存AI响应到历史记录
              if (aiMessageIndex < _messages.length) {
                final aiMessage = _messages[aiMessageIndex];
                String? navigationJson;
                if (aiMessage.navigationInfo != null) {
                  navigationJson = jsonEncode({
                    'action': 'navigate',
                    'page_code': aiMessage.navigationInfo!.pageCode,
                    'page_name': aiMessage.navigationInfo!.pageName,
                    'reason': aiMessage.navigationInfo!.reason,
                  });
                }
                _saveChatMessage(
                  aiMessage.text,
                  false,
                  navigationJson: navigationJson,
                );
              }
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

  // 语音输入功能 - 使用新的Dify API
  Future<void> _startRecording() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      Get.snackbar('权限提示', '请在系统设置中授予麦克风权限');
      return;
    }
    
    setState(() {
      _isRecording = true;
    });
    
    // 启动震动反馈
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
    
    _audioFilePath = await _voiceInputService.startRecording();
    if (_audioFilePath == null) {
      setState(() {
        _isRecording = false;
      });
      Get.snackbar('错误', '无法开始录音，请检查设备权限');
    }
  }

  Future<void> _stopRecordingAndRecognize({bool cancel = false}) async {
    if (!_isRecording) return;
    
    setState(() {
      _isRecording = false;
    });
    
    // 停止震动反馈
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 30);
    }
    
    final filePath = await _voiceInputService.stopRecording();
    if (cancel || filePath == null) {
      if (filePath == null) {
        Get.snackbar('错误', '录音失败，请重试');
      }
      return;
    }
    
    // 显示识别中的提示
    Get.snackbar(
      '语音识别', 
      '正在识别语音内容...',
      backgroundColor: Global.currentTheme.primaryColor.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      showProgressIndicator: true,
    );
    
    try {
      // 使用新的语音转文字API
      final text = await _voiceInputService.uploadAndTranscribe(filePath);
      
      if (text != null && text.trim().isNotEmpty) {
        // 直接发送给AI
        _sendMessage(text.trim());
        Get.snackbar(
          '识别成功', 
          '识别内容已自动发送：$text',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          '识别失败', 
          '未能识别到有效语音内容，请重试',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('语音识别错误: $e');
      Get.snackbar(
        '识别错误', 
        '语音识别服务异常，请稍后重试',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      // 清理临时文件
      _voiceInputService.cleanup();
    }
  }
}

// 新增：设备点击处理工具类
class DeviceTapHandler {
  static void handleDeviceTap(BuildContext context, DeviceModel device) {
    if (device.type == DeviceType.petTracker) {
      // 这里直接跳转到猫咪定位器界面，参数传递deviceId
      Navigator.of(context).pushNamed(
        '/device-management',
        arguments: {'showCatLocator': true, 'deviceId': device.id},
      );
    } else {
      Navigator.of(context).pushNamed('/device-detail', arguments: device);
    }
  }
}

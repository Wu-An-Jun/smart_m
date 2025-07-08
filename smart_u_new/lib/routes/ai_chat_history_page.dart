import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/chat_history_service.dart';

/// AI聊天历史页面
class AiChatHistoryPage extends StatefulWidget {
  const AiChatHistoryPage({super.key});

  @override
  State<AiChatHistoryPage> createState() => _AiChatHistoryPageState();
}

class _AiChatHistoryPageState extends State<AiChatHistoryPage> {
  final ChatHistoryService _chatHistoryService = ChatHistoryService.instance;
  List<ChatHistoryGroup> _chatGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  /// 加载聊天历史
  Future<void> _loadChatHistory() async {
    try {
      final groups = await _chatHistoryService.getChatHistoryGroupedByDate();
      if (mounted) {
        setState(() {
          _chatGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载聊天历史失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
        ),
        title: const Text(
          'AI助手',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // 新建对话按钮
            _buildNewChatButton(),
            
            const SizedBox(height: 24),
            
            // 历史会话标题
            _buildHistoryTitle(),
            
            const SizedBox(height: 16),
            
            // 聊天历史列表
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildChatHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建新建对话按钮
  Widget _buildNewChatButton() {
    return GestureDetector(
      onTap: () async {
        // 创建新的聊天会话
        try {
          await _chatHistoryService.createNewSession();
          Get.back(); // 返回主页开始新对话
          Get.snackbar('提示', '已创建新对话');
        } catch (e) {
          Get.snackbar('错误', '创建对话失败: $e');
        }
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF1A73E8),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              size: 20,
              color: Color(0xFF1A73E8),
            ),
            const SizedBox(width: 8),
            const Text(
              '新建对话',
              style: TextStyle(
                color: Color(0xFF1A73E8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建历史会话标题
  Widget _buildHistoryTitle() {
    return Row(
      children: [
        const Icon(
          Icons.history,
          size: 24,
          color: Color(0xFF1A73E8),
        ),
        const SizedBox(width: 8),
        const Text(
          '历史会话',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 构建聊天历史列表
  Widget _buildChatHistoryList() {
    if (_chatGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16),
            Text(
              '暂无聊天记录',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '开始您的第一次对话吧',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _chatGroups.length,
      itemBuilder: (context, index) {
        final group = _chatGroups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间分组标题
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                group.title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // 会话列表
            ...group.sessions.map((session) => _buildChatItem(session)),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// 构建单个聊天记录项
  Widget _buildChatItem(ChatSessionData session) {
    return GestureDetector(
      onTap: () {
        // 跳转到聊天页面并传递 sessionId
        Get.toNamed('/home', arguments: {'sessionId': session.id});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                session.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              session.formattedTime,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
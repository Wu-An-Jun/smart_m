import 'package:flutter/foundation.dart';
import '../common/dify_ai_service.dart';

/// 聊天消息模型
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isUser == other.isUser &&
          timestamp == other.timestamp;

  @override
  int get hashCode => text.hashCode ^ isUser.hashCode ^ timestamp.hashCode;
}

/// 聊天状态管理类
/// 负责管理AI聊天相关的跨组件共享状态
class ChatState extends ChangeNotifier {
  static final ChatState _instance = ChatState._internal();
  factory ChatState() => _instance;
  ChatState._internal();

  final DifyAiService _aiService = DifyAiService();

  // 聊天消息列表
  final List<ChatMessage> _messages = [];
  
  // 状态标识
  bool _isTyping = false;
  bool _isLoading = false;
  
  // 当前会话ID（可用于区分不同会话）
  String? _currentSessionId;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  String? get currentSessionId => _currentSessionId;
  bool get hasMessages => _messages.isNotEmpty;

  /// 开始新会话
  void startNewSession({String? sessionId}) {
    _currentSessionId = sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
    _messages.clear();
    _isTyping = false;
    _isLoading = false;
    notifyListeners();
  }

  /// 添加消息
  void addMessage(String text, bool isUser) {
    final message = ChatMessage(text: text, isUser: isUser);
    _messages.add(message);
    notifyListeners();
  }

  /// 更新最后一条AI消息
  void updateLastAIMessage(String text) {
    if (_messages.isNotEmpty && !_messages.last.isUser) {
      final lastMessage = _messages.last;
      _messages[_messages.length - 1] = ChatMessage(
        text: text,
        isUser: false,
        timestamp: lastMessage.timestamp,
      );
      notifyListeners();
    }
  }

  /// 设置打字状态
  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 发送消息给AI
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || _isTyping) return;

    // 添加用户消息
    addMessage(userMessage, true);

    // 设置AI正在回复状态
    setTyping(true);

    try {
      // 添加空的AI消息占位
      addMessage('', false);
      final aiMessageIndex = _messages.length - 1;

      // 监听流式响应（Dify返回完整文本）
      await for (String fullText in _aiService.sendMessageStream(userMessage)) {
        // 更新AI消息内容
        if (aiMessageIndex < _messages.length) {
          _messages[aiMessageIndex] = ChatMessage(
            text: fullText,
            isUser: false,
            timestamp: _messages[aiMessageIndex].timestamp,
          );
          notifyListeners();
        }
      }

      setTyping(false);
    } catch (e) {
      // 错误处理
      setTyping(false);
      
      // 移除空的AI消息
      if (_messages.isNotEmpty && _messages.last.text.isEmpty) {
        _messages.removeLast();
      }
      
      // 添加错误消息
      addMessage('抱歉，AI暂时无法回复，请稍后再试。', false);
      
      print('发送消息失败: $e');
    }
  }

  /// 重新发送最后一条消息
  Future<void> resendLastMessage() async {
    if (_messages.length >= 2 && _messages[_messages.length - 2].isUser) {
      final lastUserMessage = _messages[_messages.length - 2].text;
      
      // 移除最后一条AI回复
      _messages.removeLast();
      notifyListeners();
      
      // 重新发送
      await sendMessage(lastUserMessage);
    }
  }

  /// 清除消息历史
  void clearMessages() {
    _messages.clear();
    _isTyping = false;
    _isLoading = false;
    notifyListeners();
  }

  /// 删除指定消息
  void removeMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      notifyListeners();
    }
  }

  /// 获取消息数量统计
  Map<String, int> getMessageStats() {
    final userMessages = _messages.where((msg) => msg.isUser).length;
    final aiMessages = _messages.where((msg) => !msg.isUser).length;
    
    return {
      'total': _messages.length,
      'user': userMessages,
      'ai': aiMessages,
    };
  }

  /// 导出聊天记录
  List<Map<String, dynamic>> exportMessages() {
    return _messages.map((msg) => {
      'text': msg.text,
      'isUser': msg.isUser,
      'timestamp': msg.timestamp.toIso8601String(),
    }).toList();
  }

  /// 导入聊天记录
  void importMessages(List<Map<String, dynamic>> messageData) {
    _messages.clear();
    
    for (final data in messageData) {
      final message = ChatMessage(
        text: data['text'] ?? '',
        isUser: data['isUser'] ?? false,
        timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      );
      _messages.add(message);
    }
    
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _messages.clear();
    _isTyping = false;
    _isLoading = false;
    _currentSessionId = null;
    notifyListeners();
  }
} 
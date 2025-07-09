import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 聊天历史服务 - 负责管理聊天记录的持久化存储
class ChatHistoryService {
  static const String _chatHistoryKey = 'ai_chat_history';
  static const String _chatSessionsKey = 'ai_chat_sessions';
  
  static ChatHistoryService? _instance;
  static ChatHistoryService get instance => _instance ??= ChatHistoryService._();
  ChatHistoryService._();

  /// 保存聊天会话
  Future<void> saveChatSession(ChatSessionData session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getChatSessions();
    
    // 检查是否已存在该会话，如果存在则更新
    final existingIndex = sessions.indexWhere((s) => s.id == session.id);
    if (existingIndex != -1) {
      sessions[existingIndex] = session;
    } else {
      sessions.insert(0, session); // 新会话添加到开头
    }
    
    // 限制会话数量，最多保存100个会话
    if (sessions.length > 100) {
      sessions.removeRange(100, sessions.length);
    }
    
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_chatSessionsKey, jsonEncode(sessionsJson));
  }

  /// 获取所有聊天会话
  Future<List<ChatSessionData>> getChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_chatSessionsKey);
    
    if (sessionsString == null) return [];
    
    try {
      final List<dynamic> sessionsJson = jsonDecode(sessionsString);
      return sessionsJson.map((json) => ChatSessionData.fromJson(json)).toList();
    } catch (e) {
      print('解析聊天会话数据失败: $e');
      return [];
    }
  }

  /// 保存聊天消息到指定会话
  Future<void> saveChatMessage(String sessionId, ChatMessageData message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_chatHistoryKey}_$sessionId';
    final messages = await getChatMessages(sessionId);
    
    messages.add(message);
    
    // 限制每个会话的消息数量，最多保存1000条消息
    if (messages.length > 1000) {
      messages.removeRange(0, messages.length - 1000);
    }
    
    final messagesJson = messages.map((m) => m.toJson()).toList();
    await prefs.setString(key, jsonEncode(messagesJson));
    
    // 更新会话的最后一条消息和时间
    final sessions = await getChatSessions();
    final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      sessions[sessionIndex] = sessions[sessionIndex].copyWith(
        lastMessage: message.text,
        lastMessageTime: message.timestamp,
        messageCount: messages.length,
      );
      await saveChatSession(sessions[sessionIndex]);
    }
  }

  /// 获取指定会话的聊天消息
  Future<List<ChatMessageData>> getChatMessages(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_chatHistoryKey}_$sessionId';
    final messagesString = prefs.getString(key);
    
    if (messagesString == null) return [];
    
    try {
      final List<dynamic> messagesJson = jsonDecode(messagesString);
      return messagesJson.map((json) => ChatMessageData.fromJson(json)).toList();
    } catch (e) {
      print('解析聊天消息数据失败: $e');
      return [];
    }
  }

  /// 创建新的聊天会话
  Future<ChatSessionData> createNewSession({String? firstMessage}) async {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final session = ChatSessionData(
      id: sessionId,
      title: firstMessage ?? '新建对话',
      lastMessage: firstMessage ?? '',
      lastMessageTime: DateTime.now(),
      createdTime: DateTime.now(),
      messageCount: 0,
    );
    
    await saveChatSession(session);
    return session;
  }

  /// 删除聊天会话
  Future<void> deleteChatSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 删除会话消息
    final messageKey = '${_chatHistoryKey}_$sessionId';
    await prefs.remove(messageKey);
    
    // 从会话列表中删除
    final sessions = await getChatSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_chatSessionsKey, jsonEncode(sessionsJson));
  }

  /// 更新会话标题
  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final sessions = await getChatSessions();
    final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);
    
    if (sessionIndex != -1) {
      sessions[sessionIndex] = sessions[sessionIndex].copyWith(title: newTitle);
      await saveChatSession(sessions[sessionIndex]);
    }
  }

  /// 清空所有聊天历史
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getChatSessions();
    
    // 删除所有会话的消息
    for (final session in sessions) {
      final messageKey = '${_chatHistoryKey}_${session.id}';
      await prefs.remove(messageKey);
    }
    
    // 清空会话列表
    await prefs.remove(_chatSessionsKey);
  }

  /// 按日期分组聊天会话
  Future<List<ChatHistoryGroup>> getChatHistoryGroupedByDate() async {
    final sessions = await getChatSessions();
    if (sessions.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));

    // 分组存储
    final Map<String, List<ChatSessionData>> groupedSessions = {
      '今天': <ChatSessionData>[],
      '昨天': <ChatSessionData>[],
      '7天内': <ChatSessionData>[],
      '30天内': <ChatSessionData>[],
    };
    
    // 存储按月份分组的历史记录
    final Map<String, List<ChatSessionData>> monthlyGroups = {};

    for (final session in sessions) {
      final sessionDate = session.lastMessageTime;
      final sessionDay = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      if (sessionDay.isAtSameMomentAs(today)) {
        // 今天
        groupedSessions['今天']!.add(session);
      } else if (sessionDay.isAtSameMomentAs(yesterday)) {
        // 昨天
        groupedSessions['昨天']!.add(session);
      } else if (sessionDay.isAfter(sevenDaysAgo) && sessionDay.isBefore(yesterday)) {
        // 7天内（不包含今天和昨天）
        groupedSessions['7天内']!.add(session);
      } else if (sessionDay.isAfter(thirtyDaysAgo) && sessionDay.isBefore(sevenDaysAgo.add(const Duration(days: 1)))) {
        // 30天内（不包含前面的）
        groupedSessions['30天内']!.add(session);
      } else {
        // 更早的记录按月份分组
        final monthKey = sessionDate.year == now.year 
            ? '${sessionDate.month}月' 
            : '${sessionDate.year}年${sessionDate.month}月';
        
        if (!monthlyGroups.containsKey(monthKey)) {
          monthlyGroups[monthKey] = [];
        }
        monthlyGroups[monthKey]!.add(session);
      }
    }

    // 构建最终分组列表
    final List<ChatHistoryGroup> result = [];
    
    // 按顺序添加固定分组（只添加非空的分组）
    final fixedGroupOrder = ['今天', '昨天', '7天内', '30天内'];
    for (final groupKey in fixedGroupOrder) {
      final sessions = groupedSessions[groupKey]!;
      if (sessions.isNotEmpty) {
        // 按时间倒序排序会话
        sessions.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        result.add(ChatHistoryGroup(
          title: groupKey,
          sessions: sessions,
        ));
      }
    }
    
    // 添加月份分组，按月份倒序排序
    final monthKeys = monthlyGroups.keys.toList();
    monthKeys.sort((a, b) {
      // 解析月份字符串进行正确的时间排序
      final aDate = _parseMonthKey(a);
      final bDate = _parseMonthKey(b);
      return bDate.compareTo(aDate);
    });
    
    for (final monthKey in monthKeys) {
      final sessions = monthlyGroups[monthKey]!;
      // 按时间倒序排序会话
      sessions.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      result.add(ChatHistoryGroup(
        title: monthKey,
        sessions: sessions,
      ));
    }

    return result;
  }

  /// 解析月份key为DateTime用于排序
  DateTime _parseMonthKey(String monthKey) {
    try {
      if (monthKey.contains('年')) {
        // 格式: "2024年12月"
        final parts = monthKey.split('年');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1].replaceAll('月', ''));
        return DateTime(year, month);
      } else {
        // 格式: "12月" (当前年)
        final month = int.parse(monthKey.replaceAll('月', ''));
        final currentYear = DateTime.now().year;
        return DateTime(currentYear, month);
      }
    } catch (e) {
      // 解析失败时返回最早时间
      return DateTime(1970);
    }
  }
}

/// 聊天会话数据模型
class ChatSessionData {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdTime;
  final int messageCount;

  ChatSessionData({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdTime,
    required this.messageCount,
  });

  factory ChatSessionData.fromJson(Map<String, dynamic> json) {
    return ChatSessionData(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(json['lastMessageTime'] as int),
      createdTime: DateTime.fromMillisecondsSinceEpoch(json['createdTime'] as int),
      messageCount: json['messageCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'createdTime': createdTime.millisecondsSinceEpoch,
      'messageCount': messageCount,
    };
  }

  ChatSessionData copyWith({
    String? title,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? messageCount,
  }) {
    return ChatSessionData(
      id: id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdTime: createdTime,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  /// 获取格式化的时间字符串
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime);

    if (diff.inDays == 0) {
      // 今天的消息显示时:分
      return '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      // 昨天的消息
      return '昨天';
    } else if (diff.inDays < 7) {
      // 一周内的消息显示星期
      final weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[lastMessageTime.weekday];
    } else {
      // 更早的消息显示月日
      return '${lastMessageTime.month}/${lastMessageTime.day}';
    }
  }
}

/// 聊天消息数据模型
class ChatMessageData {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? navigationJson; // 存储导航信息的JSON字符串

  ChatMessageData({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.navigationJson,
  });

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      navigationJson: json['navigationJson'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'navigationJson': navigationJson,
    };
  }
}

/// 聊天历史分组模型
class ChatHistoryGroup {
  final String title;
  final List<ChatSessionData> sessions;

  ChatHistoryGroup({
    required this.title,
    required this.sessions,
  });
} 
# AI聊天历史时间分组功能说明

## 功能概述

本文档说明了AI聊天历史页面的新时间分组功能实现。该功能将用户的聊天记录按照时间层级进行智能分组，提供更好的历史记录管理体验。

## 时间分组规则

### 1. 时间层级结构

聊天记录按以下时间层级进行分组，各层级互不交叉：

1. **今天** - 当天的聊天记录
2. **昨天** - 昨天的聊天记录  
3. **7天内** - 除今天和昨天外，7天内的聊天记录
4. **30天内** - 除前面层级外，30天内的聊天记录
5. **按历史月份统计** - 更早的记录按月份分组

### 2. 分组特点

- **互不交叉**: 各时间层级的聊天记录互不重复，确保每条记录只出现在一个分组中
- **智能排序**: 分组按时间倒序排列，最新的分组显示在最前面
- **动态显示**: 只显示包含聊天记录的分组，空分组不会显示
- **月份智能命名**: 
  - 当前年份的记录：显示为 "X月"
  - 历史年份的记录：显示为 "XXXX年X月"

## 技术实现

### 核心文件

- **ChatHistoryService** (`lib/common/chat_history_service.dart`)
  - 负责聊天历史的存储和检索
  - 实现了新的 `getChatHistoryGroupedByDate()` 方法
  - 提供月份解析功能 `_parseMonthKey()`

- **AiChatHistoryPage** (`lib/routes/ai_chat_history_page.dart`)
  - AI聊天历史页面UI实现
  - 使用新的分组数据进行展示

### 关键方法

#### getChatHistoryGroupedByDate()

```dart
Future<List<ChatHistoryGroup>> getChatHistoryGroupedByDate() async {
  // 获取所有会话
  final sessions = await getChatSessions();
  
  // 计算时间边界
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final sevenDaysAgo = today.subtract(const Duration(days: 7));
  final thirtyDaysAgo = today.subtract(const Duration(days: 30));
  
  // 按规则分组会话
  // ...
  
  return result;
}
```

#### _parseMonthKey()

```dart
DateTime _parseMonthKey(String monthKey) {
  // 解析月份key为DateTime用于排序
  // 支持 "12月" 和 "2024年12月" 两种格式
}
```

### 数据模型

#### ChatHistoryGroup

```dart
class ChatHistoryGroup {
  final String title;           // 分组标题（如"今天"、"7天内"、"2024年12月"）
  final List<ChatSessionData> sessions;  // 该分组下的会话列表
}
```

#### ChatSessionData

```dart
class ChatSessionData {
  final String id;              // 会话ID
  final String title;           // 会话标题
  final String lastMessage;     // 最后一条消息
  final DateTime lastMessageTime;  // 最后消息时间
  final DateTime createdTime;   // 创建时间
  final int messageCount;       // 消息数量
}
```

## 使用示例

### 演示页面

创建了 `DemoChatHistoryGroupsPage` (`lib/demo_chat_history_groups.dart`) 来演示新的分组功能：

```dart
// 初始化演示数据并展示分组效果
final groups = await chatHistoryService.getChatHistoryGroupedByDate();
```

### 测试验证

提供了完整的测试用例 (`test/common/chat_history_service_test.dart`)：

```dart
testWidgets('测试时间分组逻辑', (WidgetTester tester) async {
  // 创建不同时间的测试会话
  // 验证分组结果的正确性
});
```

## 功能特点

### 1. 用户体验优化

- **直观的时间标识**: 使用"今天"、"昨天"等易懂的标识
- **清晰的层级结构**: 从近到远的时间层级，符合用户查找习惯
- **统计信息显示**: 每个分组显示包含的会话数量

### 2. 性能考虑

- **高效的时间计算**: 使用 DateTime 的精确比较避免误判
- **智能排序**: 在分组内按时间倒序排列，最新会话在前
- **内存优化**: 只显示非空分组，减少UI渲染负担

### 3. 扩展性

- **灵活的分组规则**: 可以轻松调整时间边界
- **可配置的月份显示**: 支持年份和月份的不同显示格式
- **易于测试**: 完整的单元测试覆盖

## 界面展示

### 分组标题样式

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(
    '${group.title} (${group.sessions.length}条)',
    style: const TextStyle(
      color: Color(0xFF1A73E8),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### 会话卡片信息

- 会话标题
- 最后一条消息预览
- 消息数量统计
- 详细时间信息
- 相对时间显示

## 总结

新的时间分组功能实现了：

1. ✅ **明确的时间层级**: 今天、昨天、7天内、30天内、历史月份
2. ✅ **互不交叉的分组**: 确保每条记录只属于一个分组
3. ✅ **智能排序显示**: 按时间倒序，最新的内容在前
4. ✅ **月份智能命名**: 根据年份自动选择显示格式
5. ✅ **完整的测试覆盖**: 保证功能的稳定性和正确性

该功能提升了用户查找历史聊天记录的效率，提供了更好的用户体验。 
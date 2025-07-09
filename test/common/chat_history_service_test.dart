import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/common/chat_history_service.dart';

void main() {
  group('ChatHistoryService 时间分组测试', () {
    late ChatHistoryService chatHistoryService;

    setUp(() async {
      // 设置测试环境
      SharedPreferences.setMockInitialValues({});
      chatHistoryService = ChatHistoryService.instance;
    });

    tearDown(() async {
      // 清理测试数据
      await chatHistoryService.clearAllHistory();
    });

    /// 创建测试会话的辅助方法
    ChatSessionData createTestSession({
      required String id,
      required String title,
      required DateTime lastMessageTime,
    }) {
      return ChatSessionData(
        id: id,
        title: title,
        lastMessage: '测试消息',
        lastMessageTime: lastMessageTime,
        createdTime: lastMessageTime,
        messageCount: 1,
      );
    }

    testWidgets('测试时间分组逻辑', (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final tenDaysAgo = today.subtract(const Duration(days: 10));
      final twoMonthsAgo = DateTime(now.year, now.month - 2, 15);
      final lastYear = DateTime(now.year - 1, 12, 15);

      // 创建不同时间的测试会话
      final sessions = [
        createTestSession(
          id: '1',
          title: '今天的会话',
          lastMessageTime: today.add(const Duration(hours: 10)),
        ),
        createTestSession(
          id: '2',
          title: '昨天的会话',
          lastMessageTime: yesterday.add(const Duration(hours: 15)),
        ),
        createTestSession(
          id: '3',
          title: '7天内的会话',
          lastMessageTime: threeDaysAgo.add(const Duration(hours: 12)),
        ),
        createTestSession(
          id: '4',
          title: '30天内的会话',
          lastMessageTime: tenDaysAgo.add(const Duration(hours: 9)),
        ),
        createTestSession(
          id: '5',
          title: '两个月前的会话',
          lastMessageTime: twoMonthsAgo,
        ),
        createTestSession(
          id: '6',
          title: '去年的会话',
          lastMessageTime: lastYear,
        ),
      ];

      // 保存测试会话
      for (final session in sessions) {
        await chatHistoryService.saveChatSession(session);
      }

      // 获取分组结果
      final groups = await chatHistoryService.getChatHistoryGroupedByDate();

      // 验证分组数量和结构
      expect(groups.length, greaterThan(0));

      // 验证"今天"分组
      final todayGroup = groups.firstWhere(
        (g) => g.title == '今天',
        orElse: () => ChatHistoryGroup(title: '', sessions: []),
      );
      expect(todayGroup.sessions.length, 1);
      expect(todayGroup.sessions.first.title, '今天的会话');

      // 验证"昨天"分组
      final yesterdayGroup = groups.firstWhere(
        (g) => g.title == '昨天',
        orElse: () => ChatHistoryGroup(title: '', sessions: []),
      );
      expect(yesterdayGroup.sessions.length, 1);
      expect(yesterdayGroup.sessions.first.title, '昨天的会话');

      // 验证"7天内"分组
      final sevenDaysGroup = groups.firstWhere(
        (g) => g.title == '7天内',
        orElse: () => ChatHistoryGroup(title: '', sessions: []),
      );
      expect(sevenDaysGroup.sessions.length, 1);
      expect(sevenDaysGroup.sessions.first.title, '7天内的会话');

      // 验证"30天内"分组
      final thirtyDaysGroup = groups.firstWhere(
        (g) => g.title == '30天内',
        orElse: () => ChatHistoryGroup(title: '', sessions: []),
      );
      expect(thirtyDaysGroup.sessions.length, 1);
      expect(thirtyDaysGroup.sessions.first.title, '30天内的会话');

      // 验证月份分组
      final monthGroups = groups.where((g) => g.title.contains('月')).toList();
      expect(monthGroups.length, 2); // 两个月前和去年的会话

      // 验证去年会话在正确的月份分组中
      final lastYearGroup = groups.firstWhere(
        (g) => g.title.contains('${lastYear.year}年'),
        orElse: () => ChatHistoryGroup(title: '', sessions: []),
      );
      expect(lastYearGroup.sessions.isNotEmpty, true);
      expect(
        lastYearGroup.sessions.any((s) => s.title == '去年的会话'),
        true,
      );
    });

    testWidgets('测试分组顺序正确', (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 创建按固定顺序的测试会话
      final sessions = [
        createTestSession(
          id: '1',
          title: '今天会话',
          lastMessageTime: today.add(const Duration(hours: 10)),
        ),
        createTestSession(
          id: '2',
          title: '昨天会话',
          lastMessageTime: today.subtract(const Duration(days: 1)),
        ),
        createTestSession(
          id: '3',
          title: '7天内会话',
          lastMessageTime: today.subtract(const Duration(days: 3)),
        ),
        createTestSession(
          id: '4',
          title: '30天内会话',
          lastMessageTime: today.subtract(const Duration(days: 15)),
        ),
      ];

      // 保存测试会话
      for (final session in sessions) {
        await chatHistoryService.saveChatSession(session);
      }

      // 获取分组结果
      final groups = await chatHistoryService.getChatHistoryGroupedByDate();

      // 验证分组顺序
      final expectedOrder = ['今天', '昨天', '7天内', '30天内'];
      final actualOrder = groups.map((g) => g.title).toList();

      // 检查预期的分组是否按正确顺序出现
      int lastIndex = -1;
      for (final expectedTitle in expectedOrder) {
        final currentIndex = actualOrder.indexOf(expectedTitle);
        if (currentIndex != -1) {
          expect(currentIndex, greaterThan(lastIndex), 
            reason: '分组 "$expectedTitle" 应该在之前的分组之后');
          lastIndex = currentIndex;
        }
      }
    });

    testWidgets('测试空分组不显示', (WidgetTester tester) async {
      final now = DateTime.now();
      final tenDaysAgo = now.subtract(const Duration(days: 10));

      // 只创建一个30天内的会话
      final session = createTestSession(
        id: '1',
        title: '30天内的会话',
        lastMessageTime: tenDaysAgo,
      );

      await chatHistoryService.saveChatSession(session);

      // 获取分组结果
      final groups = await chatHistoryService.getChatHistoryGroupedByDate();

      // 验证空的分组不出现
      final groupTitles = groups.map((g) => g.title).toList();
      expect(groupTitles.contains('今天'), false);
      expect(groupTitles.contains('昨天'), false);
      expect(groupTitles.contains('7天内'), false);
      expect(groupTitles.contains('30天内'), true);
    });

    testWidgets('测试月份解析功能', (WidgetTester tester) async {
      // 测试 _parseMonthKey 方法的逻辑
      final now = DateTime.now();
      final testYearMonth = DateTime(2023, 12);
      final testCurrentYearMonth = DateTime(now.year, 6);

      // 创建不同月份的测试会话
      final sessions = [
        createTestSession(
          id: '1',
          title: '2023年12月会话',
          lastMessageTime: testYearMonth,
        ),
        createTestSession(
          id: '2',
          title: '今年6月会话',
          lastMessageTime: testCurrentYearMonth,
        ),
      ];

      for (final session in sessions) {
        await chatHistoryService.saveChatSession(session);
      }

      final groups = await chatHistoryService.getChatHistoryGroupedByDate();
      
      // 验证月份分组存在
      final monthGroups = groups.where((g) => g.title.contains('月')).toList();
      expect(monthGroups.length, greaterThan(0));
      
      // 验证2023年12月的会话分组正确
      final yearMonthGroup = groups.firstWhere(
        (g) => g.title.contains('2023年12月'),
        orElse: () => ChatHistoryGroup(title: '', sessions: []),
      );
      expect(yearMonthGroup.sessions.isNotEmpty, true);
    });
  });
} 
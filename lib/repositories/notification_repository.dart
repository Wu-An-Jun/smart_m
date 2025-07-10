import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

/// 通知仓库，负责通知数据和已读状态的本地持久化
class NotificationRepository {
  static const String _readIdsKey = 'read_notification_ids';
  static const String _notificationsKey = 'notification_list';

  /// 保存已读通知ID列表到本地
  Future<void> saveReadIds(List<int> readIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readIdsKey, readIds.map((e) => e.toString()).toList());
  }

  /// 获取已读通知ID列表
  Future<List<int>> getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_readIdsKey) ?? [];
    return ids.map((e) => int.tryParse(e) ?? 0).where((e) => e != 0).toList();
  }

  /// 保存通知列表到本地（可选，简单序列化）
  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final list = notifications.map((n) => _notificationToMap(n)).toList();
    await prefs.setStringList(_notificationsKey, list.map((e) => e.toString()).toList());
  }

  /// 获取通知列表（可选，简单反序列化）
  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_notificationsKey) ?? [];
    return list.map((e) => _notificationFromMapString(e)).toList();
  }

  /// 通知对象转Map
  Map<String, dynamic> _notificationToMap(NotificationModel n) {
    return {
      'id': n.id,
      'type': n.type,
      'title': n.title,
      'message': n.message,
      'date': n.date,
      'time': n.time,
      'read': n.read,
      'details': n.details == null
          ? null
          : {
              'speed': n.details!.speed,
              'fullDate': n.details!.fullDate,
              'address': n.details!.address,
              'mapUrl': n.details!.mapUrl,
            },
    };
  }

  /// Map字符串转通知对象
  NotificationModel _notificationFromMapString(String mapString) {
    final map = _parseMapString(mapString);
    return NotificationModel(
      id: map['id'] as int,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      read: map['read'] as bool? ?? false,
      details: map['details'] == null
          ? null
          : NotificationDetails(
              speed: map['details']['speed'] as String,
              fullDate: map['details']['fullDate'] as String,
              address: map['details']['address'] as String,
              mapUrl: map['details']['mapUrl'] as String,
            ),
    );
  }

  /// 简单Map字符串解析（仅适用于本例，建议实际用json）
  Map<String, dynamic> _parseMapString(String mapString) {
    // 这里建议用json，实际项目请用jsonEncode/jsonDecode
    // 这里只做简单演示
    // TODO: 替换为json解析
    return {};
  }
} 
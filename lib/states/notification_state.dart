import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationState extends GetxController {
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final Rx<NotificationModel?> _selectedNotification = Rx<NotificationModel?>(
    null,
  );
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> get notifications => _notifications;
  NotificationModel? get selectedNotification => _selectedNotification.value;
  bool get hasUnread => _notifications.any((n) => !n.read);

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _loadReadStatus();
  }

  Future<void> _loadReadStatus() async {
    final readIds = await _repository.getReadIds();
    for (var n in _notifications) {
      n.read = readIds.contains(n.id);
    }
    _notifications.refresh();
  }

  void _initializeNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: 1,
        type: "device",
        title: "智能设备",
        message: "进入电子围栏报警!",
        date: "2025-06-23",
        time: "18:00:27",
        read: false,
        details: NotificationDetails(
          speed: "1.4km/h",
          fullDate: "2025-07-20 14:00",
          address: "广东省深圳市南山区立桥金融中心",
          mapUrl:
              "https://maps.googleapis.com/maps/api/staticmap?center=116.397428, 39.90923&zoom=14&size=400x400&key=YOUR_API_KEY",
        ),
      ),
      NotificationModel(
        id: 2,
        type: "device",
        title: "智能设备",
        message: "震动报警!",
        date: "2025-06-22",
        time: "18:00:27",
        read: false,
        details: NotificationDetails(
          speed: "0 km/h",
          fullDate: "2025-06-22 18:00:27",
          address: "北京市朝阳区建国路",
          mapUrl:
              "https://maps.googleapis.com/maps/api/staticmap?center=39.9042,116.4074&zoom=14&size=400x400&key=YOUR_API_KEY",
        ),
      ),
      NotificationModel(
        id: 3,
        type: "device",
        title: "智能设备",
        message: "进入电子围栏报警!",
        date: "2025-06-23",
        time: "18:00:27",
        read: true,
        details: NotificationDetails(
          speed: "1.5 km/h",
          fullDate: "2025-06-23 18:00:27",
          address: "上海市浦东新区世纪大道",
          mapUrl:
              "https://maps.googleapis.com/maps/api/staticmap?center=31.2304,121.4737&zoom=14&size=400x400&key=YOUR_API_KEY",
        ),
      ),
    ]);
  }

  void selectNotification(NotificationModel notification) {
    _selectedNotification.value = notification;
    markAsRead(notification.id);
  }

  void clearSelectedNotification() {
    _selectedNotification.value = null;
  }

  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].read = true;
      _notifications.refresh();
      _saveReadStatus();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.read = true;
    }
    _notifications.refresh();
    _saveReadStatus();
  }

  Future<void> _saveReadStatus() async {
    final readIds =
        _notifications.where((n) => n.read).map((n) => n.id).toList();
    await _repository.saveReadIds(readIds);
  }

  /// 生成测试通知数据
  void generateTestNotifications() {
    final now = DateTime.now();
    final testList = List.generate(
      5,
      (i) => NotificationModel(
        id: now.millisecondsSinceEpoch + i,
        type: "test",
        title: "测试通知${i + 1}",
        message: "这是一条测试通知消息 ${i + 1}",
        date: now.toString().substring(0, 10),
        time: now.toString().substring(11, 19),
        read: false,
        details: NotificationDetails(
          speed: "0 km/h",
          fullDate: now.toString(),
          address: "测试地址${i + 1}",
          mapUrl: "https://maps.example.com/test${i + 1}",
        ),
      ),
    );
    _notifications.insertAll(0, testList);
    _notifications.refresh();
    _saveReadStatus();
  }

  // 清空所有通知，便于开发测试无通知页面
  void clearAllNotifications() {
    _notifications.clear();
    _notifications.refresh();
  }
}

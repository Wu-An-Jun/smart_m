import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationState extends GetxController {
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final Rx<NotificationModel?> _selectedNotification = Rx<NotificationModel?>(null);

  List<NotificationModel> get notifications => _notifications;
  NotificationModel? get selectedNotification => _selectedNotification.value;
  bool get hasUnread => _notifications.any((n) => !n.read);

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
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
          speed: "1km/h",
          fullDate: "2025-07-20 14:00",
          address: "广东省深圳市南山区立桥金融中心A座1506",
          mapUrl: "https://maps.googleapis.com/maps/api/staticmap?center=40.714728,-73.998672&zoom=14&size=400x400&key=YOUR_API_KEY",
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
          mapUrl: "https://maps.googleapis.com/maps/api/staticmap?center=39.9042,116.4074&zoom=14&size=400x400&key=YOUR_API_KEY",
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
          mapUrl: "https://maps.googleapis.com/maps/api/staticmap?center=31.2304,121.4737&zoom=14&size=400x400&key=YOUR_API_KEY",
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
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.read = true;
    }
    _notifications.refresh();
  }
} 
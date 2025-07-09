import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../common/Global.dart';
import '../models/notification_model.dart';
import '../states/notification_state.dart';

class NotificationPage extends StatelessWidget {
  final NotificationState notificationState = Get.put(NotificationState());

  NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedNotification = notificationState.selectedNotification;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Global.currentTheme.backgroundColor,
          elevation: 0,
          title: Text(
            selectedNotification == null ? '消息通知' : '通知详情',
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (selectedNotification == null) {
                Get.back();
              } else {
                notificationState.clearSelectedNotification();
              }
            },
          ),
        ),
        body:
            selectedNotification == null
                ? _buildNotificationList()
                : _buildNotificationDetail(selectedNotification),
      );
    });
  }

  Widget _buildNotificationList() {
    return Container(
      color: Global.currentTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部栏
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: 17,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '通知列表',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontFamily: 'Noto Sans',
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Row(
                      children: [
                        // 开发用清空按钮
                        TextButton(
                          onPressed:
                              () => notificationState.clearAllNotifications(),
                          child: const Text(
                            '清空通知',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => notificationState.markAllAsRead(),
                          child: Row(
                            children: [
                              const Text(
                                '全部已读',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                'imgs/notification_all_read.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 内容区
              Expanded(
                child:
                    notificationState.notifications.isEmpty
                        ? _buildEmptyNotification()
                        : Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ListView.builder(
                            itemCount:
                                notificationState.notifications.length + 1,
                            itemBuilder: (context, index) {
                              if (index <
                                  notificationState.notifications.length) {
                                final notification =
                                    notificationState.notifications[index];
                                return _buildNotificationItem(notification);
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '没有更多内容',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 空状态UI，完全还原喵多设计
  Widget _buildEmptyNotification() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 装饰图标，偏右上
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 54, bottom: 0),
                  child: SvgPicture.asset(
                    'imgs/notification_empty_decor.svg',
                    width: 64,
                    height: 56.89,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // 主图标，居中
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 8),
                child: SvgPicture.asset(
                  'imgs/notification_empty_main.svg',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '您还没有收到任何通知',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 37),
                child: Text(
                  '当您的宠物设备触发报警时，消息将显示在这里',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          if (notification.details != null) {
            notificationState.selectNotification(notification);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[100]!, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      notification.read ? Colors.grey[300] : Color(0xFFD2B48C),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (!notification.read)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9500),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '推荐',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Alibaba PuHuiTi 3.0',
                              height: 15/10, // 设置行高为15px
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                notification.read
                                    ? Colors.grey[400]
                                    : Colors.grey[900],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            notification.read
                                ? Colors.grey[400]
                                : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${notification.date} ${notification.time}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationDetail(NotificationModel notification) {
    final details = notification.details!;

    return Container(
      color: const Color(0xFFF7F5FA),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.map, size: 64, color: Colors.grey[400]),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(top: 16, bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFB923C),
                                      Color(0xFFF97316),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'imgs/notification_detail_main_icon.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 144,
                                    child: Text(
                                      notification.title,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'imgs/notification_detail_warning_icon.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 124,
                                        child: Text(
                                          notification.message,
                                          style: const TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // 速度卡片
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.10),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDBEAFE),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset(
                                    'imgs/notification_detail_speed_icon.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '速度',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 14,
                                        height: 20 / 14,
                                      ),
                                    ),
                                    Text(
                                      details.speed,
                                      style: const TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 24 / 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 时间卡片
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.10),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDCFCE7),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset(
                                    'imgs/notification_detail_time_icon.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '时间',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 14,
                                        height: 20 / 14,
                                      ),
                                    ),
                                    Text(
                                      details.fullDate,
                                      style: const TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 24 / 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 地址卡片
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFFE5E5E5),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFEDD5),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 10,
                                  ),
                                  child: SvgPicture.asset(
                                    'imgs/notification_detail_address_icon.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '地址',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 14,
                                          height: 20 / 14,
                                        ),
                                      ),
                                      Text(
                                        details.address,
                                        style: const TextStyle(
                                          color: Color(0xFF1F2937),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          height: 24 / 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Expanded(child: Text(value, style: TextStyle(color: Colors.grey[600]))),
      ],
    );
  }
}

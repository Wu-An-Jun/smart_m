class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final String date;
  final String time;
  bool read;
  final NotificationDetails? details;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    this.read = false,
    this.details,
  });
}

class NotificationDetails {
  final String speed;
  final String fullDate;
  final String address;
  final String mapUrl;

  NotificationDetails({
    required this.speed,
    required this.fullDate,
    required this.address,
    required this.mapUrl,
  });
} 
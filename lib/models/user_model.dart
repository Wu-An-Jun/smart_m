import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// 用户信息模型
@HiveType(typeId: 10)
class UserModel extends HiveObject {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String nickname;
  @HiveField(2)
  final String avatarUrl;
  @HiveField(3)
  final String token;
  @HiveField(4)
  final String? email;
  @HiveField(5)
  final String? phone;

  UserModel({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.token,
    this.email,
    this.phone,
  });

  UserModel copyWith({
    String? userId,
    String? nickname,
    String? avatarUrl,
    String? token,
    String? email,
    String? phone,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
// 注：需运行 flutter pub run build_runner build 生成 user_model.g.dart 文件。 
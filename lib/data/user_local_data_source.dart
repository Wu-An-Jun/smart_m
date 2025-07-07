import 'package:hive/hive.dart';
import '../models/user_model.dart';

/// 用户本地数据源，负责用户信息的本地持久化
class UserLocalDataSource {
  static const String userBoxName = 'user_box';
  static const String userKey = 'current_user';

  /// 初始化Hive及注册Adapter
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    await Hive.openBox<UserModel>(userBoxName);
  }

  /// 保存当前用户
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.put(userKey, user);
  }

  /// 获取当前用户
  UserModel? getUser() {
    final box = Hive.box<UserModel>(userBoxName);
    return box.get(userKey);
  }

  /// 清除当前用户
  Future<void> clearUser() async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.delete(userKey);
  }
} 
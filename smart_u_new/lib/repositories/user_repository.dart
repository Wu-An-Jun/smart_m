import '../models/user_model.dart';
import '../data/user_local_data_source.dart';
import '../data/user_remote_data_source.dart';

/// 用户仓库，统一管理本地与远程用户数据
class UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;

  UserRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// 获取当前用户（本地）
  UserModel? getUser() {
    return localDataSource.getUser();
  }

  /// 保存当前用户（本地+预留远程同步）
  Future<void> saveUser(UserModel user) async {
    await localDataSource.saveUser(user);
    // TODO: 可在此调用远程同步
  }

  /// 清除当前用户（本地+预留远程同步）
  Future<void> clearUser() async {
    await localDataSource.clearUser();
    // TODO: 可在此调用远程同步
  }

  /// 登录（远程，成功后本地保存）
  Future<UserModel?> login(String username, String password) async {
    // 先尝试远程登录
    final user = await remoteDataSource.login(username, password);
    if (user != null) {
      await saveUser(user);
      return user;
    }
    // 远程无，尝试本地
    final localUser = getUser();
    if (localUser != null) {
      // 简单校验手机号和token（开发环境下无密码）
      if ((localUser.phone == username || localUser.userId == username) && localUser.token == password) {
        return localUser;
      } else {
        return null;
      }
    }
    // 本地无用户，自动注册
    final newUser = UserModel(
      userId: username,
      nickname: 'User_$username',
      avatarUrl: '',
      token: password,
      email: null,
      phone: username,
    );
    await saveUser(newUser);
    return newUser;
  }

  /// 登出（远程+本地清除）
  Future<void> logout() async {
    await remoteDataSource.logout();
    await clearUser();
  }

  /// 刷新Token（远程，成功后本地更新）
  Future<String?> refreshToken(String oldToken) async {
    final newToken = await remoteDataSource.refreshToken(oldToken);
    if (newToken != null) {
      final user = getUser();
      if (user != null) {
        await saveUser(user.copyWith(token: newToken));
      }
    }
    return newToken;
  }
} 
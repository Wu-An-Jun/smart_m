import '../models/user_model.dart';

/// 用户远程数据源，预留后端API对接接口
class UserRemoteDataSource {
  /// 登录（预留，暂返回null）
  Future<UserModel?> login(String username, String password) async {
    // TODO: 实现API请求
    return null;
  }

  /// 登出（预留，无实际操作）
  Future<void> logout() async {
    // TODO: 实现API请求
  }

  /// 刷新Token（预留，暂返回null）
  Future<String?> refreshToken(String oldToken) async {
    // TODO: 实现API请求
    return null;
  }
} 
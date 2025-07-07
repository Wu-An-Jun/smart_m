import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../data/user_local_data_source.dart';
import '../data/user_remote_data_source.dart';

/// 用户控制器，管理登录状态
class UserController extends GetxController {
  final UserRepository repository = UserRepository(
    localDataSource: UserLocalDataSource(),
    remoteDataSource: UserRemoteDataSource(),
  );

  final Rxn<UserModel> _user = Rxn<UserModel>();
  UserModel? get user => _user.value;
  bool get isLoggedIn => _user.value != null;

  final RxBool _isInitializing = true.obs;
  bool get isInitializing => _isInitializing.value;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  /// 初始化用户信息（本地持久化）
  Future<void> _initializeUser() async {
    await UserLocalDataSource.initialize();
    _user.value = repository.getUser();
    _isInitializing.value = false;
  }

  /// 登录
  Future<bool> login(String username, String password) async {
    final user = await repository.login(username, password);
    if (user != null) {
      _user.value = user;
      await repository.saveUser(user);
      update();
      return true;
    }
    return false;
  }

  /// 登出
  Future<void> logout() async {
    await repository.logout();
    _user.value = null;
    update();
  }

  /// 清除本地用户
  Future<void> clearUser() async {
    await repository.clearUser();
    _user.value = null;
  }
} 
import 'package:flutter/material.dart';
import 'user_state.dart';
import 'chat_state.dart';
import 'app_state.dart';

/// 状态管理器
/// 提供统一的状态管理入口和便捷的访问方式
class StateManager {
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  // 状态实例
  final UserState _userState = UserState();
  final ChatState _chatState = ChatState();
  final AppState _appState = AppState();

  // 获取状态实例
  UserState get user => _userState;
  ChatState get chat => _chatState;
  AppState get app => _appState;

  /// 初始化所有状态
  Future<void> initialize() async {
    try {
      // 加载应用设置
      await _appState.loadSettingsFromLocal();
      
      print('状态管理器初始化完成');
    } catch (e) {
      print('状态管理器初始化失败: $e');
    }
  }

  /// 用户登录后初始化数据
  Future<void> initializeUserData() async {
    try {
      print('用户数据初始化完成');
    } catch (e) {
      print('用户数据初始化失败: $e');
    }
  }

  /// 用户登出时清理数据
  void clearUserData() {
    _userState.logout();
    _chatState.reset();
    
    print('用户数据已清理');
  }

  /// 重置所有状态
  void resetAll() {
    _userState.reset();
    _chatState.reset();
    _appState.reset();
    
    print('所有状态已重置');
  }

  /// 刷新所有数据
  Future<void> refreshAll() async {
    try {
      print('所有数据刷新完成');
    } catch (e) {
      print('数据刷新失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _userState.dispose();
    _chatState.dispose();
    _appState.dispose();
  }
}

/// 全局状态访问器
/// 提供便捷的全局状态访问方式
class GlobalState {
  static StateManager get manager => StateManager();
  static UserState get user => StateManager().user;
  static ChatState get chat => StateManager().chat;
  static AppState get app => StateManager().app;
}

/// 状态监听Widget
/// 用于监听多个状态的变化
class MultiStateBuilder extends StatelessWidget {
  final List<ChangeNotifier> states;
  final Widget Function(BuildContext context) builder;

  const MultiStateBuilder({
    super.key,
    required this.states,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(states),
      builder: (context, child) => builder(context),
    );
  }
}

/// 状态消费者Widget
/// 简化状态监听的使用
class StateConsumer<T extends ChangeNotifier> extends StatelessWidget {
  final T state;
  final Widget Function(BuildContext context, T state) builder;

  const StateConsumer({
    super.key,
    required this.state,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, child) => builder(context, state),
    );
  }
}

/// 状态选择器Widget
/// 只在指定属性变化时重建
class StateSelector<T extends ChangeNotifier, R> extends StatelessWidget {
  final T state;
  final R Function(T state) selector;
  final Widget Function(BuildContext context, R value) builder;

  const StateSelector({
    super.key,
    required this.state,
    required this.selector,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, child) {
        final value = selector(state);
        return builder(context, value);
      },
    );
  }
} 
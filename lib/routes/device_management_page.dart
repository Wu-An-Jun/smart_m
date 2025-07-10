import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/Global.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../routes/app_routes.dart';
import '../routes/geofence_management_page.dart';
import '../views/add_device_view.dart';
import '../widgets/center_popup.dart';
import '../widgets/geofence_map_widget.dart';
import '../widgets/more_settings_dialog.dart';
import '../widgets/positioning_mode_selector.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../states/notification_state.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final DeviceController controller = Get.find<DeviceController>();

  // 控制是否显示猫咪定位器界面
  final RxBool _showCatLocatorView = false.obs;

  // 控制是否显示定位模式选择器
  final RxBool _showPositioningModeSelector = false.obs;

  // 远程开关状态
  final RxBool _remoteSwitch = false.obs;

  // 猫咪定位器的任务列表
  final RxList<String> _tasks = <String>[].obs;

  // 控制是否显示添加设备界面
  final RxBool _showAddDeviceView = false.obs;

  DateTime? _disconnectTime;
  String? _currentDeviceId;

  @override
  void initState() {
    super.initState();
    controller.loadDevices();
    _loadTasks();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['showAddDevice'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddDeviceView.value = true;
      });
    }

    // 检查是否需要直接显示猫咪定位器界面
    if (arguments != null && arguments['showCatLocator'] == true) {
      // 延迟一帧执行，确保widget构建完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCatLocator();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['deviceId'] != null) {
      if (_currentDeviceId != arguments['deviceId']) {
        _currentDeviceId = arguments['deviceId'];
        _loadPersistedState();
        _showCatLocator(deviceId: _currentDeviceId);
      }
    }
  }

  /// 加载任务持久化数据
  Future<void> _loadTasks() async {
    if (_currentDeviceId == null) {
      _tasks.assignAll(["宠物离开小区时给我发消息", "每天10点以后关闭定位"]);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('smart_butler_tasks_${_currentDeviceId!}');
    if (tasksJson != null) {
      final List<String> list = tasksJson.split('\n');
      _tasks.assignAll(list);
    } else {
      // 默认任务
      _tasks.assignAll(["宠物离开小区时给我发消息", "每天10点以后关闭定位"]);
    }
  }

  /// 保存任务到本地
  Future<void> _saveTasks() async {
    if (_currentDeviceId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('smart_butler_tasks_${_currentDeviceId!}', _tasks.join('\n'));
  }

  Future<void> _loadPersistedState() async {
    if (_currentDeviceId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final switchVal = prefs.getBool('remote_switch_${_currentDeviceId!}');
    if (switchVal != null) {
      _remoteSwitch.value = switchVal;
    } else {
      _remoteSwitch.value = true; // 默认开启
    }
    final disconnectStr = prefs.getString('disconnect_time_${_currentDeviceId!}');
    if (disconnectStr != null) {
      _disconnectTime = DateTime.tryParse(disconnectStr);
    } else {
      _disconnectTime = null;
    }
  }

  Future<void> _saveRemoteSwitchState() async {
    if (_currentDeviceId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remote_switch_${_currentDeviceId!}', _remoteSwitch.value);
  }

  Future<void> _saveDisconnectTime() async {
    if (_currentDeviceId == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (_disconnectTime == null) {
      await prefs.remove('disconnect_time_${_currentDeviceId!}');
    } else {
      await prefs.setString('disconnect_time_${_currentDeviceId!}', _disconnectTime!.toIso8601String());
    }
  }

  /// 切换到猫咪定位器界面（并加载对应任务）
  void _showCatLocator({String? deviceId}) {
    if (deviceId != null) {
      _currentDeviceId = deviceId;
    }
    _loadTasks();
    _showCatLocatorView.value = true;
    _showPositioningModeSelector.value = false;
  }

  /// 切换到定位模式选择器界面
  void _showPositioningMode() {
    _showPositioningModeSelector.value = true;
    _showCatLocatorView.value = false;
  }

  /// 返回原界面
  void _backToDeviceList() {
    setState(() {
      _showCatLocatorView.value = false;
      _showPositioningModeSelector.value = false;
      _showAddDeviceView.value = false;
    });
    Navigator.of(context).maybePop();
  }

  /// 切换远程开关状态
  void _toggleRemoteSwitch() async {
    if (_remoteSwitch.value) {
      // 关闭时弹窗确认
      final confirmed = await context.showDeleteConfirmation(
        title: '关闭远程开关',
        content: '关闭远程开关后，部分功能将不可用，确定要关闭吗？',
        confirmText: '关闭',
        isDangerous: true,
      );
      if (!confirmed) return;
    }
    _remoteSwitch.value = !_remoteSwitch.value;
    await _saveRemoteSwitchState();
    if (!_remoteSwitch.value) {
      if (_disconnectTime == null) {
        _disconnectTime = DateTime.now();
        await _saveDisconnectTime();
      }
      Get.rawSnackbar(
        messageText: _buildDeviceDisconnectedBanner(),
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
    } else {
      _disconnectTime = null;
      await _saveDisconnectTime();
    }
  }

  /// 移除任务
  void _removeTask(String task) {
    _tasks.remove(task);
    _saveTasks();
  }

  /// 显示更多设置弹窗
  void _showMoreSettingsDialog() {
    MoreSettingsDialog.show(
      context,
      onOneKeyRestart: () => _handleOneKeyRestart(),
      onRemoteWakeup: () => _handleRemoteWakeup(),
      onFactoryReset: () => _handleFactoryReset(),
    );
  }

  /// 处理一键重启
  void _handleOneKeyRestart() {
    CenterPopup.show(
      context,
      '正在重启设备...',
      duration: const Duration(seconds: 3),
    );

    // 模拟重启过程
    Future.delayed(const Duration(seconds: 3), () {
      CenterPopup.show(
        context,
        '设备重启成功！',
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// 处理远程唤醒
  void _handleRemoteWakeup() {
    CenterPopup.show(
      context,
      '正在唤醒设备...',
      duration: const Duration(seconds: 2),
    );

    // 模拟唤醒过程
    Future.delayed(const Duration(seconds: 2), () {
      CenterPopup.show(
        context,
        '设备已成功唤醒！',
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// 处理恢复出厂设置
  void _handleFactoryReset() {
    CenterPopup.show(
      context,
      '正在恢复出厂设置...',
      duration: const Duration(seconds: 4),
    );

    // 模拟恢复过程
    Future.delayed(const Duration(seconds: 4), () {
      CenterPopup.show(
        context,
        '出厂设置恢复完成！',
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// 弹出重命名设备对话框
  void _showRenameDeviceDialog(DeviceModel device) {
    final TextEditingController nameController = TextEditingController(
      text: device.name,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            '重命名设备',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '新设备名称',
              border: OutlineInputBorder(),
            ),
            maxLength: 20,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) {
                  Get.snackbar(
                    '错误',
                    '设备名称不能为空',
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red,
                  );
                  return;
                }
                final updatedDevice = device.copyWith(name: newName);
                await controller.updateDevice(device.id, updatedDevice);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Global.currentTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor, // 使用全局主题背景色
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Obx(() {
                final hasDevices = controller.devices.isNotEmpty;

                if (controller.isLoading) {
                  return _buildLoadingState();
                }

                // 根据当前状态显示不同的界面
                if (_showAddDeviceView.value) {
                  return AddDeviceView(onBack: _backToDeviceList);
                } else if (_showPositioningModeSelector.value) {
                  return _buildPositioningModeSelectorView();
                } else if (_showCatLocatorView.value) {
                  return _buildCatLocatorView();
                } else {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    child:
                        hasDevices
                            ? _buildDeviceListState()
                            : _buildEmptyState(),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部应用栏
  Widget _buildAppBar() {
    return Obx(() {
      final hasDevices = controller.devices.isNotEmpty;
      final title = hasDevices ? '我的设备' : '设备管理';

      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Global.currentTheme.backgroundColor, // 使用全局主题背景色
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Global.currentTextColor,
              ),
            ),
            const Spacer(),
            // 添加按钮
            GestureDetector(
              onTap: () => _showAddDeviceView.value = true,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Global.currentTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            // 更多选项按钮
            GestureDetector(
              onTap: () => _showMoreOptions(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Global.currentTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 通知按钮
            GestureDetector(
              onTap: () => _showNotifications(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Global.currentTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    // 只有有未读通知时才显示红点
                    Obx(() {
                      final notificationState = Get.isRegistered<NotificationState>()
                          ? Get.find<NotificationState>()
                          : Get.put(NotificationState());
                      final hasUnread = notificationState.hasUnread;
                      return hasUnread
                          ? Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 无设备空状态界面
  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 20), // 距离顶部20像素
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200], // 灰色背景
            borderRadius: BorderRadius.circular(16), // 圆边处理
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '我的设备',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),

              // 空状态提示
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '暂无设备，请先绑定设备！',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // 绑定按钮
              GestureDetector(
                onTap: () => _showAddDeviceView.value = true,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Global.currentTheme.primaryColor, // 使用主题主色
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '绑定',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.add, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(), // 剩余空间
      ],
    );
  }

  /// 有设备时的列表状态
  Widget _buildDeviceListState() {
    return Column(
      children: [
        // 设备列表
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [_buildDeviceGrid(), const SizedBox(height: 20)],
            ),
          ),
        ),
      ],
    );
  }

  /// 设备网格布局
  Widget _buildDeviceGrid() {
    return Obx(() {
      final devices = controller.devices;

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildDeviceItem(devices[index]);
        },
      );
    });
  }

  /// 设备项
  Widget _buildDeviceItem(DeviceModel device) {
    return GestureDetector(
      onTap: () => _handleDeviceItemTap(device),
      child: Container(
        decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 设备信息行
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 设备图标
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB366), // 橙色图标背景
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDeviceIcon(device.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 设备信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _getDeviceLocation(device),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? device.description ?? '获取位置中...',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white60,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatLastSeen(device.lastSeen),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 信号和电池状态、连接状态 垂直排列
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 电量百分比
                      Text(
                        _getBatteryLevel(device),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _getBatteryColor(device),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 电池图标
                      Icon(
                        _getBatteryIcon(device),
                        color: _getBatteryColor(device),
                        size: 16,
                      ),
                      const SizedBox(height: 8),
                      // wifi图标
                      Icon(
                        device.isOnline ? Icons.wifi : Icons.wifi_off,
                        color: device.isOnline ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(height: 8),
                      // 编辑设备名称按钮
                      // GestureDetector(
                      //   onTap: () => _showRenameDeviceDialog(device),
                      //   child: const Icon(
                      //     Icons.edit,
                      //     color: Colors.white70,
                      //     size: 20,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取设备图标
  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.camera:
        return Icons.videocam;
      case DeviceType.map:
        return Icons.map;
      case DeviceType.petTracker:
        return Icons.location_on;
      case DeviceType.smartSwitch:
        return Icons.toggle_on;
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.router:
        return Icons.router;
    }
  }

  /// 加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
          SizedBox(height: 16),
          Text('加载设备中...', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  /// 处理设备项点击
  void _handleDeviceItemTap(DeviceModel device) {
    if (device.type == DeviceType.petTracker) {
      _currentDeviceId = device.id;
      _loadPersistedState();
      _showCatLocator(deviceId: device.id);
    } else {
      Get.toNamed(AppRoutes.deviceDetail, arguments: device);
    }
  }

  /// 处理地理围栏卡片点击
  void _handleGeofenceCardTap() {
    // 跳转到地理围栏管理页面
    Get.to(() => const GeofenceManagementPage());
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('刷新设备'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.loadDevices();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('设备设置'),
                  onTap: () {
                    Navigator.pop(context);
                    // 跳转到设备设置页面
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('高德地图围栏测试'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.amapGeofenceTest);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('清空所有设备'),
                  onTap: () {
                    Navigator.pop(context);
                    _clearAllDevices();
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// 清空所有设备（用于演示状态切换）
  Future<void> _clearAllDevices() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空设备'),
        content: const Text('确定要清空所有设备吗？这仅用于演示状态切换。'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              await controller.clearAllDevices();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清空', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 显示通知页面
  void _showNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  /// 构建猫咪定位器界面
  Widget _buildCatLocatorView() {
    return Container(
      decoration: BoxDecoration(color: Global.currentTheme.backgroundColor),
      child: Column(
        children: [
          // 标题栏
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Global.currentTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 返回按钮
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      print('返回按钮被点击');
                      _backToDeviceList();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'imgs/nav_back.svg',
                          width: 22,
                          height: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // 标题
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '猫咪定位器',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Alibaba PuHuiTi 3.0',
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                // 右侧占位，保持标题居中
                const SizedBox(width: 48),
              ],
            ),
          ),
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // 地图区域
                  _buildMapSection(),
                  const SizedBox(height: 24),
                  // 功能列表
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: _buildFunctionList(),
                  ),
                  const SizedBox(height: 24),
                  // 智能管家
                  Container(width: double.infinity, child: _buildSmartButler()),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地图区域
  Widget _buildMapSection() {
    if (!_remoteSwitch.value) {
      // 断开样式
      final String timeStr = _disconnectTime == null
          ? ''
          : _formatDisconnectTime(_disconnectTime!);
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF9CA3AF), // 灰色背景，若有断开背景图可替换
        ),
        child: Stack(
          children: [
            // 背景图（如有）
            // Positioned.fill(
            //   child: Image.asset('imgs/device_disconnect_bg.png', fit: BoxFit.cover),
            // ),
            // 半透明蒙层
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x661F2937), // #1F2937, 40%透明
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // 顶部右侧icon
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'imgs/device_disconnect_main_icon.svg',
                    width: 20,
                    height: 20,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            // 中间大icon
            Positioned(
              top: 68,
              left: 0,
              right: 0,
              child: Center(
                child: SvgPicture.asset(
                  'imgs/device_disconnect_center_icon.svg',
                  width: 48,
                  height: 48,
                  color: Colors.white,
                ),
              ),
            ),
            // 标题
            Positioned(
              top: 132,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '设备连接已断开',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Alibaba PuHuiTi 3.0',
                    height: 1.5,
                  ),
                ),
              ),
            ),
            // 底部提示
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '显示最后更新时间：$timeStr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Alibaba PuHuiTi 3.0',
                      height: 16 / 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // 正常地图
    return Container(
      height: 300, // 增加地图高度
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GeofenceMapWidget(
          config: const GeofenceMapConfig(
            title: '',
            showLegend: false,
            show3D: false,
            enableTestFences: true,
            height: 300,
            showStatus: false,
            showEvents: false,
          ),
          onStatusChanged: (status) {
            // 可以在这里处理地图状态变化
            print('地图状态: $status');
          },
        ),
      ),
    );
  }

  String _formatDisconnectTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      // 今天
      return '今天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 构建功能列表
  Widget _buildFunctionList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'imgs/feature_list_bar.svg',
                width: 4,
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '功能列表',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Alibaba PuHuiTi 3.0',
                  height: 1.55,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildFunctionListItem(
                  svgPath: 'imgs/feature_remote.svg',
                  label: '远程开关',
                  bgColor: const Color.fromRGBO(159, 71, 242, 0.3),
                  onTap: _toggleRemoteSwitch,
                  iconColor:
                      _remoteSwitch.value
                          ? const Color(0xFF9F47F2) // 开：紫色
                          : const Color(0xFFBDBDBD), // 关：灰色
                ),
                _buildVerticalDivider(),
                _buildFunctionListItem(
                  svgPath: 'imgs/feature_fence.svg',
                  label: '电子围栏',
                  bgColor: const Color.fromRGBO(59, 74, 246, 0.3),
                  onTap: () {
                    final petTracker = controller.devices.firstWhere(
                      (device) => device.type == DeviceType.petTracker,
                      orElse:
                          () => DeviceModel(
                            id: 'pet_tracker_default',
                            name: '猫咪定位器',
                            type: DeviceType.petTracker,
                            category: DeviceCategory.pet,
                            isOnline: true,
                            lastSeen: DateTime.now(),
                          ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GeofenceManagementPage(
                              deviceId: petTracker.id,
                              deviceName: petTracker.name,
                            ),
                      ),
                    );
                  },
                ),
                _buildVerticalDivider(),
                _buildFunctionListItem(
                  svgPath: 'imgs/feature_location_mode.svg',
                  label: '定位模式',
                  bgColor: const Color.fromRGBO(236, 162, 91, 0.3),
                  onTap: _showPositioningMode,
                ),
                _buildVerticalDivider(),
                _buildFunctionListItem(
                  svgPath: 'imgs/feature_more.svg',
                  label: '更多设置',
                  bgColor: const Color(0xFFE5E7EB),
                  onTap: _showMoreSettingsDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 88, color: const Color(0xFFF3F4F6));
  }

  Widget _buildFunctionListItem({
    required String svgPath,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final bool isRemoteSwitch = label == '远程开关';
    final bool isRemoteSwitchOff = isRemoteSwitch && iconColor == const Color(0xFFBDBDBD);
    final bool isDisableByRemote = !isRemoteSwitch && !_remoteSwitch.value && (label == '电子围栏' || label == '定位模式' || label == '更多设置');
    return Expanded(
      child: GestureDetector(
        onTap: isDisableByRemote ? null : onTap, // 远程开关始终可点
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isRemoteSwitchOff
                      ? const Color(0x99D1D5DB)
                      : isDisableByRemote
                          ? const Color(0xFFF3F4F6)
                          : bgColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: isRemoteSwitchOff ? const EdgeInsets.all(12) : EdgeInsets.zero,
                child: Center(
                  child: SvgPicture.asset(
                    isRemoteSwitchOff ? 'imgs/automation_icon.svg' : svgPath,
                    width: isRemoteSwitchOff ? 24 : 20,
                    height: isRemoteSwitchOff ? 24 : 20,
                    color: isRemoteSwitchOff
                        ? const Color(0xFF6B7280)
                        : isDisableByRemote
                            ? const Color(0xFFD1D5DB)
                            : iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isRemoteSwitchOff
                      ? const Color(0xFF1F2937)
                      : isDisableByRemote
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Alibaba PuHuiTi 3.0',
                  height: 1.42,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建智能管家
  Widget _buildSmartButler() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'imgs/feature_list_bar.svg',
                width: 4,
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '智能设置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Alibaba PuHuiTi 3.0',
                  height: 1.55,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          // 用Column渲染所有任务项，保证每个任务项宽度拉满
          Obx(
            () => Column(
              children: List.generate(
                _tasks.length,
                (i) => Column(
                  children: [
                    _buildTaskListItem(
                      _tasks[i],
                      svgPath:
                          i == 0
                              ? 'imgs/smart_butler_msg.svg'
                              : 'imgs/smart_butler_time.svg',
                      onTap: () => _removeTask(_tasks[i]),
                    ),
                    if (i != _tasks.length - 1) const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(
    String task, {
    required String svgPath,
    required VoidCallback onTap,
  }) {
    if (task.isEmpty) return const SizedBox.shrink();
    final bool isRemoteSwitchOff = !_remoteSwitch.value;
    return Container(
      width: double.infinity, // 拉满父容器宽度
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF9FAFB), width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              task,
              style: TextStyle(
                color: isRemoteSwitchOff ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Alibaba PuHuiTi 3.0',
                height: 1.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          GestureDetector(
            onTap: isRemoteSwitchOff
                ? null
                : () async {
                    final confirmed = await context.showDeleteConfirmation(
                      title: '删除任务',
                      content: '确定要删除该任务吗？删除后无法恢复。',
                    );
                    if (confirmed) {
                      onTap();
                    }
                  },
            child: SvgPicture.asset(
              svgPath,
              width: 20,
              height: 20,
              color: isRemoteSwitchOff ? const Color(0xFFD1D5DB) : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建定位模式选择器视图
  Widget _buildPositioningModeSelectorView() {
    return Container(
      color: Global.currentTheme.backgroundColor, // 浅灰色背景
      child: Column(
        children: [
          // 头部区域
          _buildHeader(),
          // 定位模式选择器内容
          Expanded(
            child: PositioningModeSelector(
              deviceId: _currentDeviceId ?? '',
              initialMode: PositioningMode.normal,
              onModeChanged: (mode) {
                // 处理模式变更
                print('选择了定位模式: $mode');
              },
              onCancel: () {
                _backToDeviceList();
              },
              onConfirm: () {
                Get.snackbar(
                  '设置成功',
                  '定位模式已更新',
                  backgroundColor: Global.currentTheme.primaryColor.withOpacity(
                    0.1,
                  ),
                  colorText: Global.currentTheme.primaryColor,
                  duration: const Duration(seconds: 2),
                );
                _backToDeviceList();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Global.currentTheme.backgroundColor),
      child: Row(
        children: [
          GestureDetector(
            onTap: _backToDeviceList,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Global.currentTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '定位模式设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Global.currentTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 设备列表状态下的添加设备按钮（示例，实际请根据UI放置位置调整）
  Widget _buildAddDeviceButton() {
    return ElevatedButton.icon(
      onPressed: () {
        _showAddDeviceView.value = true;
      },
      icon: const Icon(Icons.add),
      label: const Text('添加设备'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Global.currentTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 格式化最后活跃时间
  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return '刚刚更新';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前更新';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前更新';
    } else {
      return '${difference.inDays}天前更新';
    }
  }

  /// 获取信号强度
  String _getSignalStrength(DeviceModel device) {
    // 从设备属性中获取信号强度，如果没有则返回默认值
    if (device.properties != null &&
        device.properties!.containsKey('signalStrength')) {
      return '${device.properties!['signalStrength']}%';
    }
    return '85%'; // 默认值
  }

  /// 获取信号颜色
  Color _getSignalColor(DeviceModel device) {
    int strength = 85; // 默认值
    if (device.properties != null &&
        device.properties!.containsKey('signalStrength')) {
      strength = device.properties!['signalStrength'] as int;
    }

    if (strength > 70) {
      return Colors.green;
    } else if (strength > 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 获取电池图标
  IconData _getBatteryIcon(DeviceModel device) {
    int level = 80; // 默认值
    if (device.properties != null &&
        device.properties!.containsKey('batteryLevel')) {
      level = device.properties!['batteryLevel'] as int;
    }
    // 60以上满，20-60三格，20及以下警告
    if (level > 60) {
      return Icons.battery_full;
    } else if (level > 20) {
      return Icons.battery_3_bar;
    } else {
      return Icons.battery_alert;
    }
  }

  /// 获取电池颜色
  Color _getBatteryColor(DeviceModel device) {
    int level = 80; // 默认值
    if (device.properties != null &&
        device.properties!.containsKey('batteryLevel')) {
      level = device.properties!['batteryLevel'] as int;
    }
    // 60以上绿色，20-60黄色，20及以下红色
    if (level > 60) {
      return Colors.green;
    } else if (level > 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 获取电池电量
  String _getBatteryLevel(DeviceModel device) {
    // 从设备属性中获取电池电量，如果没有则返回默认值
    if (device.properties != null &&
        device.properties!.containsKey('batteryLevel')) {
      return '${device.properties!['batteryLevel']}%';
    }
    return '80%'; // 默认值
  }

  /// 获取设备位置信息
  Future<String> _getDeviceLocation(DeviceModel device) async {
    try {
      // 如果设备属性中已有位置信息，直接使用
      if (device.properties != null &&
          device.properties!.containsKey('latitude') &&
          device.properties!.containsKey('longitude')) {
        double lat = device.properties!['latitude'];
        double lng = device.properties!['longitude'];
        return await _getAddressFromCoordinates(lat, lng);
      }

      // 如果是宠物定位器类型，尝试获取当前位置
      if (device.type == DeviceType.petTracker) {
        // 检查位置权限
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return '位置服务未开启';
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return '位置权限被拒绝';
          }
        }

        if (permission == LocationPermission.deniedForever) {
          return '位置权限被永久拒绝';
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        return await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }

      // 默认返回描述或固定位置
      return device.description ?? '深圳市万象城-B1层宠物区';
    } catch (e) {
      print('获取位置失败: $e');
      return '获取位置失败';
    }
  }

  /// 根据坐标获取地址
  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality ?? ''} ${place.subLocality ?? ''} ${place.street ?? ''}';
      } else {
        return '无法获取地址信息';
      }
    } catch (e) {
      print('获取地址失败: $e');
      return '地址解析失败';
    }
  }

  /// 设备断开提示
  Widget _buildDeviceDisconnectedBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xE6F59E0B), // #F59E0B, 90%不透明
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 12, right: 19.82, top: 12, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 18.11,
            height: 40,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 0, bottom: 0),
            child: SvgPicture.asset(
              'imgs/device_disconnect_icon.svg',
              width: 18.11,
              height: 18.11,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '设备已断开，部分功能不可用。请检查网络连接后重试。',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Alibaba PuHuiTi 3.0',
                fontWeight: FontWeight.w400,
                height: 20 / 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

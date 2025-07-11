import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/Global.dart';
import '../controllers/user_controller.dart';
import '../states/user_state.dart';
import '../states/state_manager.dart';
import 'app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  // 模拟用户数据
  final Map<String, dynamic> _userInfo = {
    'name': '武安',
    'avatar': '', // 存储选择的头像路径
    'phone': '18899996666',
    'email': 'user@example.com',
    'level': 'VIP',
    'joinDate': '2024-01-15',
  };

  // 预设头像选项
  final List<Map<String, dynamic>> _presetAvatars = [
    {'type': 'icon', 'data': Icons.person, 'color': Colors.blue},
    {'type': 'icon', 'data': Icons.face, 'color': Colors.green},
    {
      'type': 'icon',
      'data': Icons.sentiment_very_satisfied,
      'color': Colors.orange,
    },
    {'type': 'icon', 'data': Icons.pets, 'color': Colors.purple},
    {'type': 'icon', 'data': Icons.favorite, 'color': Colors.red},
    {'type': 'icon', 'data': Icons.star, 'color': Colors.amber},
  ];

  // 新增：帮助中心状态
  bool _showHelpFaq = false;

  @override
  void initState() {
    super.initState();
    // 页面初始化时同步UserModel.avatarUrl到UserState，保证重启后头像能恢复
    final userController = Get.find<UserController>();
    if (userController.user != null &&
        userController.user!.avatarUrl.isNotEmpty) {
      Global.userState.updateAvatar(userController.user!.avatarUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StateConsumer<UserState>(
      state: Global.userState,
      builder: (context, userState) {
        return Scaffold(
          backgroundColor: Global.currentTheme.backgroundColor,
          body: _showHelpFaq
              ? _buildHelpFaqWidget()
              : Column(
                  children: [
                    _buildUserInfoSection(),
                    Expanded(child: _buildServicesSection()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildUserInfoSection() {
    // 顶部用户信息区域，完全还原设计稿
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0C1E),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // 顶部标题栏
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 头像（可点击修改）
                GestureDetector(
                  onTap: _showAvatarPicker, // 点击头像选择图片
                  child: _buildAvatarWidget(),
                ),
                const SizedBox(width: 16),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 28,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            Global.userName.isNotEmpty
                                ? Global.userName
                                : (Global.userInfo['phone'] != null && Global.userInfo['phone'].toString().length >= 4
                                    ? '手机用户${Global.userInfo['phone'].toString().substring(Global.userInfo['phone'].toString().length - 4)}'
                                    : '手机用户'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '手机: ' + (Global.userInfo['phone'] ?? ''),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontFamily: 'Noto Sans',
                              fontSize: 14,
                              height: 1.43,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建头像显示组件，优先显示本地头像路径，保证正圆
  Widget _buildAvatarWidget() {
    final avatarPath = Global.userInfo['avatar'] ?? '';
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          avatarPath.isNotEmpty && File(avatarPath).existsSync()
              ? Image.file(
                File(avatarPath),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              )
              : Image.asset(
                'imgs/user_avatar.jpeg',
                fit: BoxFit.cover,
                width: 64,
                height: 64,
              ),
    );
  }

  // 点击头像时显示选择器
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '选择头像',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: Color(0xFF3B82F6),
                  ),
                  title: const Text('拍照'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar(ImageSource.camera);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF3B82F6),
                  ),
                  title: const Text('从相册选择'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // 选择头像（拍照或从相册）
  Future<void> _pickAvatar(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512, // 限制图片最大宽度
      maxHeight: 512, // 限制图片最大高度
      imageQuality: 85, // 图片质量 (0-100)
    );

    if (image != null) {
      // 1. 更新UserState
      Global.userState.updateAvatar(image.path);

      // 2. 更新UserModel并持久化
      final userController = Get.find<UserController>();
      if (userController.user != null) {
        final updated = userController.user!.copyWith(avatarUrl: image.path);
        await userController.repository.saveUser(updated);
        userController.update();
      }

      // 3. 强制刷新UI
      setState(() {});

      // 4. 通知所有页面刷新
      Get.forceAppUpdate();

      Get.snackbar('成功', '头像已更新');
    }
  }

  Widget _buildServicesSection() {
    // 服务区域，完全还原设计稿
    return Container(
      color: const Color(0xFF0A0C1E),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 0),
      child: Column(
        children: [
          // 服务卡片
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '服务',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // 流量充值服务
                Row(
                  children: [
                    GestureDetector(
                      onTap: _navigateToDataRecharge,
                      child: Container(
                        width: 81,
                        height: 73,
                        padding: const EdgeInsets.fromLTRB(18, 10, 15, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.transparent,
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'imgs/service_recharge.svg',
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '流量充值',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontSize: 12,
                                height: 1.66,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 个人信息卡片
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 8, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '个人信息',
                  style: TextStyle(
                    color: Color(0xFFEDEEF0),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                // 个人账号
                GestureDetector(
                  onTap: _showPersonalAccountPage,
                  child: Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 13),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0x4DF3F3F6), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x4D3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'imgs/account_icon.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '个人账号',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '管理您的个人资料和隐私设置',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  height: 1.33,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SvgPicture.asset(
                          'imgs/arrow_right_1.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // 生成间距
                SizedBox(height: 10),
                // 帮助中心
                GestureDetector(
                  onTap: _showHelpCenter,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x4D22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'imgs/help_center_icon.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '帮助中心',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '常见问题解答和客户支持',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SvgPicture.asset(
                        'imgs/arrow_right_2.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 退出登录按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20, top: 36),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF1A73E8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _showLogoutDialog,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Center(
                    child: Text(
                      '退出登录',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示个人账号页面
  void _showPersonalAccountPage() {
    Get.to(() => PersonalAccountPage(userInfo: _userInfo));
  }

  // 跳转到流量充值页面
  void _navigateToDataRecharge() {
    Get.toNamed(AppRoutes.dataRecharge);
  }

  void _showHelpCenter() {
    setState(() {
      _showHelpFaq = true;
    });
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 64, color: Color(0xFF6B4DFF)),
              const SizedBox(height: 16),
              const Text(
                '确认退出',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '确定要退出当前账号吗？',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed('/login'); // 退出到登录页
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4DFF),
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 帮助中心FAQ Widget
  Widget _buildHelpFaqWidget() {
    return Container(
      color: const Color(0xFF0A101E),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showHelpFaq = false),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '常见问题',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // FAQ 列表
          _buildFaqItem(
            '无法添加设备，怎么办？',
            'imgs/faq_arrow2.svg',
            onTap: () {
              Get.toNamed(AppRoutes.faqHelpAddDevice);
            },
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            '不小心删除了设备应该怎么添加回来？',
            'imgs/faq_arrow2.svg',
            onTap: () {
              Get.toNamed(AppRoutes.faqHelpDeletedDevice);
            },
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            'wifi无法连接成功是什么原因？',
            'imgs/faq_arrow2.svg',
            onTap: () {
              Get.toNamed(AppRoutes.faqHelpWifi);
            },
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            '如何更新设备固件？',
            'imgs/faq_arrow2.svg',
            onTap: () {
              Get.toNamed(AppRoutes.faqHelpFirmware);
            },
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            '设备定位不准确怎么解决？',
            'imgs/faq_arrow2.svg',
            onTap: () {
              Get.toNamed(AppRoutes.faqHelpLocation);
            },
          ),
          const Spacer(),
          // 人工客服按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _showCustomerServiceDialog, // 修改为弹窗
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      '人工客服',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String title, String iconPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.43,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),
            SvgPicture.asset(iconPath, width: 16, height: 16),
          ],
        ),
      ),
    );
  }

  // 显示人工客服电话弹窗
  void _showCustomerServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 白底弹窗
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('人工客服电话', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          content: const Text('18866668888', style: TextStyle(fontSize: 18, color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                const phone = '18866668888';
                final uri = Uri(scheme: 'tel', path: phone);
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('当前设备不支持拨号功能或未授权')),
                    );
                  }
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('拨号失败: ${e.toString()}')),
                  );
                }
              },
              child: const Text('拨打电话', style: TextStyle(color: Color(0xFF3B82F6))),
            ),
          ],
        );
      },
    );
  }
}

// 个人账号页面
class PersonalAccountPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const PersonalAccountPage({super.key, required this.userInfo});

  @override
  State<PersonalAccountPage> createState() => _PersonalAccountPageState();
}

class _PersonalAccountPageState extends State<PersonalAccountPage> {
  late Map<String, dynamic> _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = Map.from(widget.userInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Global.currentTheme.backgroundColor,
        title: const Text('个人信息', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: Global.currentTheme.backgroundColor),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoItem(
                        title: '头像',
                        content: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildAvatarInAccountPage(),
                        ),
                        onTap: () {
                          _showAvatarPickerOptions(context);
                        },
                      ),
                      Divider(color: Colors.grey.shade300, height: 20),
                      _buildInfoItem(
                        title: '昵称',
                        content: Text(
                          Global.userName.isNotEmpty
                              ? Global.userName
                              : (_userInfo['name'] ?? ''),
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          final controller = TextEditingController(
                            text: Global.userName.isNotEmpty
                                ? Global.userName
                                : (Global.userInfo['phone'] != null && Global.userInfo['phone'].toString().length >= 4
                                    ? '手机用户${Global.userInfo['phone'].toString().substring(Global.userInfo['phone'].toString().length - 4)}'
                                    : '手机用户'),
                          );
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  width: 350,
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    16,
                                    20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // const SizedBox(width: 123.5),
                                          const Text(
                                            '修改昵称',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              height: 1.5,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: SvgPicture.asset(
                                              'imgs/settings_close.svg',
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 8,
                                          right: 4,
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          0,
                                          12,
                                          0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: controller,
                                                decoration:
                                                    const InputDecoration(
                                                      hintText: '请输入新昵称',
                                                      border: InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      counterText: '',
                                                    ),
                                                maxLength: 30,
                                                style: const TextStyle(
                                                  color: Color(0xFF1F2937),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => controller.clear(),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF9CA3AF),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    'imgs/clear_input.svg',
                                                    color: Colors.white,
                                                    width: 12,
                                                    height: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        '昵称限制1-30个字符。',
                                        style: TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final newName =
                                              controller.text.trim();
                                          if (newName.isEmpty) {
                                            Get.snackbar(
                                              '错误',
                                              '昵称不能为空',
                                              backgroundColor:
                                                  Colors.red.shade100,
                                              colorText: Colors.red,
                                            );
                                            return;
                                          }
                                          Global.userState.updateUserName(
                                            newName,
                                          );
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            top: 8,
                                            right: 4,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '保存',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Divider(color: Colors.grey.shade300, height: 20),
                      _buildInfoItem(
                        title: '手机',
                        content: Text(
                          Global.userInfo['phone'] ??
                              (_userInfo['phone'] ?? ''),
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Get.snackbar('提示', '手机号修改功能开发中...');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 始终读取全局UserState中的头像路径，保证与主页面一致，显示方式完全统一
  Widget _buildAvatarInAccountPage() {
    final avatarPath = Global.userInfo['avatar'] ?? '';
    return avatarPath.isNotEmpty && File(avatarPath).existsSync()
        ? Image.file(File(avatarPath), width: 40, height: 40, fit: BoxFit.cover)
        : Image.asset(
          'imgs/user_avatar.jpeg',
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        );
  }

  Widget _buildInfoItem({
    required String title,
    required Widget content,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中
          children: [
            SizedBox(
              width: 60,
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft, // 靠左垂直居中
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.left, // 左对齐
                ),
              ),
            ),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: content),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // 显示头像选择器选项（拍照或相册）
  void _showAvatarPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '选择头像',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: Color(0xFF3B82F6),
                  ),
                  title: const Text('拍照'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar(ImageSource.camera);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF3B82F6),
                  ),
                  title: const Text('从相册选择'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // 选择头像（拍照或从相册）
  Future<void> _pickAvatar(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512, // 限制图片最大宽度
      maxHeight: 512, // 限制图片最大高度
      imageQuality: 85, // 图片质量 (0-100)
    );

    if (image != null) {
      // 1. 更新UserState
      Global.userState.updateAvatar(image.path);

      // 2. 更新UserModel并持久化
      final userController = Get.find<UserController>();
      if (userController.user != null) {
        final updated = userController.user!.copyWith(avatarUrl: image.path);
        await userController.repository.saveUser(updated);
        userController.update();
      }

      // 3. 强制刷新UI
      setState(() {});

      // 4. 通知所有页面刷新
      Get.forceAppUpdate();

      Get.snackbar('成功', '头像已更新');
    }
  }
}

// 新增：miaoduo帮助详情弹窗组件
class _FaqHelpDetailDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 29, 0),
                child: Text(
                  '无法添加设备，怎么办？',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 29, 0),
                child: Text(
                  '当您在使用我们的宠物定位器时，如果遇到无法添加设备的问题，请按照以下步骤进行排查和解决。',
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 解决方案
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Text(
                      '解决方案',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              // 步骤1
              _FaqStepItem(
                index: 1,
                title: '检查设备电量',
                content: '确保设备电量充足。如果电量过低，请先为设备充电至少10分钟后再尝试添加。',
                tip: '提示：设备指示灯呈红色闪烁表示电量不足，请立即充电。',
              ),
              // 步骤2
              _FaqStepItem(
                index: 2,
                title: '确认设备处于配对模式',
                content: '长按设备电源键5秒，直到指示灯呈蓝色快速闪烁，表示设备已进入配对模式。',
                tip: '如果设备无法进入配对模式，请尝试重置设备：同时按住电源键和复位键10秒。',
              ),
              // 步骤3
              _FaqStepItem(
                index: 3,
                title: '检查网络连接',
                content: '确保您的手机已连接到2.4GHz的WiFi网络。本设备不支持5GHz网络连接。',
              ),
              // 步骤4
              _FaqStepItem(
                index: 4,
                title: '重启应用并重新尝试',
                content: '完全关闭应用后重新打开，然后点击"添加设备"按钮，按照屏幕提示操作。',
              ),
              const SizedBox(height: 20),
              // 问题是否已解决
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '问题是否已解决？',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'imgs/faq_yes.svg',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '是',
                              style: TextStyle(color: Color(0xFF3B82F6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'imgs/faq_no.svg',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '否',
                              style: TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 相关问题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '相关问题',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _FaqRelatedItem('不小心删除了设备应该怎么添加回来？'),
                    const SizedBox(height: 8),
                    _FaqRelatedItem('wifi无法连接成功是什么原因？'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 联系人工客服
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // TODO: 跳转客服
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '联系人工客服',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 步骤组件
class _FaqStepItem extends StatelessWidget {
  final int index;
  final String title;
  final String content;
  final String? tip;
  const _FaqStepItem({
    required this.index,
    required this.title,
    required this.content,
    this.tip,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              content,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          if (tip != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  tip!,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// 相关问题组件
class _FaqRelatedItem extends StatelessWidget {
  final String title;
  const _FaqRelatedItem(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}

// 新增：miaoduo帮助详情新页面
class FaqHelpDetailPage extends StatelessWidget {
  const FaqHelpDetailPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A101E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部返回和标题
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '常见问题',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 内容卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 29, 20.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '无法添加设备，怎么办？',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '当您在使用我们的宠物定位器时，如果遇到无法添加设备的问题，请按照以下步骤进行排查和解决。',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 解决方案卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.only(right: 20, bottom: 28.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          const Text(
                            '解决方案',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      _FaqStepItem(
                        index: 1,
                        title: '检查设备电量',
                        content: '确保设备电量充足。如果电量过低，请先为设备充电至少10分钟后再尝试添加。',
                        tip: '提示：设备指示灯呈红色闪烁表示电量不足，请立即充电。',
                      ),
                      _FaqStepItem(
                        index: 2,
                        title: '确认设备处于配对模式',
                        content: '长按设备电源键5秒，直到指示灯呈蓝色快速闪烁，表示设备已进入配对模式。',
                        tip: '如果设备无法进入配对模式，请尝试重置设备：同时按住电源键和复位键10秒。',
                      ),
                      _FaqStepItem(
                        index: 3,
                        title: '检查网络连接',
                        content: '确保您的手机已连接到2.4GHz的WiFi网络。本设备不支持5GHz网络连接。',
                      ),
                      _FaqStepItem(
                        index: 4,
                        title: '重启应用并重新尝试',
                        content: '完全关闭应用后重新打开，然后点击"添加设备"按钮，按照屏幕提示操作。',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 问题是否已解决
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '问题是否已解决？',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF3B82F6),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'imgs/faq_yes.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '是',
                                    style: TextStyle(color: Color(0xFF3B82F6)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'imgs/faq_no.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '否',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 相关问题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '相关问题',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      _FaqRelatedItem('不小心删除了设备应该怎么添加回来？'),
                      SizedBox(height: 8),
                      _FaqRelatedItem('wifi无法连接成功是什么原因？'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 联系人工客服
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            '联系人工客服',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_rec/routes/app_routes.dart';
import 'package:test_rec/widgets/agreement_dialog.dart';
import 'package:test_rec/widgets/center_popup.dart';
import 'package:test_rec/controllers/user_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  Timer? _timer;
  bool _isButtonDisabled = false;
  int _countdown = 30;
  bool _isAgreementChecked = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _sendVerificationCode() {
    final String phone = _phoneController.text;
    if (phone.isEmpty) {
      CenterPopup.show(context, '请输入手机号码');
      return;
    }

    // 简单的手机号格式验证
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      CenterPopup.show(context, '手机号码格式错误');
      return;
    }

    // TODO: 在此处调用发送验证码的API
    // 例如: await ApiService.sendCode(phone);

    CenterPopup.show(context, '验证码已发送至 $phone');

    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _isButtonDisabled = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
            _isButtonDisabled = false;
            _countdown = 30;
          }
        });
      }
    });
  }

  void _login() {
    if (!_isAgreementChecked) {
      AgreementDialog.show(
        context,
        onAgree: () {
          setState(() {
            _isAgreementChecked = true;
          });
          // 同意后自动执行登录逻辑
          _performLogin();
        },
        onCancel: () {
          // 取消操作，不做任何处理
        },
      );
      return;
    }

    _performLogin();
  }

  void _performLogin() async {
    final String phone = _phoneController.text;
    final String code = _codeController.text;

    if (phone.isEmpty) {
      CenterPopup.show(context, '请输入手机号');
      return;
    }

    if (code.isEmpty) {
      CenterPopup.show(context, '请输入验证码');
      return;
    }

    // 调用UserController登录
    final userController = Get.find<UserController>();
    bool success = await userController.login(phone, code);
    if (success) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      CenterPopup.show(context, '手机号或验证码错误');
    }
  }

  void _showAgreementDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('用户协议和隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '这里是用户协议和隐私政策的详细内容...\n\n'
            '1. 导言\n'
            '欢迎您使用我们的服务！我们深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠...\n\n'
            '2. 信息的收集和使用\n'
            '为了向您提供更好的服务，我们会收集和使用您的相关信息...\n\n'
            '3. 信息的共享、转让、公开披露\n'
            '我们不会与任何公司、组织和个人分享您的个人信息，除非获得您的明确同意...\n\n'
            '请仔细阅读并理解本《用户协议》和《隐私政策》。',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('关闭')),
          TextButton(
            onPressed: () {
              setState(() {
                _isAgreementChecked = true;
              });
              Get.back();
            },
            child: const Text('同意'),
          ),
        ],
      ),
    );
  }

  void _loginWithWeChat() {
    // TODO: 实现微信登录逻辑
    CenterPopup.show(context, '调用微信登录');
  }

  void _loginWithQQ() {
    // TODO: 实现QQ登录逻辑
    CenterPopup.show(context, '调用QQ登录');
  }

  void _loginWithWeibo() {
    // TODO: 实现抖音登录逻辑
    CenterPopup.show(context, '调用抖音登录');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('imgs/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const Spacer(flex: 1),
                _buildLoginForm(context),
                const Spacer(flex: 2),
                // 暂时取消第三方登录
                // _buildThirdPartyLogin(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset('imgs/login_icon.png', width: 120);
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              '短信登录/注册',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.center,
            child: Text(
              '未注册的手机号将自动注册',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _phoneController,
            hintText: '请输入手机号码',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildVerificationCodeField(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 16),
          _buildAgreement(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildVerificationCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '请输入验证码',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8, // 减小垂直内边距以降低整体高度
              ),
              suffixIcon: ElevatedButton(
                onPressed: _isButtonDisabled ? null : _sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6a4dff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2, // 进一步减小垂直内边距以匹配输入框高度
                  ),
                ),
                child: Text(
                  _isButtonDisabled ? '$_countdown秒后重发' : '发送验证码',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff6a4dff),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        '登录',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAgreement() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: _isAgreementChecked,
          onChanged: (bool? value) {
            setState(() {
              _isAgreementChecked = value ?? false;
            });
          },
        ),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[600]),
              children: [
                const TextSpan(text: '我已阅读并同意'),
                TextSpan(
                  text: '《用户协议》',
                  style: const TextStyle(color: Colors.blue),
                  recognizer:
                      TapGestureRecognizer()..onTap = _showAgreementDialog,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThirdPartyLogin() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(indent: 40, endIndent: 20)),
            Text('第三方登录', style: TextStyle(color: Colors.white70)),
            Expanded(child: Divider(indent: 20, endIndent: 40)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon('imgs/wechat_icon.png', '微信', _loginWithWeChat),
            const SizedBox(width: 40),
            _buildSocialIcon('imgs/qq_icon.png', 'QQ', _loginWithQQ),
            const SizedBox(width: 40),
            _buildSocialIcon('imgs/tiktok_icon.png', '抖音', _loginWithWeibo),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(iconPath, width: 48, height: 48),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

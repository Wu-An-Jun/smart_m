import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataRechargePage extends StatefulWidget {
  const DataRechargePage({super.key});

  @override
  State<DataRechargePage> createState() => _DataRechargePageState();
}

class _DataRechargePageState extends State<DataRechargePage> {
  String selectedPackage = '100G';
  double selectedPrice = 95.0;
  final TextEditingController _simCardController = TextEditingController();
  static const String _simCardKey = 'sim_card_number';

  final List<DataPackage> packages = [
    DataPackage(
      data: '100G',
      price: 95.0,
      isRecommended: true,
      isSelected: true,
    ),
    DataPackage(data: '50G', price: 60.0, isRecommended: true),
    DataPackage(data: '30G', price: 30.25),
    DataPackage(data: '25G', price: 25.0),
    DataPackage(data: '10G', price: 18.0),
    DataPackage(data: '3G', price: 10.0),
  ];

  @override
  void initState() {
    super.initState();
    _loadSimCardNumber();
  }

  Future<void> _loadSimCardNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final simCard = prefs.getString(_simCardKey) ?? '3000 **** 9910';
    _simCardController.text = simCard;
  }

  Future<void> _saveSimCardNumber(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_simCardKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '流量充值',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSimCardInfo(),
            const SizedBox(height: 24),
            _buildPackageSelection(),
            const SizedBox(height: 32),
            _buildPaymentInfo(),
            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimCardInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: _simCardController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              onChanged: (value) {
                _saveSimCardNumber(value);
              },
            ),
          ),
          Text('流量卡号', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPackageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择流量套餐',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            final isSelected = package.data == selectedPackage;

            return GestureDetector(
              onTap: () => _selectPackage(package),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A73E8) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF1A73E8)
                            : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: const Color(0xFF1A73E8).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            package.data,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF1A73E8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '售价: ${package.price.toStringAsFixed(package.price == package.price.round() ? 0 : 2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (package.isRecommended)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9500),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '推荐',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '套餐',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                selectedPackage,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '应付金额',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '¥${selectedPrice.toStringAsFixed(selectedPrice == selectedPrice.round() ? 0 : 2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF9500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmRecharge,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          '确认充值',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _selectPackage(DataPackage package) {
    // 添加触觉反馈
    HapticFeedback.lightImpact();

    setState(() {
      // 清除所有选中状态
      for (var pkg in packages) {
        pkg.isSelected = false;
      }
      // 设置新选中的套餐
      package.isSelected = true;
      selectedPackage = package.data;
      selectedPrice = package.price;
    });
  }

  void _confirmRecharge() {
    // 添加触觉反馈
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            '确认充值',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('流量卡号: 3000 **** 9910'),
              const SizedBox(height: 8),
              Text('充值套餐: $selectedPackage'),
              const SizedBox(height: 8),
              Text(
                '支付金额: ¥${selectedPrice.toStringAsFixed(selectedPrice == selectedPrice.round() ? 0 : 2)}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('确认支付'),
            ),
          ],
        );
      },
    );
  }

  void _processPayment() {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在处理支付...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    // 模拟支付处理
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // 关闭加载对话框

      // 显示成功对话框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                const SizedBox(width: 8),
                const Text(
                  '充值成功',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('恭喜您！流量充值已成功完成。'),
                const SizedBox(height: 8),
                Text('充值套餐: $selectedPackage'),
                const SizedBox(height: 4),
                Text(
                  '支付金额: ¥${selectedPrice.toStringAsFixed(selectedPrice == selectedPrice.round() ? 0 : 2)}',
                ),
                const SizedBox(height: 8),
                Text(
                  '流量将在5分钟内到账，请耐心等待。',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 关闭成功对话框
                  Navigator.pop(context); // 返回上一页
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('完成'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _simCardController.dispose();
    super.dispose();
  }
}

class DataPackage {
  final String data;
  final double price;
  final bool isRecommended;
  bool isSelected;

  DataPackage({
    required this.data,
    required this.price,
    this.isRecommended = false,
    this.isSelected = false,
  });
}

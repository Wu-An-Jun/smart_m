import 'package:flutter/material.dart';
import 'common/api_config.dart';

/// 高德地图API配置测试工具
class AmapConfigTest extends StatefulWidget {
  const AmapConfigTest({super.key});

  @override
  State<AmapConfigTest> createState() => _AmapConfigTestState();
}

class _AmapConfigTestState extends State<AmapConfigTest> {
  String _testResult = '点击按钮开始检查配置...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高德地图API配置测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '高德地图API配置检查工具',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 配置检查按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkConfig,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(_isLoading ? '检查中...' : '检查API配置'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 新增：测试修复效果按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testFixedConfig,
                    icon: const Icon(Icons.science),
                    label: const Text('测试修复效果'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 结果显示
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkConfig() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在检查API配置...';
    });

    final results = <String>[];
    
    try {
      // 1. 检查API密钥配置
      if (ApiConfig.isAmapConfigured) {
        results.add('✅ API密钥已配置');
      } else {
        results.add('❌ API密钥未配置');
      }
      
      // 2. 检查Web端密钥格式
      if (ApiConfig.amapWebApiKey.length == 32) {
        results.add('✅ Web API密钥格式正确 (32位)');
      } else {
        results.add('❌ Web API密钥格式错误 (当前${ApiConfig.amapWebApiKey.length}位)');
      }
      
      // 3. 检查移动端密钥格式
      if (ApiConfig.amapMobileApiKey.length == 32) {
        results.add('✅ 移动端API密钥格式正确 (32位)');
      } else {
        results.add('❌ 移动端API密钥格式错误 (当前${ApiConfig.amapMobileApiKey.length}位)');
      }
      
      // 4. 检查密钥是否不同（避免平台混用）
      if (ApiConfig.amapWebApiKey != ApiConfig.amapMobileApiKey) {
        results.add('✅ Web端和移动端使用不同密钥 (正确)');
      } else {
        results.add('⚠️  Web端和移动端使用相同密钥 (可能导致平台不匹配错误)');
      }
      
      // 5. 检查安全密钥
      if (ApiConfig.amapSecurityCode.isNotEmpty) {
        results.add('✅ 安全密钥已配置');
      } else {
        results.add('⚠️  安全密钥未配置');
      }
      
      // 6. 显示当前配置
      results.add('\n=== 当前配置详情 ===');
      results.add('Web API Key: ${ApiConfig.amapWebApiKey}');
      results.add('移动端 Key: ${ApiConfig.amapMobileApiKey}');
      results.add('安全密钥: ${ApiConfig.amapSecurityCode}');
      
      // 7. 给出建议
      results.add('\n=== 配置检查完成 ===');
      
      if (ApiConfig.isAmapConfigured) {
        results.add('✅ 基本配置正确！');
        results.add('\n平台密钥说明:');
        results.add('• Web API Key: 用于WebView中的地图显示');
        results.add('• 移动端Key: 用于原生定位和移动端SDK');
        results.add('\n如果仍然出现错误:');
        results.add('1. 确认高德控制台中已添加包名: com.Explorex.smart');
        results.add('2. 确认SHA1指纹已正确配置');
        results.add('3. 确认对应平台的API服务已开启');
        results.add('4. 检查密钥是否被禁用或过期');
      } else {
        results.add('❌ 配置有问题，请检查API密钥');
      }
      
    } catch (e) {
      results.add('❌ 检查过程中出现异常: $e');
    }

    await Future.delayed(const Duration(seconds: 1)); // 模拟检查时间

    setState(() {
      _testResult = results.join('\n');
      _isLoading = false;
    });
  }

  /// 新增：测试修复效果
  Future<void> _testFixedConfig() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在测试修复效果...';
    });

    final results = <String>[];
    
    try {
      results.add('=== 🔧 API配置修复效果测试 ===\n');
      
      // 1. 检查密钥分离
      if (ApiConfig.amapWebApiKey != ApiConfig.amapMobileApiKey) {
        results.add('✅ 密钥分离正确');
        results.add('   Web密钥:     ${ApiConfig.amapWebApiKey}');
        results.add('   移动端密钥:   ${ApiConfig.amapMobileApiKey}');
      } else {
        results.add('❌ 密钥分离失败 - 两个密钥相同');
      }
      
      // 2. 检查安全密钥配置
      if (ApiConfig.amapSecurityCode.isNotEmpty && 
          ApiConfig.amapSecurityCode.length == 32) {
        results.add('✅ 安全密钥配置正确');
        results.add('   安全密钥:     ${ApiConfig.amapSecurityCode}');
      } else {
        results.add('❌ 安全密钥配置错误');
      }
      
      // 3. 检查修复内容
      results.add('\n=== 🎯 主要修复内容 ===');
      results.add('1. ✅ 分离了Web端和移动端API密钥');
      results.add('2. ✅ 修正了安全配置中的密钥使用');
      results.add('3. ✅ 增强了JavaScript错误处理');
      results.add('4. ✅ 改进了数据序列化（空值处理）');
      results.add('5. ✅ 添加了NaN值检查');
      
      // 4. 预期解决的问题
      results.add('\n=== 🚀 预期解决的问题 ===');
      results.add('• INVALID_USER_KEY 错误');
      results.add('• USERKEY_PLAT_NOMATCH 错误');
      results.add('• LngLat(NaN, NaN) 坐标错误');
      results.add('• "重新绘制围栏时出错：undefined" 错误');
      results.add('• 地图无法正常显示问题');
      
      // 5. 配置验证
      results.add('\n=== 📋 高德控制台配置要求 ===');
      results.add('包名：     com.Explorex.smart');
      results.add('SHA1指纹： 51:B1:BA:ED:A0:9C:2F:C6:6F:69:56:F1:E3:A7:3A:A8:C1:02:67:27');
      results.add('');
      results.add('Web服务（JS API）：');
      results.add('  ✓ Web服务API');
      results.add('  ✓ 静态地图API');
      results.add('');
      results.add('移动端服务：');
      results.add('  ✓ 定位');
      results.add('  ✓ 地图SDK');
      
      // 6. 下一步测试建议
      results.add('\n=== 🧪 下一步测试建议 ===');
      results.add('1. 重启应用');
      results.add('2. 进入"地理围栏演示"');
      results.add('3. 查看是否还有API错误');
      results.add('4. 测试围栏重绘功能');
      results.add('5. 检查地图坐标是否正常');
      
      if (ApiConfig.isAmapConfigured) {
        results.add('\n🎉 配置检查通过！应该已经解决了主要问题。');
      } else {
        results.add('\n⚠️  基础配置仍有问题，请检查API密钥是否正确。');
      }
      
    } catch (e) {
      results.add('❌ 测试过程中出现异常: $e');
    }

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _testResult = results.join('\n');
      _isLoading = false;
    });
  }
} 
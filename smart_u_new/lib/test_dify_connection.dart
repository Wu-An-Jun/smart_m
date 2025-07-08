import 'package:flutter/material.dart';
import 'common/dify_ai_service.dart';

void main() {
  runApp(const TestDifyApp());
}

class TestDifyApp extends StatelessWidget {
  const TestDifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dify AI 连接测试',
      home: const TestDifyPage(),
    );
  }
}

class TestDifyPage extends StatefulWidget {
  const TestDifyPage({super.key});

  @override
  State<TestDifyPage> createState() => _TestDifyPageState();
}

class _TestDifyPageState extends State<TestDifyPage> {
  final DifyAiService _aiService = DifyAiService();
  String _result = '准备测试...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dify AI 连接测试'),
        backgroundColor: const Color(0xFF6B4DFF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '测试 Dify AI 服务连接',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4DFF),
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('测试中...'),
                    ],
                  )
                : const Text('开始测试连接'),
            ),
            const SizedBox(height: 24),
            const Text(
              '测试结果:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = '正在测试连接...';
    });

    try {
      bool isFirstChunk = true;
      await for (final chunk in _aiService.sendMessageStream('你好，请简单介绍一下自己')) {
        if (isFirstChunk) {
          setState(() {
            _result = '✅ 连接成功！开始接收流式回复...\n\n';
          });
          isFirstChunk = false;
        }
        
        setState(() {
          _result = '✅ 连接成功！正在接收流式回复...\n\nAI 回复：\n$chunk';
        });
      }
      
      setState(() {
        _isLoading = false;
        _result = _result.replaceFirst('正在接收流式回复...', '流式回复完成！');
      });
    } catch (e) {
      setState(() {
        _result = '❌ 连接失败：\n$e';
        _isLoading = false;
      });
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'common/voice_input_service.dart';

/// 语音输入功能演示页面
/// 演示如何使用新的Dify语音转文字功能
class VoiceInputDemoPage extends StatefulWidget {
  const VoiceInputDemoPage({super.key});

  @override
  State<VoiceInputDemoPage> createState() => _VoiceInputDemoPageState();
}

class _VoiceInputDemoPageState extends State<VoiceInputDemoPage> {
  final VoiceInputService _voiceService = VoiceInputService();
  final TextEditingController _resultController = TextEditingController();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String _status = '准备录音';

  @override
  void dispose() {
    _voiceService.dispose();
    _resultController.dispose();
    super.dispose();
  }

  /// 开始录音
  Future<void> _startRecording() async {
    // 检查权限
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      Get.snackbar('权限提示', '请在系统设置中授予麦克风权限');
      return;
    }

    setState(() {
      _isRecording = true;
      _status = '正在录音...';
    });

    final recordPath = await _voiceService.startRecording();
    if (recordPath == null) {
      setState(() {
        _isRecording = false;
        _status = '录音失败';
      });
      Get.snackbar('错误', '无法开始录音');
    }
  }

  /// 停止录音并处理
  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _status = '正在处理录音...';
    });

    try {
      final filePath = await _voiceService.stopRecording();
      if (filePath == null) {
        throw Exception('录音文件生成失败');
      }

      setState(() {
        _status = '正在上传并识别...';
      });

      final text = await _voiceService.uploadAndTranscribe(filePath);
      
      setState(() {
        _isProcessing = false;
        if (text != null && text.isNotEmpty) {
          _resultController.text = text;
          _status = '识别成功';
          Get.snackbar('成功', '语音识别完成');
        } else {
          _status = '识别失败';
          Get.snackbar('失败', '未能识别到有效语音');
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = '处理失败: ${e.toString()}';
      });
      Get.snackbar('错误', '语音处理失败: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语音输入测试'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态显示
            Card(
              color: const Color(0xFF1A1D36),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '状态',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _isRecording 
                            ? Colors.blue
                            : _isProcessing 
                                ? Colors.orange
                                : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    if (_isProcessing) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(
                        color: Colors.blue,
                        backgroundColor: Color(0xFF2A2A2A),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 录音按钮
            Center(
              child: GestureDetector(
                onLongPress: _isProcessing ? null : _startRecording,
                onLongPressUp: _isProcessing ? null : _stopRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isRecording ? 120 : 100,
                  height: _isRecording ? 120 : 100,
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? Colors.red 
                        : _isProcessing 
                            ? Colors.grey 
                            : Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: _isRecording
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    _isProcessing 
                        ? Icons.hourglass_empty 
                        : Icons.mic,
                    color: Colors.white,
                    size: _isRecording ? 60 : 50,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _isProcessing 
                  ? '处理中，请稍候...'
                  : '长按录音，松开停止',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 结果显示
            const Text(
              '识别结果',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D36),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _resultController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: '识别到的文字会显示在这里...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 清空按钮
            ElevatedButton(
              onPressed: () {
                _resultController.clear();
                setState(() {
                  _status = '准备录音';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('清空结果'),
            ),
          ],
        ),
      ),
    );
  }
} 
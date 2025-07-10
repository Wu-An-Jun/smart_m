import 'dart:io';
import 'dart:convert';
import 'package:record/record.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// 语音输入服务，负责录音和上传音频到 Dify 进行语音转文字
class VoiceInputService {
  static const String _baseUrl = 'http://dify.explorex-ai.com/v1';
  static const String _apiKey = 'app-f8LfFNPYtORijWvHPjqBYhtA';
  
  final AudioRecorder _audioRecorder = AudioRecorder();
  late final Dio _dio;

  /// 录音文件路径
  String? _audioFilePath;

  VoiceInputService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ),
    );

    // 添加请求拦截器用于调试
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[VoiceInputService] $obj'),
        ),
      );
    }
  }

  /// 开始录音，返回录音文件路径
  Future<String?> startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        debugPrint('没有录音权限');
        return null;
      }

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/audio_$timestamp.m4a';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // 使用AAC编码，生成m4a文件
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );
      
      _audioFilePath = filePath;
      debugPrint('开始录音，文件路径: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('开始录音失败: $e');
      return null;
    }
  }

  /// 停止录音，返回录音文件路径
  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null && path.isNotEmpty) {
        _audioFilePath = path;
        debugPrint('录音结束，文件路径: $path');
        
        // 检查文件是否存在和大小
        final file = File(path);
        if (file.existsSync()) {
                   final fileSize = await file.length();
           debugPrint('录音文件大小: $fileSize字节');
          if (fileSize > 0) {
            return path;
          } else {
            debugPrint('录音文件为空');
          }
        } else {
          debugPrint('录音文件不存在');
        }
      }
      return null;
    } catch (e) {
      debugPrint('停止录音失败: $e');
      return null;
    }
  }

  /// 上传音频文件到 Dify，返回文件ID
  Future<String?> uploadAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        debugPrint('音频文件不存在: $filePath');
        return null;
      }

      final fileSize = await file.length();
      debugPrint('准备上传音频文件，大小: $fileSize字节');

      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath, 
          filename: fileName,
        ),
        'user': 'flutter_app_user',
        'type': 'audio', // 明确指定为音频类型
      });

      final response = await _dio.post(
        '/files/upload',
        data: formData,
        options: Options(
          headers: {
            // multipart/form-data 的 Content-Type 由 Dio 自动设置
          },
        ),
      );

      if (response.statusCode == 201 && response.data != null) {
        final fileId = response.data['id'];
        debugPrint('音频文件上传成功，文件ID: $fileId');
        return fileId;
      } else {
        debugPrint('音频文件上传失败，状态码: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('上传音频文件失败: $e');
      return null;
    }
  }

  /// 使用 Workflow API 进行语音转文字
  Future<String?> speechToText(String fileId) async {
    try {
      debugPrint('开始语音转文字，文件ID: $fileId');

      final requestData = {
        'inputs': {
          'sys_audio': {
            'dify_model_identity': '__dify__file__',
            'id': null,
            'type': 'audio',
            'transfer_method': 'local_file',
            'upload_file_id': fileId,
            'filename': 'audio_recording.m4a',
            'extension': '.m4a',
            'mime_type': 'audio/x-m4a',
          }
        },
        'response_mode': 'blocking', // 使用阻塞模式，等待完整结果
        'user': 'flutter_app_user',
      };

      final response = await _dio.post(
        '/workflows/run',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        debugPrint('Workflow执行成功: ${jsonEncode(data)}');
        
        // 检查workflow状态
        if (data['data'] != null && data['data']['status'] == 'succeeded') {
          final outputs = data['data']['outputs'];
          if (outputs != null) {
            debugPrint('Workflow输出结构: ${jsonEncode(outputs)}');
            
            // 根据您提供的服务端输出样式解析
            // 可能的返回格式: {"text": "北京输入测试"}
            final text = outputs['text'] ?? 
                        outputs['result'] ?? 
                        outputs['transcription'] ??
                        outputs['output'] ??
                        outputs['content'];
            
            if (text != null) {
              final textStr = text.toString().trim();
              if (textStr.isNotEmpty) {
                debugPrint('语音转文字成功: $textStr');
                return textStr;
              }
            }
            
            // 如果直接字段没有找到，尝试深度查找
            for (final value in outputs.values) {
              if (value is String && value.trim().isNotEmpty) {
                debugPrint('从outputs中提取到文本: $value');
                return value.trim();
              } else if (value is Map<String, dynamic>) {
                // 如果是嵌套对象，继续查找text字段
                final nestedText = value['text'] ?? value['content'] ?? value['result'];
                if (nestedText != null && nestedText.toString().trim().isNotEmpty) {
                  debugPrint('从嵌套对象中提取到文本: $nestedText');
                  return nestedText.toString().trim();
                }
              }
            }
          }
        }
        
        debugPrint('Workflow执行失败或无输出结果');
        return null;
      } else {
        debugPrint('Workflow API调用失败，状态码: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('语音转文字失败: $e');
      return null;
    }
  }

  /// 录音并转换为文字的完整流程
  Future<String?> recordAndTranscribe() async {
    try {
      // 1. 开始录音
      final recordPath = await startRecording();
      if (recordPath == null) {
        return null;
      }

      // 这里需要等待用户停止录音
      // 实际使用中，这个方法应该分为开始录音和停止录音两个步骤
      
      return null; // 这个方法主要用于流程展示
    } catch (e) {
      debugPrint('录音转文字完整流程失败: $e');
      return null;
    }
  }

  /// 完整的语音转文字流程：上传文件 + 调用workflow
  Future<String?> uploadAndTranscribe(String filePath) async {
    try {
      // 1. 上传音频文件
      final fileId = await uploadAudioFile(filePath);
      if (fileId == null) {
        return null;
      }

      // 2. 调用workflow进行语音转文字
      final text = await speechToText(fileId);
      return text;
    } catch (e) {
      debugPrint('语音转文字完整流程失败: $e');
      return null;
    }
  }

  /// 清理临时文件
  Future<void> cleanup() async {
    try {
      if (_audioFilePath != null) {
        final file = File(_audioFilePath!);
        if (file.existsSync()) {
          await file.delete();
          debugPrint('已清理临时音频文件: $_audioFilePath');
        }
        _audioFilePath = null;
      }
    } catch (e) {
      debugPrint('清理临时文件失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _audioRecorder.dispose();
    cleanup();
  }
} 
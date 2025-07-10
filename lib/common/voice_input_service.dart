import 'dart:io';
import 'package:record/record.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 语音输入服务，负责录音和上传音频到 Dify 进行语音转文字
class VoiceInputService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Dio _dio = Dio();

  /// 录音文件路径
  String? _audioFilePath;

  /// 开始录音，返回录音文件路径
  Future<String?> startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (hasPermission) {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: filePath,
      );
      _audioFilePath = filePath;
      return filePath;
    }
    return null;
  }

  /// 停止录音，返回录音文件路径
  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path != null && path.isNotEmpty) {
      _audioFilePath = path;
      return path;
    }
    return null;
  }

  /// 上传音频文件到 Dify，返回识别文本
  /// [apiUrl] 语音转文字API地址
  /// [apiKey] Dify API密钥
  Future<String?> uploadAudioAndGetText({
    required String filePath,
    required String apiUrl,
    required String apiKey,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) return null;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'audio.wav'),
    });
    try {
      final response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        // 假设返回格式 { "text": "识别结果" }
        return response.data['text'] as String?;
      }
    } catch (e) {
      // ignore: avoid_print
      print('上传音频失败: $e');
    }
    return null;
  }
} 
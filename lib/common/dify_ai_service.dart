import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Dify AI 服务类
/// 用于集成 AI 分析功能，包括代码错误分析、建议等
class DifyAiService {
  static const String _baseUrl = 'http://dify.explorex-ai.com/v1';
  // static const String _apiKey = 'app-rBEvSQrQQXUuuQbUzYLF9Y67';
  static const String _apiKey = 'app-pEYYAl8lFm8pOkFTtNIG3oBK';

  late final Dio _dio;
  String? _conversationId;

  DifyAiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 60), // 增加连接超时
        receiveTimeout: const Duration(minutes: 5), // 增加接收超时到5分钟
        sendTimeout: const Duration(seconds: 60), // 增加发送超时
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    // 配置代理（如果需要）
    _configureProxy();

    // 添加请求拦截器用于调试
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false, // 流式响应不打印完整body
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  /// 配置代理设置
  void _configureProxy() {
    try {
      // 检查是否需要使用代理
      if (Platform.environment.containsKey('http_proxy') ||
          Platform.environment.containsKey('https_proxy')) {
        // 创建自定义HttpClient来处理代理
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.findProxy = (uri) {
            // 使用系统环境变量中的代理设置
            final httpProxy = Platform.environment['http_proxy'];
            final httpsProxy = Platform.environment['https_proxy'];

            if (uri.scheme == 'https' && httpsProxy != null) {
              return 'PROXY ${httpsProxy.replaceAll('http://', '')}';
            } else if (uri.scheme == 'http' && httpProxy != null) {
              return 'PROXY ${httpProxy.replaceAll('http://', '')}';
            }

            // 尝试常用的代理设置
            return 'PROXY 127.0.0.1:7890';
          };

          // 禁用证书验证（仅用于开发环境）
          if (kDebugMode) {
            client.badCertificateCallback = (cert, host, port) => true;
          }

          return client;
        };
      }
    } catch (e) {
      debugPrint('代理配置失败: $e');
    }
  }

  /// 流式发送消息到 Dify AI
  Stream<String> sendMessageStream(String query) async* {
    try {
      debugPrint('发送流式请求到 Dify AI: $query');

      final response = await _dio.post(
        '/chat-messages',
        data: {
          'inputs': {},
          'query': query, // 直接使用原始查询，不添加额外的模板
          'response_mode': 'streaming', // 使用流式模式
          'conversation_id': _conversationId ?? '',
          'user': 'flutter_app_user',
        },
        options: Options(responseType: ResponseType.stream),
      );

      debugPrint('开始接收流式响应');

      if (response.statusCode == 200) {
        final stream = response.data.stream as Stream<List<int>>;
        String buffer = '';
        String fullResponse = ''; // 累积完整回复

        await for (final chunk in stream) {
          final chunkStr = utf8.decode(chunk);
          buffer += chunkStr;

          // 处理SSE格式的数据
          final lines = buffer.split('\n');
          buffer = lines.removeLast(); // 保留不完整的行

          for (final line in lines) {
            if (line.startsWith('data: ') && !line.contains('[DONE]')) {
              try {
                final jsonStr = line.substring(6); // 移除 "data: " 前缀
                if (jsonStr.trim().isEmpty) continue;

                final data = jsonDecode(jsonStr);

                if (data['event'] == 'message') {
                  // 保存会话ID
                  if (data['conversation_id'] != null) {
                    _conversationId = data['conversation_id'];
                    debugPrint('保存会话ID: $_conversationId');
                  }

                  // 处理增量回复文本
                  final answer = data['answer'] ?? '';
                  if (answer.isNotEmpty) {
                    fullResponse += answer;
                    debugPrint('收到文本片段: $answer');
                    debugPrint('当前完整回复长度: ${fullResponse.length}');

                    // 实时输出累积的完整回复
                    yield fullResponse;
                  }
                } else if (data['event'] == 'message_replace') {
                  // 替换式消息（某些API可能使用）
                  final answer = data['answer'] ?? '';
                  if (answer.isNotEmpty) {
                    fullResponse = answer; // 替换而不是累加
                    yield fullResponse;
                  }
                } else if (data['event'] == 'agent_message') {
                  // Agent消息
                  final answer = data['answer'] ?? '';
                  if (answer.isNotEmpty) {
                    fullResponse += answer;
                    yield fullResponse;
                  }
                } else if (data['event'] == 'message_end') {
                  // 消息结束
                  debugPrint('消息流结束，最终回复长度: ${fullResponse.length}');
                  if (fullResponse.isNotEmpty) {
                    yield fullResponse; // 确保输出最终完整回复
                  }
                  return; // 流式结束
                }
              } catch (e) {
                debugPrint('解析流式数据错误: $e');
                debugPrint('原始数据: $line');
              }
            } else if (line.contains('[DONE]')) {
              debugPrint('流式响应完成');
              if (fullResponse.isNotEmpty) {
                yield fullResponse;
              }
              return;
            }
          }
        }

        // 处理剩余的缓冲区数据
        if (buffer.isNotEmpty) {
          debugPrint('处理剩余缓冲区数据: $buffer');
        }

        // 确保返回最终结果
        if (fullResponse.isNotEmpty) {
          yield fullResponse;
        }
      } else {
        throw Exception('API请求失败：${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.type} - ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络连接和代理设置');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('响应超时，AI服务处理时间较长，请稍后重试');
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception('发送超时，请检查网络连接');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('服务器响应错误：${e.response?.statusCode}');
      } else {
        throw Exception('网络错误：${e.message}');
      }
    } catch (e) {
      debugPrint('其他错误: $e');
      throw Exception('请求失败：${e.toString()}');
    }
  }

  /// 分析 Flutter 错误
  /// [errorMessage] 错误信息
  /// [stackTrace] 错误堆栈
  /// [codeContext] 相关代码上下文（可选）
  Future<AiAnalysisResult> analyzeFlutterError({
    required String errorMessage,
    String? stackTrace,
    String? codeContext,
  }) async {
    final query = _buildErrorAnalysisQuery(
      errorMessage,
      stackTrace,
      codeContext,
    );

    try {
      String fullResponse = '';
      await for (final chunk in sendMessageStream(query)) {
        fullResponse = chunk; // 对于完整响应，直接使用最后的结果
      }

      return AiAnalysisResult(
        analysis: fullResponse,
        suggestions: _extractSuggestions(fullResponse),
        isSuccess: true,
      );
    } catch (e) {
      return AiAnalysisResult(
        analysis: '分析失败：${e.toString()}',
        suggestions: [],
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// 获取代码优化建议
  /// [code] 需要优化的代码片段
  /// [language] 编程语言，默认为 Dart
  Future<AiAnalysisResult> getCodeOptimizationSuggestions({
    required String code,
    String language = 'Dart',
  }) async {
    final query = '''分析以下 $language 代码并提供优化建议：

```$language
$code
```

请从性能优化、代码结构、最佳实践、潜在问题等方面分析，并提供具体的改进建议和代码示例。''';

    try {
      String fullResponse = '';
      await for (final chunk in sendMessageStream(query)) {
        fullResponse = chunk;
      }

      return AiAnalysisResult(
        analysis: fullResponse,
        suggestions: _extractSuggestions(fullResponse),
        isSuccess: true,
      );
    } catch (e) {
      return AiAnalysisResult(
        analysis: '分析失败：${e.toString()}',
        suggestions: [],
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// 获取 Flutter 开发建议
  /// [question] 开发问题或需求描述
  Future<AiAnalysisResult> getFlutterDevelopmentAdvice(String question) async {
    try {
      String fullResponse = '';
      await for (final chunk in sendMessageStream(question)) {
        fullResponse = chunk;
      }

      return AiAnalysisResult(
        analysis: fullResponse,
        suggestions: _extractSuggestions(fullResponse),
        isSuccess: true,
      );
    } catch (e) {
      return AiAnalysisResult(
        analysis: '分析失败：${e.toString()}',
        suggestions: [],
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// 构建错误分析查询
  String _buildErrorAnalysisQuery(
    String errorMessage,
    String? stackTrace,
    String? codeContext,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('我的 Flutter 应用出现了错误，请帮我分析原因并提供解决方案：');
    buffer.writeln();
    buffer.writeln('错误信息：');
    buffer.writeln(errorMessage);

    if (stackTrace != null && stackTrace.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('错误堆栈：');
      buffer.writeln(stackTrace);
    }

    if (codeContext != null && codeContext.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('相关代码：');
      buffer.writeln('```dart');
      buffer.writeln(codeContext);
      buffer.writeln('```');
    }

    return buffer.toString();
  }

  /// 从AI响应中提取建议列表
  List<String> _extractSuggestions(String message) {
    final suggestions = <String>[];
    final lines = message.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      // 提取编号列表项
      if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
        suggestions.add(trimmed);
      }
      // 提取破折号列表项
      else if (trimmed.startsWith('- ')) {
        suggestions.add(trimmed.substring(2));
      }
      // 提取星号列表项
      else if (trimmed.startsWith('* ')) {
        suggestions.add(trimmed.substring(2));
      }
    }

    return suggestions;
  }

  /// 重置对话
  void resetConversation() {
    _conversationId = null;
  }

  /// 获取当前会话ID
  String? get conversationId => _conversationId;
}

/// Dify 消息结果
class DifyMessageResult {
  final String message;
  final String conversationId;
  final String messageId;

  const DifyMessageResult({
    required this.message,
    required this.conversationId,
    required this.messageId,
  });
}

/// AI 分析结果
class AiAnalysisResult {
  final String analysis;
  final List<String> suggestions;
  final bool isSuccess;
  final String? error;

  const AiAnalysisResult({
    required this.analysis,
    required this.suggestions,
    required this.isSuccess,
    this.error,
  });

  @override
  String toString() {
    return 'AiAnalysisResult(isSuccess: $isSuccess, analysis: $analysis, suggestions: ${suggestions.length})';
  }
}

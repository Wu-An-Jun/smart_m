import 'dart:convert';
import 'package:dio/dio.dart';

class AIService {
  static const String _apiKey = 'sk-e12c26b9355144d4a8b6df1eab8046ed';
  static const String _baseUrl = 'https://dashscope.aliyuncs.com/compatible-mode/v1';
  static const String _model = 'qwen-plus';
  
  late final Dio _dio;
  
  AIService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    ));
    
    // 添加请求拦截器用于调试
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: false, // 流式响应不记录body
      error: true,
    ));
  }
  
  /// 发送消息给AI并获取流式回复
  Stream<String> sendMessageStream(String userMessage, {List<Map<String, String>>? conversationHistory}) async* {
    try {
      // 构建消息历史
      List<Map<String, String>> messages = [
        {
          "role": "system", 
          "content": "你是一个智能家居助手，能够帮助用户解答关于摄像头、智能管家、设备控制等功能的问题。请用友好、专业的语调回答用户的问题。回答时使用Markdown格式，让内容更清晰易读。"
        }
      ];
      
      // 添加对话历史（最多保留最近10轮对话）
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        int startIndex = conversationHistory.length > 20 ? conversationHistory.length - 20 : 0;
        messages.addAll(conversationHistory.sublist(startIndex));
      }
      
      // 添加当前用户消息
      messages.add({
        "role": "user",
        "content": userMessage
      });
      
      final requestData = {
        "model": _model,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 1000,
        "top_p": 0.9,
        "stream": true,
        "stream_options": {"include_usage": true}
      };
      
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode(requestData),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final stream = response.data as ResponseBody;
        String buffer = '';
        
        await for (final chunk in stream.stream) {
          // 正确处理UTF-8编码
          String chunkStr = utf8.decode(chunk, allowMalformed: true);
          buffer += chunkStr;
          
          // 处理SSE格式的数据
          final lines = buffer.split('\n');
          buffer = lines.last; // 保留可能不完整的最后一行
          
          for (int i = 0; i < lines.length - 1; i++) {
            final line = lines[i].trim();
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6);
              if (dataStr == '[DONE]') {
                return;
              }
              
              try {
                final data = jsonDecode(dataStr);
                if (data['choices'] != null && data['choices'].isNotEmpty) {
                  final delta = data['choices'][0]['delta'];
                  if (delta != null && delta['content'] != null) {
                    yield delta['content'];
                  }
                }
              } catch (e) {
                // 忽略JSON解析错误，继续处理下一个chunk
                print('JSON解析错误: $e, 数据: $dataStr');
              }
            }
          }
        }
      }
      
    } on DioException catch (e) {
      print('AI流式请求错误: ${e.message}');
      if (e.response != null) {
        print('错误响应: ${e.response?.data}');
      }
      
      // 返回错误信息
      if (e.type == DioExceptionType.connectionTimeout) {
        yield '网络连接超时，请检查网络设置。';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        yield 'AI响应超时，请稍后再试。';
      } else if (e.response?.statusCode == 401) {
        yield 'API密钥验证失败，请联系管理员。';
      } else if (e.response?.statusCode == 429) {
        yield '请求过于频繁，请稍后再试。';
      } else {
        yield '网络错误，请稍后再试。';
      }
    } catch (e) {
      print('未知错误: $e');
      yield '抱歉，出现了未知错误，请稍后再试。';
    }
  }
  
  /// 发送消息给AI并获取回复（非流式，保留作为备用）
  Future<String> sendMessage(String userMessage, {List<Map<String, String>>? conversationHistory}) async {
    try {
      // 构建消息历史
      List<Map<String, String>> messages = [
        {
          "role": "system", 
          "content": "你是一个智能家居助手，能够帮助用户解答关于摄像头、智能管家、设备控制等功能的问题。请用友好、专业的语调回答用户的问题。回答时使用Markdown格式，让内容更清晰易读。"
        }
      ];
      
      // 添加对话历史（最多保留最近10轮对话）
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        int startIndex = conversationHistory.length > 20 ? conversationHistory.length - 20 : 0;
        messages.addAll(conversationHistory.sublist(startIndex));
      }
      
      // 添加当前用户消息
      messages.add({
        "role": "user",
        "content": userMessage
      });
      
      final requestData = {
        "model": _model,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 1000,
        "top_p": 0.9,
      };
      
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.toString() ?? '抱歉，我暂时无法理解您的问题。';
        }
      }
      
      return '抱歉，服务暂时不可用，请稍后再试。';
      
    } on DioException catch (e) {
      print('AI请求错误: ${e.message}');
      if (e.response != null) {
        print('错误响应: ${e.response?.data}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return '网络连接超时，请检查网络设置。';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return 'AI响应超时，请稍后再试。';
      } else if (e.response?.statusCode == 401) {
        return 'API密钥验证失败，请联系管理员。';
      } else if (e.response?.statusCode == 429) {
        return '请求过于频繁，请稍后再试。';
      } else {
        return '网络错误，请稍后再试。';
      }
    } catch (e) {
      print('未知错误: $e');
      return '抱歉，出现了未知错误，请稍后再试。';
    }
  }
  
  /// 获取预设回复（备用方案）
  String getPresetReply(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();
    
    if (lowercaseMessage.contains('摄像头') || lowercaseMessage.contains('camera')) {
      return '''## 📹 摄像头服务介绍

### 主要功能
- **实时监控**：24小时不间断监控
- **移动侦测**：智能识别异常活动
- **云端存储**：安全可靠的录像保存

### 操作指南
1. 打开摄像头应用
2. 选择监控模式
3. 设置录像参数

> **提示**：建议在光线充足的环境下使用，效果更佳。

如需了解更多功能，请联系客服。''';
    }
    
    if (lowercaseMessage.contains('智能管家') || lowercaseMessage.contains('管家')) {
      return '''## 🤖 智能管家功能

### 核心能力
- **语音对话**：自然语言交互
- **任务提醒**：日程管理和提醒
- **智能问答**：回答各类问题
- **设备控制**：联动智能家居

### 常用命令
```
"今天天气怎么样？"
"提醒我明天9点开会"
"播放音乐"
"关闭客厅灯光"
```

### 个性化设置
> 可以在设置中调整管家的：
> - 语音类型（男声/女声）
> - 响应速度
> - 唤醒词

**试试问我任何问题吧！** ✨''';
    }
    
    if (lowercaseMessage.contains('设备') || lowercaseMessage.contains('控制')) {
      return '''## 🏠 设备控制功能

### 支持的设备类型
- **照明设备**：智能灯泡、灯带、开关
- **空调系统**：温度调节、模式切换
- **安防设备**：门锁、摄像头、传感器
- **娱乐设备**：音响、电视、投影仪

### 控制方式
1. **语音控制**：直接说出指令
2. **手动操作**：点击设备面板
3. **场景模式**：一键执行多设备操作
4. **定时任务**：设置自动化规则

### 使用技巧
> 试试这些语音指令：
> - "打开客厅灯"
> - "空调调到26度"
> - "播放轻音乐"
> - "启动回家模式"

**让您的家变得更智能！** 🏡''';
    }
    
    // 默认回复
    return '''## 👋 您好！

我是您的智能家居助手，可以帮您解答关于：

### 🔧 主要服务
- **摄像头服务**：监控、录像、云存储
- **智能管家**：语音交互、智能控制
- **设备管理**：添加、控制、自动化
- **安全防护**：门锁、报警、监测

### 💡 使用建议
您可以询问：
- "摄像头如何设置？"
- "怎样添加新设备？"
- "如何设置自动化规则？"
- "智能管家有哪些功能？"

**有什么问题尽管问我！** 😊

---
*提示：我支持Markdown格式显示，让信息更清晰易读*''';
  }
} 
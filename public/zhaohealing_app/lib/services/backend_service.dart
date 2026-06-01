import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'database_service.dart';

/// 聊天消息模型
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        content: json['content'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// 灵犀后端服务
/// 连接 WebSocket 进行实时语音对话
class BackendService {
  static const String _defaultUrl = 'ws://127.0.0.1:5566';
  static const String _httpUrl = 'http://127.0.0.1:5566';

  WebSocketChannel? _channel;
  String _serverUrl = _defaultUrl;
  bool _isConnected = false;
  String _currentState = 'idle';
  String _currentSubtitle = '';

  // 回调函数
  Function(String state, {String? subtitle})? onStateChanged;
  Function(String text)? onSubtitleChanged;
  Function(String audioBase64)? onAudioReceived;
  Function()? onConnected;
  Function()? onDisconnected;

  // 单例模式
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  /// 初始化连接
  Future<void> init({String? serverUrl}) async {
    if (serverUrl != null) {
      _serverUrl = serverUrl;
    }
    await DatabaseService.init();
  }

  /// 连接 WebSocket
  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));

      _channel!.stream.listen(
        _handleMessage,
        onDone: _handleDisconnect,
        onError: _handleError,
        cancelOnError: false,
      );

      _isConnected = true;
      onConnected?.call();
    } catch (e) {
      print('连接失败: $e');
      _isConnected = false;
    }
  }

  /// 断开连接
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  /// 检查连接状态
  bool get isConnected => _isConnected;

  /// 获取当前状态
  String get currentState => _currentState;

  /// 获取当前字幕
  String get currentSubtitle => _currentSubtitle;

  /// 处理接收到的消息
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      if (data.containsKey('state')) {
        final newState = data['state'] as String;
        if (_currentState != newState) {
          _currentState = newState;
          final subtitle = data['text'] as String?;
          onStateChanged?.call(newState, subtitle: subtitle);
        }
      }

      if (data.containsKey('text')) {
        _currentSubtitle = data['text'] as String;
        onSubtitleChanged?.call(_currentSubtitle);
      }

      if (data.containsKey('audio')) {
        final audioBase64 = data['audio'] as String;
        onAudioReceived?.call(audioBase64);
      }
    } catch (e) {
      print('消息解析错误: $e');
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _currentState = 'idle';
    onDisconnected?.call();
  }

  void _handleError(dynamic error) {
    print('WebSocket 错误: $error');
    _isConnected = false;
  }

  /// 发送音频数据
  Future<void> sendAudio(String base64Audio) async {
    if (!_isConnected || _channel == null) {
      throw Exception('未连接到服务器');
    }

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'audio',
        'data': base64Audio,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      print('发送音频失败: $e');
      rethrow;
    }
  }

  /// 发送文本消息（备用）
  Future<void> sendText(String text) async {
    if (!_isConnected || _channel == null) {
      throw Exception('未连接到服务器');
    }

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'text',
        'data': text,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      print('发送文本失败: $e');
      rethrow;
    }
  }

  /// 心跳保活
  void startHeartbeat() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          _channel?.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          print('心跳失败: $e');
        }
      } else {
        timer.cancel();
      }
    });
  }
}

/// AI 语音对话管理器
class ChatManager {
  final BackendService _backend = BackendService();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;

  Function(String state)? onChatStateChanged;
  Function(String subtitle)? onSubtitleChanged;
  Function(String audioBase64)? onAudioPlay;
  Function()? onRecordingStarted;
  Function()? onRecordingStopped;

  List<ChatMessage> get messages => _messages;
  bool get isRecording => _isRecording;
  bool get isConnected => _backend._isConnected;
  String get state => _backend.currentState;

  /// 初始化
  Future<void> init({String? serverUrl}) async {
    await _backend.init(serverUrl: serverUrl);

    _backend.onStateChanged = (state, {subtitle}) {
      onChatStateChanged?.call(state);
      if (subtitle != null) {
        onSubtitleChanged?.call(subtitle);
      }
    };

    _backend.onSubtitleChanged = (text) {
      onSubtitleChanged?.call(text);
    };

    _backend.onAudioReceived = (audioBase64) {
      onAudioPlay?.call(audioBase64);
    };

    _backend.onConnected = () {
      print('已连接到灵犀服务器');
    };

    _backend.onDisconnected = () {
      print('已断开连接');
    };
  }

  /// 连接服务器
  Future<void> connect() async {
    await _backend.connect();
    _backend.startHeartbeat();
  }

  /// 开始录音
  Future<void> startRecording() async {
    if (_isRecording) return;

    _isRecording = true;
    onRecordingStarted?.call();

    // 发送开始录音信号
    await _backend.sendText('__start_recording__');
  }

  /// 停止录音
  Future<void> stopRecording() async {
    if (!_isRecording) return;

    _isRecording = false;
    onRecordingStopped?.call();

    // 发送停止录音信号
    await _backend.sendText('__stop_recording__');
  }

  /// 发送用户音频
  Future<void> sendAudio(String base64Audio) async {
    // 添加用户消息到列表
    final message = ChatMessage(
      id: const Uuid().v4(),
      content: '[语音消息]',
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(message);

    // 发送到后端
    await _backend.sendAudio(base64Audio);

    // 保存到数据库
    await DatabaseService.saveChatMessage(message.toJson());
  }

  /// 停止播放音频
  void stopAudio() {
    // 由调用方处理
  }

  /// 清空对话历史
  void clearHistory() {
    _messages.clear();
    _backend.disconnect();
  }

  /// 获取对话历史
  List<ChatMessage> getHistory() {
    return List.from(_messages);
  }

  /// 获取最后一条助手消息
  ChatMessage? getLastAssistantMessage() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isUser) {
        return _messages[i];
      }
    }
    return null;
  }

  /// 断开连接
  void disconnect() {
    _backend.disconnect();
  }
}

/// 快捷实例
final chatManager = ChatManager();

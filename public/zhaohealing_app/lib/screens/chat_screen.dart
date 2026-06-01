import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zhaohealing/providers/app_provider.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'package:zhaohealing/services/backend_service.dart';
import 'package:zhaohealing/services/audio_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  String _state = 'idle';
  String _subtitle = '';
  bool _showPlayBtn = false;
  bool _isConnected = false;
  String? _recordingPath;

  AnimationController? _breatheController;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _initChat();
  }

  Future<void> _initChat() async {
    // 初始化聊天管理器
    await chatManager.init(serverUrl: 'ws://127.0.0.1:5566');

    chatManager.onChatStateChanged = (state) {
      if (mounted) {
        setState(() => _state = state);
      }
    };

    chatManager.onSubtitleChanged = (text) {
      if (mounted) {
        setState(() => _subtitle = text);
      }
    };

    chatManager.onAudioPlay = (audioBase64) {
      if (mounted && audioBase64.isNotEmpty) {
        audioService.playVoice(audioBase64);
      }
    };

    chatManager.onRecordingStarted = () {
      if (mounted) {
        setState(() {
          _state = 'recording';
          _subtitle = '';
          _showPlayBtn = false;
        });
      }
    };

    chatManager.onRecordingStopped = () {
      if (mounted) {
        setState(() => _state = 'thinking');
      }
    };

    // 连接服务器
    await chatManager.connect();
    setState(() => _isConnected = chatManager.isConnected);
  }

  @override
  void dispose() {
    _breatheController?.dispose();
    _pulseController?.dispose();
    chatManager.disconnect();
    super.dispose();
  }

  Color _getStateColor() {
    switch (_state) {
      case 'recording':
        return AppTheme.accentGreen;
      case 'thinking':
        return AppTheme.accentOrange;
      case 'speaking':
        return AppTheme.accentPink;
      default:
        return AppTheme.soulLight;
    }
  }

  String _getHintText() {
    if (!_isConnected) return '连接中...';

    switch (_state) {
      case 'idle':
        return '按住球体 · 倾诉心声';
      case 'recording':
        return '正在聆听...';
      case 'thinking':
        return '正在用心感受...';
      case 'speaking':
        return '点击球体 · 停止播放';
      default:
        return '连接中...';
    }
  }

  void _handlePressStart() async {
    if (!_isConnected) {
      // 尝试重连
      await chatManager.connect();
      setState(() => _isConnected = chatManager.isConnected);
      return;
    }

    if (_state == 'speaking') {
      await audioService.stopVoice();
      setState(() => _state = 'idle');
      return;
    }

    if (_state == 'thinking') return;

    try {
      // 开始录音
      _recordingPath = await audioService.startRecording();
      chatManager.startRecording();
    } catch (e) {
      print('开始录音失败: $e');
      // 没有权限时使用模拟模式
      _startMockRecording();
    }
  }

  void _startMockRecording() {
    setState(() {
      _state = 'recording';
      _subtitle = '';
      _showPlayBtn = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _state = 'thinking');
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _state = 'speaking';
          _subtitle = '我在这里，陪伴你。';
        });
      }
    });
  }

  void _handlePressEnd() async {
    if (_state != 'recording') return;

    try {
      // 停止录音并发送
      final path = await audioService.stopRecording();

      // 读取音频文件并转换为 base64
      final file = File(path);
      final bytes = await file.readAsBytes();
      final base64Audio = String.fromCharCodes(bytes);

      await chatManager.sendAudio(base64Audio);

      // 删除临时文件
      await file.delete();
    } catch (e) {
      print('停止录音失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 连接状态指示
        if (!_isConnected)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '未连接，点击球体重试',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildSoulCore(),
              const SizedBox(height: 32),
              _buildHintText(),
              const SizedBox(height: 16),
              if (_showPlayBtn) _buildPlayButton(),
              const Spacer(),
              _buildSubtitleArea(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoulCore() {
    final coreColor = _getStateColor();
    final isRecording = _state == 'recording';

    return GestureDetector(
      onTapDown: (_) => _handlePressStart(),
      onTapUp: (_) => _handlePressEnd(),
      onTapCancel: _handlePressEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.soulLight,
              AppTheme.soulShadow.withOpacity(0.5),
            ],
            stops: const [0.3, 1],
            center: const Alignment(0.3, 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: coreColor.withOpacity(isRecording ? 0.5 : 0.2),
              blurRadius: isRecording ? 50 : 20,
              spreadRadius: isRecording ? 10 : 0,
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 4,
          ),
        ),
        child: _buildCoreContent(),
      ),
    );
  }

  Widget _buildCoreContent() {
    switch (_state) {
      case 'recording':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _breatheController!.drive(Tween(begin: 0.8, end: 1.2)),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      case 'thinking':
        return Text(
          '思考中',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentOrange,
            letterSpacing: 4,
          ),
        );
      case 'speaking':
        return AnimatedBuilder(
          animation: _pulseController!,
          builder: (context, child) {
            final scale = 1.0 + 0.2 * _pulseController!.value;
            final opacity = 1.0 - 0.3 * _pulseController!.value;
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  Icons.volume_up,
                  color: AppTheme.accentPink,
                  size: 24,
                ),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHintText() {
    return Text(
      _getHintText(),
      style: const TextStyle(
        fontSize: 11,
        color: AppTheme.textLight,
        letterSpacing: 3,
        height: 1.8,
      ),
    );
  }

  Widget _buildPlayButton() {
    return ElevatedButton(
      onPressed: () async {
        await audioService.playVoice('');
        setState(() {
          _state = 'speaking';
          _subtitle = '我在这里，陪伴你。';
          _showPlayBtn = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        '点击播放声音',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSubtitleArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _subtitle.isNotEmpty
            ? Text(
                _subtitle,
                key: ValueKey(_subtitle),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textBrown,
                  height: 1.6,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

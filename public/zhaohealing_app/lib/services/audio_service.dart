import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

/// 音频服务管理器
/// 处理所有音频播放、录音、暂停等功能
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // 音频播放器
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  // 录音器
  final AudioRecorder _recorder = AudioRecorder();

  // 当前状态
  String? _currentBg;
  String? _currentVoice;
  bool _isBgPlaying = false;
  bool _isVoicePlaying = false;
  bool _isRecording = false;

  // 监听器
  Function(bool isPlaying)? onBgStateChanged;
  Function(bool isRecording)? onRecordingStateChanged;
  Function(Duration duration)? onDurationChanged;
  Function(Duration position)? onPositionChanged;

  // 初始化
  Future<void> init() async {
    // 设置音频模式
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _voicePlayer.setReleaseMode(ReleaseMode.release);

    // 设置监听器
    _bgPlayer.onPlayerStateChanged.listen((state) {
      _isBgPlaying = state == PlayerState.playing;
      onBgStateChanged?.call(_isBgPlaying);
    });

    _voicePlayer.onPlayerStateChanged.listen((state) {
      _isVoicePlaying = state == PlayerState.playing;
    });

    _voicePlayer.onDurationChanged.listen((duration) {
      onDurationChanged?.call(duration);
    });

    _voicePlayer.onPositionChanged.listen((position) {
      onPositionChanged?.call(position);
    });
  }

  // ==================== 背景音乐播放 ====================

  /// 播放背景音乐
  Future<void> playBgMusic(String path, {double volume = 0.5}) async {
    try {
      if (_currentBg == path && _isBgPlaying) {
        return; // 已在播放
      }

      _currentBg = path;
      await _bgPlayer.setSource(AssetSource(path.replaceFirst('assets/', '')));
      await _bgPlayer.setVolume(volume);
      await _bgPlayer.resume();
      _isBgPlaying = true;
    } catch (e) {
      print('播放背景音乐失败: $e');
    }
  }

  /// 暂停背景音乐
  Future<void> pauseBgMusic() async {
    await _bgPlayer.pause();
    _isBgPlaying = false;
  }

  /// 停止背景音乐
  Future<void> stopBgMusic() async {
    await _bgPlayer.stop();
    _currentBg = null;
    _isBgPlaying = false;
  }

  /// 设置背景音乐音量
  Future<void> setBgVolume(double volume) async {
    await _bgPlayer.setVolume(volume.clamp(0, 1));
  }

  bool get isBgPlaying => _isBgPlaying;
  String? get currentBg => _currentBg;

  // ==================== 语音播放 ====================

  /// 播放语音（AI回复）
  Future<void> playVoice(String base64Audio, {double volume = 1.0}) async {
    try {
      // 解码 base64
      final bytes = base64Decode(base64Audio);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(bytes);

      await _voicePlayer.setSource(DeviceFileSource(tempFile.path));
      await _voicePlayer.setVolume(volume);
      await _voicePlayer.resume();
      _isVoicePlaying = true;
    } catch (e) {
      print('播放语音失败: $e');
    }
  }

  /// 暂停语音
  Future<void> pauseVoice() async {
    await _voicePlayer.pause();
  }

  /// 停止语音
  Future<void> stopVoice() async {
    await _voicePlayer.stop();
    _isVoicePlaying = false;
  }

  bool get isVoicePlaying => _isVoicePlaying;

  // ==================== 音效播放 ====================

  /// 播放简短音效
  Future<void> playEffect(String path, {double volume = 0.3}) async {
    try {
      await _effectPlayer.setSource(AssetSource(path.replaceFirst('assets/', '')));
      await _effectPlayer.setVolume(volume);
      await _effectPlayer.resume();
    } catch (e) {
      print('播放音效失败: $e');
    }
  }

  // ==================== 录音功能 ====================

  /// 开始录音
  Future<String> startRecording() async {
    if (await _recorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        RecordConfig(),
        path: path,
      );

      _isRecording = true;
      onRecordingStateChanged?.call(true);
      return path;
    }
    throw Exception('没有录音权限');
  }

  /// 停止录音
  Future<String> stopRecording() async {
    final path = await _recorder.stop() ?? '';
    _isRecording = false;
    onRecordingStateChanged?.call(false);
    return path;
  }

  /// 检查是否正在录音
  bool get isRecording => _isRecording;

  /// 获取录音权限状态
  Future<bool> hasRecordingPermission() async {
    return await _recorder.hasPermission();
  }

  // ==================== 资源释放 ====================

  /// 释放所有资源
  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _voicePlayer.dispose();
    await _effectPlayer.dispose();
    await _recorder.dispose();
  }
}

/// 快捷实例
final audioService = AudioService();

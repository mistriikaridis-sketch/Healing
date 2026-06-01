import 'package:flutter/material.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'dart:ui';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  int _currentMode = 0; // 0: focus, 1: breathe, 2: sound, 3: mind
  bool _isRunning = false;
  int _timer = 25 * 60;
  int _initialDuration = 25 * 60;
  bool _isInfinite = false;
  String _statusText = '准备';
  int _breathTimer = 0;
  String _breathPattern = '4-7-8';
  String _breathName = '舒缓';

  late AnimationController _breatheController;
  late AnimationController _scaleController;

  final List<Map<String, String>> _modes = [
    {'id': 'focus', 'label': '专注'},
    {'id': 'breathe', 'label': '呼吸'},
    {'id': 'sound', 'label': '声景'},
    {'id': 'mind', 'label': '引导'},
  ];

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String get _timerDisplay {
    final t = _timer.abs();
    final m = t ~/ 60;
    final s = t % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        if (_currentMode == 0) {
          _startFocus();
        } else if (_currentMode == 1) {
          _startBreathe();
        }
      }
    });
  }

  void _startFocus() {
    _statusText = _isInfinite ? '正计时' : '专注中...';
    Future.doWhile(() async {
      if (!_isRunning || !mounted) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (_isInfinite) {
        _timer++;
      } else {
        _timer--;
        if (_timer <= 0) {
          _reset();
          return false;
        }
      }
      setState(() {});
      return true;
    });
  }

  void _startBreathe() {
    final pattern = _breathPattern.split('-');
    final inhale = int.parse(pattern[0]);
    final hold1 = int.parse(pattern[1]);
    final exhale = int.parse(pattern.length > 2 ? pattern[2] : pattern[1]);
    final hold2 = pattern.length > 2 ? int.parse(pattern[1]) : 0;

    _statusText = '吸气';
    _breathTimer = inhale;

    Future.doWhile(() async {
      if (!_isRunning || !mounted) return false;

      // 吸气
      await Future.delayed(Duration(seconds: inhale));
      if (!_isRunning || !mounted) return false;
      _breathTimer = hold1;
      _statusText = '保持';
      setState(() {});

      // 屏息1
      await Future.delayed(Duration(seconds: hold1));
      if (!_isRunning || !mounted) return false;
      _breathTimer = exhale;
      _statusText = '呼气';
      setState(() {});

      // 呼气
      await Future.delayed(Duration(seconds: exhale));
      if (!_isRunning || !mounted) return false;

      if (hold2 > 0) {
        _breathTimer = hold2;
        _statusText = '保持';
        setState(() {});
        await Future.delayed(Duration(seconds: hold2));
        if (!_isRunning || !mounted) return false;
      }

      _breathTimer = inhale;
      _statusText = '吸气';
      setState(() {});
      return true;
    });
  }

  void _reset() {
    setState(() {
      _isRunning = false;
      _timer = _initialDuration;
      _statusText = '准备';
      _breathTimer = 0;
    });
  }

  void _setDuration(int minutes) {
    setState(() {
      _initialDuration = minutes * 60;
      _timer = _initialDuration;
      _isInfinite = minutes == 0;
      _statusText = minutes == 0 ? '正计时' : '准备';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          Container(
            width: 100,
            color: Colors.white.withOpacity(0.4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
            child: Column(
              children: [
                const SizedBox(height: 120),
                Text(
                  '在此',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'FOCUS',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.sub,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                ...List.generate(_modes.length, (index) {
                  final mode = _modes[index];
                  final isSelected = _currentMode == index;
                  return InkWell(
                    onTap: () => setState(() => _currentMode = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isSelected ? AppTheme.ink : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          mode['label']!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                            color: isSelected ? AppTheme.ink : AppTheme.sub,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // 主内容区
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentMode) {
      case 0:
        return _buildFocusMode();
      case 1:
        return _buildBreatheMode();
      case 2:
        return _buildSoundMode();
      case 3:
        return _buildMindMode();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFocusMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _toggleTimer,
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) {
              final scale = _isRunning ? 1.1 : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _timerDisplay,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 64,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.ink,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.sub,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(_isRunning ? '暂停' : '开始', _toggleTimer),
            const SizedBox(width: 24),
            _buildDurationSelector(),
            const SizedBox(width: 24),
            _buildControlButton('重置', _reset),
          ],
        ),
      ],
    );
  }

  Widget _buildBreatheMode() {
    final scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _toggleTimer,
          child: AnimatedBuilder(
            animation: _breatheController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRunning ? scaleAnimation.value : 1.0,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRunning ? _statusText : _breathName,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.ink,
                            letterSpacing: 4,
                          ),
                        ),
                        if (_isRunning && _breathTimer > 0) ...[
                          const SizedBox(height: 16),
                          Text(
                            '$_breathTimer',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              color: AppTheme.sub,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        _buildBreathPatternSelector(),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(_isRunning ? '暂停' : '开始', _toggleTimer),
            const SizedBox(width: 24),
            _buildControlButton('重置', _reset),
          ],
        ),
      ],
    );
  }

  Widget _buildSoundMode() {
    final soundCategories = {
      '自然': [
        {'title': '营地篝火', 'icon': '🔥'},
        {'title': '海浪', 'icon': '🌊'},
        {'title': '踏雪寻梅', 'icon': '❄️'},
        {'title': '竹林雨声', 'icon': '🎋'},
        {'title': '鲸语', 'icon': '🐋'},
        {'title': '瀑布', 'icon': '💦'},
        {'title': '沙丘', 'icon': '🏜️'},
        {'title': '回声谷', 'icon': '🏔️'},
      ],
      '禅意': [
        {'title': '高山流水', 'icon': '🎵'},
        {'title': '夏日微风', 'icon': '🍃'},
        {'title': '藤蔓呼吸', 'icon': '🌿'},
        {'title': '漫漫长路', 'icon': '🛤️'},
        {'title': '月夜', 'icon': '🌙'},
        {'title': '炉火梦境', 'icon': '✨'},
      ],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '声景',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 24),
          ...soundCategories.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.sub,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: category.value.map((sound) {
                    return _buildSoundCard(sound['title']!, sound['icon']!);
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMindMode() {
    final mindCategories = {
      '减压': [
        {'title': '定义压力', 'icon': '🧠'},
        {'title': '压力觉察', 'icon': '👁️'},
        {'title': '认知提升', 'icon': '📈'},
        {'title': '关注当下', 'icon': '🎯'},
      ],
      '疗愈': [
        {'title': '情绪感知', 'icon': '💭'},
        {'title': '聆听怒火', 'icon': '😤'},
        {'title': '调整情绪', 'icon': '⚖️'},
        {'title': '应对冲突', 'icon': '🤝'},
      ],
      '探索': [
        {'title': '关系之境', 'icon': '💫'},
        {'title': '卸下防备', 'icon': '🛡️'},
        {'title': '遇见本我', 'icon': '🪞'},
        {'title': '新生之旅', 'icon': '🦋'},
      ],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '正念引导',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '引导音频可与声景叠加播放',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.sub,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          ...mindCategories.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.sub,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: category.value.map((item) {
                    return _buildSoundCard(item['title']!, item['icon']!);
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSoundCard(String title, String icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.ink,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.ink,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [25, 45];
    return PopupMenuButton<int>(
      onSelected: _setDuration,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          '设置',
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.ink,
            letterSpacing: 2,
          ),
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 25, child: Text('25 分钟')),
        const PopupMenuItem(value: 45, child: Text('45 分钟')),
        const PopupMenuItem(value: 0, child: Text('无限')),
      ],
    );
  }

  Widget _buildBreathPatternSelector() {
    final patterns = [
      {'pattern': '4-7-8', 'name': '舒缓'},
      {'pattern': '5-5-5', 'name': '平衡 (箱式)'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: patterns.map((p) {
        final isSelected = _breathPattern == p['pattern'];
        return GestureDetector(
          onTap: () => setState(() {
            _breathPattern = p['pattern']!;
            _breathName = p['name']!;
          }),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.ink : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${p['name']} (${p['pattern']})',
              style: const TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : AppTheme.ink,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

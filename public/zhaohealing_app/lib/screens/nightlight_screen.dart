import 'package:flutter/material.dart';
import 'package:zhaohealing/theme/app_theme.dart';

class NightLightScreen extends StatefulWidget {
  const NightLightScreen({super.key});

  @override
  State<NightLightScreen> createState() => _NightLightScreenState();
}

class _NightLightScreenState extends State<NightLightScreen>
    with SingleTickerProviderStateMixin {
  int _hue = 260;
  int _saturation = 100;
  int _brightness = 100;
  bool _showControls = false;

  late AnimationController _breatheController;
  late AnimationController _waveController;
  late AnimationController _blinkController;

  double get _lightness => 10 + (_brightness / 100) * 45;

  Color get _bgColor => HSLColor.fromAHSL(1, _hue.toDouble(), _saturation / 100, _lightness / 100).toColor();

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _blinkController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _waveController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _interact() {
    // 点击角色时的动画
    final char = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCharacterBody(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // 角色
          Center(
            child: GestureDetector(
              onTap: _interact,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCharacterBody(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // 关闭按钮
          Positioned(
            top: 40,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                '关闭',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // 控制面板
          Positioned(
            bottom: 40,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_showControls)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '氛围调节',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildColorSlider('HUE', _hue, 0, 360, (v) => _hue = v),
                        const SizedBox(height: 16),
                        _buildColorSlider('SAT', _saturation, 0, 100, (v) => _saturation = v),
                        const SizedBox(height: 16),
                        _buildColorSlider('INT', _brightness, 0, 100, (v) => _brightness = v),
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: () => setState(() => _showControls = !_showControls),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sliders,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBody() {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        final scale = 1.0 + (_breatheController.value * 0.03);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 150,
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(75),
                topRight: Radius.circular(75),
                bottomLeft: Radius.circular(65),
                bottomRight: Radius.circular(65),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildEyes(),
                const SizedBox(height: 16),
                _buildBlush(),
                const SizedBox(height: 24),
                _buildArms(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEyes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildEye(),
        const SizedBox(width: 26),
        _buildEye(),
      ],
    );
  }

  Widget _buildEye() {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final blinkValue = _blinkController.value;
        double height = 14;
        if (blinkValue > 0.96) {
          height = 14 * ((blinkValue - 0.96) / 0.04);
        } else if (blinkValue > 0.98) {
          height = 14 * (1 - (blinkValue - 0.98) / 0.02);
        }
        return Container(
          width: 14,
          height: height.clamp(1, 14),
          decoration: const BoxDecoration(
            color: Color(0xFF222222),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
        );
      },
    );
  }

  Widget _buildBlush() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBlushDot(22),
        const SizedBox(width: 80),
        _buildBlushDot(22),
      ],
    );
  }

  Widget _buildBlushDot(double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 18,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFFFFAAAA),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildArms() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildArm(true),
        const SizedBox(width: 90),
        _buildArm(false),
      ],
    );
  }

  Widget _buildArm(bool isLeft) {
    final rotation = isLeft ? 0.3 : -0.3;
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final waveValue = _waveController.value;
        final angle = isLeft
            ? 0.3 + (waveValue * 0.2)
            : -0.3 - (waveValue * 0.2);
        return Transform.rotate(
          angle: angle,
          child: Container(
            width: 30,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSlider(String label, int value, int min, int max, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            Text(
              label == 'HUE' ? '$_hue' : '$_saturation%',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbColor: Colors.white,
              activeTrackColor: _getSliderColor(),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSliderColor() {
    if (_hue < 60) return Colors.red;
    if (_hue < 120) return Colors.yellow;
    if (_hue < 180) return Colors.green;
    if (_hue < 240) return Colors.cyan;
    if (_hue < 300) return Colors.blue;
    return Colors.purple;
  }
}

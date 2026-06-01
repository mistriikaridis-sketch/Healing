import 'package:flutter/material.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class SCL90Screen extends StatefulWidget {
  const SCL90Screen({super.key});

  @override
  State<SCL90Screen> createState() => _SCL90ScreenState();
}

class _SCL90ScreenState extends State<SCL90Screen> {
  int _step = 0;
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final List<int> _answers = List.filled(90, 0);
  Map<String, dynamic>? _results;
  bool _hasCrisis = false;

  final List<String> _questions = [
    '头痛', '神经过敏', '头脑中有不必要的想法', '头晕或晕倒', '对异性的兴趣减退',
    '对旁人责备求全', '感到别人能控制您的思想', '责怪别人制造麻烦', '忘性大',
    '担心自己的衣饰整齐', '容易烦恼和激动', '胸痛', '害怕空旷的场所', '感到精力下降',
    '想结束自己的生命', '听到旁人听不到的声音', '发抖', '感到大多数人都不可信任',
    '胃口不好', '容易哭泣', '同异性相处害羞', '感到受骗', '无故害怕', '发脾气',
    '怕单独出门', '责怪自己', '腰痛', '难以完成任务', '感到孤独', '感到苦闷',
    '过分担忧', '对事物不感兴趣', '感到害怕', '感情容易受伤害', '旁人能知道您的想法',
    '感到不被理解', '感到人们不友好', '做事必须慢', '心跳厉害', '恶心',
    '感到比不上他人', '肌肉酸痛', '感到被监视', '难以入睡', '做事反复检查',
    '难以决定', '怕乘车', '呼吸困难', '发冷发热', '避开某些场合', '脑子变空',
    '身体发麻', '喉咙梗塞', '前途无望', '不能集中注意', '身体软弱', '感到紧张',
    '手脚发重', '想到死亡', '吃得太多', '当别人看着时感到不自在', '有不属于自己的想法',
    '有想打人的冲动', '醒得太早', '反复洗手点数', '睡得不稳', '想摔东西',
    '有别人没有的想法', '对别人神经过敏', '在人多处不自在', '感到事情困难',
    '一阵阵恐惧', '公共场合吃东西不舒服', '经常争论', '单独时紧张', '别人评价不当',
    '孤单', '坐立不安', '感到无价值', '熟悉的东西变陌生', '大叫或摔东西',
    '害怕晕倒', '感到别人想占便宜', '为性想法苦恼', '认为应该受罚', '感到要很快做事',
    '身体有严重问题', '从未感到亲近', '感到有罪', '感到脑子有毛病',
  ];

  final List<Map<String, dynamic>> _options = [
    {'label': '从无', 'val': 1, 'color': Colors.green},
    {'label': '很轻', 'val': 2, 'color': Colors.lightGreen},
    {'label': '中等', 'val': 3, 'color': Colors.yellow},
    {'label': '偏重', 'val': 4, 'color': Colors.orange},
    {'label': '严重', 'val': 5, 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _factors = [
    {'key': 'Somatization', 'nameCn': '躯体化', 'ids': [0, 3, 11, 26, 39, 41, 47, 48, 51, 52, 55, 57]},
    {'key': 'OCD', 'nameCn': '强迫', 'ids': [2, 8, 9, 27, 37, 44, 45, 50, 54, 64]},
    {'key': 'Interpersonal', 'nameCn': '人际敏感', 'ids': [5, 20, 33, 35, 36, 40, 60, 68, 72]},
    {'key': 'Depression', 'nameCn': '抑郁', 'ids': [4, 13, 14, 19, 21, 25, 28, 29, 30, 31, 53, 70, 78]},
    {'key': 'Anxiety', 'nameCn': '焦虑', 'ids': [1, 16, 22, 32, 38, 56, 71, 77, 79, 85]},
    {'key': 'Hostility', 'nameCn': '敌对', 'ids': [10, 23, 62, 66, 73, 80]},
    {'key': 'Phobic', 'nameCn': '恐怖', 'ids': [12, 24, 46, 49, 69, 74, 81]},
    {'key': 'Paranoid', 'nameCn': '偏执', 'ids': [7, 17, 42, 67, 75, 82]},
    {'key': 'Psychoticism', 'nameCn': '精神病性', 'ids': [6, 15, 34, 61, 76, 83, 84, 86, 87, 89]},
    {'key': 'Other', 'nameCn': '其他', 'ids': [18, 43, 58, 59, 63, 65, 88]},
  ];

  List<int> get _currentBatch {
    final start = _currentPage * _itemsPerPage;
    return List.generate(_itemsPerPage, (i) => start + i).where((i) => i < 90).toList();
  }

  bool get _canGoNext {
    return _currentBatch.every((i) => _answers[i] > 0);
  }

  double get _progress {
    final answered = _answers.where((a) => a > 0).length;
    return answered / 90;
  }

  bool get _isLastPage {
    return _currentPage >= (90 / _itemsPerPage).ceil() - 1;
  }

  String get _currentDate {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _startTest() {
    setState(() {
      _step = 1;
      _currentPage = 0;
      _answers.fillRange(0, 90, 0);
    });
  }

  void _answer(int questionIdx, int value) {
    setState(() {
      _answers[questionIdx] = value;
    });
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('scl90_answers', _answers.join(','));
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _nextPage() {
    if (!_isLastPage) {
      setState(() => _currentPage++);
    } else {
      _calc();
    }
  }

  void _calc() {
    int total = 0;
    int pos = 0;
    for (int v in _answers) {
      total += v;
      if (v >= 2) pos++;
    }

    final fScores = _factors.map((f) {
      final sum = f['ids'].fold<int>(0, (acc, id) => acc + _answers[id]);
      return {
        'key': f['key'],
        'nameEn': f['key'],
        'nameCn': f['nameCn'],
        'score': (sum / f['ids'].length).toDouble(),
      };
    }).toList();

    final dep = fScores.firstWhere((f) => f['key'] == 'Depression')['score'] as double;
    if (dep > 3 || _answers[14] >= 3) {
      _hasCrisis = true;
    }

    _results = {
      'totalScore': total,
      'positiveCount': pos,
      'factors': fScores,
    };

    setState(() => _step = 2);
    SharedPreferences.getInstance().then((prefs) => prefs.remove('scl90_answers'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFDFCF8),
        child: SafeArea(
          child: IndexedStack(
            index: _step,
            children: [
              _buildWelcome(),
              _buildQuestionnaire(),
              _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '症状自评量表 SCL-90',
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Symptom Checklist 90',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.sub,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('16+', '适用年龄'),
                Container(width: 1, height: 32, color: Colors.grey[300]),
                _buildStatItem('90', '项目数量'),
              ],
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: AppTheme.paper,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '开始测评',
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.sub,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaire() {
    return Column(
      children: [
        // 进度条
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.ink),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _currentBatch.map((qIdx) {
                return _buildQuestionItem(qIdx);
              }).toList(),
            ),
          ),
        ),
        // 底部导航
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _currentPage > 0 ? _prevPage : null,
                child: Text(
                  '← BACK',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.sub,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _canGoNext ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canGoNext ? AppTheme.ink : Colors.grey[300],
                  foregroundColor: _canGoNext ? Colors.white : Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: Text(
                  _isLastPage ? 'SUBMIT / 提交' : 'NEXT / 下一页',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(int qIdx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Text(
            'ITEM ${qIdx + 1} / 90',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.sub,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _questions[qIdx],
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              color: AppTheme.ink,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _options.map((opt) {
              final isSelected = _answers[qIdx] == opt['val'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => _answer(qIdx, opt['val'] as int),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? opt['color'] as Color : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? opt['color'] as Color : const Color(0xFFE5E5E5),
                        width: isSelected ? 0 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (opt['color'] as Color).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${opt['val']}',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.ink,
                          ),
                        ),
                        if (isSelected)
                          Text(
                            opt['label'] as String,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_results == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'Clinical Analysis Report',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.sub,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SCL-90 Assessment • $_currentDate',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.sub,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_hasCrisis)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[800]!.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '检测到特定指标数值较高。建议咨询专业医师。',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        color: Colors.red[900],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          _buildRadarChart(),
          const SizedBox(height: 32),
          ...(_results!['factors'] as List).map((factor) {
            return _buildFactorItem(factor);
          }).toList(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.ink),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Download PDF',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Restart',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.sub,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart() {
    final factors = _results!['factors'] as List;
    return SizedBox(
      height: 240,
      child: CustomPaint(
        size: const Size(240, 240),
        painter: RadarChartPainter(factors),
      ),
    );
  }

  Widget _buildFactorItem(Map<String, dynamic> factor) {
    final score = factor['score'] as double;
    final width = (score / 5) * 120;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor['nameEn'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),
                Text(
                  factor['nameCn'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.sub,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 5,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.medicalBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
            textAlign: TextAlign.end,
            width: 32,
          ),
        ],
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> factors;
  final int sides = 9;
  final double maxRadius = 100;

  RadarChartPainter(this.factors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppTheme.medicalBlue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppTheme.medicalBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final points = <Offset>[];
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * pi / sides) - pi / 2;
      final factor = factors[i];
      final value = (factor['score'] as double) / 5;
      final radius = maxRadius * value;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      points.add(Offset(x, y));
    }

    // 绘制背景网格
    for (int level = 1; level <= 5; level++) {
      final levelRadius = maxRadius * (level / 5);
      final levelPaint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, levelRadius, levelPaint);
    }

    // 绘制数据
    if (points.length == sides) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);

      // 绘制点
      for (final point in points) {
        canvas.drawCircle(point, 4, Paint()..color = AppTheme.medicalBlue);
      }
    }

    // 绘制标签
    final labelPaint = TextPainter(
      textDirection: TextDirection.ltr,
    );
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * pi / sides) - pi / 2;
      final labelRadius = maxRadius + 20;
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);
      labelPaint.text = TextSpan(
        text: factors[i]['nameCn'],
        style: const TextStyle(
          fontSize: 9,
          color: AppTheme.sub,
        ),
      );
      labelPaint.layout();
      labelPaint.paint(
        canvas,
        Offset(x - labelPaint.width / 2, y - labelPaint.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

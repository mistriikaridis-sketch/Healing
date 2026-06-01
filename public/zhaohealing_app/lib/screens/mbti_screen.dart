import 'package:flutter/material.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MBTIScreen extends StatefulWidget {
  const MBTIScreen({super.key});

  @override
  State<MBTIScreen> createState() => _MBTIScreenState();
}

class _MBTIScreenState extends State<MBTIScreen> {
  int _step = 0;
  int _currentIdx = 0;
  int? _selectedScore;
  final Map<String, int> _scores = {
    'E': 0, 'I': 0, 'N': 0, 'S': 0, 'T': 0, 'F': 0, 'J': 0, 'P': 0,
  };
  Map<String, dynamic>? _result;

  final List<Map<String, dynamic>> _questions = [
    {'q': '你经常结交新朋友。', 'd': 'E'},
    {'q': '复杂和新颖的想法比简单直接的想法更能激发你的兴趣。', 'd': 'N'},
    {'q': '你通常更容易被能引起你情感共鸣的观点说服。', 'd': 'F'},
    {'q': '你的生活和工作空间都很干净整洁。', 'd': 'J'},
    {'q': '你通常能够保持冷静，即使在很大的压力下也是如此。', 'd': 'T'},
    {'q': '你觉得与陌生人建立关系或自我推销是一件非常令人畏惧的事情。', 'd': 'I'},
    {'q': '你能够有效地确定任务优先级并进行规划。', 'd': 'J'},
    {'q': '人们的故事和情感对你来说更有说服力。', 'd': 'F'},
    {'q': '你喜欢使用日程表和清单等整理工具。', 'd': 'J'},
    {'q': '即使是一个小小的错误，也可能让你怀疑自己的整体能力。', 'd': 'T'},
    {'q': '你很自在地走到你觉得有趣的人面前，主动与他们交谈。', 'd': 'E'},
    {'q': '你对关于创意作品不同解读的讨论不太感兴趣。', 'd': 'S'},
    {'q': '在决定行动方案时，你更看重事实，而不是人们的感受。', 'd': 'T'},
    {'q': '你经常让一天自然而然地展开，完全没有任何计划。', 'd': 'P'},
    {'q': '你很少担心自己是否能给遇到的人留下好印象。', 'd': 'T'},
    {'q': '你喜欢参与团队合作的活动。', 'd': 'E'},
    {'q': '你喜欢尝试新的、尚未经过验证的方法。', 'd': 'N'},
    {'q': '你更看重体贴他人，而不是一味追求完全的坦诚。', 'd': 'F'},
    {'q': '你主动寻找新的体验和知识领域进行探索。', 'd': 'N'},
    {'q': '你容易担心事情会变得更糟。', 'd': 'F'},
    {'q': '你更喜欢独自进行的爱好或活动，而不是集体的。', 'd': 'I'},
    {'q': '你无法想象自己以写虚构故事为生。', 'd': 'S'},
    {'q': '你在做决策时更注重效率，即使这意味着要忽略某些情感因素。', 'd': 'T'},
    {'q': '你倾向于在放松之前先完成家务。', 'd': 'J'},
    {'q': '有意见分歧时，你更重视证明自己的观点，而不是顾全他人的感受。', 'd': 'T'},
    {'q': '在社交场合，你通常会等别人先自我介绍。', 'd': 'I'},
    {'q': '你的情绪变化得非常快。', 'd': 'F'},
    {'q': '你不容易被情绪化的论点所影响。', 'd': 'T'},
    {'q': '你经常拖到最后一刻才去做事情。', 'd': 'P'},
    {'q': '你喜欢辩论道德难题。', 'd': 'T'},
    {'q': '你通常更喜欢与他人在一起，而不是独自一人。', 'd': 'E'},
    {'q': '当讨论变得非常理论化时，你会感到无聊或失去兴趣。', 'd': 'S'},
    {'q': '当事实与感受发生冲突时，你通常会选择跟随自己的内心。', 'd': 'F'},
    {'q': '你发现很难保持规律的工作或学习计划。', 'd': 'P'},
    {'q': '你很少会对自己所做的决定产生怀疑。', 'd': 'T'},
    {'q': '你的朋友会说你性格活泼外向。', 'd': 'E'},
    {'q': '你喜欢多种形式的创意表达，比如写作。', 'd': 'N'},
    {'q': '你通常根据客观事实而不是情感印象来做出选择。', 'd': 'T'},
    {'q': '你喜欢为每天制定待办事项清单。', 'd': 'J'},
    {'q': '你很少感到不安。', 'd': 'T'},
    {'q': '你避免打电话。', 'd': 'I'},
    {'q': '你喜欢探索陌生的想法和观点。', 'd': 'N'},
    {'q': '你可以很容易地与刚认识的人建立联系。', 'd': 'E'},
    {'q': '如果你的计划被打乱，你的首要任务就是尽快让一切恢复正轨。', 'd': 'J'},
    {'q': '你依然为很久以前犯下的错误感到困扰。', 'd': 'F'},
    {'q': '你对讨论未来世界可能会是什么样子的理论并不太感兴趣。', 'd': 'S'},
    {'q': '你的情绪对你的影响大于你对它们的掌控。', 'd': 'F'},
    {'q': '在做决定时，你更关注受影响者的感受。', 'd': 'F'},
    {'q': '你的个人工作方式更像是一时的能量爆发，而不是有条理和持续的努力。', 'd': 'P'},
    {'q': '当有人很看重你时，你会想，他们多久之后会对你感到失望。', 'd': 'F'},
    {'q': '你会喜欢一份大部分时间需要独自工作的工作。', 'd': 'I'},
    {'q': '你觉得探讨抽象的哲学问题是在浪费时间。', 'd': 'S'},
    {'q': '比起安静私密的地方，你更喜欢热闹繁忙的环境。', 'd': 'E'},
    {'q': '如果你觉得某个决定是对的，你通常会直接采取行动，而不需要更多的证据。', 'd': 'J'},
    {'q': '你经常感到不堪重负。', 'd': 'F'},
    {'q': '你做事有条不紊，每一步都不会遗漏。', 'd': 'J'},
    {'q': '你更喜欢需要你提出创新解决方案的任务。', 'd': 'N'},
    {'q': '在做决定时，你更倾向于依靠情感直觉，而非逻辑推理。', 'd': 'F'},
    {'q': '你在应对截止日期时感到吃力。', 'd': 'P'},
    {'q': '你相信事情会朝对自己有利的方向发展。', 'd': 'T'},
  ];

  final Map<String, Map<String, dynamic>> _profiles = {
    'INTJ': {
      'name': '架构师 (Architect)',
      'quote': '思想铸就人类的伟大。',
      'author': '布莱士·帕斯卡',
      'desc': 'INTJ 人格类型（建筑师）求知若渴，质疑一切。\n\n他们将信念建立在坚实的证据、推理与理性之上。\n\n他们不惧打破规则，也不畏非议——事实上，他们常以此为乐。',
    },
    'INTP': {
      'name': '逻辑学家 (Logician)',
      'quote': '重要的是不要停止质疑。',
      'author': '阿尔伯特·爱因斯坦',
      'desc': 'INTP 渴望理解宇宙万物，常沉醉于自己思维的奇妙世界。\n\n对他们而言，最棒的对话如同头脑风暴，充满非常规思维与天马行空的假设。',
    },
    'INFJ': {
      'name': '提倡者 (Advocate)',
      'quote': '以人应然之态待之，方能助其臻于所能之境。',
      'author': '歌德',
      'desc': 'INFJ 既理想主义，又坚守原则。\n\n他们内心世界丰盈，一心执着于探寻人生意义。',
    },
    'INFP': {
      'name': '调停者 (Mediator)',
      'quote': '真金未必璀璨，徘徊之人未必迷失。',
      'author': 'J.R.R. 托尔金',
      'desc': 'INFP 外表或许文静，但内心如熊熊烈火。\n\n他们是真正的理想主义者，总是从最坏的人和事中寻找最好的一面。',
    },
    'ENFJ': {
      'name': '主人公 (Protagonist)',
      'quote': '当举世皆寂，哪怕一声轻呼，亦能振聋发聩。',
      'author': '马拉拉',
      'desc': 'ENFJ 是天生的领导者，充满激情与魅力。\n\n他们真诚地关心他人，能够以此鼓舞人心，带来积极的改变。',
    },
    'ENFP': {
      'name': '活动家 (Campaigner)',
      'quote': '我想知晓你是否有勇气逐梦。',
      'author': '奥利亚·孟腾·德雷默',
      'desc': 'ENFP 是真正的自由精神。\n\n他们外向热忱、思想豁达，在任何群体中都能脱颖而出。',
    },
    'ISTJ': {
      'name': '物流师 (Logistician)',
      'quote': '若不施展天赋，我定深感惶恐。',
      'author': '丹泽尔·华盛顿',
      'desc': 'ISTJ 向来言出必行，表里如一。\n\n他们是脚踏实地的践行者，对结构与传统怀有深切敬意。',
    },
    'ISFJ': {
      'name': '守护者 (Defender)',
      'quote': '爱，唯有分享，方能滋长。',
      'author': '布莱恩·崔西',
      'desc': 'ISFJ 谦逊低调，如幕后的无名英雄。\n\n他们勤奋敬业，对身边之人怀有深切的责任感。',
    },
    'ESTJ': {
      'name': '管理者 (Executive)',
      'quote': '良好秩序乃万物之基。',
      'author': '埃德蒙·伯克',
      'desc': 'ESTJ 是传统和秩序的化身。\n\n他们坚守诚实与专注，善于将人们团结起来，是出色的社区组织者。',
    },
    'ESFJ': {
      'name': '执政官 (Consul)',
      'quote': '彼此激励、相互扶持。',
      'author': '黛博拉·戴',
      'desc': 'ESFJ 极有同情心，乐于助人。\n\n对于他们来说，生活在与他人的分享中绽放光彩。',
    },
    'ISTP': {
      'name': '鉴赏家 (Virtuoso)',
      'quote': '我一心向往充满趣味与挑战的生活。',
      'author': '哈里森·福特',
      'desc': 'ISTP 是天生的制造者，热衷于凭借双手与双眼探索世界。',
    },
    'ISFP': {
      'name': '冒险家 (Adventurer)',
      'quote': '一日之间，我判若两人。',
      'author': '鲍勃·迪伦',
      'desc': 'ISFP 是真正的艺术家——生活就是他们自我表达的画布。',
    },
    'ESTP': {
      'name': '企业家 (Entrepreneur)',
      'quote': '人生若非一场勇敢的冒险，便毫无意义。',
      'author': '海伦·凯勒',
      'desc': 'ESTP 总是对周围的环境产生影响。\n\n他们活在当下，行动迅速，是聚会中的焦点。',
    },
    'ESFP': {
      'name': '表演者 (Entertainer)',
      'quote': '毫不犹豫地过好每分每秒。',
      'author': '埃尔顿·约翰',
      'desc': 'ESFP 是天生的表演者。\n\n他们热爱聚光灯，世界就是他们的舞台。',
    },
    'ENTJ': {
      'name': '指挥官 (Commander)',
      'quote': '生命有限，莫为他人而活。',
      'author': '史蒂夫·乔布斯',
      'desc': 'ENTJ 是天生的领导者，兼具魅力与自信。\n\n他们凭借动力、决心与敏锐头脑，达成既定目标。',
    },
    'ENTP': {
      'name': '辩论家 (Debater)',
      'quote': '追随独立思考者的道路。',
      'author': '托马斯·J·沃森',
      'desc': 'ENTP 人格类型（辩论家）机智大胆，不惧挑战现状。\n\n他们热衷于将他人论点撕成碎片。',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('mbti_result');
    if (jsonString != null) {
      setState(() {
        _result = {'code': 'INTJ', ..._profiles['INTJ']!};
        _step = 2;
      });
    }
  }

  void _start() {
    setState(() {
      _step = 1;
      _currentIdx = 0;
      _scores.clear();
      _selectedScore = null;
    });
  }

  void _retake() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('mbti_result');
    _start();
  }

  void _selectScore(int score) {
    setState(() => _selectedScore = score);
  }

  void _next() {
    if (_selectedScore == null) return;

    final q = _questions[_currentIdx];
    final map = {'E': 'I', 'I': 'E', 'N': 'S', 'S': 'N', 'T': 'F', 'F': 'T', 'J': 'P', 'P': 'J'};

    if (_selectedScore! <= 3) {
      _scores[map[q['d']]!] = (_scores[map[q['d']]!] ?? 0) + (4 - _selectedScore!);
    } else if (_selectedScore! >= 5) {
      _scores[q['d']!] = (_scores[q['d']]! ?? 0) + (_selectedScore! - 4);
    }

    _selectedScore = null;

    if (_currentIdx < _questions.length - 1) {
      setState(() => _currentIdx++);
    } else {
      _calcResult();
    }
  }

  void _calcResult() {
    final type =
        (_scores['E']! >= _scores['I']! ? 'E' : 'I') +
        (_scores['N']! >= _scores['S']! ? 'N' : 'S') +
        (_scores['T']! >= _scores['F']! ? 'T' : 'F') +
        (_scores['J']! >= _scores['P']! ? 'J' : 'P');

    _result = {'code': type, ..._profiles[type] ?? _profiles['INTJ']!};

    // 保存结果
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('mbti_result', type);
    });

    setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.bgWarm,
        child: SafeArea(
          child: IndexedStack(
            index: _step,
            children: [
              _buildWelcome(),
              _buildQuestion(),
              _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'MBTI 人格分析',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '深度解析性格底色 · 60道精选题',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.sub,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _start,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Text(
              '开始测试',
              style: const TextStyle(
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentIdx];
    final progress = (_currentIdx + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIdx + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.sub,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '/ ${_questions.length}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.sub,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E5E5),
              valueColor: const AlwaysStoppedAnimation(AppTheme.ink),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            q['q']!,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 20,
              color: AppTheme.ink,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildLikertScale(),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _selectedScore != null ? _next : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Text(
              '下一步',
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikertScale() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '同意',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 16),
        ...List.generate(7, (index) {
          final i = index + 1;
          final isSelected = _selectedScore == i;
          final size = i == 4 ? 30.0 : (i == 1 || i == 7 ? 60.0 : 50.0);
          return GestureDetector(
            onTap: () => _selectScore(i),
            child: Container(
              width: size,
              height: size,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.accent : Colors.white,
                border: Border.all(
                  color: isSelected ? AppTheme.accent : const Color(0xFFE5E5E5),
                  width: isSelected ? 0 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? null
                  : Center(
                      child: Text(
                        '$i',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.sub,
                        ),
                      ),
                    ),
            ),
          );
        }),
        const SizedBox(width: 16),
        Text(
          '不认同',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    if (_result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Your Personality Type',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.sub,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _result!['code'],
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _result!['name'],
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 20,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '"${_result!['quote']}"',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '— ${_result!['author']}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.sub,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _result!['desc'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.sub,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  '返回主页',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.ink,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _retake,
                child: Text(
                  '重新测试',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.sub.withOpacity(0.5),
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
}

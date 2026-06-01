import 'package:flutter/material.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'dart:math' as math;

class OracleScreen extends StatefulWidget {
  const OracleScreen({super.key});

  @override
  State<OracleScreen> createState() => _OracleScreenState();
}

class _OracleScreenState extends State<OracleScreen> {
  int _activeTab = 0; // 0: cards, 1: book
  bool _isShuffling = false;
  int? _selectedCard;
  bool _isPressing = false;
  double _pressProgress = 0;
  bool _bookIsOpen = false;
  Map<String, dynamic>? _currentAnswer;
  int? _pressDuration;

  final List<Map<String, dynamic>> _cards = List.generate(
    30,
    (i) => {
      'id': i,
      'image': 'images/${i + 1}.jpg',
    },
  );

  final List<Map<String, dynamic>> _answers = [
    {'cn': '真正的智慧源于每日不间断的阅读与学习。', 'en': 'True wisdom comes from constant reading.'},
    {'cn': '承认"我不知道"是智慧的开端。', 'en': 'Admitting "I don\'t know" is the beginning of wisdom.'},
    {'cn': '理性是道德责任。', 'en': 'Rationality is a moral duty.'},
    {'cn': '不要自怜，而是建设性地利用打击。', 'en': 'Don\'t pity yourself; use the blow constructively.'},
    {'cn': '避免犯蠢，胜过追求聪明。', 'en': 'Avoiding stupidity is better than seeking brilliance.'},
    {'cn': '学会"如何学习"，比记住答案更重要。', 'en': 'Learning "how to learn" is more important than memorizing answers.'},
    {'cn': '当下即是永恒。', 'en': 'The present moment is eternal.'},
    {'cn': '放下执念，获得自由。', 'en': 'Let go of attachments to find freedom.'},
    {'cn': '一切皆流，万物皆变。', 'en': 'Everything flows, everything changes.'},
    {'cn': '简单是终极的复杂。', 'en': 'Simplicity is the ultimate sophistication.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.bgWarm,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _activeTab == 0 ? _buildCardsTab() : _buildBookTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'label': '读心卡牌', 'key': 'cards'},
      {'label': '答案之书', 'key': 'book'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: tabs.asMap().entries.map((entry) {
          final isSelected = _activeTab == entry.key;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = entry.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    entry.value['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: isSelected ? AppTheme.ink : AppTheme.sub,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 60 : 0,
                    height: 2,
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardsTab() {
    return Center(
      child: _selectedCard == null
          ? _buildCardDeck()
          : _buildSelectedCard(),
    );
  }

  Widget _buildCardDeck() {
    return GestureDetector(
      onTap: _isShuffling ? null : _drawCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isShuffling) ...[
            Text(
              'The Oracle',
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontStyle: FontStyle.italic,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click Deck to Draw',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.sub,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 32),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.ink.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _isShuffling ? '' : '♦',
                style: TextStyle(
                  fontSize: 48,
                  color: AppTheme.accent.withOpacity(0.6),
                ),
              ),
            ),
          ).animate().shake(
                duration: const Duration(milliseconds: 150),
                count: _isShuffling ? 1000 : 0,
              ),
        ],
      ),
    );
  }

  void _drawCard() {
    setState(() => _isShuffling = true);

    // 模拟洗牌动画
    Future.delayed(const Duration(milliseconds: 800), () {
      final random = math.Random().nextInt(_cards.length);
      setState(() {
        _isShuffling = false;
        _selectedCard = random;
      });
    });
  }

  Widget _buildSelectedCard() {
    final card = _cards[_selectedCard!];

    return GestureDetector(
      onTap: () => setState(() => _selectedCard = null),
      child: Container(
        color: AppTheme.bgWarm.withOpacity(0.95),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                height: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ink.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://source.unsplash.com/random/400x600/?abstract,nature&sig=${card['id']}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.paper,
                      child: Center(
                        child: Text(
                          '♦',
                          style: TextStyle(
                            fontSize: 64,
                            color: AppTheme.accent.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '"What message does this image hold for you?"',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.sub.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _selectedCard = null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.ink),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Close',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildBookTab() {
    return Center(
      child: Stack(
        children: [
          // 展开的书
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _bookIsOpen ? 1 : 0,
            child: GestureDetector(
              onTap: _bookIsOpen ? _resetBook : null,
              child: Container(
                width: 280,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ink.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.format_quote, size: 48, color: AppTheme.accent),
                    const SizedBox(height: 24),
                    if (_currentAnswer != null) ...[
                      Text(
                        _currentAnswer!['en'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.sub,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentAnswer!['cn'],
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _resetBook,
                      child: Text(
                        'Ask Again',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.sub,
                          letterSpacing: 2,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 闭合的书
          GestureDetector(
            onTapDown: (_) => _startPress(),
            onTapUp: (_) => _endPress(),
            onTapCancel: _endPress,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _bookIsOpen ? 0 : 1,
              child: Container(
                width: 280,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0E9),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFCCCCCC), width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ink.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 320,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'THE BOOK',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ink,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Of Wisdom',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.sub,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 80),
                          Column(
                            children: [
                              Text(
                                'Press & Hold',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _isPressing ? AppTheme.accent : AppTheme.ink,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _pressProgress,
                                    minHeight: 2,
                                    backgroundColor: const Color(0xFFE5E5E5),
                                    valueColor: AlwaysStoppedAnimation(AppTheme.accent),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          Text(
                            '3 Seconds',
                            style: const TextStyle(
                              fontSize: 8,
                              color: AppTheme.sub.withOpacity(0.3),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startPress() {
    if (_bookIsOpen) return;

    setState(() => _isPressing = true);
    _pressDuration = DateTime.now().millisecondsSinceEpoch;

    // 进度条动画
    Future.doWhile(() async {
      if (!_isPressing) return false;
      final elapsed = DateTime.now().millisecondsSinceEpoch - _pressDuration!;
      final progress = (elapsed / 3000).clamp(0, 1);
      setState(() => _pressProgress = progress);
      await Future.delayed(const Duration(milliseconds: 16));
      if (progress >= 1) {
        _openBook();
        return false;
      }
      return true;
    });
  }

  void _endPress() {
    if (_bookIsOpen) return;

    setState(() {
      _isPressing = false;
      _pressProgress = 0;
    });
  }

  void _openBook() {
    setState(() {
      _bookIsOpen = true;
      _isPressing = false;
      _currentAnswer = _answers[math.Random().nextInt(_answers.length)];
    });
  }

  void _resetBook() {
    setState(() => _bookIsOpen = false);
  }
}

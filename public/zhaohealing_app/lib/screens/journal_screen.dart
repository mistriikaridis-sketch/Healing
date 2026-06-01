import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zhaohealing/providers/app_provider.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _view = 0; // 0: write, 1: history
  final TextEditingController _achievementController = TextEditingController();
  final TextEditingController _gratitudeController = TextEditingController();
  final TextEditingController _moodTextController = TextEditingController();
  String _moodVal = 'Calm';

  final List<String> _moods = ['Sunny', 'Cloudy', 'Rainy', 'Storm', 'Calm'];
  final List<IconData> _moodIcons = [
    Icons.wb_sunny,
    Icons.cloud,
    Icons.umbrella,
    Icons.thunderstorm,
    Icons.self_improvement
  ];

  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('journal_history');
    if (jsonString != null) {
      // 解析历史记录
    }
    setState(() {});
  }

  String _getDateDisplay() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, yyyy', 'zh_CN').format(now);
  }

  void _save() {
    if (_moodTextController.text.trim().isEmpty &&
        _achievementController.text.trim().isEmpty) return;

    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'dateStr': DateFormat('yyyy年M月d日', 'zh_CN').format(DateTime.now()),
      'moodVal': _moodVal,
      'text': _moodTextController.text,
      'achievement': _achievementController.text,
      'gratitude': _gratitudeController.text,
    };

    _history.insert(0, entry);
    // 保存到本地
    _saveToLocal();

    _achievementController.clear();
    _gratitudeController.clear();
    _moodTextController.clear();
    _moodVal = 'Calm';
    _view = 1;
    setState(() {});
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('journal_history', _history.toString());
  }

  @override
  Widget build(BuildContext context) {
    final quotes = {
      'cn': '命运不是风，来回吹，命运是大地，走到哪你都在命运中。',
      'en': 'Fate is not the wind, but the earth.',
    };

    return Scaffold(
      body: Container(
        color: const Color(0xFFF9F8F4),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildNavBar(),
              _buildQuote(quotes),
              Expanded(
                child: _view == 0 ? _buildWriteView() : _buildHistoryView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          'Know Your Self',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavItem('深读 / 今日书写', 0),
          const SizedBox(width: 32),
          _buildNavItem('过往 / 历史篇章', 1),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, int index) {
    final isSelected = _view == index;
    return GestureDetector(
      onTap: () => setState(() => _view = index),
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: isSelected ? AppTheme.ink : AppTheme.sub,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 40 : 0,
            color: AppTheme.ink,
          ),
        ],
      ),
    );
  }

  Widget _buildQuote(Map<String, String> quote) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Column(
        children: [
          Text(
            quote['cn']!,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              color: AppTheme.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '— ${quote['en']}',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.sub,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _getDateDisplay(),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.sub,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSection('Achievement', '小确幸', '记录今日的微小成就...'),
          const SizedBox(height: 24),
          _buildSection('Gratitude', '感恩时刻', '值得感谢的人或事...'),
          const SizedBox(height: 24),
          _buildMoodSection(),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.ink,
                side: const BorderSide(color: AppTheme.ink),
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
              ),
              child: Text(
                '保存',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String enTitle, String cnTitle, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          enTitle,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.sub,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cnTitle,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: enTitle == 'Achievement'
              ? _achievementController
              : _gratitudeController,
          maxLines: null,
          minLines: 3,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            color: AppTheme.ink,
            height: 1.6,
          ),
          cursorColor: AppTheme.accent,
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Check-in',
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.sub,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '心境',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_moods.length, (index) {
            final mood = _moods[index];
            final isSelected = _moodVal == mood;
            return GestureDetector(
              onTap: () => setState(() => _moodVal = mood),
              child: AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.ink : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _moodIcons[index],
                        color: isSelected ? Colors.white : AppTheme.sub,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood,
                      style: const TextStyle(
                        fontSize: 10,
                        color: isSelected ? AppTheme.ink : AppTheme.sub,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _moodTextController,
          maxLines: null,
          minLines: 2,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            color: AppTheme.ink,
            height: 1.6,
          ),
          cursorColor: AppTheme.accent,
          decoration: InputDecoration(
            hintText: '此刻的念头...',
            hintStyle: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              color: AppTheme.sub.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    if (_history.isEmpty) {
      return Center(
        child: Text(
          '暂无记录，开始书写第一篇章。',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.sub,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _history.map((item) {
          return _buildHistoryItem(item);
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'HEAL',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.sub,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${item['dateStr']}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.sub,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${item['moodVal']}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Inner Self',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item['text']?.substring(0, 100) ?? '',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              color: const Color(0xFF555555),
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showDetail(item),
            child: Text(
              '阅读全文',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.ink,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '【心境】${item['moodVal']}',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['text'] ?? '',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '[小确幸]: ${item['achievement'] ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.sub,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '[感恩]: ${item['gratitude'] ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.sub,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

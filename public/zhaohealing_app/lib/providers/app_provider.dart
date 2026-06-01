import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // 日记数据
  List<Map<String, dynamic>> _journalEntries = [];
  List<Map<String, dynamic>> get journalEntries => _journalEntries;

  // MBTI 结果
  Map<String, dynamic>? _mbtiResult;
  Map<String, dynamic>? get mbtiResult => _mbtiResult;

  // SCL90 数据
  List<int> _scl90Answers = [];
  List<int> get scl90Answers => _scl90Answers;
  Map<String, dynamic>? _scl90Result;
  Map<String, dynamic>? get scl90Result => _scl90Result;

  // 灵犀对话状态
  String _chatState = 'idle';
  String get chatState => _chatState;
  String _chatSubtitle = '';
  String get chatSubtitle => _chatSubtitle;

  // 聊天历史
  List<Map<String, dynamic>> _chatMessages = [];
  List<Map<String, dynamic>> get chatMessages => _chatMessages;

  bool _isInitialized = false;

  // ==================== 初始化 ====================

  Future<void> init() async {
    if (_isInitialized) return;

    await DatabaseService.init();
    await _loadTheme();
    await _loadJournals();
    await _loadMbti();
    await _loadScl90();
    await _loadChatMessages();

    _isInitialized = true;
  }

  // ==================== 主题管理 ====================

  Future<void> _loadTheme() async {
    final mode = DatabaseService.getThemeMode();
    _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    DatabaseService.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    DatabaseService.setThemeMode(_themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  // ==================== 日记相关 ====================

  Future<void> _loadJournals() async {
    _journalEntries = DatabaseService.getJournals();
    notifyListeners();
  }

  Future<void> saveJournal({
    required String moodVal,
    required String achievement,
    required String gratitude,
    required String moodText,
  }) async {
    final entry = {
      'id': const Uuid().v4(),
      'date': DateTime.now().toIso8601String(),
      'moodVal': moodVal,
      'achievement': achievement,
      'gratitude': gratitude,
      'moodText': moodText,
    };

    await DatabaseService.saveJournal(entry);
    _journalEntries.insert(0, entry);
    notifyListeners();
  }

  Future<void> deleteJournal(String id) async {
    await DatabaseService.deleteJournal(id);
    _journalEntries.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }

  // ==================== MBTI 相关 ====================

  Future<void> _loadMbti() async {
    _mbtiResult = DatabaseService.getMbtiResult();
  }

  void saveMbtiResult(Map<String, dynamic> result) {
    _mbtiResult = result;
    DatabaseService.saveMbtiResult(result);
    notifyListeners();
  }

  void deleteMbtiResult() {
    _mbtiResult = null;
    DatabaseService.deleteMbtiResult();
    notifyListeners();
  }

  // ==================== SCL90 相关 ====================

  Future<void> _loadScl90() async {
    final answers = DatabaseService.getScl90Answers();
    if (answers != null) {
      _scl90Answers = answers;
    }
  }

  void saveScl90Answer(int index, int value) {
    if (index >= 0 && index < 90) {
      while (_scl90Answers.length < index) {
        _scl90Answers.add(0);
      }
      if (_scl90Answers.length == index) {
        _scl90Answers.add(value);
      } else {
        _scl90Answers[index] = value;
      }
      notifyListeners();
    }
  }

  void saveScl90Result(Map<String, dynamic> result) {
    _scl90Result = result;
    DatabaseService.saveScl90Answers(_scl90Answers);
    notifyListeners();
  }

  void clearScl90() {
    _scl90Answers = List.filled(90, 0);
    _scl90Result = null;
    notifyListeners();
  }

  // ==================== 聊天相关 ====================

  Future<void> _loadChatMessages() async {
    _chatMessages = DatabaseService.getChatMessages();
  }

  void addChatMessage(String content, bool isUser) {
    final message = {
      'id': const Uuid().v4(),
      'content': content,
      'isUser': isUser,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _chatMessages.add(message);
    DatabaseService.saveChatMessage(message);
    notifyListeners();
  }

  void clearChatMessages() {
    _chatMessages = [];
    DatabaseService.clearChatMessages();
    notifyListeners();
  }

  // ==================== 灵犀对话状态 ====================

  void updateChatState(String state, {String? subtitle}) {
    _chatState = state;
    if (subtitle != null) _chatSubtitle = subtitle;
    notifyListeners();
  }

  void updateChatSubtitle(String subtitle) {
    _chatSubtitle = subtitle;
    notifyListeners();
  }
}

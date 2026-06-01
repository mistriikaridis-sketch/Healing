import 'package:shared_preferences/shared_preferences.dart';

/// 数据库服务 - 使用 SharedPreferences 存储
/// 支持：日记、设置、MBTI、SCL90、聊天记录
class DatabaseService {
  static SharedPreferences? _prefs;

  /// 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== 日记相关 ====================

  /// 保存日记条目
  static Future<void> saveJournal(Map<String, dynamic> entry) async {
    final journals = _getList('journals');
    journals.insert(0, entry);
    await _prefs!.setStringList('journals', journals.map((e) => _encode(e)).toList());
  }

  /// 获取所有日记
  static List<Map<String, dynamic>> getJournals() {
    final list = _getList('journals');
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// 删除日记
  static Future<void> deleteJournal(String id) async {
    final journals = _getList('journals');
    journals.removeWhere((e) => e['id'] == id);
    await _prefs!.setStringList('journals', journals.map((e) => _encode(e)).toList());
  }

  // ==================== 设置相关 ====================

  static String? getSetting(String key) => _prefs!.getString(key);
  static Future<void> setSetting(String key, String value) async => await _prefs!.setString(key, value);
  static String getThemeMode() => getSetting('theme_mode') ?? 'light';
  static Future<void> setThemeMode(String mode) async => await setSetting('theme_mode', mode);

  // ==================== MBTI 相关 ====================

  static Map<String, dynamic>? getMbtiResult() {
    final json = _prefs!.getString('mbti_result');
    return json != null ? _decode(json) : null;
  }

  static Future<void> saveMbtiResult(Map<String, dynamic> result) async {
    await _prefs!.setString('mbti_result', _encode(result));
  }

  static Future<void> deleteMbtiResult() async => await _prefs!.remove('mbti_result');

  // ==================== SCL90 相关 ====================

  static List<int>? getScl90Answers() {
    final list = _prefs!.getStringList('scl90_answers');
    return list?.map((e) => int.parse(e)).toList();
  }

  static Future<void> saveScl90Answers(List<int> answers) async {
    await _prefs!.setStringList('scl90_answers', answers.map((e) => e.toString()).toList());
    await _prefs!.setString('scl90_completed_at', DateTime.now().toIso8601String());
  }

  static String? getScl90CompletedAt() => _prefs!.getString('scl90_completed_at');

  // ==================== 聊天记录相关 ====================

  static Future<void> saveChatMessage(Map<String, dynamic> message) async {
    final messages = _getList('chat_messages');
    messages.add(message);
    // 只保留最近100条
    if (messages.length > 100) {
      messages.removeRange(0, messages.length - 100);
    }
    await _prefs!.setStringList('chat_messages', messages.map((e) => _encode(e)).toList());
  }

  static List<Map<String, dynamic>> getChatMessages() {
    final list = _getList('chat_messages');
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> clearChatMessages() async => await _prefs!.remove('chat_messages');

  // ==================== 导出功能 ====================

  static Map<String, dynamic> exportAllData() {
    return {
      'theme_mode': getThemeMode(),
      'journals': getJournals(),
      'mbti': getMbtiResult(),
      'scl90_completed_at': getScl90CompletedAt(),
      'chat_messages': getChatMessages(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // ==================== 内部工具 ====================

  static List<Map<String, dynamic>> _getList(String key) {
    final list = _prefs!.getStringList(key) ?? [];
    return list.map((e) => Map<String, dynamic>.from(_decode(e))).toList();
  }

  static String _encode(Map<String, dynamic> data) {
    return data.entries.map((e) {
      final value = e.value;
      if (value is List) {
        return '${e.key}:[${value.join(',')}]';
      }
      return '${e.key}:${value.toString().replaceAll(':', '\\:').replaceAll(',', '\\,')}';
    }).join('|');
  }

  static Map<String, dynamic> _decode(String data) {
    final result = <String, dynamic>{};
    final parts = data.split('|');
    for (final part in parts) {
      final eqIndex = part.indexOf(':');
      if (eqIndex == -1) continue;
      final key = part.substring(0, eqIndex);
      var value = part.substring(eqIndex + 1);
      value = value.replaceAll('\\,', ',').replaceAll('\\:', ':');
      result[key] = value;
    }
    return result;
  }
}

/// 音频资源配置
/// 定义所有可用的声景和引导音频

class AudioConfig {
  // ==================== 自然类声景 ====================
  static const List<SoundTrack> natureSounds = [
    SoundTrack(
      id: 'campfire',
      title: '营地篝火',
      file: 'assets/audio/Nature-audio/Campfire.MP3',
      cover: 'assets/images/Nature-audio/campfire.jpg',
      duration: 300,
    ),
    SoundTrack(
      id: 'seabreeze',
      title: '海浪',
      file: 'assets/audio/Nature-audio/Seabreeze.MP3',
      cover: 'assets/images/Nature-audio/seabreeze.jpg',
      duration: 240,
    ),
    SoundTrack(
      id: 'blizzard',
      title: '踏雪寻梅',
      file: 'assets/audio/Nature-audio/Blizzard.MP3',
      cover: 'assets/images/Nature-audio/blizzard.jpg',
      duration: 280,
    ),
    SoundTrack(
      id: 'bamboo',
      title: '竹林雨声',
      file: 'assets/audio/Nature-audio/Bamboo.MP3',
      cover: 'assets/images/Nature-audio/bamboo.jpg',
      duration: 260,
    ),
    SoundTrack(
      id: 'whale',
      title: '鲸语',
      file: 'assets/audio/Nature-audio/Leviathan.MP3',
      cover: 'assets/images/Nature-audio/whale.jpg',
      duration: 320,
    ),
    SoundTrack(
      id: 'cascade',
      title: '瀑布',
      file: 'assets/audio/Nature-audio/Cascade.MP3',
      cover: 'assets/images/Nature-audio/cascade.jpg',
      duration: 290,
    ),
    SoundTrack(
      id: 'dunes',
      title: '沙丘',
      file: 'assets/audio/Nature-audio/Dunes.MP3',
      cover: 'assets/images/Nature-audio/dunes.jpg',
      duration: 270,
    ),
    SoundTrack(
      id: 'echo',
      title: '回声谷',
      file: 'assets/audio/Nature-audio/Echo.MP3',
      cover: 'assets/images/Nature-audio/echo.jpg',
      duration: 310,
    ),
    SoundTrack(
      id: 'gravel',
      title: '碎石路',
      file: 'assets/audio/Nature-audio/Gravel.MP3',
      cover: 'assets/images/Nature-audio/gravel.jpg',
      duration: 220,
    ),
    SoundTrack(
      id: 'brook',
      title: '溪流',
      file: 'assets/audio/Nature-audio/Brook.MP3',
      cover: 'assets/images/Nature-audio/brook.jpg',
      duration: 250,
    ),
  ];

  // ==================== 禅意类声景 ====================
  static const List<SoundTrack> zenSounds = [
    SoundTrack(
      id: 'mountain_stream',
      title: '高山流水',
      file: 'assets/audio/East-audio/Mountain Streamflow.mp3',
      cover: 'assets/images/East-audio/mountain.jpg',
      duration: 360,
    ),
    SoundTrack(
      id: 'summer_breeze',
      title: '夏日微风',
      file: 'assets/audio/East-audio/Summer Breeze.mp3',
      cover: 'assets/images/East-audio/summer.jpg',
      duration: 300,
    ),
    SoundTrack(
      id: 'breathing_vine',
      title: '藤蔓呼吸',
      file: 'assets/audio/East-audio/Breathing Vine.mp3',
      cover: 'assets/images/East-audio/vine.jpg',
      duration: 340,
    ),
    SoundTrack(
      id: 'journey',
      title: '漫漫长路',
      file: 'assets/audio/East-audio/Gradual Journey.mp3',
      cover: 'assets/images/East-audio/journey.jpg',
      duration: 380,
    ),
    SoundTrack(
      id: 'lunar_night',
      title: '月夜',
      file: 'assets/audio/East-audio/Lunar Night.mp3',
      cover: 'assets/images/East-audio/lunar.jpg',
      duration: 320,
    ),
    SoundTrack(
      id: 'hearthfire',
      title: '炉火梦境',
      file: 'assets/audio/East-audio/Hearthfire Dream.mp3',
      cover: 'assets/images/East-audio/hearthfire.jpg',
      duration: 360,
    ),
    SoundTrack(
      id: 'ink_wash',
      title: '水墨',
      file: 'assets/audio/East-audio/Ink-Wash.mp3',
      cover: 'assets/images/East-audio/ink.jpg',
      duration: 400,
    ),
    SoundTrack(
      id: 'dawn_pulse',
      title: '晨曦脉动',
      file: 'assets/audio/East-audio/Dawn Pulse.mp3',
      cover: 'assets/images/East-audio/dawn.jpg',
      duration: 340,
    ),
    SoundTrack(
      id: 'void',
      title: '虚空',
      file: 'assets/audio/East-audio/Void.mp3',
      cover: 'assets/images/East-audio/void.jpg',
      duration: 420,
    ),
    SoundTrack(
      id: 'pale',
      title: '清白',
      file: 'assets/audio/East-audio/Pale .mp3',
      cover: 'assets/images/East-audio/pale.jpg',
      duration: 380,
    ),
  ];

  // ==================== 书斋类声景 ====================
  static const List<SoundTrack> studySounds = [
    SoundTrack(
      id: 'afternoon',
      title: '午后',
      file: 'assets/audio/Study-audio/Afternoon.mp3',
      cover: 'assets/images/Study-audio/afternoon.jpg',
      duration: 300,
    ),
    SoundTrack(
      id: 'relic',
      title: '古籍',
      file: 'assets/audio/Study-audio/Relic.mp3',
      cover: 'assets/images/Study-audio/relic.jpg',
      duration: 360,
    ),
    SoundTrack(
      id: 'cocoon',
      title: '茧',
      file: 'assets/audio/Study-audio/Cocoon.mp3',
      cover: 'assets/images/Study-audio/cocoon.jpg',
      duration: 320,
    ),
    SoundTrack(
      id: 'pink_noise',
      title: '粉色噪音',
      file: 'assets/audio/Study-audio/Pink.mp3',
      cover: 'assets/images/Study-audio/pink.jpg',
      duration: 600,
    ),
    SoundTrack(
      id: 'event',
      title: '黑洞',
      file: 'assets/audio/Study-audio/Event.mp3',
      cover: 'assets/images/Study-audio/event.jpg',
      duration: 380,
    ),
    SoundTrack(
      id: 'nucleus',
      title: '核心',
      file: 'assets/audio/Study-audio/Nucleus.mp3',
      cover: 'assets/images/Study-audio/nucleus.jpg',
      duration: 400,
    ),
    SoundTrack(
      id: 'tide',
      title: '潮汐',
      file: 'assets/audio/Study-audio/Tide.mp3',
      cover: 'assets/images/Study-audio/tide.jpg',
      duration: 340,
    ),
    SoundTrack(
      id: 'haze',
      title: '迷雾',
      file: 'assets/audio/Study-audio/Haze.mp3',
      cover: 'assets/images/Study-audio/haze.jpg',
      duration: 360,
    ),
    SoundTrack(
      id: 'granular',
      title: '盆景',
      file: 'assets/audio/Study-audio/Granular .mp3',
      cover: 'assets/images/Study-audio/granular.jpg',
      duration: 320,
    ),
    SoundTrack(
      id: 'circuit',
      title: '雨滴',
      file: 'assets/audio/Study-audio/Circuit.mp3',
      cover: 'assets/images/Study-audio/circuit.jpg',
      duration: 280,
    ),
  ];

  // ==================== 食味类声景 ====================
  static const List<SoundTrack> foodSounds = [
    SoundTrack(
      id: 'stir_fry',
      title: '爆炒',
      file: 'assets/audio/Food-audio/Stir-fry.MP3',
      cover: 'assets/images/Food-audio/stirfry.jpg',
      duration: 180,
    ),
    SoundTrack(
      id: 'washing',
      title: '清洗',
      file: 'assets/audio/Food-audio/Washing.MP3',
      cover: 'assets/images/Food-audio/washing.jpg',
      duration: 120,
    ),
    SoundTrack(
      id: 'cut',
      title: '切菜',
      file: 'assets/audio/Food-audio/Cut.MP3',
      cover: 'assets/images/Food-audio/cut.jpg',
      duration: 150,
    ),
    SoundTrack(
      id: 'tableware',
      title: '餐具',
      file: 'assets/audio/Food-audio/Tableware.MP3',
      cover: 'assets/images/Food-audio/tableware.jpg',
      duration: 100,
    ),
    SoundTrack(
      id: 'drink',
      title: '饮水',
      file: 'assets/audio/Food-audio/Drink.MP3',
      cover: 'assets/images/Food-audio/drink.jpg',
      duration: 80,
    ),
    SoundTrack(
      id: 'chew',
      title: '咀嚼',
      file: 'assets/audio/Food-audio/Chew.MP3',
      cover: 'assets/images/Food-audio/chew.jpg',
      duration: 200,
    ),
    SoundTrack(
      id: 'boil',
      title: '煮沸',
      file: 'assets/audio/Food-audio/Boil.MP3',
      cover: 'assets/images/Food-audio/boil.jpg',
      duration: 220,
    ),
    SoundTrack(
      id: 'fry',
      title: '煎炸',
      file: 'assets/audio/Food-audio/Fry.MP3',
      cover: 'assets/images/Food-audio/fry.jpg',
      duration: 180,
    ),
    SoundTrack(
      id: 'crack',
      title: '嗑瓜子',
      file: 'assets/audio/Food-audio/Crack.MP3',
      cover: 'assets/images/Food-audio/crack.jpg',
      duration: 160,
    ),
    SoundTrack(
      id: 'tear',
      title: '撕包装',
      file: 'assets/audio/Food-audio/Tear.MP3',
      cover: 'assets/images/Food-audio/tear.jpg',
      duration: 60,
    ),
  ];

  // ==================== 正念引导音频 ====================
  static const List<SoundTrack> mindGuides = [
    SoundTrack(
      id: 'define_stress',
      title: '定义压力',
      file: 'assets/audio/Mind-audio/定义压力.mp3',
      cover: 'assets/images/Mind-audio/define_stress.jpg',
      duration: 600,
    ),
    SoundTrack(
      id: 'stress_awareness',
      title: '压力觉察',
      file: 'assets/audio/Mind-audio/压力觉察.mp3',
      cover: 'assets/images/Mind-audio/stress_awareness.jpg',
      duration: 720,
    ),
    SoundTrack(
      id: 'cognitive_boost',
      title: '认知提升',
      file: 'assets/audio/Mind-audio/认知提升.mp3',
      cover: 'assets/images/Mind-audio/cognitive.jpg',
      duration: 840,
    ),
    SoundTrack(
      id: 'ignite_passion',
      title: '唤醒激情',
      file: 'assets/audio/Mind-audio/唤醒激情.mp3',
      cover: 'assets/images/Mind-audio/passion.jpg',
      duration: 660,
    ),
    SoundTrack(
      id: 'present_moment',
      title: '关注当下',
      file: 'assets/audio/Mind-audio/关注当下.mp3',
      cover: 'assets/images/Mind-audio/present.jpg',
      duration: 780,
    ),
    SoundTrack(
      id: 'emotion_perception',
      title: '情绪感知',
      file: 'assets/audio/Mind-audio/情绪感知.mp3',
      cover: 'assets/images/Mind-audio/emotion.jpg',
      duration: 600,
    ),
    SoundTrack(
      id: 'listen_anger',
      title: '聆听怒火',
      file: 'assets/audio/Mind-audio/聆听怒火.mp3',
      cover: 'assets/images/Mind-audio/anger.jpg',
      duration: 540,
    ),
    SoundTrack(
      id: 'adjust_emotion',
      title: '调整情绪',
      file: 'assets/audio/Mind-audio/调整情绪.mp3',
      cover: 'assets/images/Mind-audio/adjust.jpg',
      duration: 660,
    ),
    SoundTrack(
      id: 'handle_conflict',
      title: '应对冲突',
      file: 'assets/audio/Mind-audio/应对冲突.mp3',
      cover: 'assets/images/Mind-audio/conflict.jpg',
      duration: 720,
    ),
    SoundTrack(
      id: 'try_compromise',
      title: '尝试退让',
      file: 'assets/audio/Mind-audio/尝试退让.mp3',
      cover: 'assets/images/Mind-audio/compromise.jpg',
      duration: 600,
    ),
  ];

  // ==================== 闹钟铃声 ====================
  static const List<SoundTrack> alarmSounds = [
    SoundTrack(
      id: 'alarm_echo',
      title: '回声谷',
      file: 'assets/audio/Nature-audio/Echo.MP3',
      cover: null,
      duration: 10,
    ),
    SoundTrack(
      id: 'alarm_campfire',
      title: '营地篝火',
      file: 'assets/audio/Nature-audio/Campfire.MP3',
      cover: null,
      duration: 10,
    ),
    SoundTrack(
      id: 'alarm_seabreeze',
      title: '海浪',
      file: 'assets/audio/Nature-audio/Seabreeze.MP3',
      cover: null,
      duration: 10,
    ),
  ];

  // ==================== 获取分类 ====================

  static Map<String, List<SoundTrack>> getSoundCollections() {
    return {
      '自然': natureSounds,
      '禅意': zenSounds,
      '书斋': studySounds,
      '食味': foodSounds,
    };
  }

  static Map<String, List<SoundTrack>> getMindCollections() {
    return {
      '减压': mindGuides.take(5).toList(),
      '疗愈': mindGuides.skip(5).take(4).toList(),
      '探索': mindGuides.skip(9).toList(),
    };
  }

  static List<SoundTrack> getAllSounds() {
    return [
      ...natureSounds,
      ...zenSounds,
      ...studySounds,
      ...foodSounds,
    ];
  }

  static List<SoundTrack> getAllMindGuides() {
    return mindGuides;
  }

  static List<SoundTrack> getAlarmSounds() {
    return alarmSounds;
  }
}

/// 音频轨道模型
class SoundTrack {
  final String id;
  final String title;
  final String file;
  final String? cover;
  final int duration; // 秒

  const SoundTrack({
    required this.id,
    required this.title,
    required this.file,
    this.cover,
    required this.duration,
  });

  /// 格式化时长显示
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'file': file,
        'cover': cover,
        'duration': duration,
      };

  /// 从 Map 创建
  factory SoundTrack.fromMap(Map map) => SoundTrack(
        id: map['id'],
        title: map['title'],
        file: map['file'],
        cover: map['cover'],
        duration: map['duration'],
      );
}

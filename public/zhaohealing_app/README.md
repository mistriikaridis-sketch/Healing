# 静屿 StillIsle - 心理疗愈 APP

基于 [赵伯泉的疗愈 web](最终版.html) 移植的 Flutter 原生 APP。

## 功能模块

### 1. 首页 (当下 / 探索)
- 每日金句
- 快速进入冥想和日记

### 2. 在此 · 冥想
- **专注模式**：计时器功能，支持 25/45 分钟
- **呼吸模式**：4-7-8 呼吸法、箱式呼吸
- **声景**：自然音 (篝火、海浪、雨声等)
- **正念引导**：减压、疗愈、探索类音频

### 3. 觉察日记
- 小确幸记录
- 感恩时刻
- 心境选择 (Sunny/Cloudy/Rainy/Storm/Calm)
- 历史记录回顾

### 4. MBTI 人格分析
- 60 道题目
- 16 种人格类型解析
- 测试结果保存

### 5. SCL-90 心理健康量表
- 90 项临床评估
- 雷达图分析
- 危机预警

### 6. 神谕与答案
- 读心卡牌
- 答案之书 (长按 3 秒获取)

### 7. 小夜灯 (色彩疗愈)
- 色相、饱和度、亮度调节
- 可爱的角色动画

### 8. 灵犀 AI 对话
- 长按球体进行语音对话
- 实时状态反馈 (聆听/思考/播放)

## 运行方式

```bash
# 创建 Flutter 项目
flutter create zhaohealing_app

# 进入目录
cd zhaohealing_app

# 添加依赖
flutter pub get

# 运行
flutter run
```

## 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  intl: ^0.18.1
  google_fonts: ^6.1.0
  flutter_animate: ^4.1.0
```

## 目录结构

```
lib/
├── main.dart                    # 入口文件
├── theme/
│   └── app_theme.dart           # 主题配置
├── providers/
│   └── app_provider.dart        # 状态管理
└── screens/
    ├── home_screen.dart         # 首页
    ├── meditation_screen.dart   # 冥想
    ├── journal_screen.dart      # 日记
    ├── mbti_screen.dart         # MBTI
    ├── scl90_screen.dart        # SCL-90
    ├── oracle_screen.dart       # 神谕
    ├── nightlight_screen.dart   # 小夜灯
    └── chat_screen.dart         # 灵犀
```

## 注意事项

- AI 对话功能需要配合后端服务使用
- 音频文件需要放在 `assets/audio/` 目录
- 图片资源需要放在 `assets/images/` 目录

## 许可证

MIT License

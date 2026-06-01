import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zhaohealing/providers/app_provider.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'package:zhaohealing/screens/chat_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late TabController _tabController;

  final List<String> _tabNames = ['当下', '探索', '灵犀'];
  final List<String> _tabEnNames = ['Now', 'Explore', 'Soul'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.bgWarm,
              AppTheme.bgWarm.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNowTab(),
                    _buildExploreTab(),
                    _buildSoulTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateStr = '${now.year}年${now.month}月${now.day}日 ${_getWeekday(now.weekday)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentTab == 0
              ? Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.sub,
                    letterSpacing: 1,
                  ),
                )
              : const SizedBox.shrink(),
          Text(
            '静屿',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
              letterSpacing: 2,
              fontFamily: 'serif',
            ),
          ),
          IconButton(
            icon: Icon(
              Provider.of<AppProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppTheme.sub,
            ),
            onPressed: () => Provider.of<AppProvider>(context, listen: false).toggleTheme(),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.ink,
        indicatorWeight: 2,
        labelColor: AppTheme.ink,
        unselectedLabelColor: AppTheme.sub,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
        tabs: List.generate(3, (index) {
          return Tab(
            child: Column(
              children: [
                Text(_tabNames[index]),
                if (_currentTab == index)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ========== 当下 Tab ==========
  Widget _buildNowTab() {
    final quotes = [
      {'cn': '生活如一杯咖啡，先苦后甜。', 'en': 'Life is like coffee.'},
      {'cn': '万物皆有裂痕，那是光照进来的地方。', 'en': 'There\'s a crack in everything.'},
      {'cn': '人生没有白走的路，每一步都算数。', 'en': 'No step in life is wasted.'},
      {'cn': '心若向阳，无谓悲伤。', 'en': 'If the heart faces the sun.'},
    ];
    final dailyQuote = quotes[math.Random().nextInt(quotes.length)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 金句
          Text(
            '"${dailyQuote['cn']}"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: AppTheme.ink,
              height: 1.6,
              fontFamily: 'serif',
            ),
          ),
          Text(
            '— ${dailyQuote['en']}',
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppTheme.sub,
            ),
          ),
          const SizedBox(height: 32),

          // 冥想卡片
          _buildMainCard(
            icon: '🧘',
            title: '在此 · 冥想',
            subtitle: 'Focus & Breathe',
            description: '给自己十分钟 · 专注呼吸 · 正念引导',
            gradient: const LinearGradient(
              colors: [Color(0xFFE8D5C8), Color(0xFFF5EFE9)],
            ),
            onTap: () => Navigator.pushNamed(context, '/meditation'),
          ),
          const SizedBox(height: 20),

          // 日记卡片
          _buildMainCard(
            icon: '📔',
            title: '觉察日记',
            subtitle: 'Daily Journal',
            description: '观照自我 · 记录情绪与念头',
            gradient: const LinearGradient(
              colors: [Color(0xFFE0E5E9), Color(0xFFF0F3F5)],
            ),
            onTap: () => Navigator.pushNamed(context, '/journal'),
          ),
          const SizedBox(height: 32),

          // 呼吸练习入口
          _buildQuickAction(
            icon: '🌬️',
            title: '呼吸练习',
            subtitle: '4-7-8 呼吸法',
            onTap: () => Navigator.pushNamed(context, '/meditation'),
          ),
        ],
      ),
    );
  }

  // ========== 探索 Tab ==========
  Widget _buildExploreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 心理测评
          _buildSectionTitle('心理测评'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildExploreCard(
                  title: 'MBTI',
                  subtitle: '人格深度解析',
                  icon: '🔮',
                  onTap: () => Navigator.pushNamed(context, '/mbti'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildExploreCard(
                  title: 'SCL-90',
                  subtitle: '心理健康自查',
                  icon: '📊',
                  onTap: () => Navigator.pushNamed(context, '/scl90'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 灵启疗愈
          _buildSectionTitle('灵启 & 疗愈'),
          const SizedBox(height: 16),
          _buildExploreCard(
            title: '神谕与答案',
            subtitle: '读心卡牌 · 直觉指引',
            icon: '🃏',
            fullWidth: true,
            onTap: () => Navigator.pushNamed(context, '/oracle'),
          ),
          const SizedBox(height: 16),
          _buildExploreCard(
            title: '小夜灯',
            subtitle: '色彩疗愈 · 点亮内心',
            icon: '🌙',
            fullWidth: true,
            onTap: () => Navigator.pushNamed(context, '/nightlight'),
          ),
        ],
      ),
    );
  }

  // ========== 灵犀 Tab ==========
  Widget _buildSoulTab() {
    return const ChatScreen();
  }

  Widget _buildMainCard({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                      fontFamily: 'serif',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.accent,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.sub,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.sub,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.sub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_outline,
              color: AppTheme.accent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.sub,
            letterSpacing: 2,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 1,
          width: 60,
          color: Colors.black.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildExploreCard({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8F6F3), Color(0xFFFCFAF8)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Column(
          crossAxisAlignment: fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.ink,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.sub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

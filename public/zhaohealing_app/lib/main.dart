import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zhaohealing/screens/home_screen.dart';
import 'package:zhaohealing/screens/meditation_screen.dart';
import 'package:zhaohealing/screens/journal_screen.dart';
import 'package:zhaohealing/screens/mbti_screen.dart';
import 'package:zhaohealing/screens/scl90_screen.dart';
import 'package:zhaohealing/screens/oracle_screen.dart';
import 'package:zhaohealing/screens/nightlight_screen.dart';
import 'package:zhaohealing/screens/chat_screen.dart';
import 'package:zhaohealing/providers/app_provider.dart';
import 'package:zhaohealing/theme/app_theme.dart';
import 'package:zhaohealing/services/database_service.dart';
import 'package:zhaohealing/services/audio_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await DatabaseService.init();
    await AudioService().init();
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: '静屿 StillIsle',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            home: _isInitialized ? const HomeScreen() : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            routes: {
              '/meditation': (_) => const MeditationScreen(),
              '/journal': (_) => const JournalScreen(),
              '/mbti': (_) => const MBTIScreen(),
              '/scl90': (_) => const SCL90Screen(),
              '/oracle': (_) => const OracleScreen(),
              '/nightlight': (_) => const NightLightScreen(),
              '/chat': (_) => const ChatScreen(),
            },
          );
        },
      ),
    );
  }
}

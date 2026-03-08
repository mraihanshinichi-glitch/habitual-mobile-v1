import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'core/database/database_service.dart';
import 'core/constants/app_colors.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/background_service.dart';
import 'features/home/home_page.dart';
import 'features/stats/stats_page.dart';
import 'features/settings/settings_page.dart';

void main() async {
  // Catch all errors
  runZonedGuarded(() async {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    print('DEBUG main: Starting app initialization');
    
    try {
      // Initialize date formatting for Indonesian locale
      await initializeDateFormatting('id_ID', null);
      print('DEBUG main: Date formatting initialized');
    } catch (e) {
      print('DEBUG main: Date formatting initialization failed: $e');
      // Continue anyway, not critical
    }
    
    // Initialize notification service
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.requestPermissions();
      print('DEBUG main: Notification service initialized');
    } catch (e) {
      print('DEBUG main: Notification service initialization failed: $e');
      // Continue anyway, notifications are optional
    }
    
    // Initialize background service (check streak & reschedule notifications)
    try {
      final backgroundService = BackgroundService();
      await backgroundService.initialize();
      print('DEBUG main: Background service initialized');
    } catch (e) {
      print('DEBUG main: Background service initialization failed: $e');
      // Continue anyway
    }
    
    // Initialize database and handle migration
    final databaseService = DatabaseService.instance;
    
    try {
      print('DEBUG main: Initializing database...');
      await databaseService.initialize();
      print('DEBUG main: Database initialized successfully');
      
      await databaseService.seedDefaultCategories();
      print('DEBUG main: Default categories seeded');
      
      // Try to migrate existing data
      await databaseService.migrateDatabase();
      print('DEBUG main: Database migration completed');
    } catch (e, stackTrace) {
      print('DEBUG main: Database initialization/migration failed: $e');
      print('DEBUG main: Stack trace: $stackTrace');
      print('DEBUG main: Attempting database reset...');
      
      try {
        // If migration fails, reset database as last resort
        await databaseService.resetDatabase();
        print('DEBUG main: Database reset successful');
      } catch (resetError, resetStackTrace) {
        print('DEBUG main: Database reset also failed: $resetError');
        print('DEBUG main: Reset stack trace: $resetStackTrace');
        // App will still try to run, but may have issues
      }
    }
    
    print('DEBUG main: Launching app...');
    runApp(const ProviderScope(child: HabitualApp()));
  }, (error, stack) {
    print('FATAL ERROR: $error');
    print('STACK TRACE: $stack');
  });
}

class HabitualApp extends ConsumerWidget {
  const HabitualApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Habitual Mobile',
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const MainNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StatsPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      print('DEBUG MainNavigation: App resumed, checking background tasks...');
      // Check streak dan reschedule notifications saat app kembali ke foreground
      BackgroundService().initialize().catchError((e) {
        print('DEBUG MainNavigation: Background service error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
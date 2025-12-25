import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_plant_app/pages/auth/auth_page.dart';
import 'package:the_plant_app/pages/onBoarding/on_boarding.dart';
import 'package:the_plant_app/pages/root.dart';
import 'package:the_plant_app/providers/auth_providers.dart';
import 'package:the_plant_app/providers/database_providers.dart';
import 'package:the_plant_app/providers/theme_provider.dart';
import 'package:the_plant_app/providers/user_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    /// ProviderScope ریشه Riverpod برای کل اپ
    /// Root ProviderScope to enable Riverpod & database providers.
    const ProviderScope(child: MyApp()),
  );
}

bool? isOnBoardinPageWatched;
bool? isAuthenticated;

Future<void> saveOnboardingStatus(bool value) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setBool('isOnboardingPageWatched', value);
}

Future<void> saveAuthStatus(bool value) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setBool('isAuthenticated', value);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isLoading = true;

  Future<void> loadStatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final authNotifier = ref.read(authControllerProvider.notifier);
    setState(() {
      isOnBoardinPageWatched = pref.getBool('isOnboardingPageWatched') ?? false;
      isAuthenticated = pref.getBool('isAuthenticated') ?? false;
    });

    // اگر کاربر قبلاً وارد شده بود، کاربر را از دیتابیس hydrate کن
    if (isAuthenticated == true) {
      final email = await getCurrentUserEmail();
      if (email != null && email.isNotEmpty) {
        final db = ref.read(appDatabaseProvider);
        final user = await db.getUserByEmail(email);
        authNotifier.setUser(user);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    loadStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);

    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final bool hasSeenOnboarding = isOnBoardinPageWatched ?? false;
    final bool hasAuthenticated = isAuthenticated ?? false;

    final Widget home = !hasSeenOnboarding
        ? const OnBoarding()
        : (!hasAuthenticated ? const AuthPage() : const RootPage());

    return MaterialApp(
      title: 'Plant App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2F9E62),
        scaffoldBackgroundColor: const Color(0xFFF5F8F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F9E62),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2F9E62),
        scaffoldBackgroundColor: const Color(0xFF101418),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F9E62),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101418),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: home,
    );
  }
}

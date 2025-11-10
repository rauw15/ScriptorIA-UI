import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/session_service.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/practice/presentation/pages/practice_page.dart';
import 'features/home/domain/entities/practice_item.dart';
import 'features/results/presentation/pages/results_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/home/presentation/pages/all_letters_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  SessionService().initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aprendIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/practice': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is PracticeItem) {
            return PracticePage.fromPracticeItem(practiceItem: args);
          }
          // Fallback si no hay argumentos
          return const PracticePage(letter: 'A');
        },
        '/results': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            if (args['practiceId'] != null) {
              return ResultsPage.fromPracticeId(
                practiceId: args['practiceId'] as String,
              );
            }
            if (args['imagePath'] != null && args['letter'] != null) {
              return ResultsPage.fromImageAndLetter(
                imagePath: args['imagePath'] as String,
                letter: args['letter'] as String,
              );
            }
          }
          return const Scaffold(
            body: Center(child: Text('No hay resultados disponibles')),
          );
        },
        '/profile': (context) => const ProfilePage(),
        '/statistics': (context) => const StatisticsPage(),
        '/history': (context) => const HistoryPage(),
        '/all-letters': (context) => const AllLettersPage(),
      },
    );
  }
}

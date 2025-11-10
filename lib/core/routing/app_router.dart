import 'package:go_router/go_router.dart';
import '../../features/practice/presentation/pages/practice_page.dart';
import '../../features/results/presentation/pages/results_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/practice',
    routes: [
      GoRoute(
        path: '/practice',
        name: 'practice',
        builder: (context, state) {
          final letter = state.uri.queryParameters['letter'] ?? 'A';
          return PracticePage(letter: letter);
        },
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        builder: (context, state) {
          final imagePath = state.uri.queryParameters['imagePath'] ?? '';
          final letter = state.uri.queryParameters['letter'] ?? 'A';
          return ResultsPage(
            imagePath: imagePath,
            letter: letter,
          );
        },
      ),
    ],
  );
}


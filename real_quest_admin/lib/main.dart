import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:real_quest_admin/screens/home_screen.dart';
import 'package:real_quest_admin/screens/card_generator_screen.dart';
import 'package:real_quest_admin/screens/item_generator_screen.dart';
import 'package:real_quest_admin/screens/monster_generator_screen.dart';
import 'package:real_quest_admin/screens/status_adjuster_screen.dart';
import 'package:real_quest_admin/screens/db_viewer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tmrgsijuvyhzymaogbag.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI',
  );

  runApp(const ProviderScope(child: AdminApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/card-gen',
        builder: (context, state) => const CardGeneratorScreen(),
      ),
      GoRoute(
        path: '/item-gen',
        builder: (context, state) => const ItemGeneratorScreen(),
      ),
      GoRoute(
        path: '/monster-gen',
        builder: (context, state) => const MonsterGeneratorScreen(),
      ),
      GoRoute(
        path: '/status-adj',
        builder: (context, state) => const StatusAdjusterScreen(),
      ),
      GoRoute(
        path: '/db-viewer',
        builder: (context, state) => const DatabaseViewerScreen(),
      ),
    ],
  );
});

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Real Quest Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

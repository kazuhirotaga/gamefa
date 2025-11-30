import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_quest/router.dart';
import 'package:real_quest/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:real_quest/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  // TODO: Replace with your actual Supabase URL and Anon Key from the Supabase Dashboard
  await Supabase.initialize(
    url: 'https://tmrgsijuvyhzymaogbag.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI',
  );

  // Initialize Auth
  final supabaseService = SupabaseService();
  try {
    await supabaseService.initializeAuth();
  } catch (e) {
    print('Main: Failed to initialize auth: $e');
    // Continue to run app, but features might fail
  }

  runApp(const ProviderScope(child: RealQuestApp()));
}

class RealQuestApp extends ConsumerWidget {
  const RealQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Real Quest',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

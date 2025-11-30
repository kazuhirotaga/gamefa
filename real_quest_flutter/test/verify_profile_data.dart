import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify User Profile Data', () async {
    print('--- Starting Profile Verification ---');

    const supabaseUrl = 'https://tmrgsijuvyhzymaogbag.supabase.co';
    const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI';
    
    final client = SupabaseClient(supabaseUrl, supabaseKey);

    // 1. Login
    print('\n1. Logging in...');
    final authResponse = await client.auth.signInWithPassword(
      email: 'real.quest.test.user@gmail.com',
      password: 'password123',
    );
    final userId = authResponse.user!.id;
    print('✅ Login success. User ID: $userId');

    // 2. Fetch Profile
    print('\n2. Fetching Profile...');
    final profile = await client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    
    print('Profile Data:');
    profile.forEach((key, value) {
      print('$key: $value (${value.runtimeType})');
    });

    if (profile.containsKey('exp') && profile.containsKey('coins')) {
      print('✅ exp and coins columns exist.');
      print('EXP: ${profile['exp']}');
      print('Coins: ${profile['coins']}');
    } else {
      print('❌ exp or coins columns MISSING.');
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify Battle Action Stats Update', () async {
    print('--- Starting Battle Stats Verification ---');

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

    // 2. Get Initial Stats
    print('\n2. Fetching Initial Stats...');
    final initialProfile = await client
        .from('users')
        .select('exp, coins')
        .eq('id', userId)
        .single();
    print('Initial Stats: $initialProfile');
    final initialExp = initialProfile['exp'] as int;
    final initialCoins = initialProfile['coins'] as int;

    // 3. Call Battle Action (Loop until win)
    bool won = false;
    int attempts = 0;
    
    while (!won && attempts < 10) {
      attempts++;
      print('\nAttempt $attempts: Calling battle-action...');
      
      try {
        final result = await client.functions.invoke(
          'battle-action',
          body: {
            'userId': userId,
            'battleId': 'test-battle',
            'action': 'attack',
            'targetId': 'test-target'
          },
        );
        
        final data = result.data as Map<String, dynamic>;
        final isWin = data['isWin'] as bool;
        print('Battle Result: ${isWin ? "WIN" : "LOSE"}');
        
        if (isWin) {
          won = true;
          print('Rewards: ${data['rewards']}');
        }
      } catch (e) {
        print('Function call failed: $e');
        break;
      }
    }

    if (!won) {
      fail('Could not trigger a win after 10 attempts. Verification inconclusive.');
    }

    // 4. Get Updated Stats
    print('\n4. Fetching Updated Stats...');
    final updatedProfile = await client
        .from('users')
        .select('exp, coins, level')
        .eq('id', userId)
        .single();
    print('Updated Stats: $updatedProfile');
    final updatedExp = updatedProfile['exp'] as int;
    final updatedCoins = updatedProfile['coins'] as int;

    // 5. Verify Increase
    final expDiff = updatedExp - initialExp;
    final coinsDiff = updatedCoins - initialCoins;

    print('\nEXP Gained: $expDiff');
    print('Coins Gained: $coinsDiff');
    print('New Level: ${updatedProfile['level']}');

    expect(expDiff, 50, reason: 'EXP should increase by 50');
    expect(coinsDiff, 100, reason: 'Coins should increase by 100');
    
    // Check if level matches expected (e.g., if EXP > 100, Level should be >= 2)
    if (updatedExp >= 100) {
      expect(updatedProfile['level'] as int, greaterThanOrEqualTo(2), reason: 'Level should be at least 2');
    }
    
    print('✅ SUCCESS: Stats updated correctly.');
  });
}

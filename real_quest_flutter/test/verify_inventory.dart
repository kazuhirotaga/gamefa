import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify Inventory', () async {
    print('--- Starting Inventory Verification ---');

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

    // 2. Get Item Templates
    print('\n2. Fetching Item Templates...');
    final templates = await client.from('item_templates').select();
    if (templates.isEmpty) {
      fail('No item templates found. Migration might have failed.');
    }
    final potion = templates.firstWhere((t) => t['name'] == 'ポーション');
    print('Found Potion Template: ${potion['id']}');

    // 3. Give Item to User (Upsert)
    print('\n3. Giving Potion to User...');
    await client.from('user_items').upsert({
      'user_id': userId,
      'template_id': potion['id'],
      'quantity': 5,
    }, onConflict: 'user_id, template_id');
    print('✅ Potion added/updated.');

    // 4. Fetch User Items
    print('\n4. Fetching User Items...');
    final userItems = await client
        .from('user_items')
        .select('*, item_templates(*)')
        .eq('user_id', userId);
    
    print('User Items: $userItems');

    if (userItems.isEmpty) {
      fail('User items empty after insertion.');
    }

    final userPotion = userItems.firstWhere((i) => i['template_id'] == potion['id']);
    expect(userPotion['quantity'], 5);
    expect(userPotion['item_templates']['name'], 'ポーション');

    print('✅ SUCCESS: Inventory verification passed.');
  });
}

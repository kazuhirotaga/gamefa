import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest/services/quest_service.dart';
import 'package:real_quest/models/quest.dart';

void main() {
  test('Verify Quest System', () async {
    print('--- Starting Quest System Verification ---');

    // 1. Initialize Supabase (Mock or Real)
    // Note: We need real connection for this integration test
    const supabaseUrl = 'https://tmrgsijuvyhzymaogbag.supabase.co';
    const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI';
    
    final client = SupabaseClient(supabaseUrl, supabaseKey);
    final questService = QuestService(client);

    // 2. Login (Reuse test user)
    print('\n1. Logging in...');
    final authResponse = await client.auth.signInWithPassword(
      email: 'real.quest.test.user@gmail.com',
      password: 'password123',
    );
    final userId = authResponse.user!.id;
    print('✅ Login success. User ID: $userId');

    // 3. Fetch Quests
    print('\n2. Fetching Quests...');
    final quests = await questService.getQuests();
    print('Found ${quests.length} quests');
    if (quests.isEmpty) {
      fail('No quests found. Did you run the migration?');
    }
    
    // 4. Start a Quest (e.g., Daily Check-in)
    print('\n3. Starting Quest...');
    final targetQuest = quests.firstWhere((q) => q.targetAction == 'checkin');
    print('Target Quest: ${targetQuest.title} (ID: ${targetQuest.id})');
    
    await questService.startQuest(userId, targetQuest.id);
    print('✅ Quest started');

    // 5. Verify User Quest Created
    print('\n4. Verifying User Quest...');
    var userQuests = await questService.getUserQuests(userId);
    var userQuest = userQuests.firstWhere((uq) => uq.questId == targetQuest.id);
    print('User Quest Status: ${userQuest.status}, Progress: ${userQuest.currentProgress}');
    
    // 6. Simulate Progress Update
    print('\n5. Updating Progress...');
    await questService.updateProgress(userId, 'checkin');
    
    // 7. Verify Progress Updated
    print('\n6. Verifying Progress Update...');
    userQuests = await questService.getUserQuests(userId);
    userQuest = userQuests.firstWhere((uq) => uq.questId == targetQuest.id);
    print('User Quest Status: ${userQuest.status}, Progress: ${userQuest.currentProgress}');
    
    if (userQuest.currentProgress > 0) {
      print('✅ Progress updated successfully');
    } else {
      fail('Progress did not update');
    }

    print('\n--- Verification Complete ---');
  });
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest/models/quest.dart';

class QuestService {
  final SupabaseClient _client;

  QuestService(this._client);

  // Fetch all available quests
  Future<List<Quest>> getQuests() async {
    final response = await _client.from('quests').select();
    return (response as List).map((json) => Quest.fromJson(json)).toList();
  }

  // Fetch user's quest progress
  Future<List<UserQuest>> getUserQuests(String userId) async {
    final response = await _client
        .from('user_quests')
        .select('*, quests(*)')
        .eq('user_id', userId);
    
    return (response as List).map((json) => UserQuest.fromJson(json)).toList();
  }

  // Start a quest (if not already started)
  Future<void> startQuest(String userId, String questId) async {
    await _client.from('user_quests').upsert({
      'user_id': userId,
      'quest_id': questId,
      'status': 'active',
      'current_progress': 0,
    }, onConflict: 'user_id, quest_id');
  }

  // Update progress for a specific action
  Future<void> updateProgress(String userId, String action, {int count = 1}) async {
    // 1. Find active quests for this user that match the action
    // Note: In a real app, this logic might be better in an Edge Function or Database Trigger
    
    // Get all active user quests
    final userQuestsResponse = await _client
        .from('user_quests')
        .select('*, quests!inner(*)')
        .eq('user_id', userId)
        .eq('status', 'active')
        .eq('quests.target_action', action);

    final userQuests = (userQuestsResponse as List)
        .map((json) => UserQuest.fromJson(json))
        .toList();

    for (final uq in userQuests) {
      if (uq.quest == null) continue;

      final newProgress = uq.currentProgress + count;
      final isCompleted = newProgress >= uq.quest!.targetCount;
      
      await _client.from('user_quests').update({
        'current_progress': newProgress,
        'status': isCompleted ? 'completed' : 'active',
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      }).eq('id', uq.id);
    }
  }

  // Claim reward
  Future<void> claimReward(String userQuestId) async {
    await _client.from('user_quests').update({
      'status': 'claimed',
    }).eq('id', userQuestId);
    
    // TODO: Add coins/exp to user (should be done transactionally or via Edge Function)
  }
}

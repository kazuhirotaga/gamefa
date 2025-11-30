import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest/models/item.dart';

class ItemService {
  final SupabaseClient _client;

  ItemService(this._client);

  Future<List<UserItem>> getUserItems(String userId) async {
    try {
      final response = await _client
          .from('user_items')
          .select('*, item_templates(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => UserItem.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching user items: $e');
      return [];
    }
  }

  Future<void> useItem(String userId, String userItemId) async {
    // TODO: Implement item usage logic (e.g., call RPC to consume item and apply effect)
    print('Using item: $userItemId for user: $userId');
  }
}

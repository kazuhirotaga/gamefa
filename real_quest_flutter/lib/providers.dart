import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_quest/models/card.dart';
import 'package:real_quest/services/supabase_service.dart';
import 'package:real_quest/services/quest_service.dart';
import 'package:real_quest/models/quest.dart';
import 'package:real_quest/services/item_service.dart';
import 'package:real_quest/models/item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase Service Provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Current User ID Provider
final userIdProvider = Provider<String?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.id;
});

// Auth Initialization Provider
final authInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  await service.initializeAuth();
});

// User Profile Provider
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  await ref.watch(authInitializationProvider.future);
  final service = ref.watch(supabaseServiceProvider);
  return service.getUserProfile();
});

// User Cards Provider
final userCardsProvider = FutureProvider<List<GameCard>>((ref) async {
  await ref.watch(authInitializationProvider.future);
  final service = ref.watch(supabaseServiceProvider);
  return service.getUserCards();
});

// Quest Service Provider
final questServiceProvider = Provider<QuestService>((ref) {
  return QuestService(Supabase.instance.client);
});

// User Quests Provider
final userQuestsProvider = FutureProvider<List<UserQuest>>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return [];
  return ref.read(questServiceProvider).getUserQuests(userId);
});

// Item Service Provider
final itemServiceProvider = Provider<ItemService>((ref) {
  return ItemService(Supabase.instance.client);
});

// User Items Provider
final userItemsProvider = FutureProvider<List<UserItem>>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return [];
  return ref.read(itemServiceProvider).getUserItems(userId);
});

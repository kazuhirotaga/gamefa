import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest/models/card.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Initialize Auth (Auto-login for prototype)
  Future<void> initializeAuth() async {
    print('SupabaseService: initializeAuth started');
    User? user = _client.auth.currentUser;
    print('SupabaseService: Initial currentUser: ${user?.id}');
    
    if (user == null) {
      try {
        print('SupabaseService: Attempting anonymous sign-in...');
        // Try Anonymous Sign-in first
        final response = await _client.auth.signInAnonymously();
        user = response.user;
        print('SupabaseService: Anonymous sign-in success: ${user?.id}');
      } catch (e) {
        print('SupabaseService: Anonymous login failed: $e');
        // Fallback to Test User
        try {
          print('SupabaseService: Attempting test user login...');
          const email = 'real.quest.test.user@gmail.com';
          const password = 'password123';
          try {
            final response = await _client.auth.signInWithPassword(email: email, password: password);
            user = response.user;
            print('SupabaseService: Password sign-in success: ${user?.id}');
          } catch (e) {
             print('SupabaseService: Password sign-in failed: $e');
             
             // Try to create user via Edge Function (Admin) to bypass email confirmation
             try {
               print('SupabaseService: Calling create-test-user Edge Function...');
               final functionResponse = await _client.functions.invoke(
                 'create-test-user',
                 body: {'email': email, 'password': password},
               );
               
               if (functionResponse.status == 200) {
                 print('SupabaseService: User created via Edge Function. Logging in...');
                 final response = await _client.auth.signInWithPassword(email: email, password: password);
                 user = response.user;
                 print('SupabaseService: Login success after creation: ${user?.id}');
               } else {
                 throw Exception('Function failed: ${functionResponse.status}');
               }
             } catch (funcError) {
                print('SupabaseService: Edge Function creation failed: $funcError');
                // Fallback to normal sign up (will fail if email confirmation required)
                final response = await _client.auth.signUp(email: email, password: password);
                user = response.user;
                print('SupabaseService: Sign-up success (unconfirmed): ${user?.id}');
             }
          }
        } catch (e) {
          print('SupabaseService: Test user login failed: $e');
          throw Exception('Failed to login');
        }
      }
    }

    if (user != null) {
      print('SupabaseService: Syncing user to public table...');
      // Ensure user exists in public.users
      try {
        await _client.from('users').upsert({
          'id': user.id,
          'display_name': '勇者タナカ', // Default name
          'email': user.email, // If available
        });
        print('SupabaseService: User synced to public table');
      } catch (e) {
        print('SupabaseService: Error syncing user to public table: $e');
        // Ignore if it fails, might already exist or RLS issue (but we need it for FKs)
      }
    } else {
      print('SupabaseService: User is still null after initialization attempt');
    }
  }

  // Check-in Function
  Future<Map<String, dynamic>> checkin({
    required double latitude,
    required double longitude,
    required String facilityId,
    int? paymentAmount,
    String? receiptImageBase64,
  }) async {
    print('SupabaseService: checkin called');
    try {
      final user = _client.auth.currentUser;
      print('SupabaseService: checkin currentUser: ${user?.id}');
      
      if (user == null) {
        print('SupabaseService: User is null, throwing exception');
        throw Exception('User not logged in');
      }

      print('SupabaseService: Invoking Edge Function checkin...');
      final response = await _client.functions.invoke(
        'checkin',
        body: {
          'userId': user.id,
          'latitude': latitude,
          'longitude': longitude,
          'facilityId': facilityId,
          'paymentAmount': paymentAmount,
          'receiptImage': receiptImageBase64,
        },
      );
      print('SupabaseService: Edge Function response status: ${response.status}');

      if (response.status != 200) {
        throw Exception('Check-in failed: ${response.status}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Battle Action Function
  Future<Map<String, dynamic>> performBattleAction({
    required String battleId,
    required String action, // 'attack', 'skill', 'item'
    required String targetId,
    String? cardId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _client.functions.invoke(
        'battle-action',
        body: {
          'userId': user.id,
          'battleId': battleId,
          'action': action,
          'targetId': targetId,
          'cardId': cardId,
        },
      );

      if (response.status != 200) {
        throw Exception('Battle action failed: ${response.status}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch User Cards
  Future<List<GameCard>> getUserCards() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _client
          .from('user_cards')
          .select('*, card_templates(*)')
          .eq('user_id', user.id);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) {
        // Merge template data into card data for GameCard model
        final template = json['card_templates'];
        final Map<String, dynamic> cardData = {
          ...json,
          ...template,
          'id': json['id'], // Ensure user_card id is used
        };
        return GameCard.fromJson(cardData);
      }).toList();
    } catch (e) {
      // Return empty list on error for prototype robustness
      print('Error fetching cards: $e');
      return [];
    }
  }

  // Fetch User Profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}

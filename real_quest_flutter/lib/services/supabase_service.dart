import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest/models/card.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  // Initialize Auth - Just check current state, no auto-login
  Future<void> initializeAuth() async {
    print('SupabaseService: initializeAuth started');
    final user = _client.auth.currentUser;
    print('SupabaseService: Initial currentUser: ${user?.id}');
    
    if (user != null) {
      await _syncUser(user);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        await _syncUser(response.user!);
      }
    } catch (e) {
      print('Sign in failed: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      // Try to create user via Edge Function to bypass email confirmation
      print('SupabaseService: Attempting to create user via Edge Function...');
      try {
        final functionResponse = await _client.functions.invoke(
          'create-test-user',
          body: {'email': email, 'password': password},
        );

        if (functionResponse.status != 200) {
           print('SupabaseService: Edge Function failed with status ${functionResponse.status}');
           // Fallback to normal sign up if function fails
           throw Exception('Function failed');
        }
        
        print('SupabaseService: User created via Edge Function. Logging in...');
        // After creation, log in to get the session
        await signIn(email, password);

      } catch (funcError) {
        print('SupabaseService: Edge Function creation failed: $funcError');
        // Fallback to normal sign up
        final response = await _client.auth.signUp(email: email, password: password);
        if (response.user != null) {
          await _syncUser(response.user!);
        }
        // If session is null here, it means email confirmation is required.
        if (response.session == null) {
           throw Exception('Please check your email to confirm your account.');
        }
      }
    } catch (e) {
      print('Sign up failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> _syncUser(User user) async {
    print('SupabaseService: Syncing user to public table...');
    try {
      await _client.from('users').upsert({
        'id': user.id,
        'display_name': user.userMetadata?['display_name'] ?? '勇者タナカ', // Default name
        'email': user.email,
      });
      print('SupabaseService: User synced to public table');
    } catch (e) {
      print('SupabaseService: Error syncing user to public table: $e');
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

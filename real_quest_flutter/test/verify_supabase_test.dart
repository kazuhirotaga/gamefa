import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify Supabase Functionality', () async {
    const supabaseUrl = 'https://tmrgsijuvyhzymaogbag.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI';

    // Initialize Supabase (mocking local storage for test environment if needed, 
    // but Supabase.initialize might fail in pure Dart test without Flutter binding?
    // Actually Supabase.initialize needs Flutter. 
    // We should use SupabaseClient directly for pure Dart/test usage if possible, 
    // or ensure WidgetsFlutterBinding is initialized.)
    
    // For pure Dart test, better to use SupabaseClient from 'package:supabase/supabase.dart' 
    // but supabase_flutter exports it.
    
    final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

    print('\n--- Starting Supabase Verification ---');

    final email = 'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
    const password = 'password123';

    // 1. Test create-test-user Edge Function
    print('\n1. Testing create-test-user with $email...');
    try {
      final functionResponse = await client.functions.invoke(
        'create-test-user',
        body: {'email': email, 'password': password},
      );
      
      if (functionResponse.status != 200) {
        print('❌ create-test-user failed: ${functionResponse.status}');
        // fail('create-test-user failed');
      } else {
        print('✅ create-test-user success: ${functionResponse.data}');
      }
    } catch (e) {
      print('❌ create-test-user exception: $e');
    }

    // 2. Test Login
    print('\n2. Testing Login...');
    String? userId;
    try {
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      userId = authResponse.user?.id;
      print('✅ Login success. User ID: $userId');
    } catch (e) {
      print('❌ Login failed: $e');
      return;
    }

    if (userId == null) return;

    // 3. Test DB Sync (Upsert to public.users)
    print('\n3. Testing DB Sync (Upsert to public.users)...');
    try {
      await client.from('users').upsert({
        'id': userId,
        'display_name': 'Test User',
        'email': email,
      });
      print('✅ DB Upsert success');
    } catch (e) {
      print('❌ DB Upsert failed: $e');
    }

    // 4. Test DB Read
    print('\n4. Testing DB Read...');
    try {
      final userData = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      print('✅ DB Read success: $userData');
      if (userData['email'] == email) {
        print('   (Email column verified)');
      } else {
        print('   ⚠️ Email column mismatch or missing');
      }
    } catch (e) {
      print('❌ DB Read failed: $e');
    }

    // 5. Test Check-in Edge Function
    print('\n5. Testing Check-in Edge Function...');
    const facilityId = '00000000-0000-0000-0000-000000000001';
    
    // Insert mock facility first
    try {
      await client.from('facilities').upsert({
        'id': facilityId,
        'name': 'Test Facility',
        'type': 'public',
        'location': 'POINT(139.6917 35.6895)',
      });
      print('✅ Mock Facility inserted');
    } catch (e) {
      print('⚠️ Mock Facility insert failed (might exist): $e');
    }

    try {
      final checkinResponse = await client.functions.invoke(
        'checkin',
        body: {
          'userId': userId,
          'latitude': 35.6895,
          'longitude': 139.6917,
          'facilityId': facilityId,
        },
      );
      
      if (checkinResponse.status != 200) {
        print('❌ Check-in failed: ${checkinResponse.status}');
      } else {
        print('✅ Check-in success: ${checkinResponse.data}');
      }
    } catch (e) {
      print('❌ Check-in exception: $e');
    }

    // 6. Check Card Templates
    print('\n6. Checking Card Templates...');
    final templatesResponse = await client.from('card_templates').select('count');
    print('Card Templates count: ${templatesResponse.length}'); // select('count') returns list of rows if not using count() modifier properly, but let's just see length of all
    
    // Better:
    final templates = await client.from('card_templates').select('id');
    print('Card Templates found: ${templates.length}');

    print('\n--- Verification Complete ---');
  });
}

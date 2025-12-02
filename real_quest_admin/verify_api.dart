import 'package:http/http.dart' as http;
import 'dart:convert';

const supabaseUrl = 'https://tmrgsijuvyhzymaogbag.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI';

void main() async {
  print('--- Verifying Supabase API ---');
  
  final url = Uri.parse('$supabaseUrl/rest/v1/card_templates?select=*&limit=5');
  
  try {
    final response = await http.get(
      url,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Success! Found ${data.length} cards.');
      if (data.isNotEmpty) {
        print('Sample Card: ${data[0]['name']}');
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

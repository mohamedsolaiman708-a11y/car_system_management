import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Inspect DB inventory items and test status update', () async {
    print('Starting DB inspection test...');
    final client = SupabaseClient(
      'https://trflombswaszomydbnoo.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyZmxvbWJzd2Fzem9teWRibm9vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNzA0MzQsImV4cCI6MjA5ODg0NjQzNH0.lZeuQKkjS-MZanM_gMfICifbVdmerPV-B0ZQLeNBg0o',
    );

    try {
      final response = await client.from('inventory_items').select();
      print('Number of vehicles found: ${response.length}');
      for (var item in response) {
        print('ID: ${item['id']}, Model: ${item['make']} ${item['model']}, Status: ${item['status']}');
        
        if (item['status'] == 'maintenance') {
          print('Attempting to update status to available for ID: ${item['id']}');
          try {
            final updateRes = await client.from('inventory_items').update({'status': 'available'}).eq('id', item['id']).select();
            print('Direct update response: $updateRes');
          } catch (updateErr) {
            print('Direct update error: $updateErr');
          }
        }
      }
    } catch (e) {
      print('Test failed: $e');
    }
  });
}

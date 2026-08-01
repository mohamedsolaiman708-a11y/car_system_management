import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify Supabase Storage documents bucket and RLS policies', () async {
    print('--- STORAGE VERIFICATION START ---');
    final client = SupabaseClient(
      'https://trflombswaszomydbnoo.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyZmxvbWJzd2Fzem9teWRibm9vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNzA0MzQsImV4cCI6MjA5ODg0NjQzNH0.lZeuQKkjS-MZanM_gMfICifbVdmerPV-B0ZQLeNBg0o',
    );
    
    // Run upload / download test directly
    final testPath = 'verification_${DateTime.now().millisecondsSinceEpoch}.txt';
    final testContent = 'Verification test payload';
    final bytes = utf8.encode(testContent);
    
    try {
      print('Uploading file to storage: $testPath');
      await client.storage.from('documents').uploadBinary(
        testPath,
        bytes,
        fileOptions: const FileOptions(contentType: 'text/plain'),
      );
      print('Upload successful.');
      
      final url = client.storage.from('documents').getPublicUrl(testPath);
      print('Generated Public URL: $url');
      
      print('Downloading file from public URL...');
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        print('Download successful. Content: "$content"');
        expect(content, testContent);
      } else {
        fail('Failed to download public file. Status: ${response.statusCode}');
      }
      httpClient.close();
      
      print('Deleting temporary file from storage...');
      await client.storage.from('documents').remove([testPath]);
      print('Deletion successful.');
      
      print('--- VERIFICATION SUCCESSFUL ---');
    } catch (e) {
      print('Verification failed with exception: $e');
      fail('Storage verification failed.');
    }
  });
}

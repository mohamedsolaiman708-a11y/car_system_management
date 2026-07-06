import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ملاحظة: يجب وضع قيم Supabase الحقيقية هنا ليعمل التطبيق
  await Supabase.initialize(
    url: 'https://trflombswaszomydbnoo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyZmxvbWJzd2Fzem9teWRibm9vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNzA0MzQsImV4cCI6MjA5ODg0NjQzNH0.lZeuQKkjS-MZanM_gMfICifbVdmerPV-B0ZQLeNBg0o',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Finance System',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A192F),
          primary: const Color(0xFF0A192F),
        ),
        useMaterial3: true,
      ),
    );
  }
}

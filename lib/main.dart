import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'src/core/routing/app_router.dart';
import 'l10n/app_localizations.dart';
import 'src/core/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // درع الحماية العالمي: استبدال الشاشة الحمراء بواجهة احترافية
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _GlobalErrorShield(details: details);
  };

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
      title: 'Al Sami Auto ERP',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      locale: const Locale('ar', ''),
      theme: AppTheme.lightTheme,
    );
  }
}

// واجهة الخطأ العالمية (Premium Error View)
class _GlobalErrorShield extends StatelessWidget {
  final FlutterErrorDetails details;
  const _GlobalErrorShield({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FE),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                  ),
                  child: const Icon(Icons.settings_suggest_rounded, size: 80, color: AppColors.primaryNavy),
                ),
                const SizedBox(height: 32),
                const Text(
                  'نعتذر، واجهنا عطلاً فنياً مؤقتاً',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'فريقنا التقني يعمل الآن على معالجة هذا العطل. يرجى محاولة العودة للرئيسية لإكمال العمل.',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    // العودة إلى الشاشة الرئيسية وتصفير حالة الملاح (Navigator)
                    // هذا يضمن خروج المستخدم من دائرة الخطأ والعودة لبر الأمان
                    try {
                      context.go('/');
                    } catch (e) {
                      // في حال تعذر الوصول للملاح، لا نقوم بأي إجراء إضافي
                    }
                  },
                  icon: const Icon(Icons.dashboard_customize_rounded),
                  label: const Text('العودة للوحة التحكم الرئيسية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: AppColors.primaryNavy.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







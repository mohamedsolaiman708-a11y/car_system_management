import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/portal_selection_screen.dart';
import '../../features/authentication/presentation/screens/staff_login_screen.dart';
import '../../features/authentication/presentation/screens/investor_login_screen.dart';
import '../../features/authentication/presentation/screens/investor_register_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/reset_password_screen.dart';
import '../../features/authentication/presentation/screens/email_verification_screen.dart';
import '../../features/authentication/presentation/screens/pending_approval_screen.dart';
import '../../features/authentication/presentation/screens/account_rejected_screen.dart';
import '../../features/authentication/presentation/screens/session_expired_screen.dart';
import '../../features/authentication/domain/user_role.dart';

// CRM Screens
import '../../features/crm/presentation/screens/customers_screen.dart';
import '../../features/crm/presentation/screens/create_customer_screen.dart';
import '../../features/crm/presentation/screens/customer_details_screen.dart';
import '../../features/crm/presentation/screens/edit_customer_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final path = state.matchedLocation;

      // Public paths that don't require authentication
      if (!isLoggedIn) {
        if (path == '/' || 
            path == '/portal-selection' || 
            path.startsWith('/auth')) {
          return null;
        }
        return '/portal-selection';
      }

      // If logged in, check approval status for investors
      if (user.role == UserRole.investor) {
        if (user.status == 'pending') return '/auth/pending';
        if (user.status == 'rejected') return '/auth/rejected';
        if (user.status == 'approved' && path.startsWith('/auth')) {
          return '/investor-portal';
        }
      } else {
        // Staff logic
        if (path.startsWith('/auth')) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/portal-selection',
        builder: (context, state) => const PortalSelectionScreen(),
      ),
      GoRoute(
        path: '/auth/staff/login',
        builder: (context, state) => const StaffLoginScreen(),
      ),
      GoRoute(
        path: '/auth/investor/login',
        builder: (context, state) => const InvestorLoginScreen(),
      ),
      GoRoute(
        path: '/auth/investor/register',
        builder: (context, state) => const InvestorRegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/auth/pending',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/auth/rejected',
        builder: (context, state) => const AccountRejectedScreen(),
      ),
      GoRoute(
        path: '/auth/session-expired',
        builder: (context, state) => const SessionExpiredScreen(),
      ),
      
      // Staff Dashboard
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const StaffDashboardScreen(),
      ),

      // CRM Module Routes
      GoRoute(
        path: '/crm/customers',
        builder: (context, state) => const CustomersScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CreateCustomerScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => CustomerDetailsScreen(
              id: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => EditCustomerScreen(
                  id: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/investor-portal',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Investor Portal')),
          body: const Center(child: Text('Investor Dashboard')),
        ),
      ),
    ],
  );
}

// Simple Staff Dashboard with Navigation to CRM
class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
               // ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GridView.count(
          padding: const EdgeInsets.all(24),
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _DashboardCard(
              title: 'إدارة العملاء',
              icon: Icons.people_alt,
              color: Colors.blue,
              onTap: () => context.push('/crm/customers'),
            ),
            _DashboardCard(
              title: 'إدارة المخزون',
              icon: Icons.directions_car,
              color: Colors.orange,
              onTap: () {}, 
            ),
            _DashboardCard(
              title: 'عقود التمويل',
              icon: Icons.description,
              color: Colors.green,
              onTap: () {}, 
            ),
            _DashboardCard(
              title: 'العمليات المالية',
              icon: Icons.account_balance,
              color: Colors.purple,
              onTap: () {}, 
            ),
            _DashboardCard(
              title: 'المستثمرين',
              icon: Icons.trending_up,
              color: Colors.teal,
              onTap: () {}, 
            ),
            _DashboardCard(
              title: 'الإعدادات',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () {}, 
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

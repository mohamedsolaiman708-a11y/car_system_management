import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
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
import '../../features/authentication/presentation/screens/staff_management_screen.dart';
import '../../features/authentication/domain/user_role.dart';

// CRM Screens
import '../../features/crm/presentation/screens/customers_screen.dart';
import '../../features/crm/presentation/screens/create_customer_screen.dart';
import '../../features/crm/presentation/screens/customer_details_screen.dart';
import '../../features/crm/presentation/screens/edit_customer_screen.dart';

// Inventory Screens
import '../../features/inventory/presentation/screens/vehicles_screen.dart';
import '../../features/inventory/presentation/screens/vehicle_details_screen.dart';
import '../../features/inventory/presentation/screens/create_vehicle_screen.dart';
import '../../features/inventory/presentation/screens/edit_vehicle_screen.dart';

// Contracts Screens
import '../../features/contracts/presentation/screens/contracts_screen.dart';
import '../../features/contracts/presentation/screens/create_contract_screen.dart';
import '../../features/contracts/presentation/screens/contract_details_screen.dart';

// Investor Management
import '../../features/investors/presentation/screens/investors_screen.dart';
import '../../features/investors/presentation/screens/investor_details_screen.dart';
import '../../features/investors/presentation/screens/investor_dashboard_screen.dart';

// Dashboard
import '../../features/dashboard/presentation/screens/staff_dashboard_screen.dart';

// Global Search
import '../../features/search/presentation/screens/search_screen.dart';

// Settings & Maintenance
import '../../features/settings/presentation/screens/maintenance_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/company_settings_screen.dart';
import '../../features/settings/presentation/settings_controller.dart';

// Audit Logs
import '../../features/audit/presentation/screens/audit_logs_screen.dart';
import '../../features/audit/presentation/screens/disaster_recovery_screen.dart';

// Reports
import '../../features/reports/presentation/screens/reports_screen.dart';

// Background Jobs
import '../../features/jobs/presentation/screens/jobs_screen.dart';

// Backup & Restore
import '../../features/backup/presentation/screens/backup_screen.dart';

// Help Center
import '../../features/help/presentation/screens/help_center_screen.dart';

// Notifications
import '../../features/notifications/presentation/screens/notifications_screen.dart';

// Accounting
import '../../features/accounting/presentation/screens/accounts_screen.dart';
import '../../features/accounting/presentation/screens/journal_entries_screen.dart';
import '../../features/accounting/presentation/screens/trial_balance_screen.dart';

import 'main_scaffold.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authStateProvider);
  final maintenanceModeAsync = ref.watch(isMaintenanceModeProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final path = state.matchedLocation;

      if (maintenanceModeAsync.value == true && path != '/maintenance') {
        if (isLoggedIn && user.role != UserRole.admin) return '/maintenance';
        if (!isLoggedIn) return '/maintenance';
      }

      if (!isLoggedIn) {
        if (path == '/portal-selection' || path.startsWith('/auth') || path == '/') return null;
        return '/portal-selection';
      }

      final isStaff = user.role != UserRole.investor;
      
      if (isStaff) {
        if (path == '/' || path == '/portal-selection' || path.startsWith('/auth')) {
          return '/dashboard';
        }
        return null;
      }

      if (user.status == 'pending' && path != '/auth/pending') return '/auth/pending';
      if (user.status == 'rejected' && path != '/auth/rejected') return '/auth/rejected';

      if ((user.status == 'approved' || user.status == 'active') && 
          (path == '/' || path == '/portal-selection' || path.startsWith('/auth'))) {
        return '/investor-portal';
      }

      final staffPaths = ['/dashboard', '/crm', '/inventory', '/contracts', '/investors', '/accounting', '/settings', '/staff-management'];
      if (user.role == UserRole.investor && staffPaths.any((p) => path.startsWith(p))) return '/investor-portal';

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/maintenance', builder: (context, state) => const MaintenanceScreen()),
      GoRoute(path: '/portal-selection', builder: (context, state) => const PortalSelectionScreen()),
      GoRoute(path: '/auth/staff/login', builder: (context, state) => const StaffLoginScreen()),
      GoRoute(path: '/auth/investor/login', builder: (context, state) => const InvestorLoginScreen()),
      GoRoute(
        path: '/auth/register', 
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'investor';
          return InvestorRegisterScreen(type: type);
        }
      ),
      GoRoute(path: '/auth/investor/register', redirect: (_, __) => '/auth/register?type=investor'),
      GoRoute(path: '/auth/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/auth/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/auth/verify-email', builder: (context, state) => const EmailVerificationScreen()),
      GoRoute(path: '/auth/pending', builder: (context, state) => const PendingApprovalScreen()),
      GoRoute(path: '/auth/rejected', builder: (context, state) => const AccountRejectedScreen()),
      GoRoute(path: '/auth/session-expired', builder: (context, state) => const SessionExpiredScreen()),
      
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const StaffDashboardScreen()),
          GoRoute(path: '/search', builder: (context, state) => const GlobalSearchScreen()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),

          GoRoute(
            path: '/crm/customers',
            builder: (context, state) => const CustomersScreen(),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const CreateCustomerScreen()),
              GoRoute(path: ':id', builder: (context, state) => CustomerDetailsScreen(id: state.pathParameters['id']!),
                routes: [GoRoute(path: 'edit', builder: (context, state) => EditCustomerScreen(id: state.pathParameters['id']!))],
              ),
            ],
          ),

          GoRoute(
            path: '/inventory',
            builder: (context, state) => const VehiclesScreen(),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const CreateVehicleScreen()),
              GoRoute(path: ':id', builder: (context, state) => VehicleDetailsScreen(id: state.pathParameters['id']!),
                routes: [GoRoute(path: 'edit', builder: (context, state) => EditVehicleScreen(id: state.pathParameters['id']!))],
              ),
            ],
          ),

          GoRoute(
            path: '/contracts',
            builder: (context, state) => const ContractsScreen(),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const CreateContractScreen()),
              GoRoute(path: ':id', builder: (context, state) => ContractDetailsScreen(id: state.pathParameters['id']!)),
            ],
          ),

          GoRoute(
            path: '/investors',
            builder: (context, state) {
              final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
              return InvestorsScreen(initialIndex: tab);
            },
            routes: [
              GoRoute(path: ':id', builder: (context, state) => InvestorDetailsScreen(id: state.pathParameters['id']!)),
            ],
          ),

          GoRoute(
            path: '/accounting',
            builder: (context, state) => const AccountsScreen(),
            routes: [
              GoRoute(path: 'journal', builder: (context, state) => const JournalEntriesScreen()),
              GoRoute(path: 'trial-balance', builder: (context, state) => const TrialBalanceScreen()),
            ],
          ),

          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(path: 'company', builder: (context, state) => const CompanySettingsScreen()),
            ],
          ),
          
          GoRoute(path: '/staff-management', builder: (context, state) => const StaffManagementScreen()),
          GoRoute(path: '/audit-logs', builder: (context, state) => const AuditLogsScreen()),
          GoRoute(path: '/background-jobs', builder: (context, state) => const BackgroundJobsScreen()),
          GoRoute(path: '/backups', builder: (context, state) => const BackupScreen()),
          GoRoute(path: '/disaster-recovery', builder: (context, state) => const DisasterRecoveryScreen()),
          GoRoute(path: '/help-center', builder: (context, state) => const HelpCenterScreen()),
        ],
      ),

      GoRoute(path: '/investor-portal', builder: (context, state) => const InvestorDashboardScreen()),
    ],
  );
}

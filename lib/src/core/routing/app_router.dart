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

      if (!isLoggedIn) {
        if (path == '/' || 
            path == '/portal-selection' || 
            path.startsWith('/auth')) {
          return null;
        }
        return '/portal-selection';
      }

      if (user.role == UserRole.investor) {
        if (user.status == 'pending') return '/auth/pending';
        if (user.status == 'rejected') return '/auth/rejected';
        if (user.status == 'approved' && path.startsWith('/auth')) {
          return '/investor-portal';
        }
      } else {
        if (path.startsWith('/auth') || path == '/portal-selection' || path == '/') {
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
      
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const StaffDashboardScreen(),
      ),

      GoRoute(
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),

      // CRM Module
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

      // Inventory Module
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const VehiclesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CreateVehicleScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => VehicleDetailsScreen(
              id: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => EditVehicleScreen(
                  id: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),

      // Contracts Module
      GoRoute(
        path: '/contracts',
        builder: (context, state) => const ContractsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CreateContractScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => ContractDetailsScreen(
              id: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Investor Management (Staff Side)
      GoRoute(
        path: '/investors',
        builder: (context, state) => const InvestorsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => InvestorDetailsScreen(
              id: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/investor-portal',
        builder: (context, state) => const InvestorDashboardScreen(),
      ),
    ],
  );
}

import 'package:campus_hub/features/admin/presentation/pages/admin_user_list_page.dart';
import 'package:campus_hub/features/reports/presentation/pages/reports_page.dart';
import 'package:campus_hub/features/suggestions/presentation/cubit/suggestion_list_cubit/suggestion_list_cubit.dart';
import 'package:campus_hub/features/suggestions/presentation/pages/suggestion_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../core/utils/go_router_refresh_stream.dart';
import '../features/auth/domain/entities/user_role.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/complaints/presentation/pages/complaint_list_page.dart';
import '../features/complaints/presentation/pages/new_complaint_page.dart';
import '../features/complaints/presentation/pages/complaint_detail_page.dart';
import '../features/venues/presentation/pages/venue_list_page.dart';
import '../features/venues/presentation/pages/venue_detail_page.dart';
import '../features/venues/presentation/pages/my_bookings_page.dart';
import '../features/venues/presentation/pages/booking_detail_page.dart';

import '../features/venues/presentation/pages/coordinator_dashboard_page.dart';
import '../features/venues/presentation/pages/approval_detail_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/complaints/presentation/pages/staff_complaint_dashboard_page.dart';
import '../features/complaints/presentation/pages/staff_complaint_detail_page.dart';

import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_create_user_page.dart';
import '../features/admin/presentation/pages/admin_edit_user_page.dart';
import '../features/admin/presentation/pages/admin_venue_list_page.dart';
import '../features/admin/presentation/pages/admin_venue_form_page.dart';
import '../features/admin/presentation/pages/admin_venue_edit_loader_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sl<AuthStateCubit>().stream),
    redirect: (context, state) {
      final authState = sl<AuthStateCubit>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isInitial = authState is AuthInitial;

      final goingToSplash = state.matchedLocation == '/';
      final goingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isInitial) {
        return goingToSplash ? null : '/';
      }
      if (!isAuthenticated && !goingToAuth) {
        return '/login';
        // return '/suggestions';
      }
      if (isAuthenticated && (goingToSplash || goingToAuth)) {
        return '/home';
        // return '/suggestions';
      }

      // --- Role guards ---
      // Each guard is checked only once we know the user is authenticated,
      // so `authState.user` below is always safe to access.
      if (isAuthenticated) {
        final role = authState.user.role;
        final location = state.matchedLocation;

        if (location.startsWith('/admin') && role != UserRole.admin) {
          return '/home';
        }
        if (location.startsWith('/coordinator') &&
            role != UserRole.venueCoordinator) {
          return '/home';
        }
        if (location.startsWith('/staff') && role != UserRole.departmentStaff) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/complaints',
        name: 'complaints',
        builder: (context, state) => const ComplaintListPage(),
      ),
      GoRoute(
        path: '/new-complaint',
        name: 'newComplaint',
        builder: (context, state) => const NewComplaintPage(),
      ),
      GoRoute(
        path: '/complaint/:id',
        name: 'complaintDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ComplaintDetailPage(complaintId: id);
        },
      ),
      GoRoute(
        path: '/venues',
        name: 'venues',
        builder: (context, state) => const VenueListPage(),
      ),
      GoRoute(
        path: '/venue/:id',
        name: 'venueDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VenueDetailPage(venueId: id);
        },
      ),
      GoRoute(
        path: '/my-bookings',
        name: 'myBookings',
        builder: (context, state) => const MyBookingsPage(),
      ),
      GoRoute(
        path: '/booking/:id',
        name: 'bookingDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookingDetailPage(bookingId: id);
        },
      ),
      GoRoute(
        path: '/coordinator/approvals',
        name: 'coordinatorApprovals',
        builder: (context, state) => const CoordinatorDashboardPage(),
      ),
      GoRoute(
        path: '/approval/:id',
        name: 'approvalDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ApprovalDetailPage(bookingId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/staff/complaints',
        name: 'staffComplaints',
        builder: (context, state) => const StaffComplaintDashboardPage(),
      ),
      GoRoute(
        path: '/staff/complaint/:id',
        name: 'staffComplaintDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StaffComplaintDetailPage(complaintId: id);
        },
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'adminUsers',
        builder: (context, state) => const AdminUserListPage(),
      ),
      GoRoute(
        path: '/admin/users/new',
        name: 'adminCreateUser',
        builder: (context, state) => const AdminCreateUserPage(),
      ),
      GoRoute(
        path: '/admin/users/:id/edit',
        name: 'adminEditUser',
        builder: (context, state) =>
            AdminEditUserPage(uid: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin/venues',
        name: 'adminVenues',
        builder: (context, state) => const AdminVenueListPage(),
      ),
      GoRoute(
        path: '/admin/venues/new',
        name: 'adminCreateVenue',
        builder: (context, state) => const AdminVenueFormPage(),
      ),
      GoRoute(
        path: '/admin/venues/:id/edit',
        name: 'adminEditVenue',
        builder: (context, state) =>
            AdminVenueEditLoaderPage(venueId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin/reports',
        name: 'adminReports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/suggestions',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SuggestionListCubit>(),
          child: const SuggestionListPage(),
        ),
      ),
    ],
  );
}

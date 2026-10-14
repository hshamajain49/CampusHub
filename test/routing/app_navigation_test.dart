import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:campus_hub/core/error/failure.dart';
import 'package:campus_hub/core/theme/app_theme.dart';
import 'package:campus_hub/di/injection_container.dart';
import 'package:campus_hub/features/auth/domain/entities/user_entity.dart';
import 'package:campus_hub/features/auth/domain/entities/user_role.dart';
import 'package:campus_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_hub/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:campus_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:campus_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import 'package:campus_hub/features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import 'package:campus_hub/features/complaints/domain/entities/complaint_category.dart';
import 'package:campus_hub/features/complaints/domain/entities/complaint_status.dart';
import 'package:campus_hub/features/complaints/presentation/cubit/my_complaints_cubit/my_complaints_cubit.dart';
import 'package:campus_hub/features/complaints/presentation/cubit/my_complaints_cubit/my_complaints_state.dart';
import 'package:campus_hub/features/notifications/presentation/cubit/notifications_cubit/notifications_cubit.dart';
import 'package:campus_hub/features/notifications/presentation/cubit/notifications_cubit/notifications_state.dart';
import 'package:campus_hub/features/profile/presentation/cubit/delete_account_cubit/delete_account_cubit.dart';
import 'package:campus_hub/features/reports/domain/entities/analytics_summary_entity.dart';
import 'package:campus_hub/features/reports/domain/repositories/reports_repository.dart';
import 'package:campus_hub/features/reports/domain/usecases/get_analytics_summary_usecase.dart';
import 'package:campus_hub/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:campus_hub/features/venues/domain/entities/booking_status.dart';
import 'package:campus_hub/features/venues/presentation/cubit/my_bookings_cubit/my_booking_cubit.dart';
import 'package:campus_hub/features/venues/presentation/cubit/my_bookings_cubit/my_bookings_state.dart';
import 'package:campus_hub/routing/app_router.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthStateCubit extends MockCubit<AuthState>
    implements AuthStateCubit {}

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

class MockMyComplaintsCubit extends MockCubit<MyComplaintsState>
    implements MyComplaintsCubit {}

class MockMyBookingsCubit extends MockCubit<MyBookingsState>
    implements MyBookingsCubit {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockReportsRepository extends Mock implements ReportsRepository {}

final admin = UserEntity(
  uid: 'admin',
  email: 'ada@campus.edu',
  name: 'Ada Admin',
  role: UserRole.admin,
  createdAt: DateTime(2025, 8, 1),
);

final student = UserEntity(
  uid: 'student',
  email: 'sam@campus.edu',
  name: 'Sam Student',
  role: UserRole.student,
  createdAt: DateTime(2025, 8, 1),
);

final summary = AnalyticsSummaryEntity(
  totalUsers: 7,
  usersByRole: {
    for (final r in UserRole.values) r: r == UserRole.student ? 5 : 1,
  },
  totalComplaints: 7,
  complaintsByStatus: {for (final s in ComplaintStatus.values) s: 1},
  complaintsByCategory: {for (final c in ComplaintCategory.values) c: 1},
  complaintsByDepartment: const {'IT Department': 7},
  complaintsTrend30d: const [],
  totalBookings: 8,
  bookingsByStatus: {for (final s in BookingStatus.values) s: 2},
  bookingsByVenue: const {'Main Hall': 8},
  bookingApprovalRate: 0.83,
  generatedAt: DateTime(2026, 10, 14, 9, 30),
);

void main() {
  final authStates = StreamController<AuthState>.broadcast();
  late MockAuthStateCubit authCubit;
  late MockAuthRepository authRepository;

  void signIn(AuthState state) {
    when(() => authCubit.state).thenReturn(state);
    authStates.add(state);
  }

  setUpAll(() {
    authCubit = MockAuthStateCubit();
    authRepository = MockAuthRepository();
    when(() => authCubit.stream).thenAnswer((_) => authStates.stream);
    when(() => authCubit.state).thenReturn(const AuthUnauthenticated());

    final reportsRepository = MockReportsRepository();
    when(
      reportsRepository.getAnalyticsSummary,
    ).thenAnswer((_) async => Right(summary));

    sl
      ..registerSingleton<AuthStateCubit>(authCubit)
      ..registerFactory(() => LoginCubit(LoginUseCase(authRepository)))
      ..registerSingleton(LogoutUseCase(authRepository))
      ..registerFactory(
        () => DeleteAccountCubit(DeleteAccountUseCase(authRepository)),
      )
      ..registerFactory(
        () => ReportsCubit(GetAnalyticsSummaryUseCase(reportsRepository)),
      )
      ..registerFactory<NotificationsCubit>(() {
        final cubit = MockNotificationsCubit();
        when(() => cubit.state).thenReturn(const NotificationsLoaded([]));
        return cubit;
      })
      ..registerFactory<MyComplaintsCubit>(() {
        final cubit = MockMyComplaintsCubit();
        when(() => cubit.state).thenReturn(const MyComplaintsLoaded([]));
        return cubit;
      })
      ..registerFactory<MyBookingsCubit>(() {
        final cubit = MockMyBookingsCubit();
        when(() => cubit.state).thenReturn(const MyBookingsLoaded([]));
        return cubit;
      });
  });

  tearDownAll(() async {
    await sl.reset();
    await authStates.close();
  });

  Future<void> pumpApp(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<AuthStateCubit>.value(
        value: authCubit,
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
        ),
      ),
    );
    AppRouter.router.go(location);
    await tester.pumpAndSettle();
  }

  /// The top-most page's location, including routes opened with push().
  String location() =>
      AppRouter.router.routerDelegate.currentConfiguration.last.matchedLocation;

  group('Admin Panel', () {
    testWidgets(
      'opened from the dashboard, lists Manage Users, Manage Venues and Reports',
      (tester) async {
        signIn(AuthAuthenticated(admin));
        await pumpApp(tester, '/home');

        await tester.tap(find.text('Admin panel'));
        await tester.pumpAndSettle();

        expect(location(), '/admin');
        expect(find.text('Manage Users'), findsOneWidget);
        expect(find.text('Manage Venues'), findsOneWidget);
        expect(find.text('Reports'), findsOneWidget);
      },
    );

    testWidgets('Reports opens the statistics page', (tester) async {
      signIn(AuthAuthenticated(admin));
      await pumpApp(tester, '/admin');

      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      expect(location(), '/admin/reports');
      expect(find.text('Reports & Analytics'), findsOneWidget);
      expect(find.text('Total complaints'), findsOneWidget);
      expect(find.text('83%'), findsOneWidget);
    });

    testWidgets('is off limits to non-admins', (tester) async {
      signIn(AuthAuthenticated(student));
      await pumpApp(tester, '/admin/reports');

      expect(location(), '/home');
      expect(find.text('Reports & Analytics'), findsNothing);
    });
  });

  group('My Account', () {
    testWidgets('opens from the profile menu with a Delete Account option', (
      tester,
    ) async {
      signIn(AuthAuthenticated(student));
      await pumpApp(tester, '/home');

      await tester.tap(find.byTooltip('Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My account'));
      await tester.pumpAndSettle();

      expect(location(), '/profile');
      expect(find.text('sam@campus.edu'), findsWidgets);
      expect(find.text('DANGER ZONE'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('deletion needs the acknowledgement and password', (
      tester,
    ) async {
      when(() => authRepository.deleteAccount(password: 'wrong')).thenAnswer(
        (_) async =>
            const Left(AuthFailure('Incorrect password. Please try again.')),
      );
      signIn(AuthAuthenticated(student));
      await pumpApp(tester, '/profile');

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete your account?'), findsOneWidget);

      // Disabled until the user ticks the acknowledgement.
      await tester.tap(find.text('Delete My Account'));
      await tester.pumpAndSettle();
      verifyNever(
        () => authRepository.deleteAccount(password: any(named: 'password')),
      );

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.text('Delete My Account'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your password to confirm'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'wrong');
      await tester.tap(find.text('Delete My Account'));
      await tester.pumpAndSettle();
      expect(
        find.text('Incorrect password. Please try again.'),
        findsOneWidget,
      );
      expect(location(), '/profile');
    });

    testWidgets('a successful deletion shows the confirmation page', (
      tester,
    ) async {
      when(() => authRepository.deleteAccount(password: 'secret')).thenAnswer((
        _,
      ) async {
        // Deleting the account signs the user out, as Firebase does.
        signIn(const AuthUnauthenticated());
        return const Right(null);
      });
      signIn(AuthAuthenticated(student));
      await pumpApp(tester, '/profile');

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.enterText(find.byType(TextFormField), 'secret');
      await tester.tap(find.text('Delete My Account'));
      await tester.pumpAndSettle();

      expect(location(), '/account-deleted');
      expect(find.text('Account deleted'), findsOneWidget);
      expect(
        find.textContaining('deleted successfully', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();
      expect(location(), '/login');
    });

    testWidgets('explains a half-finished deletion after the forced sign-out', (
      tester,
    ) async {
      const message =
          'Your data was deleted, but your sign-in could not be removed. '
          'Sign in once more to finish deleting your account.';
      when(() => authRepository.deleteAccount(password: 'secret')).thenAnswer((
        _,
      ) async {
        signIn(const AuthUnauthenticated());
        return const Left(SignedOutFailure(message));
      });
      signIn(AuthAuthenticated(student));
      await pumpApp(tester, '/profile');

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.enterText(find.byType(TextFormField), 'secret');
      await tester.tap(find.text('Delete My Account'));
      await tester.pumpAndSettle();

      expect(location(), '/login');
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('signed-out users cannot open it', (tester) async {
      signIn(const AuthUnauthenticated());
      await pumpApp(tester, '/profile');
      expect(location(), '/login');
    });
  });
}

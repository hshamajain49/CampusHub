import 'package:bloc_test/bloc_test.dart';
import 'package:campus_hub/core/theme/app_theme.dart';
import 'package:campus_hub/di/injection_container.dart';
import 'package:campus_hub/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:campus_hub/features/admin/presentation/widgets/delete_user_dialog.dart';
import 'package:campus_hub/features/auth/domain/entities/user_entity.dart';
import 'package:campus_hub/features/auth/domain/entities/user_role.dart';
import 'package:campus_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_hub/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:campus_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import 'package:campus_hub/features/profile/presentation/cubit/delete_account_cubit/delete_account_cubit.dart';
import 'package:campus_hub/features/profile/presentation/pages/account_deleted_page.dart';
import 'package:campus_hub/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthStateCubit extends MockCubit<AuthState>
    implements AuthStateCubit {}

class MockAuthRepository extends Mock implements AuthRepository {}

final staff = UserEntity(
  uid: 'staff',
  email: 'a.very.long.email.address.for.testing@campus-university.edu',
  name: 'Maximiliana Alexandra Rodriguez-Fernandez',
  role: UserRole.departmentStaff,
  department: 'Furniture/Carpentry Department',
  createdAt: DateTime(2025, 8, 1),
);

void main() {
  late MockAuthStateCubit authCubit;

  setUpAll(() {
    final repository = MockAuthRepository();
    sl
      ..registerFactory(
        () => DeleteAccountCubit(DeleteAccountUseCase(repository)),
      )
      ..registerSingleton(LogoutUseCase(repository));
  });

  tearDownAll(sl.reset);

  setUp(() {
    authCubit = MockAuthStateCubit();
    when(() => authCubit.state).thenReturn(AuthAuthenticated(staff));
  });

  /// Small phone (320 x 568 dp) with large accessibility text.
  Future<void> pumpSmall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthStateCubit>.value(
        value: authCubit,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('admin panel shows all three sections on a small phone', (
    tester,
  ) async {
    await pumpSmall(tester, const AdminDashboardPage());
    expect(find.text('Manage Users'), findsOneWidget);
    expect(find.text('Manage Venues'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile page and delete sheet fit a small phone', (
    tester,
  ) async {
    await pumpSmall(tester, const ProfilePage());
    expect(find.text('Furniture/Carpentry Department'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Delete Account'), 200);
    await tester.ensureVisible(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    await tester.ensureVisible(find.text('Keep my account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Keep my account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsNothing);
  });

  testWidgets('account deleted page fits a small phone', (tester) async {
    await pumpSmall(tester, const AccountDeletedPage());
    expect(find.text('Account deleted'), findsOneWidget);
    expect(find.text('Back to Sign In'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin delete dialog only confirms after typing DELETE', (
    tester,
  ) async {
    bool? confirmed;
    await pumpSmall(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async =>
                confirmed = await DeleteUserDialog.show(context, staff),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final deleteButton = find.widgetWithText(TextButton, 'Delete');
    expect(tester.widget<TextButton>(deleteButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'delete');
    await tester.pump();
    expect(tester.widget<TextButton>(deleteButton).onPressed, isNotNull);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('cancelling the admin delete dialog returns false', (
    tester,
  ) async {
    bool? confirmed;
    await pumpSmall(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async =>
                confirmed = await DeleteUserDialog.show(context, staff),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);
  });
}

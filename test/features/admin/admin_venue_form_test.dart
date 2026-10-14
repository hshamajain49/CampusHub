import 'package:campus_hub/core/theme/app_theme.dart';
import 'package:campus_hub/di/injection_container.dart';
import 'package:campus_hub/features/admin/domain/repositories/admin_repository.dart';
import 'package:campus_hub/features/admin/domain/usecases/get_all_users_usecase.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/venue_action_cubit.dart/venue_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/pages/admin_venue_form_page.dart';
import 'package:campus_hub/features/auth/domain/entities/user_entity.dart';
import 'package:campus_hub/features/auth/domain/entities/user_role.dart';
import 'package:campus_hub/features/venues/domain/entities/venue_entity.dart';
import 'package:campus_hub/features/venues/domain/repositories/venue_repository.dart';
import 'package:campus_hub/features/venues/domain/usecases/create_venue_usecase.dart';
import 'package:campus_hub/features/venues/domain/usecases/update_venue_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

class MockVenueRepository extends Mock implements VenueRepository {}

void main() {
  setUpAll(() {
    final adminRepository = MockAdminRepository();
    when(adminRepository.getAllUsers).thenAnswer(
      (_) => Stream.value([
        UserEntity(
          uid: 'coord',
          email: 'cora@campus.edu',
          name: 'Cora Coord',
          role: UserRole.venueCoordinator,
          createdAt: DateTime(2026),
        ),
      ]),
    );
    final venueRepository = MockVenueRepository();
    sl
      ..registerFactory(
        () => AdminUsersCubit(GetAllUsersUseCase(adminRepository)),
      )
      ..registerFactory(
        () => VenueActionCubit(
          createVenueUseCase: CreateVenueUseCase(venueRepository),
          updateVenueUseCase: UpdateVenueUseCase(venueRepository),
        ),
      );
  });

  tearDownAll(sl.reset);

  testWidgets(
    'a venue whose coordinator account is gone opens and asks for a new one',
    (tester) async {
      const venue = VenueEntity(
        id: 'hall',
        name: 'Main Hall',
        description: 'Big',
        capacity: 200,
        building: 'Block A',
        amenities: [],
        imageUrl: '',
        isActive: true,
        coordinatorId: 'deleted-coordinator',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AdminVenueFormPage(venue: venue),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      expect(find.text('Please assign a coordinator'), findsOneWidget);
    },
  );
}

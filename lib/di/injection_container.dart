import 'package:campus_hub/features/admin/domain/usecases/create_manage_user_usecase.dart';
import 'package:campus_hub/features/admin/domain/usecases/send_password_reset_usecase.dart';
import 'package:campus_hub/features/admin/domain/usecases/update_user_active_status_usecase.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/venue_action_cubit.dart/venue_action_cubit.dart';
import 'package:campus_hub/features/auth/domain/usecases/register_usecase_student.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import 'package:campus_hub/features/complaints/presentation/cubit/complaint_detail_cubit/complaint_detail_cubit.dart';
import 'package:campus_hub/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:campus_hub/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:campus_hub/features/reports/domain/repositories/reports_repository.dart';
import 'package:campus_hub/features/reports/domain/usecases/get_analytics_summary_usecase.dart';
import 'package:campus_hub/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:campus_hub/features/suggestions/data/datasources/suggestion_remote_datasource.dart';
import 'package:campus_hub/features/suggestions/data/repositories/suggestion_repository_impl.dart';
import 'package:campus_hub/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:campus_hub/features/suggestions/domain/usecases/create_suggestion_usecase.dart';
import 'package:campus_hub/features/suggestions/domain/usecases/get_suggestions_stream_usecase.dart';
import 'package:campus_hub/features/suggestions/domain/usecases/toggle_upvote_usecase.dart';
import 'package:campus_hub/features/suggestions/presentation/cubit/suggestion_list_cubit/suggestion_list_cubit.dart';
import 'package:campus_hub/features/venues/domain/usecases/get_venue_by_id_usecase.dart';
import 'package:campus_hub/features/venues/presentation/cubit/create_booking_cubit/create_booking_cubit.dart';
import 'package:campus_hub/features/venues/presentation/cubit/my_bookings_cubit/my_booking_cubit.dart';
import 'package:campus_hub/features/venues/presentation/cubit/venue_list_cubit/venue_list_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import '../features/auth/presentation/cubit/register_cubit/register_cubit.dart';
import '../core/constants/cloudinary_constants.dart';
import '../core/services/cloudinary_service.dart';
import '../features/complaints/data/datasources/complaint_remote_datasource.dart';
import '../features/complaints/data/repositories/complaint_repository_impl.dart';
import '../features/complaints/domain/repositories/complaint_repository.dart';
import '../features/complaints/domain/usecases/create_complaint_usecase.dart';
import '../features/complaints/domain/usecases/get_my_complaints_usecase.dart';
import '../features/complaints/domain/usecases/get_complaint_by_id_usecase.dart';
import '../features/complaints/presentation/cubit/create_complaint_cubit/create_complaint_cubit.dart';
import '../features/complaints/presentation/cubit/my_complaints_cubit/my_complaints_cubit.dart';
import '../features/venues/data/datasources/venue_remote_datasource.dart';
import '../features/venues/data/datasources/booking_remote_datasource.dart';
import '../features/venues/data/repositories/venue_repository_impl.dart';
import '../features/venues/domain/repositories/venue_repository.dart';
import '../features/venues/domain/usecases/get_venues_usecase.dart';
import '../features/venues/domain/usecases/create_booking_usecase.dart';
import '../features/venues/domain/usecases/get_my_bookings_usecase.dart';
import '../features/venues/presentation/cubit/venue_detail_cubit/venue_detail_cubit.dart';
import '../features/venues/domain/usecases/get_booking_by_id_usecase.dart';
import '../features/venues/domain/usecases/update_booking_usecase.dart';
import '../features/venues/domain/usecases/cancel_booking_usecase.dart';
import '../features/venues/presentation/cubit/booking_detail_cubit/booking_detail_cubit.dart';
import '../features/venues/presentation/cubit/booking_action_cubit/booking_action_cubit.dart';

import '../features/venues/domain/usecases/get_bookings_for_coordinator_usecase.dart';
import '../features/venues/domain/usecases/approve_booking_usecase.dart';
import '../features/venues/domain/usecases/reject_booking_usecase.dart';
import '../features/venues/presentation/cubit/coordinator_approvals_cubit/coordinator_approvals_cubit.dart';
import '../features/venues/presentation/cubit/approval_action_cubit/approval_action_cubit.dart';
import '../features/notifications/data/notification_writer.dart';
import '../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/domain/usecases/get_my_notifications_usecase.dart';
import '../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import '../features/notifications/presentation/cubit/notifications_cubit/notifications_cubit.dart';
import '../features/complaints/domain/usecases/update_complaint_status_usecase.dart';
import '../features/complaints/domain/usecases/get_complaints_by_department_usecase.dart';
import '../features/complaints/presentation/cubit/staff_complaints_cubit/staff_complaints_cubit.dart';
import '../features/complaints/presentation/cubit/complaint_status_action_cubit/complaint_status_action_cubit.dart';
import '../features/admin/data/datasources/admin_remote_datasource.dart';
import '../features/admin/data/repositories/admin_repository_impl.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/admin/domain/usecases/get_all_users_usecase.dart';
import '../features/admin/domain/usecases/update_user_role_usecase.dart';
import '../features/venues/domain/usecases/create_venue_usecase.dart';
import '../features/venues/domain/usecases/update_venue_usecase.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterStudentUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton(() => AuthStateCubit(authRepository: sl()));

  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactory(() => RegisterCubit(sl()));
  sl.registerLazySingleton(
    () => const CloudinaryService(
      cloudName: CloudinaryConstants.cloudName,
      uploadPreset: CloudinaryConstants.uploadPreset,
    ),
  );

  sl.registerLazySingleton<ComplaintRepository>(
    () => ComplaintRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => CreateComplaintUseCase(sl()));
  sl.registerLazySingleton(() => GetMyComplaintsUseCase(sl()));
  sl.registerLazySingleton(() => GetComplaintByIdUseCase(sl()));

  sl.registerFactory(() => CreateComplaintCubit(sl()));
  sl.registerFactory(
    () => MyComplaintsCubit(getMyComplaintsUseCase: sl(), firebaseAuth: sl()),
  );
  sl.registerFactory(() => ComplaintDetailCubit(sl()));
  sl.registerLazySingleton<VenueRemoteDataSource>(
    () => VenueRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      notificationWriter: sl(),
    ),
  );

  sl.registerLazySingleton<ComplaintRemoteDataSource>(
    () => ComplaintRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      cloudinaryService: sl(),
      notificationWriter: sl(),
    ),
  );

  sl.registerLazySingleton<VenueRepository>(
    () => VenueRepositoryImpl(venueDataSource: sl(), bookingDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetVenuesUseCase(sl()));
  sl.registerLazySingleton(() => GetVenueByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetMyBookingsUseCase(sl()));
  sl.registerFactory(() => VenueListCubit(sl()));
  sl.registerFactory(() => CreateBookingCubit(sl()));
  sl.registerFactory(
    () => MyBookingsCubit(getMyBookingsUseCase: sl(), firebaseAuth: sl()),
  );
  sl.registerFactory(() => VenueDetailCubit(sl()));
  sl.registerLazySingleton(() => GetBookingByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBookingUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerFactory(() => BookingDetailCubit(sl()));
  sl.registerFactory(
    () => BookingActionCubit(
      updateBookingUseCase: sl(),
      cancelBookingUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetBookingsForCoordinatorUseCase(sl()));
  sl.registerLazySingleton(() => ApproveBookingUseCase(sl()));
  sl.registerLazySingleton(() => RejectBookingUseCase(sl()));
  sl.registerFactory(
    () => CoordinatorApprovalsCubit(
      getBookingsForCoordinatorUseCase: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerFactory(
    () => ApprovalActionCubit(
      approveBookingUseCase: sl(),
      rejectBookingUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => NotificationWriter(sl<FirebaseFirestore>()));
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetMyNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));
  sl.registerFactory(
    () => NotificationsCubit(
      getMyNotificationsUseCase: sl(),
      markNotificationReadUseCase: sl(),
      markAllNotificationsReadUseCase: sl(),
      firebaseAuth: sl(),
    ),
  );

  sl.registerLazySingleton(() => UpdateComplaintStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetComplaintsByDepartmentUseCase(sl()));
  sl.registerFactory(
    () => StaffComplaintsCubit(getComplaintsByDepartmentUseCase: sl()),
  );
  sl.registerFactory(() => ComplaintStatusActionCubit(sl()));
  // --- Admin feature ---
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton(() => UpdateUserActiveStatusUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => CreateManagedUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserRoleUseCase(sl()));
  sl.registerFactory(() => AdminUsersCubit(sl()));
  sl.registerFactory(
    () => UserActionCubit(
      createManagedUserUseCase: sl(),
      updateUserRoleUseCase: sl(),
      updateUserActiveStatusUseCase: sl(),
      sendPasswordResetUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreateVenueUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVenueUseCase(sl()));
  sl.registerFactory(
    () => VenueActionCubit(createVenueUseCase: sl(), updateVenueUseCase: sl()),
  );
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAnalyticsSummaryUseCase(sl()));
  sl.registerFactory(() => ReportsCubit(sl()));
  sl.registerLazySingleton<SuggestionRemoteDataSource>(
    () => SuggestionRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<SuggestionRepository>(
    () => SuggestionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetSuggestionsStreamUseCase(sl()));
  sl.registerLazySingleton(() => CreateSuggestionUseCase(sl()));
  sl.registerLazySingleton(() => ToggleUpvoteUseCase(sl()));

  sl.registerFactory(() {
    final authState = sl<AuthStateCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';
    return SuggestionListCubit(
      getSuggestionsStreamUseCase: sl(),
      toggleUpvoteUseCase: sl(),
      currentUserId: uid,
    );
  });
}

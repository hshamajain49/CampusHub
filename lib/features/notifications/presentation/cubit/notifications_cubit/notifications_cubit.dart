import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/usecases/get_my_notifications_usecase.dart';
import '../../../domain/usecases/mark_notification_read_usecase.dart';
import '../../../domain/usecases/mark_all_notifications_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetMyNotificationsUseCase getMyNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  final FirebaseAuth firebaseAuth;
  StreamSubscription? _subscription;

  NotificationsCubit({
    required this.getMyNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
    required this.firebaseAuth,
  }) : super(const NotificationsLoading()) {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      emit(const NotificationsError('Not logged in.'));
      return;
    }
    _subscription = getMyNotificationsUseCase(uid).listen(
      (notifications) => emit(NotificationsLoaded(notifications)),
      onError: (_) =>
          emit(const NotificationsError('Failed to load notifications.')),
    );
  }

  Future<void> markAsRead(String notificationId) =>
      markNotificationReadUseCase(notificationId);

  Future<void> markAllAsRead() async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid != null) await markAllNotificationsReadUseCase(uid);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

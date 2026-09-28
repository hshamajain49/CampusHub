import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/booking_status.dart';
import '../../../domain/usecases/get_bookings_for_coordinator_usecase.dart';
import 'coordinator_approvals_state.dart';

class CoordinatorApprovalsCubit extends Cubit<CoordinatorApprovalsState> {
  final GetBookingsForCoordinatorUseCase getBookingsForCoordinatorUseCase;
  final FirebaseAuth firebaseAuth;
  StreamSubscription? _subscription;

  CoordinatorApprovalsCubit({
    required this.getBookingsForCoordinatorUseCase,
    required this.firebaseAuth,
  }) : super(const CoordinatorApprovalsLoading()) {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      emit(const CoordinatorApprovalsError('Not logged in.'));
      return;
    }
    _subscription = getBookingsForCoordinatorUseCase(uid).listen(
      (bookings) {
        final pending = bookings
            .where((b) => b.status == BookingStatus.pending)
            .toList();
        final history = bookings
            .where((b) => b.status != BookingStatus.pending)
            .toList();
        emit(CoordinatorApprovalsLoaded(pending: pending, history: history));
      },
      onError: (_) => emit(
        const CoordinatorApprovalsError('Failed to load approval requests.'),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

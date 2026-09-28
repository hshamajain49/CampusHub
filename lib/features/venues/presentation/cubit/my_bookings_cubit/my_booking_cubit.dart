import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/usecases/get_my_bookings_usecase.dart';
import 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final FirebaseAuth firebaseAuth;
  StreamSubscription? _subscription;

  MyBookingsCubit({
    required this.getMyBookingsUseCase,
    required this.firebaseAuth,
  }) : super(const MyBookingsLoading()) {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      emit(const MyBookingsError('Not logged in.'));
      return;
    }
    _subscription = getMyBookingsUseCase(uid).listen(
      (bookings) => emit(MyBookingsLoaded(bookings)),
      onError: (_) => emit(const MyBookingsError('Failed to load bookings.')),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

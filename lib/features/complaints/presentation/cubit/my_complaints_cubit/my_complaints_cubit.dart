import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/usecases/get_my_complaints_usecase.dart';
import 'my_complaints_state.dart';

class MyComplaintsCubit extends Cubit<MyComplaintsState> {
  final GetMyComplaintsUseCase getMyComplaintsUseCase;
  final FirebaseAuth firebaseAuth;
  StreamSubscription? _subscription;

  MyComplaintsCubit({
    required this.getMyComplaintsUseCase,
    required this.firebaseAuth,
  }) : super(const MyComplaintsLoading()) {
    _listen();
  }

  void _listen() {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      emit(const MyComplaintsError('Not logged in.'));
      return;
    }

    _subscription = getMyComplaintsUseCase(uid).listen(
      (complaints) => emit(MyComplaintsLoaded(complaints)),
      onError: (_) =>
          emit(const MyComplaintsError('Failed to load complaints.')),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

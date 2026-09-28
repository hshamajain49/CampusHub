import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthStateCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _subscription;
  bool _hasResolvedInitialState = false;

  AuthStateCubit({required this.authRepository}) : super(const AuthInitial()) {
    _listen();
  }

  void _listen() {
    final splashMinDuration = Future.delayed(
      const Duration(milliseconds: 2000),
    );

    _subscription = authRepository.authStateChanges.listen(
      (user) async {
        if (!_hasResolvedInitialState) {
          await splashMinDuration;
          _hasResolvedInitialState = true;
        }
        emit(
          user == null ? const AuthUnauthenticated() : AuthAuthenticated(user),
        );
      },
      onError: (_) async {
        // splash screen would never navigate anywhere.
        if (!_hasResolvedInitialState) {
          await splashMinDuration;
          _hasResolvedInitialState = true;
        }
        emit(const AuthUnauthenticated());
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

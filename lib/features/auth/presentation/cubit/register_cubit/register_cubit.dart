import 'package:campus_hub/features/auth/domain/usecases/register_usecase_student.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterStudentUseCase registerStudentUseCase;
  RegisterCubit(this.registerStudentUseCase) : super(const RegisterInitial());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const RegisterLoading());

    final result = await registerStudentUseCase(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(RegisterError(failure.message)),
      (user) => emit(RegisterSuccess(user)),
    );
  }
}

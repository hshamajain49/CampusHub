import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_users_usecase.dart';
import 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  AdminUsersCubit(this.getAllUsersUseCase) : super(const AdminUsersLoading()) {
    getAllUsersUseCase().listen(
      (users) => emit(AdminUsersLoaded(users)),
      onError: (_) => emit(const AdminUsersError('Failed to load users.')),
    );
  }
}

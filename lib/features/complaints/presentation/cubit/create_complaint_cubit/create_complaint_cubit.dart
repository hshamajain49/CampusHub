import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/complaint_category.dart';
import '../../../domain/usecases/create_complaint_usecase.dart';
import 'create_complaint_state.dart';

class CreateComplaintCubit extends Cubit<CreateComplaintState> {
  final CreateComplaintUseCase createComplaintUseCase;
  CreateComplaintCubit(this.createComplaintUseCase)
    : super(const CreateComplaintInitial());

  Future<void> submit({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  }) async {
    emit(const CreateComplaintLoading());

    final result = await createComplaintUseCase(
      title: title,
      description: description,
      category: category,
      location: location,
      imagePaths: imagePaths,
    );

    result.fold(
      (failure) => emit(CreateComplaintError(failure.message)),
      (complaint) => emit(CreateComplaintSuccess(complaint)),
    );
  }
}

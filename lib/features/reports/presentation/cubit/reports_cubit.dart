import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_analytics_summary_usecase.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final GetAnalyticsSummaryUseCase getAnalyticsSummaryUseCase;
  ReportsCubit(this.getAnalyticsSummaryUseCase) : super(ReportsInitial());

  Future<void> load() async {
    emit(ReportsLoading());
    final result = await getAnalyticsSummaryUseCase();
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (summary) => emit(ReportsLoaded(summary)),
    );
  }
}

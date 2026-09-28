import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/analytics_summary_entity.dart';
import '../repositories/reports_repository.dart';

class GetAnalyticsSummaryUseCase {
  final ReportsRepository repository;
  const GetAnalyticsSummaryUseCase(this.repository);

  Future<Either<Failure, AnalyticsSummaryEntity>> call() =>
      repository.getAnalyticsSummary();
}

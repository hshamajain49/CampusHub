import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/analytics_summary_entity.dart';

abstract class ReportsRepository {
  Future<Either<Failure, AnalyticsSummaryEntity>> getAnalyticsSummary();
}

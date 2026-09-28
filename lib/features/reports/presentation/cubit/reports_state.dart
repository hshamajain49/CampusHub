import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics_summary_entity.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final AnalyticsSummaryEntity summary;
  const ReportsLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

class DailyCount extends Equatable {
  final DateTime date;
  final int count;

  const DailyCount({required this.date, required this.count});

  @override
  List<Object?> get props => [date, count];
}

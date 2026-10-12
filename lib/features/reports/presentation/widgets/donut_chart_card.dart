import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'chart_datum.dart';
import 'report_card.dart';

/// Donut chart with the total in the centre and a legend. Segments with
/// value 0 are skipped.
class DonutChartCard extends StatelessWidget {
  final String title;
  final List<ChartDatum> data;
  const DonutChartCard({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final nonZero = data.where((d) => d.value > 0).toList();
    final total = nonZero.fold<int>(0, (sum, d) => sum + d.value);

    return ReportCard(
      title: title,
      subtitle: total == 0 ? null : '$total total',
      child: total == 0
          ? const _EmptyState()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 124,
                  height: 124,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: nonZero
                              .map(
                                (d) => PieChartSectionData(
                                  value: d.value.toDouble(),
                                  color: d.color,
                                  title: '',
                                  radius: 20,
                                ),
                              )
                              .toList(),
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: AppTextStyles.h2.copyWith(height: 1.1),
                          ),
                          Text('total', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nonZero.map((d) {
                      final pct = ((d.value / total) * 100).round();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: d.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.label,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text('$pct%', style: AppTextStyles.label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text('No data yet.', style: AppTextStyles.bodySecondary),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'chart_datum.dart';
import 'report_card.dart';

/// Donut chart with a legend. Segments with value 0 are skipped.
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
      child: total == 0
          ? const _EmptyState()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: nonZero
                          .map(
                            (d) => PieChartSectionData(
                              value: d.value.toDouble(),
                              color: d.color,
                              title: '',
                              radius: 26,
                            ),
                          )
                          .toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nonZero.map((d) {
                      final pct = ((d.value / total) * 100).round();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: d.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.label,
                                style: AppTextStyles.bodySecondary,
                              ),
                            ),
                            Text(
                              '${d.value} · $pct%',
                              style: AppTextStyles.caption,
                            ),
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

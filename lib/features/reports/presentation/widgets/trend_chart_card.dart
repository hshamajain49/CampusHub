import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/daily_count.dart';
import 'report_card.dart';

class TrendChartCard extends StatelessWidget {
  final String title;
  final List<DailyCount> data;
  const TrendChartCard({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, d) => sum + d.count);
    final spots = <FlSpot>[
      for (int i = 0; i < data.length; i++)
        FlSpot(i.toDouble(), data[i].count.toDouble()),
    ];
    final maxY = data.isEmpty
        ? 1.0
        : (data.map((d) => d.count).reduce((a, b) => a > b ? a : b)).toDouble();

    return ReportCard(
      title: title,
      child: total == 0
          ? Text(
              'No activity in the last 30 days.',
              style: AppTextStyles.bodySecondary,
            )
          : SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY < 4 ? 4 : maxY + 1,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((s) {
                        final day = data[s.x.toInt()].date;
                        return LineTooltipItem(
                          '${day.day}/${day.month}: ${s.y.toInt()}',
                          const TextStyle(
                            color: AppColors.surface,
                            fontSize: 11,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: AppColors.secondary,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
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
      subtitle: total == 0 ? null : '$total new',
      child: total == 0
          ? Text(
              'No activity in the last 30 days.',
              style: AppTextStyles.bodySecondary,
            )
          : Column(
              children: [
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY < 4 ? 4 : maxY + 1,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.divider,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.textPrimary,
                          getTooltipItems: (spots) => spots.map((s) {
                            final day = data[s.x.toInt()].date;
                            return LineTooltipItem(
                              '${day.day} ${monthShort(day)}: ${s.y.toInt()}',
                              const TextStyle(
                                color: AppColors.surface,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
                          preventCurveOverShooting: true,
                          color: AppColors.secondary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.secondary.withValues(alpha: 0.25),
                                AppColors.secondary.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (data.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${data.first.date.day} ${monthShort(data.first.date)}',
                        style: AppTextStyles.caption,
                      ),
                      Text('Today', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

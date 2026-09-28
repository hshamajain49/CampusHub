import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'chart_datum.dart';
import 'report_card.dart';

/// Simple proportional horizontal bars — used for breakdowns with arbitrary
/// text labels (categories, departments, venue names) where axis-tick charts
/// don't fit well. Sorted descending, capped to [maxItems].
class HorizontalBarListCard extends StatelessWidget {
  final String title;
  final List<ChartDatum> data;
  final int maxItems;
  const HorizontalBarListCard({
    super.key,
    required this.title,
    required this.data,
    this.maxItems = 6,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...data.where((d) => d.value > 0)]
      ..sort((a, b) => b.value.compareTo(a.value));
    final shown = sorted.take(maxItems).toList();
    final maxValue = shown.isEmpty ? 1 : shown.first.value;

    return ReportCard(
      title: title,
      child: shown.isEmpty
          ? Text('No data yet.', style: AppTextStyles.bodySecondary)
          : Column(
              children: shown.map((d) {
                final fraction = d.value / maxValue;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d.label,
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                          Text('${d.value}', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Stack(
                            children: [
                              Container(
                                height: 8,
                                width: constraints.maxWidth,
                                color: AppColors.divider,
                              ),
                              Container(
                                height: 8,
                                width: constraints.maxWidth * fraction,
                                color: d.color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

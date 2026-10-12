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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${d.value}', style: AppTextStyles.label),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 8,
                          child: Stack(
                            children: [
                              Container(color: AppColors.surfaceMuted),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: fraction),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) =>
                                    FractionallySizedBox(
                                      widthFactor: value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              d.color.withValues(alpha: 0.7),
                                              d.color,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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

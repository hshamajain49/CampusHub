import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/suggestion_entity.dart';

class SuggestionCard extends StatelessWidget {
  final SuggestionEntity suggestion;
  final bool isUpvoted;
  final VoidCallback onUpvoteTap;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.isUpvoted,
    required this.onUpvoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UpvoteButton(
            count: suggestion.upvoteCount,
            isUpvoted: isUpvoted,
            onTap: onUpvoteTap,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suggestion.title, style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(
                  suggestion.description,
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 13.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    UserAvatar(
                      name: suggestion.authorName,
                      size: 22,
                      color: AppColors.suggestions,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        suggestion.authorName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '  ·  ${timeAgo(suggestion.createdAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpvoteButton extends StatelessWidget {
  final int count;
  final bool isUpvoted;
  final VoidCallback onTap;
  const _UpvoteButton({
    required this.count,
    required this.isUpvoted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUpvoted ? AppColors.secondary : AppColors.textSecondary;
    final radius = BorderRadius.circular(AppRadius.md);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isUpvoted
                ? AppColors.secondary.withValues(alpha: 0.12)
                : AppColors.surfaceMuted,
            borderRadius: radius,
            border: Border.all(
              color: isUpvoted
                  ? AppColors.secondary.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isUpvoted ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: Icon(
                  isUpvoted
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_alt_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  '$count',
                  key: ValueKey(count),
                  style: AppTextStyles.label.copyWith(
                    color: isUpvoted
                        ? AppColors.onTint(AppColors.secondary)
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

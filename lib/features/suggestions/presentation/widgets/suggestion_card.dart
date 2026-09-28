import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suggestion.title, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  suggestion.description,
                  style: AppTextStyles.bodySecondary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '— ${suggestion.authorName}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _UpvoteButton(
            count: suggestion.upvoteCount,
            isUpvoted: isUpvoted,
            onTap: onUpvoteTap,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUpvoted
              ? AppColors.secondary.withOpacity(0.12)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUpvoted ? AppColors.secondary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUpvoted
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_upward_outlined,
              color: isUpvoted ? AppColors.secondary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text('$count', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

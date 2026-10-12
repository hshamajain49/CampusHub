import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/suggestion_list_cubit/suggestion_list_cubit.dart';
import '../cubit/suggestion_list_cubit/suggestion_list_state.dart';
import '../widgets/suggestion_card.dart';
import 'new_suggestion_page.dart';

class SuggestionListPage extends StatelessWidget {
  const SuggestionListPage({super.key});

  void _openNewSuggestion(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewSuggestionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggestion Box')),
      body: BlocBuilder<SuggestionListCubit, SuggestionListState>(
        builder: (context, state) {
          if (state is SuggestionListLoading) {
            return const LoadingView();
          }
          if (state is SuggestionListError) {
            return ErrorState(message: state.message);
          }
          final loaded = state as SuggestionListLoaded;
          if (loaded.suggestions.isEmpty) {
            return EmptyState(
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.suggestions,
              title: 'No suggestions yet',
              message: 'Be the first to share an idea for a better campus!',
              actionLabel: 'Share an idea',
              onAction: () => _openNewSuggestion(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            itemCount: loaded.suggestions.length + 1,
            separatorBuilder: (_, index) =>
                SizedBox(height: index == 0 ? 16 : 12),
            itemBuilder: (context, index) {
              if (index == 0) return const _IntroBanner();
              final suggestion = loaded.suggestions[index - 1];
              return FadeSlideIn(
                index: index - 1,
                child: SuggestionCard(
                  suggestion: suggestion,
                  isUpvoted: suggestion.isUpvotedBy(loaded.currentUserId),
                  onUpvoteTap: () => context
                      .read<SuggestionListCubit>()
                      .toggleUpvote(suggestion),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewSuggestion(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Suggestion'),
      ),
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.suggestions.withValues(alpha: 0.16),
            AppColors.suggestions.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              color: AppColors.suggestions,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shape your campus', style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  'Upvote the ideas you like — popular ones get noticed.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

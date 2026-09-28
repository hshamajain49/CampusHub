import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/suggestion_list_cubit/suggestion_list_cubit.dart';
import '../cubit/suggestion_list_cubit/suggestion_list_state.dart';
import '../widgets/suggestion_card.dart';
import 'new_suggestion_page.dart';

class SuggestionListPage extends StatelessWidget {
  const SuggestionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Suggestion Box')),
      body: BlocBuilder<SuggestionListCubit, SuggestionListState>(
        builder: (context, state) {
          if (state is SuggestionListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SuggestionListError) {
            return Center(child: Text(state.message));
          }
          final loaded = state as SuggestionListLoaded;
          if (loaded.suggestions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No suggestions yet. Be the first to share an idea!',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: loaded.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = loaded.suggestions[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(
                  milliseconds: 200 + (index * 40).clamp(0, 400),
                ),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                ),
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
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NewSuggestionPage())),
        icon: const Icon(Icons.add),
        label: const Text('New Suggestion'),
      ),
    );
  }
}

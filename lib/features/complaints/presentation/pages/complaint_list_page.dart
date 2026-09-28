import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../cubit/my_complaints_cubit/my_complaints_cubit.dart';
import '../cubit/my_complaints_cubit/my_complaints_state.dart';
import '../widgets/complaint_card.dart';

class ComplaintListPage extends StatelessWidget {
  const ComplaintListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyComplaintsCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('My Complaints')),
        body: BlocBuilder<MyComplaintsCubit, MyComplaintsState>(
          builder: (context, state) {
            if (state is MyComplaintsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MyComplaintsError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodySecondary),
              );
            }
            final complaints = (state as MyComplaintsLoaded).complaints;

            if (complaints.isEmpty) {
              return const _EmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: complaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return ComplaintCard(
                  complaint: complaints[index],
                  index: index,
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/new-complaint'),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('New Complaint', style: AppTextStyles.button),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text('All clear!', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            Text(
              "You haven't raised any complaints yet.\nThat's a good sign.",
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

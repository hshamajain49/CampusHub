import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
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
        appBar: AppBar(title: const Text('My Complaints')),
        body: BlocBuilder<MyComplaintsCubit, MyComplaintsState>(
          builder: (context, state) {
            if (state is MyComplaintsLoading) {
              return const LoadingView();
            }
            if (state is MyComplaintsError) {
              return ErrorState(message: state.message);
            }
            final complaints = (state as MyComplaintsLoaded).complaints;

            if (complaints.isEmpty) {
              return const EmptyState(
                icon: Icons.task_alt_rounded,
                color: AppColors.secondary,
                title: 'All clear!',
                message:
                    "You haven't raised any complaints yet.\nThat's a good sign.",
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: complaints.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
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
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Complaint'),
        ),
      ),
    );
  }
}

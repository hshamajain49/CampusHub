import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../cubit/venue_list_cubit/venue_list_cubit.dart';
import '../cubit/venue_list_cubit/venue_list_state.dart';
import '../widgets/venue_card.dart';

class VenueListPage extends StatelessWidget {
  const VenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VenueListCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book a Venue'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => context.push('/my-bookings'),
                icon: const Icon(Icons.event_note_outlined, size: 19),
                label: const Text('My bookings'),
              ),
            ),
          ],
        ),
        body: BlocBuilder<VenueListCubit, VenueListState>(
          builder: (context, state) {
            if (state is VenueListLoading) {
              return const LoadingView();
            }
            if (state is VenueListError) {
              return ErrorState(message: state.message);
            }

            final venues = (state as VenueListLoaded).venues;

            if (venues.isEmpty) {
              return const EmptyState(
                icon: Icons.domain_disabled_outlined,
                color: AppColors.venues,
                title: 'No venues yet',
                message: 'No venues are available for booking right now.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: venues.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    '${venues.length} ${venues.length == 1 ? 'space' : 'spaces'} available',
                    style: AppTextStyles.bodySecondary,
                  );
                }
                return VenueCard(venue: venues[index - 1], index: index - 1);
              },
            );
          },
        ),
      ),
    );
  }
}

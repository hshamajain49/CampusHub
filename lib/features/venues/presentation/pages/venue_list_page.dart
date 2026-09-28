import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Book a Venue'),
          actions: [
            IconButton(
              icon: const Icon(Icons.event_note_outlined),
              tooltip: 'My Bookings',
              onPressed: () => context.push('/my-bookings'),
            ),
          ],
        ),
        body: BlocBuilder<VenueListCubit, VenueListState>(
          builder: (context, state) {
            if (state is VenueListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VenueListError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodySecondary),
              );
            }

            final venues = (state as VenueListLoaded).venues;

            if (venues.isEmpty) {
              return Center(
                child: Text(
                  'No venues available right now.',
                  style: AppTextStyles.bodySecondary,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: venues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => VenueCard(venue: venues[index]),
            );
          },
        ),
      ),
    );
  }
}

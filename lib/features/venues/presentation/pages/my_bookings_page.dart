import 'package:campus_hub/features/venues/presentation/cubit/my_bookings_cubit/my_booking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../cubit/my_bookings_cubit/my_bookings_state.dart';
import '../widgets/booking_card.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyBookingsCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: BlocBuilder<MyBookingsCubit, MyBookingsState>(
          builder: (context, state) {
            if (state is MyBookingsLoading) {
              return const LoadingView();
            }
            if (state is MyBookingsError) {
              return ErrorState(message: state.message);
            }
            final bookings = (state as MyBookingsLoaded).bookings;

            if (bookings.isEmpty) {
              return EmptyState(
                icon: Icons.event_note_outlined,
                color: AppColors.venues,
                title: 'No bookings yet',
                message: 'Reserve a venue and it will show up here.',
                actionLabel: 'Browse venues',
                actionIcon: Icons.search_rounded,
                onAction: () => context.push('/venues'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  BookingCard(booking: bookings[index], index: index),
            );
          },
        ),
      ),
    );
  }
}

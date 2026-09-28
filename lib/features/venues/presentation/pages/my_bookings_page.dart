import 'package:campus_hub/features/venues/presentation/cubit/my_bookings_cubit/my_booking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('My Bookings')),
        body: BlocBuilder<MyBookingsCubit, MyBookingsState>(
          builder: (context, state) {
            if (state is MyBookingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MyBookingsError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodySecondary),
              );
            }
            final bookings = (state as MyBookingsLoaded).bookings;

            if (bookings.isEmpty) {
              return const _EmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  BookingCard(booking: bookings[index]),
            );
          },
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
                Icons.event_note_outlined,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text('No bookings yet', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            Text(
              'Reserve a venue and it will show up here.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

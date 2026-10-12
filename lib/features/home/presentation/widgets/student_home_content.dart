import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/inline_empty_note.dart';
import '../../../../core/widgets/recent_item_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../di/injection_container.dart';
import '../../../complaints/domain/entities/complaint_status.dart';
import '../../../complaints/presentation/cubit/my_complaints_cubit/my_complaints_cubit.dart';
import '../../../complaints/presentation/cubit/my_complaints_cubit/my_complaints_state.dart';
import '../../../complaints/presentation/utils/category_ui_extension.dart';
import '../../../complaints/presentation/utils/status_ui_extension.dart';
import '../../../venues/domain/entities/booking_status.dart';
import '../../../venues/presentation/cubit/my_bookings_cubit/my_booking_cubit.dart';
import '../../../venues/presentation/cubit/my_bookings_cubit/my_bookings_state.dart';
import '../../../venues/presentation/utils/booking_status_ui_extension.dart';
import 'home_quick_actions.dart';
import 'quick_action_card.dart';

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MyComplaintsCubit>()),
        BlocProvider(create: (_) => sl<MyBookingsCubit>()),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // --- Quick stats ---
          Row(
            children: [
              Expanded(
                child: BlocBuilder<MyComplaintsCubit, MyComplaintsState>(
                  builder: (context, state) {
                    final open = state is MyComplaintsLoaded
                        ? state.complaints
                              .where(
                                (c) => c.status != ComplaintStatus.resolved,
                              )
                              .length
                        : 0;
                    return StatCard(
                      label: 'Open complaints',
                      value: '$open',
                      icon: Icons.report_gmailerrorred_rounded,
                      color: AppColors.complaints,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<MyBookingsCubit, MyBookingsState>(
                  builder: (context, state) {
                    final active = state is MyBookingsLoaded
                        ? state.bookings
                              .where(
                                (b) =>
                                    b.status == BookingStatus.pending ||
                                    b.status == BookingStatus.approved,
                              )
                              .length
                        : 0;
                    return StatCard(
                      label: 'Active bookings',
                      value: '$active',
                      icon: Icons.meeting_room_outlined,
                      color: AppColors.venues,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // --- Quick actions ---
          const SectionHeader(
            title: 'Quick actions',
            subtitle: 'What would you like to do?',
          ),
          const SizedBox(height: 14),
          QuickActionsRow(
            actions: [
              HomeQuickActions.complaint(context),
              HomeQuickActions.bookVenue(context),
              HomeQuickActions.suggestions(context),
            ],
          ),
          const SizedBox(height: 28),

          // --- Recent complaints ---
          SectionHeader(
            title: 'Recent complaints',
            actionLabel: 'View all',
            onAction: () => context.push('/complaints'),
          ),
          const SizedBox(height: 12),
          BlocBuilder<MyComplaintsCubit, MyComplaintsState>(
            builder: (context, state) {
              if (state is MyComplaintsLoading) return const _SectionLoading();
              if (state is MyComplaintsError) {
                return InlineEmptyNote(
                  message: state.message,
                  icon: Icons.cloud_off_rounded,
                );
              }
              final complaints =
                  (state as MyComplaintsLoaded).complaints.toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              if (complaints.isEmpty) {
                return const InlineEmptyNote(
                  message: "You haven't filed any complaints yet.",
                  icon: Icons.task_alt_rounded,
                );
              }
              return Column(
                children: complaints.take(3).map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RecentItemTile(
                      icon: c.category.icon,
                      iconColor: c.category.color,
                      title: c.title,
                      subtitle:
                          '${c.category.displayName} · ${formatDate(c.createdAt)}',
                      statusLabel: c.status.displayName,
                      statusColor: c.status.color,
                      onTap: () => context.push('/complaint/${c.id}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 18),

          // --- Recent bookings ---
          SectionHeader(
            title: 'Recent bookings',
            actionLabel: 'View all',
            onAction: () => context.push('/my-bookings'),
          ),
          const SizedBox(height: 12),
          BlocBuilder<MyBookingsCubit, MyBookingsState>(
            builder: (context, state) {
              if (state is MyBookingsLoading) return const _SectionLoading();
              if (state is MyBookingsError) {
                return InlineEmptyNote(
                  message: state.message,
                  icon: Icons.cloud_off_rounded,
                );
              }
              final bookings = (state as MyBookingsLoaded).bookings.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              if (bookings.isEmpty) {
                return const InlineEmptyNote(
                  message: 'Reserve a venue and it will show up here.',
                  icon: Icons.event_note_outlined,
                );
              }
              return Column(
                children: bookings.take(3).map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RecentItemTile(
                      icon: Icons.event_note_outlined,
                      iconColor: AppColors.venues,
                      title: b.venueName,
                      subtitle:
                          '${formatDateRange(b.startDate, b.endDate)} · ${b.purpose}',
                      statusLabel: b.status.displayName,
                      statusColor: b.status.color,
                      onTap: () => context.push('/booking/${b.id}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: LoadingView(),
    );
  }
}

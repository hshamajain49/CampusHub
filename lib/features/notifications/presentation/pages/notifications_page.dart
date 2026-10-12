import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../cubit/notifications_cubit/notifications_cubit.dart';
import '../cubit/notifications_cubit/notifications_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoaded && state.unreadCount > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: () =>
                          context.read<NotificationsCubit>().markAllAsRead(),
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: const Text('Mark all read'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const LoadingView();
            }
            if (state is NotificationsError) {
              return ErrorState(message: state.message);
            }
            final loaded = state as NotificationsLoaded;
            final notifications = loaded.notifications;

            if (notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications yet',
                message:
                    "Updates on your complaints and bookings will appear here.",
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: notifications.length + 1,
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == 0 ? 14 : 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    loaded.unreadCount == 0
                        ? "You're all caught up"
                        : '${loaded.unreadCount} unread',
                    style: AppTextStyles.bodySecondary,
                  );
                }
                final n = notifications[index - 1];
                return FadeSlideIn(
                  index: index - 1,
                  child: NotificationTile(
                    notification: n,
                    onTap: () {
                      if (!n.isRead) {
                        context.read<NotificationsCubit>().markAsRead(n.id);
                      }
                      if (n.actionRoute != null) context.push(n.actionRoute!);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

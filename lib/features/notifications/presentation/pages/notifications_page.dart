import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoaded && state.unreadCount > 0) {
                  return TextButton(
                    onPressed: () =>
                        context.read<NotificationsCubit>().markAllAsRead(),
                    child: const Text('Mark all read'),
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
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NotificationsError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodySecondary),
              );
            }
            final notifications = (state as NotificationsLoaded).notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 56,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text('No notifications yet', style: AppTextStyles.h2),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return NotificationTile(
                  notification: n,
                  onTap: () {
                    if (!n.isRead) {
                      context.read<NotificationsCubit>().markAsRead(n.id);
                    }
                    if (n.actionRoute != null) context.push(n.actionRoute!);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/utils/user_role_ui_extension.dart';

class AdminUserListPage extends StatelessWidget {
  const AdminUserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminUsersCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Users')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/users/new'),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('New User'),
        ),
        body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersLoading) {
              return const LoadingView();
            }
            if (state is AdminUsersError) {
              return ErrorState(message: state.message);
            }
            final users = (state as AdminUsersLoaded).users;
            if (users.isEmpty) {
              return const EmptyState(
                icon: Icons.group_outlined,
                title: 'No users yet',
                message: 'Accounts you create will be listed here.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
              itemCount: users.length + 1,
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == 0 ? 14 : 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    '${users.length} ${users.length == 1 ? 'account' : 'accounts'}',
                    style: AppTextStyles.bodySecondary,
                  );
                }
                return FadeSlideIn(
                  index: index - 1,
                  child: _UserTile(user: users[index - 1]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserEntity user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/admin/users/${user.uid}/edit'),
      child: Opacity(
        opacity: user.isActive ? 1.0 : 0.6,
        child: Row(
          children: [
            UserAvatar(name: user.name, color: user.role.color, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(fontSize: 14.5),
                        ),
                      ),
                      if (!user.isActive) ...[
                        const SizedBox(width: 6),
                        const StatusPill(
                          label: 'Inactive',
                          color: AppColors.statusRed,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  if (user.department != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.department!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusPill(
              label: user.role.shortName,
              color: user.role.color,
              icon: user.role.icon,
            ),
          ],
        ),
      ),
    );
  }
}

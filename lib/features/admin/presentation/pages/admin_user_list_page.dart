import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';

class AdminUserListPage extends StatelessWidget {
  const AdminUserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminUsersCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Users')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/users/new'),
          icon: const Icon(Icons.add),
          label: const Text('New User'),
        ),
        body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminUsersError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodySecondary),
              );
            }
            final users = (state as AdminUsersLoaded).users;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _UserTile(user: users[index]),
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

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.departmentStaff:
        return 'Dept. Staff';
      case UserRole.venueCoordinator:
        return 'Coordinator';
      case UserRole.admin:
        return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/admin/users/${user.uid}/edit'),
        child: Opacity(
          opacity: user.isActive ? 1.0 : 0.55,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              style: AppTextStyles.h3.copyWith(fontSize: 15),
                            ),
                          ),
                          if (!user.isActive) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(Inactive)',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.statusRed,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(user.email, style: AppTextStyles.caption),
                      if (user.department != null) ...[
                        const SizedBox(height: 2),
                        Text(user.department!, style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleLabel(user.role),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../../auth/presentation/utils/user_role_ui_extension.dart';
import '../cubit/delete_account_cubit/delete_account_cubit.dart';
import '../widgets/delete_account_sheet.dart';

/// The signed-in user's account settings: profile details, sign out and
/// permanent account deletion.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return BlocProvider(
      create: (_) => sl<DeleteAccountCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Account')),
        // Briefly null while signing out / after deletion, before the
        // router redirects away.
        body: user == null ? const LoadingView() : _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserEntity user;
  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final department = user.role == UserRole.departmentStaff
        ? user.department
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              UserAvatar(name: user.name, color: user.role.color, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 8),
                    StatusPill(
                      label: user.role.displayName,
                      color: user.role.color,
                      icon: user.role.icon,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Account details',
          child: Column(
            children: [
              InfoRow(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: user.email,
              ),
              InfoRow(
                icon: user.role.icon,
                label: 'Role',
                value: user.role.displayName,
                color: user.role.color,
              ),
              if (department != null)
                InfoRow(
                  icon: Icons.apartment_rounded,
                  label: 'Department',
                  value: department,
                  color: AppColors.statusOrange,
                ),
              InfoRow(
                icon: Icons.event_outlined,
                label: 'Member since',
                value: formatDate(user.createdAt),
                color: AppColors.secondary,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Sign Out',
          icon: Icons.logout_rounded,
          variant: AppButtonVariant.outlined,
          onPressed: () => sl<LogoutUseCase>().call(),
        ),
        const SizedBox(height: 24),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          borderColor: AppColors.error.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'DANGER ZONE',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Permanently delete your CampusHub account and personal data. '
                'This cannot be undone.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Delete Account',
                icon: Icons.delete_outline_rounded,
                variant: AppButtonVariant.danger,
                onPressed: () => DeleteAccountSheet.show(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

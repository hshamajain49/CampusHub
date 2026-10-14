import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../../auth/presentation/utils/user_role_ui_extension.dart';
import '../../../notifications/presentation/cubit/notifications_cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_cubit/notifications_state.dart';
import '../widgets/admin_home_content.dart';
import '../widgets/coordinator_home_content.dart';
import '../widgets/staff_home_content.dart';
import '../widgets/student_home_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 196,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
            titleSpacing: 20,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 30, showWordmark: false, onDark: true),
                const SizedBox(width: 10),
                AppWordmark(onDark: true, fontSize: 19),
              ],
            ),
            actions: [
              const _NotificationBell(),
              if (user != null) _ProfileMenu(user: user),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _HomeHero(user: user),
            ),
          ),
        ],
        body: _buildRoleContent(user?.role),
      ),
    );
  }

  Widget _buildRoleContent(UserRole? role) {
    switch (role) {
      case UserRole.venueCoordinator:
        return const CoordinatorHomeContent();
      case UserRole.departmentStaff:
        return const StaffHomeContent();
      case UserRole.admin:
        return const AdminHomeContent();
      case UserRole.student:
      case null:
        return const StudentHomeContent();
    }
  }
}

class _HomeHero extends StatelessWidget {
  final UserEntity? user;
  const _HomeHero({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '';
    final firstName = name.trim().split(' ').first;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            bottom: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 28,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${greetingFor(DateTime.now())} 👋',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName.isEmpty ? 'Welcome' : firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 10),
                  _RoleChip(user: user!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final UserEntity user;
  const _RoleChip({required this.user});

  @override
  Widget build(BuildContext context) {
    final department = user.role == UserRole.departmentStaff
        ? user.department
        : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(user.role.icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              department == null
                  ? user.role.displayName
                  : '${user.role.displayName} · $department',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>(),
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final unread = state is NotificationsLoaded ? state.unreadCount : 0;
          return IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              backgroundColor: AppColors.accent,
              textColor: AppColors.primaryDark,
              label: Text(unread > 9 ? '9+' : '$unread'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          );
        },
      ),
    );
  }
}

enum _ProfileAction { account, logout }

class _ProfileMenu extends StatelessWidget {
  final UserEntity user;
  const _ProfileMenu({required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProfileAction>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      onSelected: (action) {
        switch (action) {
          case _ProfileAction.account:
            context.push('/profile');
          case _ProfileAction.logout:
            sl<LogoutUseCase>().call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_ProfileAction>(
          enabled: false,
          child: Row(
            children: [
              UserAvatar(name: user.name, color: user.role.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(fontSize: 14),
                    ),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_ProfileAction>(
          value: _ProfileAction.account,
          child: Row(
            children: [
              const Icon(
                Icons.manage_accounts_outlined,
                size: 20,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'My account',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        PopupMenuItem<_ProfileAction>(
          value: _ProfileAction.logout,
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Sign out',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: UserAvatar(
            name: user.name,
            size: 34,
            color: Colors.white.withValues(alpha: 0.22),
            filled: true,
          ),
        ),
      ),
    );
  }
}

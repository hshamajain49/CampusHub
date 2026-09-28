import 'package:campus_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
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
    final roleLabel = authState is AuthAuthenticated
        ? _roleLabel(authState.user.role)
        : '';
    final name = authState is AuthAuthenticated ? authState.user.name : '';
    final role = authState is AuthAuthenticated ? authState.user.role : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CampusHub'),
        actions: [
          BlocProvider(
            create: (_) => sl<NotificationsCubit>(),
            child: Builder(
              builder: (context) {
                return BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    final unread = state is NotificationsLoaded
                        ? state.unreadCount
                        : 0;
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => context.push('/notifications'),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => sl<LogoutUseCase>().call(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, $name', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(roleLabel, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            Expanded(child: _buildRoleContent(role)),
          ],
        ),
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

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.departmentStaff:
        return 'Department Staff';
      case UserRole.venueCoordinator:
        return 'Venue Coordinator';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

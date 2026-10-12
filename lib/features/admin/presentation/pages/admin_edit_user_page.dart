import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_state.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/utils/user_role_ui_extension.dart';
import '../widgets/department_options.dart';

class AdminEditUserPage extends StatelessWidget {
  final String uid;
  const AdminEditUserPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AdminUsersCubit>()),
        BlocProvider(create: (_) => sl<UserActionCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit User')),
        body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersError) {
              return ErrorState(message: state.message);
            }
            if (state is! AdminUsersLoaded) {
              return const LoadingView();
            }
            final user = state.users
                .where((u) => u.uid == uid)
                .cast<UserEntity?>()
                .firstOrNull;
            if (user == null) {
              return const EmptyState(
                icon: Icons.person_off_outlined,
                title: 'User not found',
                message: 'This account may have been removed.',
              );
            }
            return _EditUserBody(user: user);
          },
        ),
      ),
    );
  }
}

class _EditUserBody extends StatefulWidget {
  final UserEntity user;
  const _EditUserBody({required this.user});

  @override
  State<_EditUserBody> createState() => _EditUserBodyState();
}

class _EditUserBodyState extends State<_EditUserBody> {
  late UserRole _role;
  String? _department;

  bool get _isSelf =>
      widget.user.uid == fb_auth.FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _role = widget.user.role;
    _department = widget.user.department;
  }

  void _onSave() {
    if (_role == UserRole.departmentStaff && _department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }
    context.read<UserActionCubit>().updateRole(
      uid: widget.user.uid,
      role: _role,
      department: _role == UserRole.departmentStaff ? _department : null,
    );
  }

  Future<void> _confirmToggleActive(bool activate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          activate ? Icons.check_circle_outline_rounded : Icons.block_rounded,
          color: activate ? AppColors.statusGreen : AppColors.error,
          size: 32,
        ),
        title: Text(activate ? 'Activate account?' : 'Deactivate account?'),
        content: Text(
          activate
              ? '${widget.user.name} will be able to sign in again immediately.'
              : '${widget.user.name} will be signed out and unable to log in until reactivated.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: activate
                  ? AppColors.statusGreen
                  : AppColors.error,
            ),
            child: Text(activate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<UserActionCubit>().setActiveStatus(
        uid: widget.user.uid,
        isActive: activate,
      );
    }
  }

  Future<void> _confirmResetPassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.mark_email_read_outlined,
          color: AppColors.primary,
          size: 32,
        ),
        title: const Text('Send password reset email?'),
        content: Text(
          'A reset link will be emailed to ${widget.user.email}.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<UserActionCubit>().resetPassword(widget.user.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return BlocListener<UserActionCubit, UserActionState>(
      listener: (context, state) {
        if (state is UserActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is UserRoleUpdated) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User updated.')));
          context.pop();
        }
        if (state is UserActiveStatusChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isActive ? 'Account activated.' : 'Account deactivated.',
              ),
            ),
          );
        }
        if (state is PasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent.')),
          );
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    UserAvatar(
                      name: user.name,
                      color: user.role.color,
                      size: 56,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: AppTextStyles.h3),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              StatusPill(
                                label: user.role.displayName,
                                color: user.role.color,
                                icon: user.role.icon,
                              ),
                              if (!user.isActive)
                                const StatusPill(
                                  label: 'Inactive',
                                  color: AppColors.statusRed,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Role & access',
                child: Column(
                  children: [
                    DropdownButtonFormField<UserRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      items: const [
                        DropdownMenuItem(
                          value: UserRole.student,
                          child: Text('Student'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.departmentStaff,
                          child: Text('Department Staff'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.venueCoordinator,
                          child: Text('Venue Coordinator/Lecturer'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.admin,
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _role = value!;
                        if (_role != UserRole.departmentStaff) {
                          _department = null;
                        }
                      }),
                    ),
                    if (_role == UserRole.departmentStaff) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _department,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.apartment_rounded, size: 20),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        items: kDepartmentOptions.map((d) {
                          return DropdownMenuItem<String>(
                            value: d,
                            child: Text(
                              d,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _department = value);
                        },
                      ),
                    ],
                    const SizedBox(height: 18),
                    BlocBuilder<UserActionCubit, UserActionState>(
                      builder: (context, state) {
                        return AppButton(
                          label: 'Save Changes',
                          icon: Icons.check_rounded,
                          isLoading: state is UserActionLoading,
                          onPressed: _onSave,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Account actions',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: 'Send Password Reset Email',
                      icon: Icons.email_outlined,
                      variant: AppButtonVariant.outlined,
                      onPressed: _confirmResetPassword,
                    ),
                    const SizedBox(height: 10),
                    if (_isSelf)
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "You can't deactivate your own account.",
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      )
                    else
                      user.isActive
                          ? AppButton(
                              label: 'Deactivate Account',
                              icon: Icons.block_rounded,
                              variant: AppButtonVariant.danger,
                              onPressed: () => _confirmToggleActive(false),
                            )
                          : AppButton(
                              label: 'Activate Account',
                              icon: Icons.check_circle_outline_rounded,
                              onPressed: () => _confirmToggleActive(true),
                            ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

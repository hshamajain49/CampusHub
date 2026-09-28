import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_state.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Edit User')),
        body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is! AdminUsersLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = state.users
                .where((u) => u.uid == uid)
                .cast<UserEntity?>()
                .firstOrNull;
            if (user == null) {
              return const Center(child: Text('User not found.'));
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
        title: Text(activate ? 'Activate account?' : 'Deactivate account?'),
        content: Text(
          activate
              ? '${widget.user.name} will be able to sign in again immediately.'
              : '${widget.user.name} will be signed out and unable to log in until reactivated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
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
        title: const Text('Send password reset email?'),
        content: Text('A reset link will be emailed to ${widget.user.email}.'),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.name, style: AppTextStyles.h2),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.email,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  if (!widget.user.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.statusRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Inactive',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.statusRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Role', style: AppTextStyles.caption),
              const SizedBox(height: 6),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
                    child: Text('Venue Coordinator'),
                  ),
                  DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                ],
                onChanged: (value) => setState(() {
                  _role = value!;
                  if (_role != UserRole.departmentStaff) _department = null;
                }),
              ),
              if (_role == UserRole.departmentStaff) ...[
                const SizedBox(height: 16),
                Text('Department', style: AppTextStyles.caption),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _department,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select department'),
                  items: kDepartmentOptions
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (value) => setState(() => _department = value),
                ),
              ],
              const SizedBox(height: 32),
              BlocBuilder<UserActionCubit, UserActionState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Save Changes',
                    isLoading: state is UserActionLoading,
                    onPressed: _onSave,
                  );
                },
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),
              Text('Account actions', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmResetPassword(),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Send Password Reset Email'),
              ),
              const SizedBox(height: 10),
              if (_isSelf)
                Text(
                  "You can't deactivate your own account.",
                  style: AppTextStyles.caption,
                )
              else
                OutlinedButton.icon(
                  onPressed: () => _confirmToggleActive(!widget.user.isActive),
                  icon: Icon(
                    widget.user.isActive
                        ? Icons.block_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                  label: Text(
                    widget.user.isActive
                        ? 'Deactivate Account'
                        : 'Activate Account',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.user.isActive
                        ? AppColors.statusRed
                        : AppColors.statusGreen,
                    side: BorderSide(
                      color: widget.user.isActive
                          ? AppColors.statusRed
                          : AppColors.statusGreen,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

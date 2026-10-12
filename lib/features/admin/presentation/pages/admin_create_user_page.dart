import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../widgets/department_options.dart';

class AdminCreateUserPage extends StatelessWidget {
  const AdminCreateUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserActionCubit>(),
      child: const _CreateUserView(),
    );
  }
}

class _CreateUserView extends StatefulWidget {
  const _CreateUserView();

  @override
  State<_CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<_CreateUserView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.departmentStaff;
  String? _department;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_role == UserRole.departmentStaff && _department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    context.read<UserActionCubit>().createUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
      department: _role == UserRole.departmentStaff ? _department : null,
    );
  }

  void _showCreatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.verified_user_outlined,
          color: AppColors.statusGreen,
          size: 34,
        ),
        title: const Text('Account created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share these credentials with ${_nameController.text.trim()} securely:',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CredentialLine(
                    label: 'Email',
                    value: _emailController.text.trim(),
                  ),
                  const SizedBox(height: 8),
                  _CredentialLine(
                    label: 'Temporary password',
                    value: _passwordController.text,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'They should change this password after first login.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New User')),
      body: BlocListener<UserActionCubit, UserActionState>(
        listener: (context, state) {
          if (state is UserActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is UserCreated) {
            _showCreatedDialog();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    title: 'Account',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'Full name',
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Temporary password',
                          prefixIcon: Icons.key_outlined,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'At least 6 characters';
                            }
                            return null;
                          },
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
                              value: UserRole.departmentStaff,
                              child: Text('Department Staff'),
                            ),
                            DropdownMenuItem(
                              value: UserRole.venueCoordinator,
                              child: Text('Venue Coordinator'),
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
                              prefixIcon: Icon(
                                Icons.apartment_rounded,
                                size: 20,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            items: kDepartmentOptions
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                      d,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _department = value),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<UserActionCubit, UserActionState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Create Account',
                        icon: Icons.person_add_alt_1_rounded,
                        isLoading: state is UserActionLoading,
                        onPressed: _onSubmit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CredentialLine extends StatelessWidget {
  final String label;
  final String value;
  const _CredentialLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        SelectableText(
          value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

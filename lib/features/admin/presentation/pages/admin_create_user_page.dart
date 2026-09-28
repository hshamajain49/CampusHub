import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
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

    context.read<UserActionCubit>().createUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
      department: _role == UserRole.departmentStaff ? _department : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Account created'),
                content: Text(
                  'Share these credentials with ${_nameController.text.trim()} securely:\n\n'
                  'Email: ${_emailController.text.trim()}\n'
                  'Temporary password: ${_passwordController.text}\n\n'
                  'They should change this password after first login.',
                ),
                actions: [
                  TextButton(
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
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Full name',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Temporary password',
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return 'At least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Role', style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _role,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
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
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _department = value),
                    ),
                  ],
                  const SizedBox(height: 32),
                  BlocBuilder<UserActionCubit, UserActionState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Create Account',
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../cubit/delete_account_cubit/delete_account_cubit.dart';
import '../cubit/delete_account_cubit/delete_account_state.dart';

/// What happens to the user's data, shown before they confirm. Mirrors the
/// policy in AccountDataCleaner.
const kAccountDeletionConsequences = [
  'Your profile and sign-in are removed',
  'Your notifications and suggestions are deleted',
  'Pending and upcoming venue bookings are cancelled',
  'Past complaints and bookings stay on record, without your name',
];

/// Confirmation step for deleting your own account: explains the
/// consequences, then asks for the password and an explicit acknowledgement.
class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<DeleteAccountCubit>();
    cubit.clearError();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const DeleteAccountSheet()),
    );
  }

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acknowledged = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onDeletePressed() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Captured up front: the sign-out that accompanies a deletion can tear
    // this sheet down before the call returns.
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await context.read<DeleteAccountCubit>().deleteAccount(
      _passwordController.text,
    );
    result.fold(
      (failure) {
        // Normally the error shows inline. After a sign-out the redirect to
        // the login screen closes this sheet, so report it app-wide instead.
        if (failure is SignedOutFailure || !mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      (_) {
        if (mounted) navigator.pop();
        router.go('/account-deleted');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
      builder: (context, state) {
        final inProgress =
            state is DeleteAccountInProgress || state is DeleteAccountSuccess;
        return PopScope(
          canPop: !inProgress,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: IconBadge(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 56,
                        circular: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Delete your account?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This is permanent and cannot be undone.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 18),
                    for (final line in kAccountDeletionConsequences)
                      _ConsequenceRow(text: line),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Confirm your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onChanged: (_) =>
                          context.read<DeleteAccountCubit>().clearError(),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Enter your password to confirm'
                          : null,
                    ),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      value: _acknowledged,
                      onChanged: inProgress
                          ? null
                          : (v) => setState(() => _acknowledged = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      title: Text(
                        'I understand my account cannot be recovered.',
                        style: AppTextStyles.body,
                      ),
                    ),
                    if (state is DeleteAccountFailure) ...[
                      const SizedBox(height: 4),
                      _ErrorBanner(message: state.message),
                    ],
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Delete My Account',
                      icon: Icons.delete_forever_rounded,
                      variant: AppButtonVariant.danger,
                      isLoading: inProgress,
                      onPressed: _acknowledged ? _onDeletePressed : null,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: inProgress
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Keep my account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConsequenceRow extends StatelessWidget {
  final String text;
  const _ConsequenceRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              size: 16,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodySecondary)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onTint(AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

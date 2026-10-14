import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Asks an admin to type DELETE before removing [user]'s account.
/// Resolves to true only when confirmed.
class DeleteUserDialog extends StatefulWidget {
  static const confirmationWord = 'DELETE';

  final UserEntity user;
  const DeleteUserDialog({super.key, required this.user});

  static Future<bool> show(BuildContext context, UserEntity user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteUserDialog(user: user),
    );
    return confirmed ?? false;
  }

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  final _controller = TextEditingController();

  bool get _canConfirm =>
      _controller.text.trim().toUpperCase() ==
      DeleteUserDialog.confirmationWord;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return AlertDialog(
      icon: const Icon(
        Icons.delete_forever_rounded,
        color: AppColors.error,
        size: 32,
      ),
      title: const Text('Delete this account?', textAlign: TextAlign.center),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: user.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' (${user.email}) will be permanently deleted. ',
                ),
                const TextSpan(
                  text:
                      'Their profile, notifications and suggestions are '
                      'removed, upcoming bookings are cancelled, and past '
                      'complaints and bookings are kept without their name.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_canConfirm) Navigator.of(context).pop(true);
            },
            decoration: const InputDecoration(
              labelText: 'Type ${DeleteUserDialog.confirmationWord} to confirm',
              prefixIcon: Icon(Icons.keyboard_outlined, size: 20),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _canConfirm ? () => Navigator.of(context).pop(true) : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

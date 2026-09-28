import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../domain/usecases/create_suggestion_usecase.dart';
import '../../../../di/injection_container.dart';

class NewSuggestionPage extends StatefulWidget {
  const NewSuggestionPage({super.key});

  @override
  State<NewSuggestionPage> createState() => _NewSuggestionPageState();
}

class _NewSuggestionPageState extends State<NewSuggestionPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    final authState = context.read<AuthStateCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isSubmitting = true);

    final result = await sl<CreateSuggestionUseCase>().call(
      authorId: authState.user.uid,
      authorName: authState.user.name,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Suggestion')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Sum it up in a few words',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell us more about your idea',
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Submit Suggestion',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

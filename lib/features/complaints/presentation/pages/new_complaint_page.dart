import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/complaint_category.dart';
import '../cubit/create_complaint_cubit/create_complaint_cubit.dart';
import '../cubit/create_complaint_cubit/create_complaint_state.dart';
import '../widgets/category_chip.dart';

class NewComplaintPage extends StatelessWidget {
  const NewComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateComplaintCubit>(),
      child: const _NewComplaintView(),
    );
  }
}

class _NewComplaintView extends StatefulWidget {
  const _NewComplaintView();

  @override
  State<_NewComplaintView> createState() => _NewComplaintViewState();
}

class _NewComplaintViewState extends State<_NewComplaintView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  ComplaintCategory? _selectedCategory;
  final List<File> _selectedImages = [];
  static const int _maxImages = 3;

  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= _maxImages) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // compress a bit — faster upload, less data usage
    );

    if (picked != null) {
      setState(() => _selectedImages.add(File(picked.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _onSubmit() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<CreateComplaintCubit>().submit(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory!,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        imagePaths: _selectedImages.map((f) => f.path).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Complaint')),
      body: BlocListener<CreateComplaintCubit, CreateComplaintState>(
        listener: (context, state) {
          if (state is CreateComplaintError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is CreateComplaintSuccess) {
            _showSuccessAndPop();
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
                  Text('What kind of issue is it?', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ComplaintCategory.values.map((cat) {
                      return CategoryChip(
                        category: cat,
                        isSelected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  Text('Details', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'e.g. Fan not working in Room 204',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please give your complaint a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _locationController,
                    label: 'Location (optional)',
                    hint: 'e.g. Block A, Room 204',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Describe the issue (optional)',
                    hint: 'Any extra details that might help...',
                  ),
                  const SizedBox(height: 28),

                  Text('Add photos', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    'Optional — up to $_maxImages photos',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  _buildImagePicker(),
                  const SizedBox(height: 36),

                  BlocBuilder<CreateComplaintCubit, CreateComplaintState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Submit Complaint',
                        isLoading: state is CreateComplaintLoading,
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

  Widget _buildImagePicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final file = entry.value;
          return _ImageThumbnail(
            file: file,
            onRemove: () => _removeImage(index),
          );
        }),
        if (_selectedImages.length < _maxImages)
          _AddImageButton(onTap: _pickImage),
      ],
    );
  }

  void _showSuccessAndPop() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SuccessDialog(
        onDone: () {
          Navigator.of(dialogContext).pop(); // close dialog
          context.pop(); // go back to complaint list
        },
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _ImageThumbnail({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            style: BorderStyle.solid,
          ),
        ),
        child: const Icon(
          Icons.add_a_photo_outlined,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Friendly success dialog with a scale-in checkmark animation.
class _SuccessDialog extends StatefulWidget {
  final VoidCallback onDone;
  const _SuccessDialog({required this.onDone});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    // Auto-dismiss after a short pause so the student sees the confirmation.
    Future.delayed(const Duration(milliseconds: 1400), widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.statusGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Complaint Submitted!', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              "We'll keep you updated on its progress.",
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

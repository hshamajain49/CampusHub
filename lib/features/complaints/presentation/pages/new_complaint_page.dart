import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/success_dialog.dart';
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
      FocusScope.of(context).unfocus();
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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Tell us what's wrong — we'll route it to the right team.",
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'What kind of issue is it?',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ComplaintCategory.values.map((cat) {
                            return CategoryChip(
                              category: cat,
                              isSelected: _selectedCategory == cat,
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                            );
                          }).toList(),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          child: _selectedCategory == null
                              ? const SizedBox(width: double.infinity)
                              : _RoutingHint(
                                  department:
                                      _selectedCategory!.assignedDepartment,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Details',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _titleController,
                          label: 'Title',
                          hint: 'e.g. Fan not working in Room 204',
                          prefixIcon: Icons.short_text_rounded,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please give your complaint a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _locationController,
                          label: 'Location (optional)',
                          hint: 'e.g. Block A, Room 204',
                          prefixIcon: Icons.location_on_outlined,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _descriptionController,
                          label: 'Describe the issue (optional)',
                          hint: 'Any extra details that might help...',
                          maxLines: 5,
                          minLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Photos (optional)',
                    trailing: Text(
                      '${_selectedImages.length}/$_maxImages',
                      style: AppTextStyles.caption,
                    ),
                    child: _buildImagePicker(),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<CreateComplaintCubit, CreateComplaintState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Submit Complaint',
                        icon: Icons.send_rounded,
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
      builder: (dialogContext) => SuccessDialog(
        title: 'Complaint submitted!',
        message: "We'll keep you updated on its progress.",
        onDone: () {
          Navigator.of(dialogContext).pop(); // close dialog
          context.pop(); // go back to complaint list
        },
      ),
    );
  }
}

class _RoutingHint extends StatelessWidget {
  final String department;
  const _RoutingHint({required this.department});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.alt_route_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Will be sent to ',
                  children: [
                    TextSpan(
                      text: department,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
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
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.file(file, width: 88, height: 88, fit: BoxFit.cover),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
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
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: AppColors.primary.withValues(alpha: 0.45),
          radius: AppRadius.md,
        ),
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                'Add',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.7),
          Radius.circular(radius),
        ),
      );
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

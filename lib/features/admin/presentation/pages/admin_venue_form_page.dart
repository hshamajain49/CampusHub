import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_state.dart';
import 'package:campus_hub/features/admin/presentation/cubit/venue_action_cubit.dart/venue_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/venue_action_cubit.dart/venue_action_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../venues/domain/entities/venue_entity.dart';

/// Handles both create (venue == null) and edit (venue != null).
class AdminVenueFormPage extends StatelessWidget {
  final VenueEntity? venue;
  const AdminVenueFormPage({super.key, this.venue});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AdminUsersCubit>()),
        BlocProvider(create: (_) => sl<VenueActionCubit>()),
      ],
      child: _VenueFormView(venue: venue),
    );
  }
}

class _VenueFormView extends StatefulWidget {
  final VenueEntity? venue;
  const _VenueFormView({this.venue});

  @override
  State<_VenueFormView> createState() => _VenueFormViewState();
}

class _VenueFormViewState extends State<_VenueFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _buildingController;
  late TextEditingController _capacityController;
  late TextEditingController _amenitiesController;

  String? _coordinatorId;
  bool _isActive = true;

  bool get _isEditing => widget.venue != null;

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    _nameController = TextEditingController(text: v?.name ?? '');
    _descriptionController = TextEditingController(text: v?.description ?? '');
    _buildingController = TextEditingController(text: v?.building ?? '');
    _capacityController = TextEditingController(
      text: v?.capacity.toString() ?? '',
    );
    _amenitiesController = TextEditingController(
      text: v?.amenities.join(', ') ?? '',
    );
    _coordinatorId = v?.coordinatorId;
    _isActive = v?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _buildingController.dispose();
    _capacityController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_coordinatorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign a coordinator')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final amenities = _amenitiesController.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;

    if (_isEditing) {
      context.read<VenueActionCubit>().update(
        id: widget.venue!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        capacity: capacity,
        building: _buildingController.text.trim(),
        amenities: amenities,
        coordinatorId: _coordinatorId!,
        isActive: _isActive,
      );
    } else {
      context.read<VenueActionCubit>().create(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        capacity: capacity,
        building: _buildingController.text.trim(),
        amenities: amenities,
        coordinatorId: _coordinatorId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Venue' : 'New Venue')),
      body: BlocListener<VenueActionCubit, VenueActionState>(
        listener: (context, state) {
          if (state is VenueActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is VenueActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing ? 'Venue updated.' : 'Venue created.'),
              ),
            );
            context.pop();
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
                    label: 'Venue name',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _buildingController,
                    label: 'Building',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _capacityController,
                    label: 'Capacity',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _amenitiesController,
                    label: 'Amenities (comma-separated)',
                    hint: 'Projector, Whiteboard, AC',
                  ),
                  const SizedBox(height: 16),
                  Text('Coordinator', style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  BlocBuilder<AdminUsersCubit, AdminUsersState>(
                    builder: (context, state) {
                      if (state is! AdminUsersLoaded) {
                        return const LinearProgressIndicator();
                      }
                      final coordinators = state.users
                          .where((u) => u.role == UserRole.venueCoordinator)
                          .toList();
                      if (coordinators.isEmpty) {
                        return Text(
                          'No Coordinator accounts yet — create one first.',
                          style: AppTextStyles.bodySecondary,
                        );
                      }
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _coordinatorId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Select coordinator'),
                        items: coordinators.map((u) {
                          return DropdownMenuItem<String>(
                            value: u.uid,
                            child: Text(
                              '${u.name} (${u.email})',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _coordinatorId = value),
                      );
                    },
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Switch(
                          value: _isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                        Text('Venue is active', style: AppTextStyles.body),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  BlocBuilder<VenueActionCubit, VenueActionState>(
                    builder: (context, state) {
                      return AppButton(
                        label: _isEditing ? 'Save Changes' : 'Create Venue',
                        isLoading: state is VenueActionLoading,
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

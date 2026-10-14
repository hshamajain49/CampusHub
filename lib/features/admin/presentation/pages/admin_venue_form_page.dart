import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_state.dart';
import 'package:campus_hub/features/admin/presentation/cubit/venue_action_cubit.dart/venue_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/venue_action_cubit.dart/venue_action_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../venues/domain/entities/venue_entity.dart';
import '../../../venues/presentation/widgets/amenity_chip.dart';

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

  List<String> get _amenities => _amenitiesController.text
      .split(',')
      .map((a) => a.trim())
      .where((a) => a.isNotEmpty)
      .toList();

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
    )..addListener(_onAmenitiesChanged);
    _coordinatorId = v?.coordinatorId;
    _isActive = v?.isActive ?? true;
  }

  void _onAmenitiesChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _buildingController.dispose();
    _capacityController.dispose();
    _amenitiesController
      ..removeListener(_onAmenitiesChanged)
      ..dispose();
    super.dispose();
  }

  /// Whether [uid] is a current Venue Coordinator account.
  bool _isCoordinator(String? uid) {
    final state = context.read<AdminUsersCubit>().state;
    return uid != null &&
        state is AdminUsersLoaded &&
        state.users.any(
          (u) => u.uid == uid && u.role == UserRole.venueCoordinator,
        );
  }

  void _onSubmit() {
    if (!_isCoordinator(_coordinatorId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign a coordinator')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final amenities = _amenities;
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
    final amenities = _amenities;
    return Scaffold(
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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    title: 'Venue details',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'Venue name',
                          prefixIcon: Icons.meeting_room_outlined,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: AppTextField(
                                controller: _buildingController,
                                label: 'Building',
                                prefixIcon: Icons.location_city_outlined,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: AppTextField(
                                controller: _capacityController,
                                label: 'Capacity',
                                prefixIcon: Icons.people_alt_outlined,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(v.trim()) == null) {
                                    return 'Number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          maxLines: 4,
                          minLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Amenities',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _amenitiesController,
                          label: 'Amenities (comma-separated)',
                          hint: 'Projector, Whiteboard, AC',
                          prefixIcon: Icons.checklist_rounded,
                        ),
                        if (amenities.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: amenities
                                .map((a) => AmenityChip(label: a))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Management',
                    child: Column(
                      children: [
                        BlocBuilder<AdminUsersCubit, AdminUsersState>(
                          builder: (context, state) {
                            if (state is! AdminUsersLoaded) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: LinearProgressIndicator(),
                              );
                            }
                            final coordinators = state.users
                                .where(
                                  (u) => u.role == UserRole.venueCoordinator,
                                )
                                .toList();
                            if (coordinators.isEmpty) {
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: AppColors.statusOrange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No Coordinator accounts yet — create one first.',
                                      style: AppTextStyles.bodySecondary,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return DropdownButtonFormField<String>(
                              isExpanded: true,
                              // The saved coordinator may no longer be one
                              // (role changed or account removed): show none
                              // rather than crash on an unknown value.
                              initialValue:
                                  coordinators.any(
                                    (u) => u.uid == _coordinatorId,
                                  )
                                  ? _coordinatorId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Coordinator',
                                prefixIcon: Icon(
                                  Icons.supervisor_account_outlined,
                                  size: 20,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
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
                          const SizedBox(height: 14),
                          SwitchField(
                            label: 'Venue is active',
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<VenueActionCubit, VenueActionState>(
                    builder: (context, state) {
                      return AppButton(
                        label: _isEditing ? 'Save Changes' : 'Create Venue',
                        icon: _isEditing
                            ? Icons.check_rounded
                            : Icons.add_business_outlined,
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

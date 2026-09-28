import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/venue_entity.dart';
import '../cubit/venue_detail_cubit/venue_detail_cubit.dart';
import '../cubit/venue_detail_cubit/venue_detail_state.dart';
import '../cubit/create_booking_cubit/create_booking_cubit.dart';
import '../cubit/create_booking_cubit/create_booking_state.dart';
import '../widgets/amenity_chip.dart';

class VenueDetailPage extends StatelessWidget {
  final String venueId;
  const VenueDetailPage({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<VenueDetailCubit>()..load(venueId)),
        BlocProvider(create: (_) => sl<CreateBookingCubit>()),
      ],
      child: const _VenueDetailView(),
    );
  }
}

class _VenueDetailView extends StatelessWidget {
  const _VenueDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Venue Details')),
      body: BlocBuilder<VenueDetailCubit, VenueDetailState>(
        builder: (context, state) {
          if (state is VenueDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VenueDetailError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.bodySecondary),
            );
          }
          final venue = (state as VenueDetailLoaded).venue;
          return _VenueDetailBody(venue: venue);
        },
      ),
    );
  }
}

class _VenueDetailBody extends StatefulWidget {
  final VenueEntity venue;
  const _VenueDetailBody({required this.venue});

  @override
  State<_VenueDetailBody> createState() => _VenueDetailBodyState();
}

class _VenueDetailBodyState extends State<_VenueDetailBody> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();

  DateTimeRange? _dateRange;
  bool _isFullDay = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _onSubmit() {
    if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range')),
      );
      return;
    }
    if (!_isFullDay && (_startTime == null || _endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start and end time')),
      );
      return;
    }
    if (!_isFullDay) {
      final startMins = _startTime!.hour * 60 + _startTime!.minute;
      final endMins = _endTime!.hour * 60 + _endTime!.minute;
      if (endMins <= startMins) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }
    }
    if (!_formKey.currentState!.validate()) return;

    context.read<CreateBookingCubit>().submit(
      venueId: widget.venue.id,
      venueName: widget.venue.name,
      coordinatorId: widget.venue.coordinatorId, // <-- add this line
      purpose: _purposeController.text.trim(),
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
      isFullDay: _isFullDay,
      startTime: _isFullDay ? null : _fmtTime(_startTime!),
      endTime: _isFullDay ? null : _fmtTime(_endTime!),
    );
  }

  void _showSuccessAndPop() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _BookingSuccessDialog(
        onDone: () {
          Navigator.of(dialogContext).pop();
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;

    return BlocListener<CreateBookingCubit, CreateBookingState>(
      listener: (context, state) {
        if (state is CreateBookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is CreateBookingSuccess) {
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
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.meeting_room_outlined,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(venue.name, style: AppTextStyles.h1),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(venue.building, style: AppTextStyles.bodySecondary),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.people_outline_rounded,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Capacity ${venue.capacity}',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
                if (venue.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(venue.description, style: AppTextStyles.body),
                ],
                if (venue.amenities.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: venue.amenities
                        .map((a) => AmenityChip(label: a))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 20),
                Text('Book this venue', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _purposeController,
                  label: 'Purpose',
                  hint: 'e.g. Department seminar',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the purpose';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _dateRange == null
                              ? 'Select date range'
                              : '${_fmtDate(_dateRange!.start)} — ${_fmtDate(_dateRange!.end)}',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: _isFullDay,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isFullDay = v),
                    ),
                    Text('Full day booking', style: AppTextStyles.body),
                  ],
                ),
                if (!_isFullDay) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _TimePickerField(
                          label: 'Start time',
                          time: _startTime,
                          formatted: _startTime != null
                              ? _fmtTime(_startTime!)
                              : null,
                          onTap: () => _pickTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimePickerField(
                          label: 'End time',
                          time: _endTime,
                          formatted: _endTime != null
                              ? _fmtTime(_endTime!)
                              : null,
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                BlocBuilder<CreateBookingCubit, CreateBookingState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Request Booking',
                      isLoading: state is CreateBookingLoading,
                      onPressed: _onSubmit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final String? formatted;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.time,
    required this.formatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formatted ?? label,
                style: AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSuccessDialog extends StatefulWidget {
  final VoidCallback onDone;
  const _BookingSuccessDialog({required this.onDone});

  @override
  State<_BookingSuccessDialog> createState() => _BookingSuccessDialogState();
}

class _BookingSuccessDialogState extends State<_BookingSuccessDialog>
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
            Text('Booking Requested!', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              "You'll be notified once it's approved.",
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

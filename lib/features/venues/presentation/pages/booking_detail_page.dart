import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../cubit/booking_detail_cubit/booking_detail_cubit.dart';
import '../cubit/booking_detail_cubit/booking_detail_state.dart';
import '../cubit/booking_action_cubit/booking_action_cubit.dart';
import '../cubit/booking_action_cubit/booking_action_state.dart';
import '../widgets/booking_status_badge.dart';

class BookingDetailPage extends StatelessWidget {
  final String bookingId;
  const BookingDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<BookingDetailCubit>()..load(bookingId)),
        BlocProvider(create: (_) => sl<BookingActionCubit>()),
      ],
      child: const _BookingDetailView(),
    );
  }
}

class _BookingDetailView extends StatelessWidget {
  const _BookingDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Details')),
      body: BlocConsumer<BookingActionCubit, BookingActionState>(
        listener: (context, actionState) {
          if (actionState is BookingActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(actionState.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (actionState is BookingUpdateSuccess) {
            final message = actionState.booking.status == BookingStatus.pending
                ? 'Booking updated — pending re-approval.'
                : 'Booking updated.';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            context.read<BookingDetailCubit>().load(actionState.booking.id);
          }
          if (actionState is BookingCancelSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
            context.pop();
          }
        },
        builder: (context, actionState) {
          return BlocBuilder<BookingDetailCubit, BookingDetailState>(
            builder: (context, state) {
              if (state is BookingDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is BookingDetailError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyles.bodySecondary,
                  ),
                );
              }
              final booking = (state as BookingDetailLoaded).booking;
              return _BookingDetailBody(
                booking: booking,
                isSubmitting: actionState is BookingActionLoading,
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingDetailBody extends StatefulWidget {
  final BookingEntity booking;
  final bool isSubmitting;
  const _BookingDetailBody({required this.booking, required this.isSubmitting});

  @override
  State<_BookingDetailBody> createState() => _BookingDetailBodyState();
}

class _BookingDetailBodyState extends State<_BookingDetailBody> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _purposeController;

  bool _isEditing = false;
  DateTimeRange? _dateRange;
  bool _isFullDay = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool get _isEditable =>
      widget.booking.status == BookingStatus.pending ||
      widget.booking.status == BookingStatus.approved;

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController(text: widget.booking.purpose);
    _resetFormToOriginal();
  }

  void _resetFormToOriginal() {
    final b = widget.booking;
    _dateRange = DateTimeRange(start: b.startDate, end: b.endDate);
    _isFullDay = b.isFullDay;
    _startTime = b.startTime != null ? _parseTime(b.startTime!) : null;
    _endTime = b.endTime != null ? _parseTime(b.endTime!) : null;
    _purposeController.text = b.purpose;
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

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

  void _onSave() {
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

    context.read<BookingActionCubit>().update(
      original: widget.booking,
      purpose: _purposeController.text.trim(),
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
      isFullDay: _isFullDay,
      startTime: _isFullDay ? null : _fmtTime(_startTime!),
      endTime: _isFullDay ? null : _fmtTime(_endTime!),
    );
    setState(() => _isEditing = false);
  }

  void _onCancelBooking() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: const Text(
          'This cannot be undone. The venue will become available for others.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BookingActionCubit>().cancel(widget.booking.id);
            },
            child: Text(
              'Cancel booking',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(booking.venueName, style: AppTextStyles.h1),
                ),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 20),
            if (!_isEditing) ..._buildViewMode(booking) else _buildEditMode(),
            if (!_isEditable) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'This booking is ${booking.status.displayName.toLowerCase()} and can no longer be modified.',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildViewMode(BookingEntity booking) {
    final dateLabel = _fmtDate(booking.startDate) == _fmtDate(booking.endDate)
        ? _fmtDate(booking.startDate)
        : '${_fmtDate(booking.startDate)} — ${_fmtDate(booking.endDate)}';

    return [
      Text('Purpose', style: AppTextStyles.caption),
      const SizedBox(height: 4),
      Text(booking.purpose, style: AppTextStyles.body),
      const SizedBox(height: 16),
      Text('Date', style: AppTextStyles.caption),
      const SizedBox(height: 4),
      Text(dateLabel, style: AppTextStyles.body),
      const SizedBox(height: 16),
      Text('Time', style: AppTextStyles.caption),
      const SizedBox(height: 4),
      Text(
        booking.isFullDay
            ? 'Full day'
            : '${booking.startTime} - ${booking.endTime}',
        style: AppTextStyles.body,
      ),
      if (_isEditable) ...[
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _resetFormToOriginal();
                  _isEditing = true;
                }),
                child: const Text('Edit Booking'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                onPressed: widget.isSubmitting ? null : _onCancelBooking,
                child: const Text('Cancel Booking'),
              ),
            ),
          ],
        ),
      ],
    ];
  }

  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _purposeController,
            label: 'Purpose',
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                  child: _TimeField(
                    label: 'Start time',
                    formatted: _startTime != null
                        ? _fmtTime(_startTime!)
                        : null,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: 'End time',
                    formatted: _endTime != null ? _fmtTime(_endTime!) : null,
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _resetFormToOriginal();
                    _isEditing = false;
                  }),
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Save Changes',
                  isLoading: widget.isSubmitting,
                  onPressed: _onSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String? formatted;
  final VoidCallback onTap;
  const _TimeField({
    required this.label,
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

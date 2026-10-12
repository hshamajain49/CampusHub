import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../cubit/booking_detail_cubit/booking_detail_cubit.dart';
import '../cubit/booking_detail_cubit/booking_detail_state.dart';
import '../cubit/booking_action_cubit/booking_action_cubit.dart';
import '../cubit/booking_action_cubit/booking_action_state.dart';
import '../utils/booking_status_ui_extension.dart';
import '../widgets/booking_header_card.dart';

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
                return const LoadingView();
              }
              if (state is BookingDetailError) {
                return ErrorState(message: state.message);
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
        icon: const Icon(
          Icons.event_busy_rounded,
          color: AppColors.error,
          size: 32,
        ),
        title: const Text('Cancel this booking?'),
        content: const Text(
          'This cannot be undone. The venue will become available for others.',
          textAlign: TextAlign.center,
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel booking'),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BookingHeaderCard(booking: booking),
            if (booking.status == BookingStatus.rejected &&
                booking.rejectionReason != null) ...[
              const SizedBox(height: 12),
              BookingNotice(
                icon: Icons.info_outline_rounded,
                color: booking.status.color,
                title: 'Reason for rejection',
                message: booking.rejectionReason!,
              ),
            ],
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _isEditing ? _buildEditMode() : _buildViewMode(booking),
            ),
            if (!_isEditable) ...[
              const SizedBox(height: 16),
              BookingNotice(
                icon: Icons.lock_outline_rounded,
                color: AppColors.textSecondary,
                message:
                    'This booking is ${booking.status.displayName.toLowerCase()} and can no longer be modified.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode(BookingEntity booking) {
    return Column(
      key: const ValueKey('view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Details',
          child: Column(
            children: [
              InfoRow(
                icon: Icons.edit_calendar_outlined,
                label: 'Purpose',
                value: booking.purpose,
              ),
              InfoRow(
                icon: Icons.date_range_outlined,
                color: AppColors.venues,
                label: 'Date',
                value: formatDateRange(booking.startDate, booking.endDate),
              ),
              InfoRow(
                icon: Icons.schedule_rounded,
                color: AppColors.venues,
                label: 'Time',
                value: booking.isFullDay
                    ? 'Full day'
                    : '${booking.startTime} – ${booking.endTime}',
              ),
              InfoRow(
                icon: Icons.history_rounded,
                color: AppColors.textSecondary,
                label: 'Requested',
                value: formatDateTime(booking.createdAt),
                isLast: true,
              ),
            ],
          ),
        ),
        if (_isEditable) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => setState(() {
                    _resetFormToOriginal();
                    _isEditing = true;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  icon: Icons.event_busy_outlined,
                  variant: AppButtonVariant.danger,
                  onPressed: widget.isSubmitting ? null : _onCancelBooking,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      key: const ValueKey('edit'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Edit booking',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _purposeController,
                  label: 'Purpose',
                  prefixIcon: Icons.edit_calendar_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the purpose';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                PickerField(
                  icon: Icons.date_range_outlined,
                  placeholder: 'Select date range',
                  value: _dateRange == null
                      ? null
                      : formatDateRange(_dateRange!.start, _dateRange!.end),
                  onTap: _pickDateRange,
                ),
                const SizedBox(height: 12),
                SwitchField(
                  label: 'Full-day booking',
                  value: _isFullDay,
                  onChanged: (v) => setState(() => _isFullDay = v),
                ),
                if (!_isFullDay) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PickerField(
                          icon: Icons.schedule_rounded,
                          placeholder: 'Start',
                          value: _startTime != null
                              ? _fmtTime(_startTime!)
                              : null,
                          onTap: () => _pickTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PickerField(
                          icon: Icons.schedule_rounded,
                          placeholder: 'End',
                          value: _endTime != null ? _fmtTime(_endTime!) : null,
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.booking.status == BookingStatus.approved) ...[
          const SizedBox(height: 10),
          Text(
            'Changing the date or time sends this booking back for approval.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Discard',
                variant: AppButtonVariant.outlined,
                onPressed: () => setState(() {
                  _resetFormToOriginal();
                  _isEditing = false;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Save',
                icon: Icons.check_rounded,
                isLoading: widget.isSubmitting,
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

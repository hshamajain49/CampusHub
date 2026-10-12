import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/venue_entity.dart';
import '../cubit/venue_detail_cubit/venue_detail_cubit.dart';
import '../cubit/venue_detail_cubit/venue_detail_state.dart';
import '../cubit/create_booking_cubit/create_booking_cubit.dart';
import '../cubit/create_booking_cubit/create_booking_state.dart';
import '../widgets/amenity_chip.dart';
import '../widgets/venue_banner.dart';

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
    return BlocBuilder<VenueDetailCubit, VenueDetailState>(
      builder: (context, state) {
        if (state is VenueDetailLoaded) {
          return Scaffold(body: _VenueDetailBody(venue: state.venue));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Venue Details')),
          body: state is VenueDetailError
              ? ErrorState(message: state.message)
              : const LoadingView(),
        );
      },
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

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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

    FocusScope.of(context).unfocus();
    context.read<CreateBookingCubit>().submit(
      venueId: widget.venue.id,
      venueName: widget.venue.name,
      coordinatorId: widget.venue.coordinatorId,
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
      builder: (dialogContext) => SuccessDialog(
        title: 'Booking requested!',
        message: "You'll be notified once it's approved.",
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
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            backgroundColor: VenueBanner.paletteFor(venue.id).first,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                end: 20,
                bottom: 16,
              ),
              title: Text(
                venue.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              background: VenueBanner(
                seed: venue.id,
                imageUrl: venue.imageUrl,
                height: 260,
                iconSize: 64,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x33000000),
                        Color(0x00000000),
                        Color(0x66000000),
                      ],
                      stops: [0, 0.4, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FactTile(
                            icon: Icons.location_on_outlined,
                            label: 'Building',
                            value: venue.building,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FactTile(
                            icon: Icons.people_alt_outlined,
                            label: 'Capacity',
                            value: '${venue.capacity} people',
                          ),
                        ),
                      ],
                    ),
                    if (venue.description.isNotEmpty ||
                        venue.amenities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'About this space',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (venue.description.isNotEmpty)
                              Text(
                                venue.description,
                                style: AppTextStyles.body,
                              ),
                            if (venue.description.isNotEmpty &&
                                venue.amenities.isNotEmpty)
                              const SizedBox(height: 14),
                            if (venue.amenities.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: venue.amenities
                                    .map((a) => AmenityChip(label: a))
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Request a booking',
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _purposeController,
                              label: 'Purpose',
                              hint: 'e.g. Department seminar',
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
                                  : formatDateRange(
                                      _dateRange!.start,
                                      _dateRange!.end,
                                    ),
                              onTap: _pickDateRange,
                            ),
                            const SizedBox(height: 12),
                            SwitchField(
                              label: 'Full-day booking',
                              subtitle: 'Turn off to pick specific hours',
                              value: _isFullDay,
                              onChanged: (v) => setState(() => _isFullDay = v),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              child: _isFullDay
                                  ? const SizedBox(width: double.infinity)
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: PickerField(
                                              icon: Icons.schedule_rounded,
                                              placeholder: 'Start',
                                              value: _startTime == null
                                                  ? null
                                                  : _fmtTime(_startTime!),
                                              onTap: () =>
                                                  _pickTime(isStart: true),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: PickerField(
                                              icon: Icons.schedule_rounded,
                                              placeholder: 'End',
                                              value: _endTime == null
                                                  ? null
                                                  : _fmtTime(_endTime!),
                                              onTap: () =>
                                                  _pickTime(isStart: false),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<CreateBookingCubit, CreateBookingState>(
                      builder: (context, state) {
                        return AppButton(
                          label: 'Request Booking',
                          icon: Icons.event_available_rounded,
                          isLoading: state is CreateBookingLoading,
                          onPressed: _onSubmit,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The venue coordinator will review your request.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconBadge(icon: icon, color: AppColors.venues, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

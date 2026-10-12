import 'package:flutter/material.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/booking_status.dart';
import '../utils/booking_status_ui_extension.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;
  final bool showIcon;
  const BookingStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return StatusPill(
      label: status.displayName,
      color: status.color,
      icon: showIcon ? status.icon : null,
    );
  }
}

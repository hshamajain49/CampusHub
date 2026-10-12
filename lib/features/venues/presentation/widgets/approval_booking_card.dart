import 'package:flutter/material.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_card.dart';

/// Booking card for the coordinator dashboard — same look as the student
/// card, plus the requester's name.
class ApprovalBookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onTap;
  final int index;
  const ApprovalBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      booking: booking,
      index: index,
      onTap: onTap,
      showRequester: true,
    );
  }
}

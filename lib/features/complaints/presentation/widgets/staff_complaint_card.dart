import 'package:flutter/material.dart';
import '../../domain/entities/complaint_entity.dart';
import 'complaint_card.dart';

/// Complaint card for the staff dashboard — same look as the student card,
/// plus the reporter's name.
class StaffComplaintCard extends StatelessWidget {
  final ComplaintEntity complaint;
  final VoidCallback onTap;
  final int index;
  const StaffComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ComplaintCard(
      complaint: complaint,
      index: index,
      onTap: onTap,
      showReporter: true,
    );
  }
}

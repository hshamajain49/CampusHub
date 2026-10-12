import 'package:flutter/material.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/complaint_status.dart';
import '../utils/status_ui_extension.dart';

class StatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  final bool showIcon;
  const StatusBadge({super.key, required this.status, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return StatusPill(
      label: status.displayName,
      color: status.color,
      icon: showIcon ? status.icon : null,
    );
  }
}

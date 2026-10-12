import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/complaint_status.dart';

/// Three-step tracker: Submitted -> In progress -> Resolved.
class ComplaintProgress extends StatelessWidget {
  final ComplaintStatus status;
  const ComplaintProgress({super.key, required this.status});

  static const _labels = ['Submitted', 'In progress', 'Resolved'];

  int get _currentStep {
    switch (status) {
      case ComplaintStatus.pendingReview:
      case ComplaintStatus.unassigned:
        return 0;
      case ComplaintStatus.inProgress:
        return 1;
      case ComplaintStatus.resolved:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentStep;
    final isDone = status == ComplaintStatus.resolved;
    final activeColor = isDone ? AppColors.statusGreen : AppColors.primary;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _labels.length; i++) ...[
              _StepDot(
                state: i < current || isDone
                    ? _StepState.done
                    : i == current
                    ? _StepState.current
                    : _StepState.upcoming,
                color: activeColor,
              ),
              if (i < _labels.length - 1)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: i < current ? activeColor : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < _labels.length; i++)
              Expanded(
                child: Text(
                  _labels[i],
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == _labels.length - 1
                      ? TextAlign.right
                      : TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: i <= current
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight: i == current
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

enum _StepState { done, current, upcoming }

class _StepDot extends StatelessWidget {
  final _StepState state;
  final Color color;
  const _StepDot({required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: state == _StepState.done
            ? color
            : state == _StepState.current
            ? color.withValues(alpha: 0.12)
            : AppColors.surfaceMuted,
        border: Border.all(
          color: state == _StepState.upcoming ? AppColors.divider : color,
          width: 2,
        ),
      ),
      child: state == _StepState.done
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : state == _StepState.current
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

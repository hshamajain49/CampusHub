import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'quick_action_card.dart';

/// Quick actions shared by the role dashboards. Pass `detailed: true` when
/// there are only two per row and there's room for a subtitle.
class HomeQuickActions {
  HomeQuickActions._();

  static QuickActionCard complaint(
    BuildContext context, {
    bool detailed = false,
  }) => QuickActionCard(
    icon: Icons.report_gmailerrorred_rounded,
    title: 'Complaint',
    subtitle: detailed ? 'Report an issue' : null,
    color: AppColors.complaints,
    onTap: () => context.push('/new-complaint'),
  );

  static QuickActionCard bookVenue(
    BuildContext context, {
    bool detailed = false,
  }) => QuickActionCard(
    icon: Icons.event_available_rounded,
    title: 'Book Venue',
    subtitle: detailed ? 'Reserve a space' : null,
    color: AppColors.venues,
    onTap: () => context.push('/venues'),
  );

  static QuickActionCard suggestions(
    BuildContext context, {
    bool detailed = false,
  }) => QuickActionCard(
    icon: Icons.lightbulb_outline_rounded,
    title: 'Suggestions',
    subtitle: detailed ? 'Share your idea' : null,
    color: AppColors.suggestions,
    onTap: () => context.push('/suggestions'),
  );
}

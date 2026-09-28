import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _AdminTile(
              icon: Icons.people_outline_rounded,
              title: 'Manage Users',
              subtitle: 'Create and edit Staff & Coordinator accounts',
              onTap: () => context.push('/admin/users'),
            ),
            const SizedBox(height: 14),
            _AdminTile(
              icon: Icons.meeting_room_outlined,
              title: 'Manage Venues',
              subtitle: 'Add venues and assign coordinators',
              onTap: () => context.push('/admin/venues'),
            ),
            const SizedBox(height: 14),
            // _AdminTile(
            //   icon: Icons.bar_chart_rounded,
            //   title: 'Reports & Analytics',
            //   subtitle: 'Complaints, bookings, and user stats',
            //   onTap: () => context.push('/admin/reports'),
            // ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: 3),
                    Text(subtitle, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_badge.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            'Manage the accounts and spaces that power CampusHub.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          _AdminTile(
            icon: Icons.manage_accounts_outlined,
            color: AppColors.primary,
            title: 'Manage Users',
            subtitle: 'Create and edit Staff & Coordinator accounts',
            onTap: () => context.push('/admin/users'),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.domain_rounded,
            color: AppColors.venues,
            title: 'Manage Venues',
            subtitle: 'Add venues and assign coordinators',
            onTap: () => context.push('/admin/venues'),
          ),
          // _AdminTile(
          //   icon: Icons.bar_chart_rounded,
          //   title: 'Reports & Analytics',
          //   subtitle: 'Complaints, bookings, and user stats',
          //   onTap: () => context.push('/admin/reports'),
          // ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AdminTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title.copyWith(fontSize: 16)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

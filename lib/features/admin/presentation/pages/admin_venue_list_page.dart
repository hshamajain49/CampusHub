import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../di/injection_container.dart';
import '../../../venues/domain/entities/venue_entity.dart';
import '../../../venues/domain/usecases/get_venues_usecase.dart';
import '../../../venues/presentation/widgets/venue_banner.dart';

class AdminVenueListPage extends StatelessWidget {
  const AdminVenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venues')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/venues/new'),
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('New Venue'),
      ),
      body: StreamBuilder<List<VenueEntity>>(
        stream: sl<GetVenuesUseCase>()(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(message: '${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const LoadingView();
          }
          final venues = snapshot.data!;
          if (venues.isEmpty) {
            return EmptyState(
              icon: Icons.domain_add_outlined,
              color: AppColors.venues,
              title: 'No venues yet',
              message: 'Add your first bookable space.',
              actionLabel: 'Add venue',
              onAction: () => context.push('/admin/venues/new'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
            itemCount: venues.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final venue = venues[index];
              return FadeSlideIn(
                index: index,
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.push('/admin/venues/${venue.id}/edit'),
                  child: Opacity(
                    opacity: venue.isActive ? 1 : 0.6,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: VenueBanner(
                            seed: venue.id,
                            imageUrl: venue.imageUrl,
                            height: 52,
                            iconSize: 24,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venue.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${venue.building} · ${venue.capacity} seats',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        if (!venue.isActive) ...[
                          const SizedBox(width: 8),
                          const StatusPill(
                            label: 'Inactive',
                            color: AppColors.textSecondary,
                          ),
                        ],
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

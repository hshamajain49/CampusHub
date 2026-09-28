import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../venues/domain/entities/venue_entity.dart';
import '../../../venues/domain/usecases/get_venues_usecase.dart';

class AdminVenueListPage extends StatelessWidget {
  const AdminVenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Venues')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/venues/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Venue'),
      ),
      body: StreamBuilder<List<VenueEntity>>(
        stream: sl<GetVenuesUseCase>()(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final venues = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: venues.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final venue = venues[index];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push('/admin/venues/${venue.id}/edit'),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venue.name,
                                style: AppTextStyles.h3.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${venue.building} · Cap. ${venue.capacity}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        if (!venue.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Inactive',
                              style: AppTextStyles.caption,
                            ),
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

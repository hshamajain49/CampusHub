import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/entities/complaint_entity.dart';
import '../pages/image_viewer_page.dart';
import '../utils/category_ui_extension.dart';
import 'complaint_progress.dart';
import 'status_badge.dart';

/// Title, category, status and the progress tracker.
class ComplaintHeaderCard extends StatelessWidget {
  final ComplaintEntity complaint;
  const ComplaintHeaderCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final category = complaint.category;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(icon: category.icon, color: category.color, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(complaint.title, style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    StatusBadge(status: complaint.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ComplaintProgress(status: complaint.status),
        ],
      ),
    );
  }
}

/// Horizontally scrolling thumbnails that open the fullscreen viewer.
class ComplaintPhotos extends StatelessWidget {
  final List<String> imageUrls;
  const ComplaintPhotos({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Photos',
      trailing: Text('${imageUrls.length}', style: AppTextStyles.caption),
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImageViewerPage(
                      imageUrls: imageUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  imageUrls[index],
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const _PhotoPlaceholder(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const _PhotoPlaceholder(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final Widget child;
  const _PhotoPlaceholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: child,
    );
  }
}

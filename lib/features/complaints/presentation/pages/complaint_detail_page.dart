import 'package:campus_hub/features/complaints/presentation/pages/image_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_cubit.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_state.dart';
import '../widgets/status_badge.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String complaintId;
  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComplaintDetailCubit>()..load(complaintId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Complaint Details')),
        body: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          builder: (context, state) {
            if (state is ComplaintDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ComplaintDetailError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodySecondary),
              );
            }

            final complaint = (state as ComplaintDetailLoaded).complaint;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(complaint.title, style: AppTextStyles.h1),
                      ),
                      StatusBadge(status: complaint.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: complaint.category.displayName,
                  ),
                  _InfoRow(
                    icon: Icons.apartment_outlined,
                    label: complaint.assignedDepartment,
                  ),
                  if (complaint.location != null)
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: complaint.location!,
                    ),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Submitted ${_formatFullDate(complaint.createdAt)}',
                  ),

                  if (complaint.description != null) ...[
                    const SizedBox(height: 20),
                    Text('Description', style: AppTextStyles.h3),
                    const SizedBox(height: 6),
                    Text(complaint.description!, style: AppTextStyles.body),
                  ],

                  if (complaint.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Photos', style: AppTextStyles.h3),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: complaint.imageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        // Add import at the top:

                        // Replace the itemBuilder inside the ListView.separated for photos with:
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ImageViewerPage(
                                    imageUrls: complaint.imageUrls,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                complaint.imageUrls[index],
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const SizedBox(
                                    width: 110,
                                    height: 110,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

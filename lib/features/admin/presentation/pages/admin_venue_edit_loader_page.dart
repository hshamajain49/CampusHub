import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../venues/presentation/cubit/venue_detail_cubit/venue_detail_cubit.dart';
import '../../../venues/presentation/cubit/venue_detail_cubit/venue_detail_state.dart';
import 'admin_venue_form_page.dart';

class AdminVenueEditLoaderPage extends StatelessWidget {
  final String venueId;
  const AdminVenueEditLoaderPage({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VenueDetailCubit>()..load(venueId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Edit Venue')),
        body: BlocBuilder<VenueDetailCubit, VenueDetailState>(
          builder: (context, state) {
            if (state is VenueDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VenueDetailError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodySecondary),
              );
            }
            return AdminVenueFormPage(
              venue: (state as VenueDetailLoaded).venue,
            );
          },
        ),
      ),
    );
  }
}

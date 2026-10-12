import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/state_views.dart';
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
      child: BlocBuilder<VenueDetailCubit, VenueDetailState>(
        builder: (context, state) {
          // The form page brings its own Scaffold/AppBar, so only wrap the
          // loading and error states (avoids a doubled app bar).
          if (state is VenueDetailLoaded) {
            return AdminVenueFormPage(venue: state.venue);
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Venue')),
            body: state is VenueDetailError
                ? ErrorState(message: state.message)
                : const LoadingView(),
          );
        },
      ),
    );
  }
}

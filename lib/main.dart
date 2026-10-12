import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/app_logo.dart';
import 'di/injection_container.dart';
import 'routing/app_router.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Decode the logo while Firebase starts so the splash page's first frame
  // already shows it (matching the native launch screen, no flicker).
  final logoReady = _precacheAsset(const AssetImage(AppLogo.assetPath));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();
  await logoReady;
  runApp(const CampusHubApp());
}

/// Like [precacheImage], but usable before there is a BuildContext.
Future<void> _precacheAsset(ImageProvider provider) {
  final completer = Completer<void>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, _) {
      if (!completer.isCompleted) completer.complete();
      stream.removeListener(listener);
    },
    onError: (_, _) {
      if (!completer.isCompleted) completer.complete();
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

class CampusHubApp extends StatelessWidget {
  const CampusHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthStateCubit>(),
      child: MaterialApp.router(
        title: 'CampusHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

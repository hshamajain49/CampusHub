import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests can't download Google Fonts, and the fallback test font draws
/// every glyph as a full em-square (far wider than Poppins / Inter), which
/// triggers overflow errors that never happen on a device. Loading the Roboto
/// files shipped with the Flutter SDK under the app's family names gives
/// realistic text metrics. If they can't be found, tests run unchanged.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadRealisticFonts();
  await testMain();
}

Future<void> _loadRealisticFonts() async {
  final dir = _materialFontsDir();
  if (dir == null) return;

  Future<ByteData>? read(String name) {
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    return file.existsSync()
        ? file.readAsBytes().then(ByteData.sublistView)
        : null;
  }

  Future<void> register(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final bytes in files.map(read).nonNulls) {
      loader.addFont(bytes);
    }
    await loader.load();
  }

  const all = ['roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf'];
  for (final family in ['Poppins', 'Inter', 'Roboto']) {
    await register(family, all);
  }

  // google_fonts names each weight as its own family ("Inter_500",
  // "Poppins_regular", "Inter_700italic") and the test engine doesn't fall
  // back from an unknown family, so register those names as well.
  for (final family in ['Poppins', 'Inter']) {
    for (var weight = 100; weight <= 900; weight += 100) {
      final file = weight < 500
          ? 'roboto-regular.ttf'
          : weight == 500
          ? 'roboto-medium.ttf'
          : 'roboto-bold.ttf';
      final variant = weight == 400 ? 'regular' : '$weight';
      await register('${family}_$variant', [file]);
      await register('${family}_${weight == 400 ? '' : weight}italic', [file]);
    }
  }

  final icons = File(
    '${dir.path}${Platform.pathSeparator}materialicons-regular.otf',
  );
  if (icons.existsSync()) {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(icons.readAsBytes().then(ByteData.sublistView))).load();
  }
}

Directory? _materialFontsDir() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final candidates = [
    if (flutterRoot != null)
      Directory('$flutterRoot/bin/cache/artifacts/material_fonts'),
    // flutter_tester runs from <flutter>/bin/cache/artifacts/engine/<platform>/.
    Directory(
      '${File(Platform.resolvedExecutable).parent.parent.parent.path}'
      '/material_fonts',
    ),
  ];
  for (final dir in candidates) {
    if (dir.existsSync()) return dir;
  }
  return null;
}

import 'package:flutter/services.dart';

/// The app asks for the platform font, which the test environment does not
/// have, so text would render as boxes. Load the bundled face under the family
/// name the default resolves to, purely so goldens are readable.
Future<void> loadTestFonts() async {
  final icons = FontLoader('MaterialIcons');
  icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
  const assets = [
    'assets/fonts/IBMPlexSans-Regular.ttf',
    'assets/fonts/IBMPlexSans-Medium.ttf',
    'assets/fonts/IBMPlexSans-SemiBold.ttf',
    'assets/fonts/IBMPlexSans-Bold.ttf',
  ];
  for (final family in ['Roboto', 'IBMPlexSans']) {
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

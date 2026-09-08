import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/theme/theme_controller.dart';

final fieldPreferencesProvider =
    NotifierProvider<FieldPreferencesController, FieldPreferences>(
      FieldPreferencesController.new,
    );

class FieldPreferences {
  const FieldPreferences({this.outdoor = false, this.reduceMotion = false});
  final bool outdoor;
  final bool reduceMotion;
}

class FieldPreferencesController extends Notifier<FieldPreferences> {
  @override
  FieldPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return FieldPreferences(
      outdoor: prefs.getBool('field_outdoor') ?? false,
      reduceMotion: prefs.getBool('field_reduce_motion') ?? false,
    );
  }

  Future<void> setOutdoor(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool('field_outdoor', value);
    state = FieldPreferences(outdoor: value, reduceMotion: state.reduceMotion);
  }

  Future<void> setReduceMotion(bool value) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool('field_reduce_motion', value);
    state = FieldPreferences(outdoor: state.outdoor, reduceMotion: value);
  }
}

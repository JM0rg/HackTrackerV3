import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/theme/theme_controller.dart';
import 'package:hacktracker/features/premium/data/plan_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'plan preview starts free, persists, and separates player/team access',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ProviderContainer container() => ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      var ref = container();
      expect(ref.read(planPreviewProvider), Plan.free);
      await ref.read(planPreviewProvider.notifier).select(Plan.playerPlus);
      expect(ref.read(planPreviewProvider).personalCloud, true);
      expect(ref.read(planPreviewProvider).teamCloud, false);
      ref.dispose();
      ref = container();
      expect(ref.read(planPreviewProvider), Plan.playerPlus);
      await ref.read(planPreviewProvider.notifier).select(Plan.teamPlus);
      expect(ref.read(planPreviewProvider).teamCloud, true);
      await ref.read(planPreviewProvider.notifier).select(Plan.free);
      expect(ref.read(planPreviewProvider).personalCloud, false);
      ref.dispose();
    },
  );
}

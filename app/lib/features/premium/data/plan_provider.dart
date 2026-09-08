import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/theme/theme_controller.dart';

/// A preview of product access, never proof of a server entitlement.
enum Plan {
  free('Free'),
  playerPlus('Player Plus'),
  teamPlus('Team Plus');

  const Plan(this.label);
  final String label;
  bool get locationTracking => this != free;
  bool get personalCloud => this != free;
  bool get teamCloud => this == teamPlus;
}

// Release builds cannot enable this, even through a saved preference.
const planPreviewEnabled = !kReleaseMode;
const _previewKey = 'development_plan_preview';
final planPreviewProvider = NotifierProvider<PlanPreviewController, Plan>(
  PlanPreviewController.new,
);

class PlanPreviewController extends Notifier<Plan> {
  @override
  Plan build() {
    if (!planPreviewEnabled) return Plan.free;
    final saved = ref.watch(sharedPreferencesProvider).getString(_previewKey);
    return Plan.values.where((p) => p.name == saved).firstOrNull ?? Plan.free;
  }

  Future<void> select(Plan plan) async {
    if (!planPreviewEnabled) return;
    await ref.read(sharedPreferencesProvider).setString(_previewKey, plan.name);
    state = plan;
  }
}

/// Central access decision; store entitlements can replace the preview later.
final locationTrackingProvider = Provider<bool>(
  (ref) => ref.watch(planPreviewProvider).locationTracking,
);

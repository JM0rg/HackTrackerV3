import 'package:flutter/material.dart';

import 'app_theme.dart';

extension ThemeContextX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppSpacing get themeSpacing => Theme.of(this).extension<AppSpacing>()!;
  AppRadii get themeRadii => Theme.of(this).extension<AppRadii>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

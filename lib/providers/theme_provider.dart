import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dark theme removed: always use light theme.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  /// Toggle is intentionally a no-op; the app uses only light theme.
  Future<void> toggle(bool _) async {
    state = ThemeMode.light;
  }
}

/// Provider for theme (always light)
final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (mode != _themeMode) {
      _themeMode = mode;
      notifyListeners(); // Tell widgets listening to rebuild
    }
  }

// You might want to add logic here to save/load the user's preference
// using shared_preferences or similar, but for now, this is enough for toggling.
}
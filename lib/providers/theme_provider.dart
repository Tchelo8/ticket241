import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/design_tokens.dart';

/// Thème et ville sélectionnés — persistés (README, section "État").
class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'app_theme_variant';
  static const _cityKey = 'selected_city';

  AppThemeVariant _variant = AppThemeVariant.paper;
  String _city = 'Libreville';

  AppThemeVariant get variant => _variant;
  String get city => _city;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedVariant = prefs.getString(_themeKey);
    if (storedVariant != null) {
      _variant = AppThemeVariant.values.firstWhere(
        (v) => v.name == storedVariant,
        orElse: () => AppThemeVariant.paper,
      );
    }
    _city = prefs.getString(_cityKey) ?? _city;
    notifyListeners();
  }

  Future<void> setVariant(AppThemeVariant variant) async {
    if (_variant == variant) return;
    _variant = variant;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, variant.name);
  }

  Future<void> setCity(String city) async {
    if (_city == city) return;
    _city = city;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
  }
}

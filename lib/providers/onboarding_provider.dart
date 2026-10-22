import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding vu ou non. Écouté par le routeur (refreshListenable) : sans cela, le routeur gardait
/// la valeur lue au démarrage et renvoyait vers l'onboarding même après « Passer ».
class OnboardingProvider with ChangeNotifier {
  static const _key = 'onboardingCompleted';

  bool _completed;

  OnboardingProvider({required bool completed}) : _completed = completed;

  bool get completed => _completed;

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _completed = true;
    notifyListeners();
  }

  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}

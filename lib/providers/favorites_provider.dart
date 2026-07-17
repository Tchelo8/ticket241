
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  List<Event> _favorites = [];
  static const _favoritesKey = 'favorites';

  FavoritesProvider() {
    _loadFavorites();
  }

  List<Event> get favorites => _favorites;

  bool isFavorite(Event event) {
    return _favorites.any((e) => e.id == event.id);
  }

  void toggleFavorite(Event event) {
    if (isFavorite(event)) {
      _favorites.removeWhere((e) => e.id == event.id);
    } else {
      _favorites.add(event);
    }
    _saveFavorites();
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getString(_favoritesKey);
    if (favoritesString != null) {
      try {
        final List<dynamic> favoritesJson = json.decode(favoritesString);
        _favorites = favoritesJson.map((json) => Event.fromJson(json)).toList();
      } catch (e) {
        // If decoding fails, it might be due to old data format. Clear it.
        await prefs.remove(_favoritesKey);
        _favorites = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> favoritesJson = _favorites.map((event) => event.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(favoritesJson));
  }
}

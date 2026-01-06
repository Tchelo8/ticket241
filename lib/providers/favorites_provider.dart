
import 'package:flutter/material.dart';
import 'package:myapp/models/event_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Event> _favorites = [];

  List<Event> get favorites => _favorites;

  bool isFavorite(Event event) {
    return _favorites.any((e) => e.name == event.name); // Simple check based on name for this example
  }

  void toggleFavorite(Event event) {
    if (isFavorite(event)) {
      _favorites.removeWhere((e) => e.name == event.name);
    } else {
      _favorites.add(event);
    }
    notifyListeners();
  }
}

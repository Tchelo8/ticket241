import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favoris de l'utilisateur :
/// - sans compte : gardés sur ce téléphone (SharedPreferences) ;
/// - avec un compte : enregistrés dans event-service (`/api/events/favorites`), donc retrouvés
///   sur tout appareil et sur le site, avec les infos à jour de chaque événement.
/// À la connexion, les favoris du téléphone sont versés sur le compte puis effacés du téléphone.
class FavoritesProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Event> _favorites = [];
  static const _favoritesKey = 'favorites';

  FavoritesProvider() {
    refresh();
  }

  List<Event> get favorites => _favorites;

  bool get _hasAccount => SessionStore.instance.hasSession;

  bool isFavorite(Event event) {
    return _favorites.any((e) => e.id == event.id);
  }

  /// Relit les favoris (au démarrage, puis à chaque connexion / déconnexion)
  Future<void> refresh() async {
    final local = await _loadLocal();
    if (!_hasAccount) {
      _favorites = local;
      notifyListeners();
      return;
    }

    final uuids = local.map((e) => e.uuid).whereType<String>().toList();
    final response = uuids.isEmpty ? await _api.getFavorites() : await _api.importFavorites(uuids);
    if (response.success) {
      _favorites = response.data ?? [];
      if (uuids.isNotEmpty) await _saveLocal(const []);
    }
    // Échec réseau : on garde la liste affichée, le prochain rafraîchissement réessaiera
    notifyListeners();
  }

  /// Mise à jour immédiate à l'écran ; avec un compte, annulée si le serveur refuse
  Future<void> toggleFavorite(Event event) async {
    final wasFavorite = isFavorite(event);
    _apply(event, add: !wasFavorite);

    if (!_hasAccount || event.uuid == null) {
      await _saveLocal(_favorites);
      return;
    }
    final response = wasFavorite ? await _api.removeFavorite(event.uuid!) : await _api.addFavorite(event.uuid!);
    if (!response.success) _apply(event, add: wasFavorite);
  }

  void _apply(Event event, {required bool add}) {
    _favorites = [
      ..._favorites.where((e) => e.id != event.id),
      if (add) event,
    ];
    notifyListeners();
  }

  Future<List<Event>> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getString(_favoritesKey);
    if (favoritesString == null) return [];
    try {
      final List<dynamic> favoritesJson = json.decode(favoritesString);
      return favoritesJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      // If decoding fails, it might be due to old data format. Clear it.
      await prefs.remove(_favoritesKey);
      return [];
    }
  }

  Future<void> _saveLocal(List<Event> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    if (favorites.isEmpty) {
      await prefs.remove(_favoritesKey);
      return;
    }
    final List<Map<String, dynamic>> favoritesJson = favorites.map((event) => event.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(favoritesJson));
  }
}

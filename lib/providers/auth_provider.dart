
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart'; // Importez le service API
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = true; // Commence à true pour vérifier l'état de connexion initial

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _tryAutoLogin(); // Tente de se connecter automatiquement au démarrage
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Tente de charger le token et les données utilisateur depuis le stockage local.
  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('access_token') || !prefs.containsKey('user_data')) {
      _setLoading(false);
      return;
    }

    _token = prefs.getString('access_token');
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _user = jsonDecode(userDataString);
    }

    // Idéalement, ici, vous devriez faire un appel API pour valider le token
    // Par exemple: GET /api/auth/me. Si l'appel réussit, l'utilisateur est connecté.
    // Pour l'instant, on considère que si le token est présent, c'est bon.
    
    _setLoading(false);
    notifyListeners();
  }

  /// Gère le processus de connexion.
  Future<ApiResponse> login(String phone, String password) async {
    _setLoading(true);

    final response = await _apiService.post(
      '/api/auth/login/structure', // Assurez-vous que l'endpoint est correct
      body: {'phone': phone, 'password': password},
    );

    if (response.success && response.data != null) {
      // Suppose que la réponse contient {"token": "...", "user": {...}}
      final responseData = response.data as Map<String, dynamic>;
      _token = responseData['token'];
      _user = responseData['user'];

      if (_token != null && _user != null) {
        await _saveSession(_token!, _user!);
      }
    } else {
      // L'API a retourné une erreur (ex: mauvais identifiants)
      // L'erreur sera déjà dans `response.error`
    }

    _setLoading(false);
    return response; // On retourne la réponse complète à l'UI
  }

  /// Sauvegarde la session dans le stockage local.
  Future<void> _saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('user_data', jsonEncode(user));
  }

  /// Gère la déconnexion.
  Future<void> logout() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');

    _token = null;
    _user = null;
    
    _setLoading(false);
    notifyListeners();
  }
}

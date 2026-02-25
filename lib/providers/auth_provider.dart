
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

    _setLoading(false);
    notifyListeners();
  }

  /// Gère le processus de connexion.
  Future<ApiResponse> login(String phone, String password) async {
    _setLoading(true);

    final response = await _apiService.post(
      '/api/auth/login/structure',
      body: {'phone': phone, 'password': password},
    );

    if (response.success && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;
      
      // On extrait le token de la réponse
      _token = responseData['token'];
      
      // La réponse entière (moins le token peut-être, mais c'est ok) est l'objet utilisateur
      _user = responseData; 

      if (_token != null && _user != null) {
        await _saveSession(_token!, _user!); // On sauvegarde la session
        notifyListeners(); // On notifie les listeners que l'état a changé !
      }
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

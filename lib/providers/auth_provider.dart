import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/session_store.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SessionStore _session = SessionStore.instance;
  bool _isLoading = true; // Vrai tant que la session enregistrée n'est pas relue
  Timer? _expiryTimer;

  Map<String, dynamic>? get user => _session.user;
  String? get token => _session.token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _session.hasSession;

  AuthProvider() {
    // Un 401 de l'API = JWT refusé (expiré, compte suspendu…) : on ferme la session
    _session.onUnauthorized = () {
      if (isAuthenticated) logout();
    };
    _tryAutoLogin();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _tryAutoLogin() async {
    await _session.load(); // session expirée = aucune session
    _armExpiryTimer();
    _setLoading(false);
  }

  /// Déconnexion automatique à l'expiration du JWT (application restée ouverte).
  void _armExpiryTimer() {
    _expiryTimer?.cancel();
    final token = _session.token;
    if (token == null) return;
    final expiry = SessionStore.expiryOf(token);
    if (expiry == null) return;
    final delay = expiry.difference(DateTime.now());
    _expiryTimer = Timer(delay.isNegative ? Duration.zero : delay, logout);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiService.register(firstName, lastName, email, phone, password);

    if (!response.success) {
      if (response.errors != null) {
        // Erreurs de validation (400)
        throw response.errors!;
      } else {
        // Message du serveur (409 numéro déjà utilisé, 503…)
        throw response.message ?? "L'inscription n'a pas abouti. Réessayez.";
      }
    }
    // Succès : le code est parti par e-mail, l'écran passe à la vérification
  }

  Future<void> verifyOtp(String phone, String code) async {
    final response = await _apiService.verifyOtp(phone, code);

    if (response.success && response.data != null) {
      await _openSession(response.data!);
    } else {
      throw response.message ?? 'La vérification du code a échoué. Réessayez.';
    }
  }

  Future<void> resendOtp(String phone) async {
    final response = await _apiService.resendOtp(phone);
    if (!response.success) {
      throw response.message ?? "Le nouveau code n'a pas pu être envoyé.";
    }
  }

  Future<void> login(String phone, String password) async {
    final response = await _apiService.login(phone, password);

    if (response.success && response.data != null) {
      await _openSession(response.data!);
    } else {
      if (response.errors != null) {
        throw response.errors!;
      } else {
        throw response.message ?? 'La connexion a échoué. Réessayez.';
      }
    }
  }

  // Pas encore de réinitialisation du mot de passe côté auth-service : on ne fait aucun appel
  Future<void> forgotPassword(String phone) async {
    throw "La réinitialisation du mot de passe n'est pas encore disponible : contactez le support Ticket241.";
  }

  /// Profil modifié (prénom, nom) : gardé dans la session sans changer le JWT.
  Future<void> updateUser(Map<String, dynamic> changes) async {
    final current = _session.user;
    if (current == null) return;
    await _session.updateUser({...current, ...changes});
    notifyListeners();
  }

  // Réponse de l'auth-service = profil + JWT (null pour un compte déjà vérifié : il doit se connecter)
  Future<void> _openSession(Map<String, dynamic> responseData) async {
    final token = responseData['token'] as String?;
    if (token == null) {
      throw responseData['message'] as String? ?? 'Compte déjà vérifié : connectez-vous.';
    }
    await _session.save(token, responseData);
    _armExpiryTimer();
    notifyListeners();
  }

  Future<void> logout() async {
    _expiryTimer?.cancel();
    _setLoading(true);
    await _session.clear();
    _setLoading(false);
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}

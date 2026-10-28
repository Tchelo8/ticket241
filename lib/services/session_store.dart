import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session de l'utilisateur : JWT + profil renvoyés par l'auth-service.
///
/// Stockée chiffrée (Keystore Android / Keychain iOS) via flutter_secure_storage, jamais en
/// clair dans SharedPreferences. Gardée aussi en mémoire pour que chaque appel API n'ait pas
/// à relire le stockage. Un JWT expiré est traité comme une absence de session.
class SessionStore {
  SessionStore._();
  static final SessionStore instance = SessionStore._();

  static const _tokenKey = 'session_token';
  static const _userKey = 'session_user';
  // Anciennes clés en clair (SharedPreferences), migrées puis effacées au premier lancement
  static const _legacyTokenKey = 'access_token';
  static const _legacyUserKey = 'user_data';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _user;

  /// Appelé quand l'API refuse le JWT (401) : l'AuthProvider s'y abonne pour déconnecter.
  void Function()? onUnauthorized;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get hasSession => _token != null && _user != null;

  /// Charge la session au démarrage (migration de l'ancien stockage en clair comprise).
  Future<void> load() async {
    await _migrateLegacySession();
    _token = await _storage.read(key: _tokenKey);
    final userJson = await _storage.read(key: _userKey);
    _user = userJson != null ? jsonDecode(userJson) as Map<String, dynamic> : null;
    if (_token != null && isExpired(_token!)) {
      await clear();
    }
  }

  Future<void> save(String token, Map<String, dynamic> user) async {
    _token = token;
    _user = user;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  /// Met à jour le profil gardé (après une modification), sans toucher au JWT.
  Future<void> updateUser(Map<String, dynamic> user) async {
    _user = user;
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<void> clear() async {
    _token = null;
    _user = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<void> _migrateLegacySession() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_legacyTokenKey);
    final legacyUser = prefs.getString(_legacyUserKey);
    if (legacyToken != null && legacyUser != null) {
      await _storage.write(key: _tokenKey, value: legacyToken);
      await _storage.write(key: _userKey, value: legacyUser);
    }
    await prefs.remove(_legacyTokenKey);
    await prefs.remove(_legacyUserKey);
  }

  /// Identifiant numérique du compte (champ `uid` du JWT), utilisé par notification-service
  int? get accountId {
    final uid = _token == null ? null : _claimsOf(_token!)?['uid'];
    if (uid is num) return uid.toInt();
    return uid is String ? int.tryParse(uid) : null;
  }

  /// Date d'expiration du JWT (champ `exp`), ou null si illisible.
  static DateTime? expiryOf(String token) {
    final exp = _claimsOf(token)?['exp'];
    return exp is num ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000) : null;
  }

  /// Champs du JWT, lus sans vérification de signature : seul le serveur fait foi
  static Map<String, dynamic>? _claimsOf(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return payload is Map<String, dynamic> ? payload : null;
    } catch (_) {
      return null;
    }
  }

  /// Un JWT illisible compte comme expiré : mieux vaut se reconnecter qu'appeler l'API pour rien.
  static bool isExpired(String token) {
    final expiry = expiryOf(token);
    return expiry == null || !expiry.isAfter(DateTime.now());
  }
}

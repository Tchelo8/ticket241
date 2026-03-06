import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

/// Un modèle de classe pour encapsuler les réponses de l'API de manière structurée.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });
}

/// Un service centralisé pour gérer tous les appels réseau de l'application.
/// Il gère automatiquement la sélection de l'URL de base, l'ajout des headers
/// d'authentification, et la normalisation des réponses.
class ApiService {
  /// Sélectionne dynamiquement l'URL de base en fonction de l'environnement de compilation.
  String get _baseUrl {
    if (kReleaseMode) {
      // Environnement de Production
      return dotenv.env['URL_PROD_BASE'] ?? 'https://api.default-prod.com';
    } else if (kProfileMode) {
      // Environnement de Test/Profilage
      return dotenv.env['URL_TEST_BASE'] ?? 'http://192.168.1.81:8080';
    } else {
      // Environnement de Développement (Debug)
      return dotenv.env['URL_LOCAL_BASE'] ?? 'http://10.0.2.2:8080';
    }
  }

  /// Construit les headers pour chaque requête, en ajoutant le token JWT si disponible.
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// La méthode privée et générique qui exécute les requêtes HTTP.
  Future<ApiResponse<T>> _request<T>(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl$endpoint');
      http.Response response;

      final bodyString = body != null ? jsonEncode(body) : null;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(url, headers: headers, body: bodyString);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: bodyString);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        case 'GET':
        default:
          response = await http.get(url, headers: headers);
          break;
      }
      
      // Décode le corps de la réponse en ignorant les erreurs de format (par ex. si vide)
      dynamic responseBody;
      try {
        responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        responseBody = null;
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.statusCode == 204 || responseBody == null) {
          return ApiResponse<T>(success: true, statusCode: response.statusCode, message: 'Opération réussie.');
        }
        
        // Si un parseur de JSON est fourni pour un objet complexe, on l'utilise.
        final data = fromJson != null ? fromJson(responseBody) : responseBody as T;
        
        return ApiResponse<T>(
          success: true,
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          error: responseBody?['message'] ?? 'Une erreur inconnue est survenue.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // Gère les erreurs de connectivité (pas d'internet, serveur injoignable)
      return ApiResponse<T>(
        success: false,
        error: 'Erreur réseau. Vérifiez votre connexion et réessayez.',
      );
    }
  }

  // --- Méthodes publiques pour les verbes HTTP ---

  Future<ApiResponse<T>> get<T>(String endpoint, {T Function(dynamic json)? fromJson}) =>
    _request<T>(endpoint, method: 'GET', fromJson: fromJson);

  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? body, T Function(dynamic json)? fromJson}) =>
    _request<T>(endpoint, method: 'POST', body: body, fromJson: fromJson);

  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? body, T Function(dynamic json)? fromJson}) =>
    _request<T>(endpoint, method: 'PUT', body: body, fromJson: fromJson);
  
  Future<ApiResponse<T>> delete<T>(String endpoint) =>
    _request<T>(endpoint, method: 'DELETE');


  /// Récupère la liste des villes actives depuis l'API.
  Future<ApiResponse<List<String>>> getActiveCities() {
    return get<List<String>>(
      '/api/events/cities/get/all/active',
      fromJson: (json) {
        if (json is List) {
          return List<String>.from(json.map((item) {
            if (item is Map<String, dynamic> && item.containsKey('name')) {
              return item['name'].toString();
            } else if (item is String) {
              return item;
            }
            return '';
          })).where((name) => name.isNotEmpty).toList();
        }
        throw const FormatException('Réponse invalide, une liste de villes était attendue.');
      },
    );
  }

  /// Récupère la liste des événements depuis l'API.
  Future<ApiResponse<List<Event>>> getEvents() {
    return get<List<Event>>(
      '/api/events/all',
      fromJson: (json) {
        if (json is Map<String, dynamic> && json.containsKey('content')) {
          final List content = json['content'];
          return content.map((item) => Event.fromJson(item)).toList();
        }
        throw const FormatException('Réponse invalide, un champ "content" était attendu.');
      },
    );
  }
}
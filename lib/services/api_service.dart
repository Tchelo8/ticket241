import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/models/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors; // For validation errors
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.statusCode,
  });
}

class ApiService {
  String get _baseUrl {
    if (kReleaseMode) {
      return dotenv.env['URL_PROD_BASE'] ?? 'https://api.default-prod.com';
    } else {
      return dotenv.env['URL_LOCAL_BASE'] ?? 'http://10.0.2.2:8080';
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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
        default:
          response = await http.get(url, headers: headers);
          break;
      }

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
        final data = fromJson != null ? fromJson(responseBody) : responseBody as T;
        return ApiResponse<T>(success: true, data: data, statusCode: response.statusCode);
      } else {
        return ApiResponse<T>(
          success: false,
          message: responseBody?['message'],
          errors: responseBody?['errors'] != null ? Map<String, dynamic>.from(responseBody['errors']) : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Erreur réseau. Vérifiez votre connexion et réessayez.',
      );
    }
  }

  // --- Auth Methods ---

  Future<ApiResponse<Map<String, dynamic>>> register(String firstName, String lastName, String email, String phone, String password) {
    return _request(
      '/api/auth/register',
      method: 'POST',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(String phone, String code) {
    return _request(
      '/api/auth/verify-otp',
      method: 'POST',
      body: {'phone': phone, 'code': code},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

    Future<ApiResponse<Map<String, dynamic>>> resendOtp(String phone) {
    return _request(
      '/api/auth/resend-otp',
      method: 'POST',
      body: {'phone': phone},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login(String phone, String password) {
    return _request(
      '/api/auth/login',
      method: 'POST',
      body: {'phone': phone, 'password': password},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse> forgotPassword(String phone) {
    return _request(
      '/api/auth/forgot-password',
      method: 'POST',
      body: {'phone': phone},
    );
  }

  // --- Other Methods ---

  Future<ApiResponse<List<String>>> getActiveCities() {
    return _request<List<String>>(
      '/api/events/cities/get/all/active',
      fromJson: (json) {
        if (json is List) {
          return List<String>.from(json.map((item) => item['name'].toString()));
        }
        throw const FormatException('Invalid response format for cities');
      },
    );
  }

  Future<ApiResponse<List<Event>>> getEvents({String? city}) async {
    // ... (rest of the method is unchanged)
        final List<Event> allEvents = [];
    int currentPage = 0;
    int totalPages = 1; // On commence avec 1, sera mis à jour après le premier appel

    try {
      while (currentPage < totalPages) {
        // Construit l'endpoint avec la pagination et le filtre de ville si fourni.
        String endpoint = '/api/events/all?page=$currentPage&size=20';
        if (city != null && city.isNotEmpty) {
          endpoint += '&city=${Uri.encodeComponent(city)}';
        }

        final response = await _request<Map<String, dynamic>>(
          endpoint,
          fromJson: (json) => json as Map<String, dynamic>
        );

        if (response.success && response.data != null) {
          final data = response.data!;
          
          if (data.containsKey('content') && data['content'] is List) {
            final List content = data['content'];
            allEvents.addAll(content.map((item) => Event.fromJson(item)).toList());
          } else {
            // Si la structure est inattendue, on arrête
            throw const FormatException('Le champ "content" est manquant ou invalide dans la réponse.');
          }

          // Mise à jour du nombre total de pages
          if (data.containsKey('totalPages') && data['totalPages'] is int) {
            totalPages = data['totalPages'];
          } else {
            // S'il n'y a pas d'info de pagination, on assume qu'il n'y a qu'une seule page
            break; 
          }
          
          currentPage++;

        } else {
          // Si une requête échoue, on retourne une erreur avec les événements déjà chargés
          return ApiResponse<List<Event>>(
            success: false,
            message: response.message ?? 'Erreur lors du chargement de la page $currentPage.',
            data: allEvents, // On renvoie ce qu'on a pu récupérer
            statusCode: response.statusCode,
          );
        }
      }

      return ApiResponse<List<Event>>(
        success: true,
        data: allEvents,
      );

    } catch (e) {
      return ApiResponse<List<Event>>(
        success: false,
        message: 'Erreur réseau ou de formatage. Vérifiez votre connexion et la structure de la réponse de l API.',
        data: allEvents, // On renvoie ce qu'on a pu récupérer
      );
    }
  }

  Future<ApiResponse<List<Category>>> getCategories() {
    return _request<List<Category>>(
      '/api/events/categories/get/all',
      fromJson: (json) {
        List<dynamic> categoryList;
        if (json is Map<String, dynamic> && json.containsKey('content')) {
          categoryList = json['content'] as List<dynamic>;
        } else if (json is List) {
          categoryList = json;
        } else {
          throw const FormatException('Unsupported format for categories response');
        }
        return categoryList.map((item) => Category.fromJson(item)).toList();
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/models/category_model.dart';
import 'package:myapp/models/order_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/services/session_store.dart';
import '../models/event_model.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors; // Erreurs de validation (400) : champ -> message
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.statusCode,
  });

  /// Message affichable : celui du serveur, sinon la première erreur de champ, sinon `fallback`
  String messageOr(String fallback) {
    if (message != null && message!.isNotEmpty && message != 'Erreur de validation') return message!;
    if (errors != null && errors!.isNotEmpty) return errors!.values.first.toString();
    return fallback;
  }
}

/// Environnement cible, fixé au build/lancement via --dart-define=ENV=... :
/// - (défaut) "emulator" -> URL_LOCAL_BASE (10.0.2.2, émulateur Android)
/// - "test"              -> URL_TEST_BASE (IP locale, téléphone physique en test)
/// Ignoré en release, qui utilise toujours URL_PROD_BASE.
const String _env = String.fromEnvironment('ENV', defaultValue: 'emulator');

/// En-têtes des achats sans compte (jeton de la commande, session ouverte par un code)
const guestTokenHeader = 'X-Guest-Token';
const guestSessionHeader = 'X-Guest-Session';

/// Moyen de paiement de l'application → valeur attendue par ticket-service
const apiPaymentMethods = {'airtel': 'AIRTEL_MONEY', 'moov': 'MOOV_MONEY', 'card': 'CARD'};

/// Seuls les chiffres du numéro saisi (« 074 12 34 56 » → « 074123456 »), comme le site web
String phoneDigits(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

class ApiService {
  String get _baseUrl {
    if (kReleaseMode) {
      return dotenv.env['URL_PROD_BASE'] ?? 'https://api.default-prod.com';
    }
    switch (_env) {
      case 'test':
        return dotenv.env['URL_TEST_BASE'] ?? 'http://192.168.1.81:8080';
      default:
        return dotenv.env['URL_LOCAL_BASE'] ?? 'http://10.0.2.2:8080';
    }
  }

  // JWT lu dans la session chiffrée (gardée en mémoire), jamais dans SharedPreferences
  Map<String, String> _headers({Map<String, String>? extra, bool json = true}) {
    final token = SessionStore.instance.token;
    return {
      if (json) 'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  Future<ApiResponse<T>> _request<T>(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final allHeaders = _headers(extra: headers);
      final hadSession = SessionStore.instance.token != null;
      http.Response response;

      final bodyString = body != null ? jsonEncode(body) : null;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(url, headers: allHeaders, body: bodyString);
          break;
        case 'PUT':
          response = await http.put(url, headers: allHeaders, body: bodyString);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: allHeaders, body: bodyString);
          break;
        default:
          response = await http.get(url, headers: allHeaders);
          break;
      }

      dynamic responseBody;
      try {
        responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        responseBody = null;
      }

      // JWT refusé (expiré, compte suspendu ou supprimé…) : la session est fermée
      if (response.statusCode == 401 && hadSession) {
        SessionStore.instance.onUnauthorized?.call();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.statusCode == 204 || responseBody == null) {
          return ApiResponse<T>(success: true, statusCode: response.statusCode, message: 'Opération réussie.');
        }
        final data = fromJson != null ? fromJson(responseBody) : responseBody as T;
        return ApiResponse<T>(success: true, data: data, statusCode: response.statusCode);
      } else {
        final map = responseBody is Map<String, dynamic> ? responseBody : null;
        return ApiResponse<T>(
          success: false,
          message: map?['message'] as String?,
          errors: map?['errors'] is Map ? Map<String, dynamic>.from(map!['errors']) : null,
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

  /// Fichier (PDF des billets) : octets bruts, avec le JWT ou un en-tête invité
  Future<ApiResponse<Uint8List>> _download(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {..._headers(extra: headers, json: false), 'Accept': 'application/pdf'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(success: true, data: response.bodyBytes, statusCode: response.statusCode);
      }
      String? message;
      try {
        message = (jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>)['message'] as String?;
      } catch (_) {}
      return ApiResponse(success: false, message: message, statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur réseau. Vérifiez votre connexion et réessayez.');
    }
  }

  // --- Authentification (auth-service) ---

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

  // --- Profil (auth-service, JWT) ---

  Future<ApiResponse<Map<String, dynamic>>> getMyAccount() {
    return _request('/api/auth/me', fromJson: (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateMyProfile(String firstName, String lastName) {
    return _request(
      '/api/auth/me',
      method: 'PUT',
      body: {'firstName': firstName, 'lastName': lastName},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Suppression de son compte (soft delete côté serveur) : mot de passe obligatoire
  Future<ApiResponse<Map<String, dynamic>>> deleteMyAccount(String password) {
    return _request(
      '/api/auth/me',
      method: 'DELETE',
      body: {'password': password},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // --- Événements (event-service) ---

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

  /// Tous les événements publiés (toutes les pages). L'API ne filtre pas par nom de ville :
  /// le filtre `city` est appliqué ici sur `cityName`.
  Future<ApiResponse<List<Event>>> getEvents({String? city}) async {
    final List<Event> allEvents = [];
    int currentPage = 0;
    int totalPages = 1;

    try {
      while (currentPage < totalPages) {
        final response = await _request<Map<String, dynamic>>(
          '/api/events/all?page=$currentPage&size=50&sortBy=startDate&sortDirection=asc',
          fromJson: (json) => json as Map<String, dynamic>,
        );

        if (response.success && response.data != null) {
          final data = response.data!;
          if (data['content'] is List) {
            allEvents.addAll((data['content'] as List).map((item) => Event.fromJson(item)));
          } else {
            throw const FormatException('Le champ "content" est manquant ou invalide dans la réponse.');
          }
          if (data['totalPages'] is int) {
            totalPages = data['totalPages'];
          } else {
            break;
          }
          currentPage++;
        } else {
          return ApiResponse<List<Event>>(
            success: false,
            message: response.message ?? 'Erreur lors du chargement de la page $currentPage.',
            data: _byCity(allEvents, city),
            statusCode: response.statusCode,
          );
        }
      }
      return ApiResponse<List<Event>>(success: true, data: _byCity(allEvents, city));
    } catch (e) {
      return ApiResponse<List<Event>>(
        success: false,
        message: 'Erreur réseau ou de format. Vérifiez votre connexion et réessayez.',
        data: _byCity(allEvents, city),
      );
    }
  }

  List<Event> _byCity(List<Event> events, String? city) {
    if (city == null || city.isEmpty) return events;
    final wanted = city.toLowerCase();
    return events.where((e) => e.cityName.toLowerCase() == wanted).toList();
  }

  /// Détail d'un événement, avec ses catégories de billets. Chaque appel compte une vue côté serveur.
  Future<ApiResponse<Event>> getEventDetails(String uuid) {
    return _request<Event>(
      '/api/events/${Uri.encodeComponent(uuid)}',
      fromJson: (json) => Event.fromJson(json as Map<String, dynamic>),
    );
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

  // --- Commandes (ticket-service) ---

  /// Réserve tout le panier dans UNE commande. Avec une session : commande du compte ;
  /// sans session : commande invité (téléphone obligatoire, 5 billets au plus), avec son jeton.
  Future<ApiResponse<Reservation>> reserve({
    required int eventId,
    required List<CartItem> items,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required bool guest,
  }) {
    final itemsJson = items.map((i) => i.toJson()).toList();
    if (guest) {
      return _request<Reservation>(
        '/api/tickets/guest/reserve',
        method: 'POST',
        body: {
          'eventId': eventId,
          'items': itemsJson,
          'phone': phoneDigits(phone),
          if (email != null && email.isNotEmpty) 'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'source': 'mobile',
        },
        fromJson: (json) {
          final map = json as Map<String, dynamic>;
          final reservation = map['reservation'] as Map<String, dynamic>;
          return Reservation(
            order: OrderAccess(map['orderId'] as String, guestToken: map['accessToken'] as String),
            tickets: _tickets(reservation['tickets']),
            total: (reservation['totalAmount'] as num?)?.toDouble() ?? 0,
          );
        },
      );
    }
    return _request<Reservation>(
      '/api/tickets/reserve',
      method: 'POST',
      body: {
        'eventId': eventId,
        'items': itemsJson,
        'userPhone': phoneDigits(phone),
        if (email != null && email.isNotEmpty) 'userEmail': email,
        'userFirstName': firstName,
        'userLastName': lastName,
        'source': 'mobile',
      },
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return Reservation(
          order: OrderAccess(map['orderId'] as String),
          tickets: _tickets(map['tickets']),
          total: (map['totalAmount'] as num?)?.toDouble() ?? 0,
        );
      },
    );
  }

  /// Billets d'une commande (avec compte, ou avec le jeton invité)
  Future<ApiResponse<List<EventTicket>>> getOrder(OrderAccess order) {
    final path = order.isGuest
        ? '/api/tickets/guest/orders/${Uri.encodeComponent(order.orderId)}'
        : '/api/tickets/order/${Uri.encodeComponent(order.orderId)}';
    return _request<List<EventTicket>>(path, headers: _guestHeaders(order), fromJson: _tickets);
  }

  /// Lance le paiement Mobile Money des billets réservés de la commande
  Future<ApiResponse<Map<String, dynamic>>> payOrder(OrderAccess order, String method, String phone) async {
    final apiMethod = apiPaymentMethods[method] ?? method;
    if (order.isGuest) {
      // Sans compte, le paiement part toujours du numéro de la commande (vérifié côté serveur)
      return _request(
        '/api/tickets/guest/orders/${Uri.encodeComponent(order.orderId)}/purchase',
        method: 'POST',
        body: {'paymentMethod': apiMethod},
        headers: _guestHeaders(order),
        fromJson: (json) => json as Map<String, dynamic>,
      );
    }
    // L'achat attend les id numériques des billets RESERVED : on relit la commande brute
    final raw = await _request<List<dynamic>>(
      '/api/tickets/order/${Uri.encodeComponent(order.orderId)}',
      fromJson: (json) => json as List<dynamic>,
    );
    if (!raw.success || raw.data == null) {
      return ApiResponse(success: false, message: raw.message, statusCode: raw.statusCode);
    }
    final ticketIds = raw.data!
        .whereType<Map<String, dynamic>>()
        .where((t) => t['status'] == 'RESERVED')
        .map((t) => t['id'])
        .toList();
    return _request(
      '/api/tickets/purchase',
      method: 'POST',
      body: {'ticketIds': ticketIds, 'paymentMethod': apiMethod, 'mobileMoneyNumber': phoneDigits(phone)},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Uint8List>> downloadOrderPdf(OrderAccess order) {
    final path = order.isGuest
        ? '/api/tickets/guest/orders/${Uri.encodeComponent(order.orderId)}/download'
        : '/api/tickets/order/${Uri.encodeComponent(order.orderId)}/download';
    return _download(path, headers: _guestHeaders(order));
  }

  /// Rattache à son compte une commande passée sans compte (jeton de la commande requis)
  Future<ApiResponse<List<EventTicket>>> claimGuestOrder(OrderAccess order) {
    return _request<List<EventTicket>>(
      '/api/tickets/order/${Uri.encodeComponent(order.orderId)}/claim-guest',
      method: 'POST',
      headers: _guestHeaders(order),
      fromJson: _tickets,
    );
  }

  // --- Billets du compte (ticket-service, JWT) ---

  Future<ApiResponse<List<EventTicket>>> getMyTickets() async {
    final List<EventTicket> all = [];
    for (var page = 0; page < 20; page++) {
      final response = await _request<Map<String, dynamic>>(
        '/api/tickets/my-tickets?page=$page&size=100&sortBy=createdAt&sortDirection=DESC',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      if (!response.success || response.data == null) {
        return ApiResponse(success: false, message: response.message, statusCode: response.statusCode, data: all);
      }
      all.addAll(_tickets(response.data!['content']));
      if (response.data!['last'] == true) break;
    }
    return ApiResponse(success: true, data: all);
  }

  /// Détail d'un billet du compte, avec son QR code
  Future<ApiResponse<EventTicket>> getTicket(String uuid) {
    return _request<EventTicket>(
      '/api/tickets/${Uri.encodeComponent(uuid)}',
      fromJson: (json) => EventTicket.fromApi(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Uint8List>> downloadTicketPdf(String uuid) {
    return _download('/api/tickets/${Uri.encodeComponent(uuid)}/download');
  }

  // --- Billets sans compte retrouvés par code (ticket-service) ---

  Future<ApiResponse<Map<String, dynamic>>> requestGuestAccessCode(String phone) {
    return _request(
      '/api/tickets/guest/access/request',
      method: 'POST',
      body: {'phone': phoneDigits(phone)},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Code valide : session de 30 minutes (jeton à envoyer dans X-Guest-Session)
  Future<ApiResponse<String>> verifyGuestAccessCode(String phone, String code) {
    return _request<String>(
      '/api/tickets/guest/access/verify',
      method: 'POST',
      body: {'phone': phoneDigits(phone), 'code': code},
      fromJson: (json) => (json as Map<String, dynamic>)['sessionToken'] as String,
    );
  }

  Future<ApiResponse<List<EventTicket>>> getGuestSessionTickets(String sessionToken) {
    return _request<List<EventTicket>>(
      '/api/tickets/guest/access/tickets',
      headers: {guestSessionHeader: sessionToken},
      fromJson: _tickets,
    );
  }

  Future<ApiResponse<Uint8List>> downloadGuestSessionTicketPdf(String sessionToken, String uuid) {
    return _download(
      '/api/tickets/guest/access/tickets/${Uri.encodeComponent(uuid)}/download',
      headers: {guestSessionHeader: sessionToken},
    );
  }

  // --- Utilitaires ---

  Map<String, String>? _guestHeaders(OrderAccess order) =>
      order.isGuest ? {guestTokenHeader: order.guestToken!} : null;

  static List<EventTicket> _tickets(dynamic json) => (json is List ? json : const [])
      .whereType<Map<String, dynamic>>()
      .map((t) => EventTicket.fromApi(t))
      .toList();
}

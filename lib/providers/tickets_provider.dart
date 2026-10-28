import 'package:flutter/material.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/guest_orders_store.dart';
import 'package:myapp/services/session_store.dart';

/// Billets de l'utilisateur, lus dans ticket-service :
/// - ceux du compte connecté (`/api/tickets/my-tickets`) ;
/// - ceux des commandes passées sans compte sur ce téléphone (jeton de chaque commande).
/// Seuls les billets payés (ou déjà scannés) sont des billets d'entrée ; les autres sont ignorés.
class TicketsProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<EventTicket> _tickets = [];
  bool _isLoading = false;
  String? _error;
  // Affiches des événements (le billet ne porte que l'id de l'événement)
  Map<int, String> _covers = {};
  // Connecté : commandes achetées sans compte sur ce téléphone, que l'on peut rattacher au compte
  int _claimableOrders = 0;

  TicketsProvider() {
    refresh();
  }

  List<EventTicket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get claimableOrders => _claimableOrders;

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final collected = <EventTicket>[];

    if (SessionStore.instance.hasSession) {
      final response = await _api.getMyTickets();
      collected.addAll(response.data ?? const []);
      if (!response.success) {
        _error = response.messageOr('Impossible de charger vos billets. Tirez pour réessayer.');
      }
    }

    var guestOrders = 0;
    for (final order in await GuestOrdersStore.instance.all()) {
      final response = await _api.getOrder(order.access);
      if (response.success) {
        guestOrders++;
        collected.addAll((response.data ?? const <EventTicket>[]).map((t) => t.enrich(guestToken: order.token)));
      } else if (response.statusCode == 403) {
        // Lien invalide (commande rattachée à un compte entre-temps) : on l'oublie
        await GuestOrdersStore.instance.remove(order.orderId);
      }
    }

    _claimableOrders = SessionStore.instance.hasSession ? guestOrders : 0;

    await _loadCovers();
    final seen = <String>{};
    _tickets = collected
        .where((t) => t.isValid && t.ticketUuid != null && seen.add(t.ticketUuid!))
        .map(_withCover)
        .toList();
    _isLoading = false;
    notifyListeners();
  }

  /// Rattache au compte connecté les commandes passées sans compte sur ce téléphone (avec leur jeton,
  /// comme sur le site). Renvoie le nombre de commandes rattachées, ou lève le message d'erreur.
  Future<int> claimGuestOrders() async {
    var claimed = 0;
    String? failure;
    for (final order in await GuestOrdersStore.instance.all()) {
      final response = await _api.claimGuestOrder(order.access);
      if (response.success || response.statusCode == 403) {
        // 403 : jeton déjà utilisé (commande rattachée entre-temps) : rien à garder
        await GuestOrdersStore.instance.remove(order.orderId);
        if (response.success) claimed++;
      } else {
        failure ??= response.messageOr("Le rattachement n'a pas abouti. Réessayez.");
      }
    }
    await refresh();
    if (failure != null) throw failure;
    return claimed;
  }

  Future<void> _loadCovers() async {
    if (_covers.isNotEmpty) return;
    final response = await _api.getEvents();
    _covers = {for (final e in response.data ?? const []) e.id: e.coverImageUrl};
  }

  EventTicket _withCover(EventTicket t) {
    final cover = t.eventId != null ? _covers[t.eventId] : null;
    return cover == null ? t : t.enrich(imagePath: cover);
  }
}

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

  TicketsProvider() {
    refresh();
  }

  List<EventTicket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

    for (final order in await GuestOrdersStore.instance.all()) {
      final response = await _api.getOrder(order.access);
      if (response.success) {
        collected.addAll((response.data ?? const <EventTicket>[]).map((t) => t.enrich(guestToken: order.token)));
      } else if (response.statusCode == 403) {
        // Lien invalide (commande rattachée à un compte entre-temps) : on l'oublie
        await GuestOrdersStore.instance.remove(order.orderId);
      }
    }

    await _loadCovers();
    final seen = <String>{};
    _tickets = collected
        .where((t) => t.isValid && t.ticketUuid != null && seen.add(t.ticketUuid!))
        .map(_withCover)
        .toList();
    _isLoading = false;
    notifyListeners();
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

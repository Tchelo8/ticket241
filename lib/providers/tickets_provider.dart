import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Billets achetés — persistés localement sur le même modèle que
/// FavoritesProvider (aucun endpoint "mes billets" n'existe côté API :
/// le parcours d'achat est simulé, README "Paiement (Checkout)").
class TicketsProvider with ChangeNotifier {
  List<EventTicket> _tickets = [];
  static const _ticketsKey = 'purchased_tickets';

  TicketsProvider() {
    _loadTickets();
  }

  List<EventTicket> get tickets => _tickets;

  void addTickets(List<EventTicket> newTickets) {
    _tickets = [..._tickets, ...newTickets];
    _saveTickets();
    notifyListeners();
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsString = prefs.getString(_ticketsKey);
    if (ticketsString != null) {
      try {
        final List<dynamic> ticketsJson = json.decode(ticketsString);
        _tickets = ticketsJson.map((json) => EventTicket.fromJson(json)).toList();
      } catch (e) {
        await prefs.remove(_ticketsKey);
        _tickets = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsJson = _tickets.map((t) => t.toJson()).toList();
    await prefs.setString(_ticketsKey, json.encode(ticketsJson));
  }
}

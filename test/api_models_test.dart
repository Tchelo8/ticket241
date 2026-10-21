import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:myapp/models/order_model.dart';
import 'package:myapp/models/ticket_category_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/session_store.dart';

/// JWT factice : seul le champ `exp` compte ici (la signature n'est vérifiée que par le serveur)
String jwtExpiringAt(DateTime expiry) {
  String part(Map<String, dynamic> json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part({'sub': '074123456', 'exp': expiry.millisecondsSinceEpoch ~/ 1000})}.signature';
}

Map<String, dynamic> apiTicket({String status = 'PAID', String? paymentStatus, String? qrCode = 'uuid-1|TKT|jeton'}) => {
      'id': 1,
      'uuid': 'uuid-1',
      'ticketNumber': 'TKT-2026-ABCDEFGHJK',
      'qrCode': qrCode,
      'orderId': 'order-1',
      'eventId': 7,
      'eventName': 'Nuit du Jazz',
      'eventStartDate': '2099-12-20T20:00:00',
      'eventVenueName': 'Institut Français',
      'eventVenueCityName': 'Libreville',
      'ticketCategoryName': 'VIP',
      'finalPrice': 15750,
      'status': status,
      'paymentStatus': paymentStatus,
    };

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR', null));

  group('Session (JWT)', () {
    test('un JWT encore valide n\'est pas expiré', () {
      final token = jwtExpiringAt(DateTime.now().add(const Duration(hours: 2)));
      expect(SessionStore.isExpired(token), isFalse);
      expect(SessionStore.expiryOf(token)!.isAfter(DateTime.now()), isTrue);
    });

    test('un JWT expiré ou illisible compte comme expiré', () {
      expect(SessionStore.isExpired(jwtExpiringAt(DateTime.now().subtract(const Duration(minutes: 1)))), isTrue);
      expect(SessionStore.isExpired('pas-un-jwt'), isTrue);
    });
  });

  group('Billets de l\'API', () {
    test('convertit un billet de ticket-service, avec son vrai QR code', () {
      final ticket = EventTicket.fromApi(apiTicket());
      expect(ticket.ticketUuid, 'uuid-1');
      expect(ticket.reference, 'TKT-2026-ABCDEFGHJK');
      expect(ticket.qrCode, 'uuid-1|TKT|jeton');
      expect(ticket.location, 'Institut Français, Libreville');
      expect(ticket.status, 'Payé');
      expect(ticket.price, 15750);
      expect(ticket.isValid, isTrue);
      expect(ticket.isUpcoming, isTrue);
    });

    test('un billet réservé non payé n\'est pas un billet d\'entrée', () {
      expect(EventTicket.fromApi(apiTicket(status: 'RESERVED')).isValid, isFalse);
    });

    test('garde le jeton de sa commande sans compte', () {
      final ticket = EventTicket.fromApi(apiTicket()).enrich(guestToken: 'secret', imagePath: 'affiche.jpg');
      expect(ticket.guestToken, 'secret');
      expect(ticket.imagePath, 'affiche.jpg');
      expect(ticket.qrCode, 'uuid-1|TKT|jeton');
    });
  });

  group('Suivi d\'une commande', () {
    List<EventTicket> tickets(List<Map<String, dynamic>> raw) => raw.map(EventTicket.fromApi).toList();

    test('payée seulement quand tous ses billets le sont', () {
      expect(orderOutcomeOf(tickets([apiTicket(), apiTicket()])), OrderOutcome.paid);
      expect(orderOutcomeOf(tickets([apiTicket(), apiTicket(status: 'RESERVED', paymentStatus: 'PROCESSING')])),
          OrderOutcome.reserved);
    });

    test('refusée, expirée ou encore en cours de réservation', () {
      expect(orderOutcomeOf(tickets([apiTicket(status: 'RESERVED', paymentStatus: 'FAILED')])), OrderOutcome.failed);
      expect(orderOutcomeOf(tickets([apiTicket(status: 'EXPIRED')])), OrderOutcome.expired);
      expect(orderOutcomeOf(tickets([apiTicket(status: 'PENDING')])), OrderOutcome.pending);
      expect(orderOutcomeOf(const []), OrderOutcome.pending);
    });
  });

  group('Catégories de billets', () {
    test('seules les catégories actives, dans l\'ordre de l\'organisateur', () {
      final categories = TicketCategory.listFrom([
        {'id': 2, 'name': 'VIP', 'price': 25000, 'displayOrder': 2, 'isActive': true, 'availableSeats': 3, 'maxTicketsPerOrder': 4},
        {'id': 1, 'name': 'Standard', 'price': 10000, 'displayOrder': 1, 'isActive': true, 'availableSeats': 50},
        {'id': 3, 'name': 'Archivé', 'price': 1, 'displayOrder': 0, 'isActive': false},
      ]);
      expect(categories.map((c) => c.name), ['Standard', 'VIP']);
      expect(categories[1].maxSelectable, 3); // 3 places restantes < 4 par commande
      expect(categories[0].maxSelectable, 10); // pas de maximum : 10 par défaut
    });

    test('une catégorie épuisée', () {
      final soldOut = TicketCategory.fromJson({'id': 1, 'name': 'VIP', 'price': 1, 'hasAvailableSeats': false});
      expect(soldOut.soldOut, isTrue);
    });
  });

  test('le panier part en lignes catégorie + quantité', () {
    expect(const CartItem(12, 2).toJson(), {'ticketCategoryId': 12, 'quantity': 2});
    expect(phoneDigits('074 12-34.56'), '074123456');
  });
}

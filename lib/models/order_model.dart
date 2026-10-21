import 'package:myapp/models/ticket_model.dart';

/// Accès à une commande : avec un compte (JWT de la session) ou sans compte grâce au jeton de la
/// commande (`guestToken`, donné une seule fois à la réservation ; le serveur n'en garde que le hash).
class OrderAccess {
  final String orderId;
  final String? guestToken;

  const OrderAccess(this.orderId, {this.guestToken});

  bool get isGuest => guestToken != null;
}

/// Réponse d'une réservation (le panier entier = une commande).
class Reservation {
  final OrderAccess order;
  final List<EventTicket> tickets;
  final double total;

  Reservation({required this.order, required this.tickets, required this.total});
}

/// Une ligne du panier : X billets d'une catégorie.
class CartItem {
  final int ticketCategoryId;
  final int quantity;

  const CartItem(this.ticketCategoryId, this.quantity);

  Map<String, dynamic> toJson() => {'ticketCategoryId': ticketCategoryId, 'quantity': quantity};
}

/// Où en est une commande, d'après ses billets.
enum OrderOutcome { pending, reserved, paid, failed, expired }

OrderOutcome orderOutcomeOf(List<EventTicket> tickets) {
  if (tickets.isEmpty) return OrderOutcome.pending;
  if (tickets.every((t) => t.apiStatus == 'PAID' || t.apiStatus == 'USED')) return OrderOutcome.paid;
  if (tickets.any((t) => t.paymentStatus == 'FAILED')) return OrderOutcome.failed;
  if (tickets.any((t) => t.apiStatus == 'EXPIRED' || t.apiStatus == 'CANCELLED')) return OrderOutcome.expired;
  if (tickets.any((t) => t.apiStatus == 'PENDING')) return OrderOutcome.pending;
  return OrderOutcome.reserved;
}

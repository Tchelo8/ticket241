import 'package:intl/intl.dart';

/// Billet affiché par l'application. Deux usages :
/// - une ligne du panier (avant achat) : `categoryId` + `ticketCount` + `price` ;
/// - un billet émis par ticket-service (`EventTicket.fromApi`) : un billet = une place, avec son
///   uuid, son numéro, son QR code (contenu exact scanné à l'entrée) et son statut.
class EventTicket {
  final String imagePath;
  final String eventName;
  final String location;
  final String date;
  final String time;
  final String status; // libellé affiché : "Payé", "Utilisé"…
  final int ticketCount;
  final int daysLeft;
  final bool isUpcoming;
  final double price;
  final String reference;
  final DateTime eventStartDate;

  // Panier : catégorie de billet réservée
  final int? categoryId;

  // Billet émis par l'API
  final String? ticketUuid;
  final String? qrCode;
  final String? orderId;
  final String? apiStatus; // PENDING, RESERVED, PAID, USED, CANCELLED, EXPIRED, REFUNDED
  final String? paymentStatus; // PENDING, PROCESSING, COMPLETED, FAILED…
  final int? eventId;
  final String? categoryName;
  final DateTime? expiresAt;
  // Billet d'une commande sans compte : jeton de la commande (pour son PDF)
  final String? guestToken;

  EventTicket({
    required this.imagePath,
    required this.eventName,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.ticketCount,
    required this.daysLeft,
    required this.isUpcoming,
    required this.price,
    required this.reference,
    required this.eventStartDate,
    this.categoryId,
    this.ticketUuid,
    this.qrCode,
    this.orderId,
    this.apiStatus,
    this.paymentStatus,
    this.eventId,
    this.categoryName,
    this.expiresAt,
    this.guestToken,
  });

  /// Billet payé ou déjà scanné : un vrai billet d'entrée
  bool get isValid => apiStatus == 'PAID' || apiStatus == 'USED';

  /// Complète un billet de l'API : affiche de l'événement et, sans compte, jeton de sa commande
  EventTicket enrich({String? imagePath, String? guestToken}) => EventTicket(
        imagePath: imagePath ?? this.imagePath,
        eventName: eventName,
        location: location,
        date: date,
        time: time,
        status: status,
        ticketCount: ticketCount,
        daysLeft: daysLeft,
        isUpcoming: isUpcoming,
        price: price,
        reference: reference,
        eventStartDate: eventStartDate,
        categoryId: categoryId,
        ticketUuid: ticketUuid,
        qrCode: qrCode,
        orderId: orderId,
        apiStatus: apiStatus,
        paymentStatus: paymentStatus,
        eventId: eventId,
        categoryName: categoryName,
        expiresAt: expiresAt,
        guestToken: guestToken ?? this.guestToken,
      );

  EventTicket copyWith({int? ticketCount}) => EventTicket(
        imagePath: imagePath,
        eventName: eventName,
        location: location,
        date: date,
        time: time,
        status: status,
        ticketCount: ticketCount ?? this.ticketCount,
        daysLeft: daysLeft,
        isUpcoming: isUpcoming,
        price: price,
        reference: reference,
        eventStartDate: eventStartDate,
        categoryId: categoryId,
        ticketUuid: ticketUuid,
        qrCode: qrCode,
        orderId: orderId,
        apiStatus: apiStatus,
        paymentStatus: paymentStatus,
        eventId: eventId,
        categoryName: categoryName,
        expiresAt: expiresAt,
        guestToken: guestToken,
      );

  static const _statusLabels = {
    'PENDING': 'Réservation en cours',
    'RESERVED': 'En attente de paiement',
    'PAID': 'Payé',
    'USED': 'Utilisé',
    'CANCELLED': 'Annulé',
    'EXPIRED': 'Expiré',
    'REFUNDED': 'Remboursé',
  };

  /// Les dates de l'API sont sans fuseau : heure du Gabon (UTC+1, pas d'heure d'été)
  static DateTime? _serverDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    final hasZone = RegExp(r'([zZ]|[+-]\d\d:?\d\d)$').hasMatch(value);
    return DateTime.tryParse(hasZone ? value : '$value+01:00')?.toLocal();
  }

  /// Billet renvoyé par ticket-service (détail complet ou résumé de liste).
  /// `imagePath` : l'affiche de l'événement, que le billet ne contient pas (vide si inconnue).
  factory EventTicket.fromApi(Map<String, dynamic> json, {String imagePath = ''}) {
    final start = _serverDate(json['eventStartDate']) ?? DateTime.now();
    final apiStatus = json['status'] as String?;
    final venue = json['eventVenueName'] as String? ?? '';
    final city = json['eventVenueCityName'] as String? ?? '';
    final upcoming = apiStatus != 'USED' && start.isAfter(DateTime.now());
    return EventTicket(
      imagePath: imagePath,
      eventName: json['eventName'] as String? ?? 'Événement',
      location: [venue, city].where((s) => s.isNotEmpty).join(', '),
      date: DateFormat('dd MMMM yyyy', 'fr_FR').format(start),
      time: DateFormat('HH:mm', 'fr_FR').format(start),
      status: _statusLabels[apiStatus] ?? (apiStatus ?? ''),
      ticketCount: 1,
      daysLeft: start.difference(DateTime.now()).inDays,
      isUpcoming: upcoming,
      price: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      reference: json['ticketNumber'] as String? ?? '',
      eventStartDate: start,
      ticketUuid: json['uuid'] as String?,
      qrCode: json['qrCode'] as String?,
      orderId: json['orderId'] as String?,
      apiStatus: apiStatus,
      paymentStatus: json['paymentStatus'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      categoryName: json['ticketCategoryName'] as String?,
      expiresAt: _serverDate(json['expirationDate']),
    );
  }
}

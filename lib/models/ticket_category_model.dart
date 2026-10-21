/// Catégorie de billet d'un événement (Standard, VIP…), telle que renvoyée par event-service
/// dans le détail d'un événement (`ticketCategories`).
class TicketCategory {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? benefits;
  final int? availableSeats;
  final int? maxTicketsPerOrder;
  final bool isActive;
  final bool hasAvailableSeats;
  final int displayOrder;

  TicketCategory({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.benefits,
    this.availableSeats,
    this.maxTicketsPerOrder,
    required this.isActive,
    required this.hasAvailableSeats,
    required this.displayOrder,
  });

  factory TicketCategory.fromJson(Map<String, dynamic> json) => TicketCategory(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? 'Billet',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        description: json['description'] as String?,
        benefits: json['benefits'] as String?,
        availableSeats: (json['availableSeats'] as num?)?.toInt(),
        maxTicketsPerOrder: (json['maxTicketsPerOrder'] as num?)?.toInt(),
        isActive: json['isActive'] != false,
        hasAvailableSeats: json['hasAvailableSeats'] != false,
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      );

  bool get soldOut => !hasAvailableSeats || (availableSeats != null && availableSeats! <= 0);

  /// Quantité maximale sélectionnable : maximum par commande et places restantes
  int get maxSelectable {
    var max = maxTicketsPerOrder ?? 10;
    if (availableSeats != null && availableSeats! < max) max = availableSeats!;
    return max < 0 ? 0 : max;
  }

  /// Catégories actives d'un événement, dans l'ordre d'affichage choisi par l'organisateur
  static List<TicketCategory> listFrom(List<dynamic> raw) {
    final categories = raw
        .whereType<Map<String, dynamic>>()
        .map(TicketCategory.fromJson)
        .where((c) => c.isActive)
        .toList();
    categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return categories;
  }
}

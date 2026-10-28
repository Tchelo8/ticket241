/// Alertes e-mail du compte (notification-service), mêmes réglages que sur le site.
/// Valeur absente côté serveur : billets et rappels activés, offres désactivées.
class EmailAlerts {
  final bool ticketUpdates;
  final bool eventReminders;
  final bool promotions;

  const EmailAlerts({required this.ticketUpdates, required this.eventReminders, required this.promotions});

  factory EmailAlerts.fromJson(Map<String, dynamic> json) => EmailAlerts(
        ticketUpdates: json['emailTicketUpdates'] != false,
        eventReminders: json['emailEventReminders'] != false,
        promotions: json['emailPromotions'] == true,
      );

  Map<String, dynamic> toJson() => {
        'emailTicketUpdates': ticketUpdates,
        'emailEventReminders': eventReminders,
        'emailPromotions': promotions,
      };

  EmailAlerts copyWith({bool? ticketUpdates, bool? eventReminders, bool? promotions}) => EmailAlerts(
        ticketUpdates: ticketUpdates ?? this.ticketUpdates,
        eventReminders: eventReminders ?? this.eventReminders,
        promotions: promotions ?? this.promotions,
      );
}

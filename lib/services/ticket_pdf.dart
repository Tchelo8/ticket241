import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:myapp/models/order_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/services/api_service.dart';

/// Télécharge le PDF officiel d'un billet (généré par ticket-service, avec le vrai QR code)
/// et l'ouvre dans le lecteur PDF du téléphone. Renvoie un message d'erreur, ou null si tout va bien.
/// Billet d'une commande sans compte : le PDF de la commande entière (seul PDF accessible avec son jeton).
Future<String?> openTicketPdf(EventTicket ticket, {ApiService? api, String? guestSession}) async {
  final service = api ?? ApiService();
  final uuid = ticket.ticketUuid;
  if (uuid == null) return 'Billet introuvable.';

  final ApiResponse<Uint8List> response;
  if (guestSession != null) {
    response = await service.downloadGuestSessionTicketPdf(guestSession, uuid);
  } else if (ticket.guestToken != null && ticket.orderId != null) {
    response = await service.downloadOrderPdf(OrderAccess(ticket.orderId!, guestToken: ticket.guestToken));
  } else {
    response = await service.downloadTicketPdf(uuid);
  }
  if (!response.success || response.data == null) {
    return response.messageOr('Le téléchargement du PDF a échoué. Réessayez.');
  }

  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/billet-${ticket.reference.isNotEmpty ? ticket.reference : uuid}.pdf');
    await file.writeAsBytes(response.data!, flush: true);
    final result = await OpenFilex.open(file.path, type: 'application/pdf');
    if (result.type != ResultType.done) {
      return "Aucune application ne peut ouvrir le PDF sur ce téléphone.";
    }
    return null;
  } catch (_) {
    return "Le PDF n'a pas pu être enregistré sur le téléphone.";
  }
}

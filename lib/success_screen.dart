import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/checkout_screen.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

class SuccessScreen extends StatelessWidget {
  final Event? event;
  final double? amount;
  final PaymentMethod? method;
  final List<EventTicket>? tickets;

  const SuccessScreen({super.key, this.event, this.amount, this.method, this.tickets});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final methodName = method == PaymentMethod.moov ? 'Moov Money' : 'Airtel Money';
    final reference = (tickets != null && tickets!.isNotEmpty) ? tickets!.first.reference : 'TK241-0000-LBV';
    final ticketCount = tickets?.fold<int>(0, (sum, t) => sum + t.ticketCount) ?? 0;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset('assets/animations/Success.json', repeat: false, fit: BoxFit.contain),
                  ),
                  Positioned(
                    top: -6,
                    right: 18,
                    child: Icon(PhosphorIconsFill.circle, size: 10, color: const Color(0xFFFF90B1)),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 12,
                    child: Icon(PhosphorIconsFill.circle, size: 7, color: c.ink3),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Paiement confirmé', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 34)),
              const SizedBox(height: 10),
              Text(
                '${amount != null ? amount!.toStringAsFixed(0) : '0'} FCFA débités via $methodName. Un SMS de confirmation arrive dans un instant.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5, color: c.ink2),
              ),
              const SizedBox(height: 24),
              if (event != null) _buildTicketCard(context, reference, ticketCount),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/app'),
                  child: const Text('Voir mes billets'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/app'),
                  child: const Text('Retour à l\'accueil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, String reference, int ticketCount) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.line, width: 1),
        boxShadow: context.tokens.shadows.sh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(event!.coverImageUrl, width: 62, height: 62, fit: BoxFit.cover,
                    errorBuilder: (context, __, ___) => Container(width: 62, height: 62, color: c.surf)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BILLET ÉMIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1, color: c.acc)),
                    const SizedBox(height: 2),
                    Text(event!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink)),
                    Text('${DateFormat('d MMM yyyy', 'fr_FR').format(event!.startDate)} · $ticketCount billet${ticketCount > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 12.5, color: c.ink2)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(height: 1, color: c.line),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(reference, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: c.ink, fontFeatures: const [FontFeature.tabularFigures()])),
              Text('Voir le QR code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.acc)),
            ],
          ),
        ],
      ),
    );
  }
}

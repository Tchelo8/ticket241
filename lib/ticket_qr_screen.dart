import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/dashed_line.dart';

/// Billet en détail (README écran 15).
class TicketQrScreen extends StatelessWidget {
  final EventTicket ticket;
  const TicketQrScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.surf,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(onTap: () => context.pop(), child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink)),
                  Text('Votre billet', style: Theme.of(context).textTheme.titleLarge),
                  Icon(PhosphorIconsRegular.shareNetwork, color: c.ink),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: 12),
                child: Column(
                  children: [
                    _buildTicketCard(context),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/pdf-viewer'),
                              icon: const Icon(PhosphorIconsRegular.downloadSimple, size: 18),
                              label: const Text('PDF'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: Icon(PhosphorIconsRegular.mapTrifold, size: 18, color: c.acc),
                              label: Text('Itinéraire', style: TextStyle(color: c.acc)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: c.line2, width: 1), borderRadius: BorderRadius.circular(AppRadii.card)),
                      child: Row(
                        children: [
                          Icon(PhosphorIconsRegular.shieldCheck, size: 20, color: c.acc),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Annulation gratuite jusqu\'à 48 h avant l\'événement.', style: TextStyle(fontSize: 12.5, color: c.ink2)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: context.tokens.shadows.shm,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TICKET241 · ENTRÉE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: c.acc)),
                const SizedBox(height: 8),
                Text(ticket.eventName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: c.ink)),
                const SizedBox(height: 6),
                Text('${ticket.date} · ${ticket.time}', style: TextStyle(fontSize: 13.5, color: c.ink2)),
                Text(ticket.location, style: TextStyle(fontSize: 13.5, color: c.ink2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DashedLine(color: c.line2),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: QrImageView(data: ticket.reference, size: 180, backgroundColor: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(ticket.reference,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 2, color: c.ink, fontFeatures: const [FontFeature.tabularFigures()])),
                const SizedBox(height: 4),
                Text('Présentez ce code à l\'entrée', style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line, width: 1))),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(child: _footerColumn(context, 'TYPE', ticket.eventName)),
                Container(width: 1, height: 32, color: c.line),
                Expanded(child: _footerColumn(context, 'PLACES', '${ticket.ticketCount}')),
                Container(width: 1, height: 32, color: c.line),
                Expanded(child: _footerColumn(context, 'PAYÉ', '${(ticket.price * ticket.ticketCount).toStringAsFixed(0)} FCFA')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(BuildContext context, String label, String value) {
    final c = context.appColors;
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 9.5, letterSpacing: 1, color: c.ink3)),
        const SizedBox(height: 4),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink)),
      ],
    );
  }
}

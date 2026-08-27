import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/providers/tickets_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/app_bottom_sheet.dart';
import 'package:myapp/widgets/empty_state_template.dart';
import 'package:myapp/widgets/segmented_sliding_tabs.dart';
import 'package:myapp/widgets/themed_network_image.dart';
import 'package:myapp/widgets/ticket_notch_card.dart';

class TicketsScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const TicketsScreen({super.key, required this.onNavigate});

  @override
  TicketsScreenState createState() => TicketsScreenState();
}

class TicketsScreenState extends State<TicketsScreen> {
  int _tabIndex = 0;

  void _showOptions(EventTicket ticket, bool isUpcoming) {
    AppBottomSheet.show(
      context: context,
      kicker: 'Billet',
      title: ticket.eventName,
      maxHeightFraction: 0.32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: isUpcoming
            ? [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(PhosphorIconsRegular.arrowClockwise),
                  title: const Text('Commander à nouveau'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(PhosphorIconsRegular.xCircle, color: const Color(0xFFD6006C)),
                  title: const Text('Annuler la réservation', style: TextStyle(color: Color(0xFFD6006C))),
                  onTap: () => Navigator.pop(context),
                ),
              ]
            : [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(PhosphorIconsRegular.downloadSimple),
                  title: const Text('Télécharger le reçu'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(PhosphorIconsRegular.archive),
                  title: const Text('Archiver'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final tickets = context.watch<TicketsProvider>().tickets;
    final now = DateTime.now();
    final upcoming = tickets.where((t) => t.eventStartDate.isAfter(now)).toList();
    final past = tickets.where((t) => !t.eventStartDate.isAfter(now)).toList();
    final isUpcoming = _tabIndex == 0;
    final currentList = isUpcoming ? upcoming : past;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 12),
              child: Text('Mes billets', style: Theme.of(context).textTheme.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              child: SegmentedSlidingTabs(
                labels: const ['À venir', 'Passés'],
                selectedIndex: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.tIn,
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: currentList.isEmpty
                    ? _buildEmptyState(isUpcoming, key: ValueKey('empty-$isUpcoming'))
                    : ListView.builder(
                        key: ValueKey('list-$isUpcoming'),
                        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 24),
                        itemCount: currentList.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTicketCard(context, currentList[index], isUpcoming),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isUpcoming, {Key? key}) {
    return Center(
      key: key,
      child: EmptyStateTemplate(
        lottieAsset: 'assets/animations/Tickets.json',
        titleLine1: isUpcoming ? 'Aucun billet' : 'Rien dans les',
        titleLine2: isUpcoming ? 'à venir.' : 'archives.',
        body: 'Explorez les événements du moment pour trouver votre prochaine sortie.',
        primaryLabel: 'Explorer les événements',
        primaryIcon: PhosphorIconsRegular.compass,
        onPrimary: () => widget.onNavigate(1),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, EventTicket ticket, bool isUpcoming) {
    final c = context.appColors;
    return Opacity(
      opacity: isUpcoming ? 1 : 0.72,
      child: TicketNotchCard(
        backgroundColor: c.card,
        notchColor: c.bg,
        lineColor: c.line2,
        top: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
            border: Border.all(color: c.line, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.control),
                child: SizedBox(width: 74, height: 74, child: ThemedNetworkImage(url: ticket.imagePath)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isUpcoming ? c.accs : c.surf,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            isUpcoming ? 'PAYÉ' : 'UTILISÉ',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isUpcoming ? c.acc : c.ink2),
                          ),
                        ),
                        const Spacer(),
                        Text(ticket.reference, style: TextStyle(fontSize: 10.5, color: c.ink3, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.eventName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: c.ink)),
                    const SizedBox(height: 4),
                    Text('${ticket.date} · ${ticket.location}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: c.ink2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottom: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadii.card)),
            border: Border.all(color: c.line, width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text('${ticket.ticketCount} billet${ticket.ticketCount > 1 ? 's' : ''}', style: TextStyle(fontSize: 11.5, color: c.ink2)),
              ),
              if (isUpcoming) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Text('J-${ticket.eventStartDate.difference(DateTime.now()).inDays}', style: TextStyle(fontSize: 11.5, color: c.ink2)),
                ),
              ],
              const Spacer(),
              TextButton.icon(
                onPressed: isUpcoming ? () => context.push('/ticket-qr', extra: ticket) : () => _showOptions(ticket, isUpcoming),
                icon: Icon(isUpcoming ? PhosphorIconsRegular.qrCode : PhosphorIconsRegular.star, size: 17),
                label: Text(isUpcoming ? 'Voir le QR' : 'Laisser un avis'),
              ),
              GestureDetector(
                onTap: () => _showOptions(ticket, isUpcoming),
                child: Icon(PhosphorIconsRegular.dotsThreeVertical, size: 18, color: c.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/ticket_pdf.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/dashed_line.dart';

/// Billet en détail (README écran 15). Le QR code affiché est le contenu exact scanné à l'entrée
/// (donné par ticket-service) ; les listes ne le contiennent pas, il est alors relu dans le détail.
class TicketQrScreen extends StatefulWidget {
  final EventTicket ticket;
  /// Billet retrouvé par code (achat sans compte) : session ouverte pour son PDF
  final String? guestSession;

  const TicketQrScreen({super.key, required this.ticket, this.guestSession});

  @override
  State<TicketQrScreen> createState() => _TicketQrScreenState();
}

class _TicketQrScreenState extends State<TicketQrScreen> {
  final ApiService _api = ApiService();
  late EventTicket ticket = widget.ticket;
  bool _loadingQr = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    if ((ticket.qrCode == null || ticket.qrCode!.isEmpty) && ticket.ticketUuid != null && ticket.guestToken == null) {
      _loadQrCode();
    }
  }

  Future<void> _loadQrCode() async {
    setState(() => _loadingQr = true);
    final response = await _api.getTicket(ticket.ticketUuid!);
    if (!mounted) return;
    setState(() {
      if (response.success && response.data != null) {
        ticket = response.data!.enrich(imagePath: widget.ticket.imagePath);
      }
      _loadingQr = false;
    });
  }

  Future<void> _openPdf() async {
    setState(() => _downloading = true);
    final error = await openTicketPdf(ticket, api: _api, guestSession: widget.guestSession);
    if (!mounted) return;
    setState(() => _downloading = false);
    if (error != null) Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_LONG);
  }

  Future<void> _openMaps() async {
    final query = Uri.encodeComponent('${ticket.location}, Gabon');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: "Impossible d'ouvrir la carte.");
    }
  }

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
                  const SizedBox(width: 24),
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
                              onPressed: _downloading || !ticket.isValid ? null : _openPdf,
                              icon: _downloading
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(PhosphorIconsRegular.downloadSimple, size: 18),
                              label: const Text('PDF'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: ticket.location.isEmpty ? null : _openMaps,
                              icon: Icon(PhosphorIconsRegular.mapTrifold, size: 18, color: c.acc),
                              label: Text('Itinéraire', style: TextStyle(color: c.acc)),
                            ),
                          ),
                        ),
                      ],
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
    final qr = ticket.qrCode;
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
                Text('TICKET241 · ${ticket.isValid ? 'ENTRÉE' : ticket.status.toUpperCase()}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: c.acc)),
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
                  width: 208,
                  height: 208,
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: _loadingQr
                      ? const Center(child: CircularProgressIndicator())
                      : ticket.isValid && qr != null && qr.isNotEmpty
                          ? QrImageView(data: qr, size: 180, backgroundColor: Colors.white)
                          : Center(
                              child: Text('QR code indisponible', textAlign: TextAlign.center, style: TextStyle(color: c.ink3)),
                            ),
                ),
                const SizedBox(height: 14),
                Text(ticket.reference,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 2, color: c.ink, fontFeatures: const [FontFeature.tabularFigures()])),
                const SizedBox(height: 4),
                Text(ticket.isValid ? 'Présentez ce code à l\'entrée' : 'Le QR code apparaît une fois le billet payé',
                    style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line, width: 1))),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(child: _footerColumn(context, 'CATÉGORIE', ticket.categoryName ?? '—')),
                Container(width: 1, height: 32, color: c.line),
                Expanded(child: _footerColumn(context, 'STATUT', ticket.status)),
                Container(width: 1, height: 32, color: c.line),
                Expanded(child: _footerColumn(context, 'PAYÉ', '${ticket.price.toStringAsFixed(0)} FCFA')),
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

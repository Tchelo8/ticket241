import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myapp/checkout_screen.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/providers/tickets_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/ussd_waiting_rings.dart';

/// Confirmation mobile money (USSD) — README écran 12. Attente réaliste de
/// la validation sur le téléphone, purement visuelle : bascule vers Succès
/// après 5,2 s comme dans le prototype (aucune API de paiement n'existe
/// côté backend à ce jour).
class UssdWaitingScreen extends StatefulWidget {
  final Event event;
  final double amount;
  final PaymentMethod method;
  final String phone;
  final List<EventTicket> tickets;

  const UssdWaitingScreen({
    super.key,
    required this.event,
    required this.amount,
    required this.method,
    required this.phone,
    required this.tickets,
  });

  @override
  State<UssdWaitingScreen> createState() => _UssdWaitingScreenState();
}

class _UssdWaitingScreenState extends State<UssdWaitingScreen> {
  static const _initialSeconds = 87;
  int _secondsLeft = _initialSeconds;
  Timer? _countdownTimer;
  Timer? _successTimer;

  Color get _providerColor => widget.method == PaymentMethod.moov ? const Color(0xFFE8622A) : const Color(0xFFE52329);
  String get _providerName => widget.method == PaymentMethod.moov ? 'Moov Money' : 'Airtel Money';
  String get _ussdCode => widget.method == PaymentMethod.moov ? '*555#' : '*150#';
  String get _logoAsset => widget.method == PaymentMethod.moov ? 'assets/images/mm.jpg' : 'assets/images/am.png';

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) setState(() => _secondsLeft--);
    });
    _successTimer = Timer(const Duration(milliseconds: 5200), () {
      if (!mounted) return;
      context.read<TicketsProvider>().addTickets(widget.tickets);
      context.go('/success', extra: {
        'event': widget.event,
        'amount': widget.amount,
        'method': widget.method,
        'tickets': widget.tickets,
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _successTimer?.cancel();
    super.dispose();
  }

  void _resend() {
    setState(() => _secondsLeft = _initialSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UssdWaitingRings(
                providerColor: _providerColor,
                logo: Image.asset(_logoAsset, width: 44, height: 44, fit: BoxFit.contain),
              ),
              const SizedBox(height: 28),
              Text(_providerName.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: _providerColor)),
              const SizedBox(height: 8),
              Text('Demande envoyée', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 31)),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 15, height: 1.5, color: c.ink2),
                  children: [
                    const TextSpan(text: 'Une notification de paiement de '),
                    TextSpan(text: '${widget.amount.toStringAsFixed(0)} FCFA', style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
                    const TextSpan(text: ' vient d\'être envoyée au '),
                    TextSpan(text: '+241 ${widget.phone}', style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(AppRadii.card)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(PhosphorIconsRegular.deviceMobile, size: 20, color: c.ink2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13, height: 1.5, color: c.ink2),
                          children: [
                            const TextSpan(text: 'Validez sur votre téléphone en saisissant votre code secret. Sans notification, composez '),
                            TextSpan(text: _ussdCode, style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
                            const TextSpan(text: ' puis suivez le menu.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PulsingDot(color: _providerColor),
                  const SizedBox(width: 8),
                  Text(
                    'En attente de confirmation · ${minutes.toString()}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 13, color: c.ink3, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 48, child: OutlinedButton(onPressed: _resend, child: const Text('Renvoyer la demande'))),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Annuler le paiement', style: TextStyle(color: c.ink3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1).animate(_controller),
      child: Container(width: 7, height: 7, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    );
  }
}

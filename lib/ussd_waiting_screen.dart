import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myapp/checkout_screen.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/order_model.dart';
import 'package:myapp/providers/tickets_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/ussd_waiting_rings.dart';

/// Confirmation mobile money (USSD) — README écran 12. La commande est relue toutes les 3 s :
/// billets payés → Succès ; paiement refusé ou délai dépassé (places libérées) → retour au
/// paiement avec le message. Le décompte suit l'échéance donnée par ticket-service.
class UssdWaitingScreen extends StatefulWidget {
  final Event event;
  final double amount;
  final PaymentMethod method;
  final String phone; // vide sans compte : la demande part au numéro de la commande
  final OrderAccess order;

  const UssdWaitingScreen({
    super.key,
    required this.event,
    required this.amount,
    required this.method,
    required this.phone,
    required this.order,
  });

  @override
  State<UssdWaitingScreen> createState() => _UssdWaitingScreenState();
}

class _UssdWaitingScreenState extends State<UssdWaitingScreen> {
  final ApiService _api = ApiService();
  DateTime? _deadline;
  int _secondsLeft = 0;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  bool _finished = false;

  Color get _providerColor => widget.method == PaymentMethod.moov ? const Color(0xFFE8622A) : const Color(0xFFE52329);
  String get _providerName => widget.method == PaymentMethod.moov ? 'Moov Money' : 'Airtel Money';
  String get _ussdCode => widget.method == PaymentMethod.moov ? '*555#' : '*150#';
  String get _logoAsset => widget.method == PaymentMethod.moov ? 'assets/images/mm.jpg' : 'assets/images/am.png';

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final deadline = _deadline;
      if (deadline == null || !mounted) return;
      final left = deadline.difference(DateTime.now()).inSeconds;
      setState(() => _secondsLeft = left < 0 ? 0 : left);
    });
    _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_finished) return;
    final response = await _api.getOrder(widget.order);
    final tickets = response.data;
    if (!mounted || _finished || !response.success || tickets == null) return;

    final deadlines = tickets.map((t) => t.expiresAt).whereType<DateTime>().toList()..sort();
    if (deadlines.isNotEmpty && _deadline == null) {
      setState(() {
        _deadline = deadlines.first;
        _secondsLeft = _deadline!.difference(DateTime.now()).inSeconds.clamp(0, 1 << 30);
      });
    }

    switch (orderOutcomeOf(tickets)) {
      case OrderOutcome.paid:
        _finished = true;
        context.read<TicketsProvider>().refresh();
        context.go('/success', extra: {
          'event': widget.event,
          'amount': widget.amount,
          'method': widget.method,
          'tickets': tickets,
          'order': widget.order,
        });
        break;
      case OrderOutcome.failed:
        _finished = true;
        context.pop("Le paiement $_providerName a été refusé. Aucun montant n'a été débité.");
        break;
      case OrderOutcome.expired:
        _finished = true;
        context.pop('La demande a expiré sans confirmation et les places ont été libérées. Vous pouvez recommencer.');
        break;
      case OrderOutcome.pending:
      case OrderOutcome.reserved:
        break;
    }
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
                    const TextSpan(text: ' vient d\'être envoyée '),
                    TextSpan(
                        text: widget.phone.isEmpty ? 'au numéro de la commande' : 'au +241 ${widget.phone}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
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
              // Pas d'annulation côté serveur pour une demande en cours : sans validation, elle expire
              // à l'échéance et les places sont libérées automatiquement
              Text('Sans validation avant la fin du décompte, la demande expire et vos places sont libérées.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: c.ink3)),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  _finished = true;
                  context.pop();
                },
                child: Text('Abandonner', style: TextStyle(color: c.ink3)),
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

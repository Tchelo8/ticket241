import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/models/email_alerts_model.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/session_store.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/toggle_switch.dart';

/// Alertes e-mail du compte, enregistrées par notification-service (mêmes réglages que sur le site).
/// Chaque interrupteur est enregistré aussitôt ; en cas d'échec, il revient à sa position.
class EmailAlertsScreen extends StatefulWidget {
  const EmailAlertsScreen({super.key});

  @override
  State<EmailAlertsScreen> createState() => _EmailAlertsScreenState();
}

class _EmailAlertsScreenState extends State<EmailAlertsScreen> {
  final ApiService _api = ApiService();
  final int? _accountId = SessionStore.instance.accountId;
  EmailAlerts? _alerts;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_accountId == null) {
      setState(() => _error = 'Reconnectez-vous pour gérer vos alertes.');
      return;
    }
    setState(() => _error = null);
    final response = await _api.getEmailAlerts(_accountId);
    if (!mounted) return;
    setState(() {
      _alerts = response.data;
      if (!response.success || response.data == null) {
        _error = response.messageOr('Alertes e-mail momentanément indisponibles.');
      }
    });
  }

  Future<void> _update(EmailAlerts next) async {
    final previous = _alerts;
    setState(() {
      _alerts = next;
      _saving = true;
    });
    final response = await _api.updateEmailAlerts(_accountId!, next);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (response.success && response.data != null) {
        _alerts = response.data;
      } else {
        _alerts = previous;
      }
    });
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.messageOr("Le réglage n'a pas pu être enregistré. Réessayez."))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final alerts = _alerts;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 32),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go('/app'),
                  child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink),
                ),
                const SizedBox(width: 14),
                Text('Alertes e-mail', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Choisissez les e-mails que vous recevez. Les réglages sont les mêmes sur l'application et sur le site.",
              style: TextStyle(fontSize: 14.5, height: 1.5, color: c.ink2),
            ),
            const SizedBox(height: 20),
            if (alerts == null && _error == null)
              const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
            else if (alerts == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_error!, style: TextStyle(fontSize: 14.5, color: c.ink2)),
                  const SizedBox(height: 12),
                  if (_accountId != null) OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
                ],
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: c.line, width: 1),
                ),
                child: Column(
                  children: [
                    _row(context, PhosphorIconsRegular.ticket, 'Mes billets par e-mail',
                        'Confirmation d\'achat et billets en PDF', alerts.ticketUpdates,
                        (v) => _update(alerts.copyWith(ticketUpdates: v))),
                    Divider(height: 1, color: c.line),
                    _row(context, PhosphorIconsRegular.alarm, 'Rappel avant l\'événement',
                        'La veille de chaque événement', alerts.eventReminders,
                        (v) => _update(alerts.copyWith(eventReminders: v))),
                    Divider(height: 1, color: c.line),
                    _row(context, PhosphorIconsRegular.megaphone, 'Nouveautés et offres',
                        'Événements et promotions Ticket241', alerts.promotions,
                        (v) => _update(alerts.copyWith(promotions: v))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, PhosphorIconData icon, String label, String hint, bool value, ValueChanged<bool> onChanged) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 21, color: c.acc),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 15.5, color: c.ink)),
                const SizedBox(height: 2),
                Text(hint, style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Un réglage à la fois : pas de second envoi tant que le premier n'a pas répondu
          ToggleSwitch(value: value, onChanged: _saving ? (_) {} : onChanged),
        ],
      ),
    );
  }
}

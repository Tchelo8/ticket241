import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

/// Billets achetés sans compte, retrouvés avec le numéro : un code part à l'e-mail donné lors d'un
/// achat payé, et ouvre une session de 30 minutes (gardée en mémoire, jamais enregistrée).
class RecoverTicketsScreen extends StatefulWidget {
  const RecoverTicketsScreen({super.key});

  @override
  State<RecoverTicketsScreen> createState() => _RecoverTicketsScreenState();
}

class _RecoverTicketsScreenState extends State<RecoverTicketsScreen> {
  final ApiService _api = ApiService();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  String? _sentMessage;
  String? _session;
  List<EventTicket> _tickets = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool get _phoneValid => phoneDigits(_phoneController.text).length >= 8;
  bool get _codeValid => RegExp(r'^\d{6}$').hasMatch(_codeController.text.trim());

  Future<void> _requestCode() async {
    if (!_phoneValid || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final response = await _api.requestGuestAccessCode(_phoneController.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (response.success) {
        _sentMessage = response.data?['message'] as String? ?? 'Code envoyé.';
        _codeController.clear();
      } else {
        _error = response.messageOr("La demande n'a pas abouti. Réessayez.");
      }
    });
  }

  Future<void> _verifyCode() async {
    if (!_codeValid || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final session = await _api.verifyGuestAccessCode(_phoneController.text, _codeController.text.trim());
    if (!mounted) return;
    if (!session.success || session.data == null) {
      setState(() {
        _busy = false;
        _error = session.messageOr('Code invalide ou expiré.');
      });
      return;
    }
    final tickets = await _api.getGuestSessionTickets(session.data!);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _session = session.data;
      _tickets = tickets.data ?? [];
      if (!tickets.success) _error = tickets.messageOr('Impossible de charger les billets.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenForm, 8, AppSpacing.screenForm, 32),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(onTap: () => context.pop(), child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink)),
            ),
            const SizedBox(height: 16),
            Text('Retrouver mes billets', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              _session == null
                  ? "Pour vos achats sans compte : saisissez le numéro utilisé pour payer. Un code vous est envoyé à l'e-mail donné lors de l'achat."
                  : 'Accès ouvert pendant 30 minutes. Téléchargez vos billets pour les garder.',
              style: TextStyle(fontSize: 14, height: 1.5, color: c.ink2),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(fontSize: 13.5, color: Color(0xFFD6006C))),
              const SizedBox(height: 12),
            ],
            if (_session == null) ..._buildCodeSteps(context) else ..._buildTickets(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCodeSteps(BuildContext context) {
    return [
      _field(context, controller: _phoneController, hint: '074 12 34 56', prefix: '+241 ', keyboardType: TextInputType.phone),
      const SizedBox(height: 12),
      SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _phoneValid && !_busy ? _requestCode : null,
          child: Text(_sentMessage == null ? 'Recevoir un code' : 'Renvoyer un code'),
        ),
      ),
      if (_sentMessage != null) ...[
        const SizedBox(height: 20),
        Text(_sentMessage!, style: TextStyle(fontSize: 13.5, height: 1.5, color: context.appColors.ink2)),
        const SizedBox(height: 12),
        _field(context, controller: _codeController, hint: 'Code à 6 chiffres', keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _codeValid && !_busy ? _verifyCode : null,
            child: const Text('Voir mes billets'),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildTickets(BuildContext context) {
    final c = context.appColors;
    if (_tickets.isEmpty) {
      return [Text('Aucun billet payé pour ce numéro.', style: TextStyle(color: c.ink2))];
    }
    return [
      for (final ticket in _tickets)
        Card(
          color: c.card,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(PhosphorIconsRegular.ticket, color: c.acc),
            title: Text(ticket.eventName, style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
            subtitle: Text('${ticket.date} · ${ticket.categoryName ?? ''} · ${ticket.reference}', style: TextStyle(color: c.ink2)),
            trailing: Icon(PhosphorIconsRegular.qrCode, color: c.acc),
            onTap: () => context.push('/ticket-qr', extra: {'ticket': ticket, 'guestSession': _session}),
          ),
        ),
    ];
  }

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    String? prefix,
    TextInputType? keyboardType,
  }) {
    final c = context.appColors;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: c.line2, width: 1),
      ),
      child: Row(
        children: [
          if (prefix != null) Text(prefix, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink2)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: AppFieldDecoration.bare(hintText: hint),
            ),
          ),
        ],
      ),
    );
  }
}

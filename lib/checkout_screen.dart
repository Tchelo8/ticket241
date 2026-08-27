import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/app_bottom_sheet.dart';
import 'package:myapp/widgets/quantity_selector.dart';
import 'package:myapp/widgets/themed_network_image.dart';

class CheckoutScreen extends StatefulWidget {
  final Event event;
  final List<EventTicket> tickets;

  const CheckoutScreen({
    super.key,
    required this.event,
    required this.tickets,
  });

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

enum PaymentMethod { airtel, moov, card }

class CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.airtel;
  bool _isProcessing = false;
  bool _agreedToTerms = false;
  late List<EventTicket> _localTickets;

  @override
  void initState() {
    super.initState();
    _localTickets = List.from(widget.tickets);
    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  double get _totalAmount => _localTickets.fold(0, (sum, item) => sum + (item.price * item.ticketCount));

  bool get _nameValid => _nameController.text.trim().length > 2;
  bool get _phoneValid => _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').length >= 8;
  bool get _canSubmit => _localTickets.isNotEmpty && _agreedToTerms && _nameValid && _phoneValid && !_isProcessing;

  void _changeTicketQty(EventTicket ticket, int newQty) {
    setState(() {
      final index = _localTickets.indexOf(ticket);
      if (newQty <= 0) {
        _localTickets.remove(ticket);
      } else if (index != -1) {
        _localTickets[index] = EventTicket(
          imagePath: ticket.imagePath,
          eventName: ticket.eventName,
          location: ticket.location,
          date: ticket.date,
          time: ticket.time,
          status: ticket.status,
          ticketCount: newQty,
          daysLeft: ticket.daysLeft,
          isUpcoming: ticket.isUpcoming,
          price: ticket.price,
          reference: ticket.reference,
          eventStartDate: ticket.eventStartDate,
        );
      }
      if (_localTickets.isEmpty) context.pop();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_canSubmit) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    await context.push('/ussd-waiting', extra: {
      'event': widget.event,
      'amount': _totalAmount,
      'method': _selectedPaymentMethod,
      'phone': _phoneController.text,
      'tickets': _localTickets,
    });
    if (mounted) setState(() => _isProcessing = false);
  }

  void _showTicketOptions(EventTicket ticket) {
    AppBottomSheet.show(
      context: context,
      kicker: 'Billet',
      title: ticket.eventName,
      maxHeightFraction: 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(PhosphorIconsRegular.trash, color: const Color(0xFFD6006C)),
            title: const Text('Retirer du ticket', style: TextStyle(color: Color(0xFFD6006C))),
            onTap: () {
              Navigator.pop(context);
              _changeTicketQty(ticket, 0);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(PhosphorIconsRegular.x),
            title: const Text('Annuler'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 16, AppSpacing.screen, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventSummary(context),
                    const SizedBox(height: 24),
                    _buildTicketsSection(context),
                    const SizedBox(height: 24),
                    _buildContactSection(context),
                    const SizedBox(height: 24),
                    _buildPaymentMethodSection(context),
                    const SizedBox(height: 24),
                    _buildPriceSummary(context),
                    const SizedBox(height: 16),
                    _buildCancellationInfo(context),
                    const SizedBox(height: 16),
                    _buildTermsCheckbox(context),
                  ],
                ),
              ),
            ),
            _buildPurchaseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(onTap: () => context.pop(), child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paiement', style: Theme.of(context).textTheme.titleLarge),
                    Text('Étape 2 sur 3 · Coordonnées & règlement', style: TextStyle(fontSize: 12, color: c.ink3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              final active = i < 2;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  decoration: BoxDecoration(color: active ? c.acc : c.line2, borderRadius: BorderRadius.circular(2)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSummary(BuildContext context) {
    final c = context.appColors;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: SizedBox(width: 78, height: 78, child: ThemedNetworkImage(url: widget.event.coverImageUrl)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.event.name, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: c.ink)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(PhosphorIconsRegular.calendar, size: 15, color: c.ink3),
                  const SizedBox(width: 4),
                  Text(DateFormat('d MMM, HH:mm', 'fr_FR').format(widget.event.startDate), style: TextStyle(fontSize: 12.5, color: c.ink2)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(PhosphorIconsRegular.mapPin, size: 15, color: c.ink3),
                  const SizedBox(width: 4),
                  Expanded(child: Text(widget.event.venueName, style: TextStyle(fontSize: 12.5, color: c.ink2), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsSection(BuildContext context) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('VOS BILLETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: c.acc)),
            Text('${_localTickets.length}', style: TextStyle(fontSize: 12, color: c.ink3)),
          ],
        ),
        const SizedBox(height: 10),
        for (final ticket in _localTickets)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line, width: 1))),
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.eventName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink)),
                        const SizedBox(height: 2),
                        Text('${ticket.price.toStringAsFixed(0)} FCFA × ${ticket.ticketCount}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
                      ],
                    ),
                  ),
                  QuantitySelector(value: ticket.ticketCount, buttonSize: 30, min: 1, onChanged: (v) => _changeTicketQty(ticket, v)),
                  SizedBox(
                    width: 82,
                    child: Text('${(ticket.price * ticket.ticketCount).toStringAsFixed(0)} FCFA',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink)),
                  ),
                  GestureDetector(
                    onTap: () => _showTicketOptions(ticket),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(PhosphorIconsRegular.x, size: 16, color: c.ink3),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations de contact', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _buildField(controller: _nameController, label: 'Nom complet', icon: PhosphorIconsRegular.user, isValid: _nameController.text.isEmpty || _nameValid),
        const SizedBox(height: 14),
        _buildField(controller: _phoneController, label: 'Numéro de téléphone', icon: PhosphorIconsRegular.phone, prefix: '+241 ', isValid: _phoneController.text.isEmpty || _phoneValid, keyboardType: TextInputType.phone),
        const SizedBox(height: 8),
        Text('La demande de paiement sera envoyée sur ce numéro.', style: TextStyle(fontSize: 12, color: context.appColors.ink3)),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required PhosphorIconData icon,
    required bool isValid,
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
        border: Border.all(color: isValid ? c.line2 : const Color(0xFFD6006C), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: c.ink3),
          const SizedBox(width: 10),
          if (prefix != null) Text(prefix, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink2)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: AppFieldDecoration.bare(hintText: label),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Moyen de paiement', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _paymentOption(PaymentMethod.airtel, 'assets/images/am.png', 'Airtel Money', const Color(0xFFE52329), '074 · 077 · Validation par code secret'),
        const SizedBox(height: 12),
        _paymentOption(PaymentMethod.moov, 'assets/images/mm.jpg', 'Moov Money', const Color(0xFFE8622A), '062 · 065 · Validation par code secret'),
        const SizedBox(height: 12),
        _paymentOption(PaymentMethod.card, null, 'Carte bancaire', context.appColors.acc, 'Visa · Mastercard — bientôt disponible', disabled: true),
      ],
    );
  }

  Widget _paymentOption(PaymentMethod method, String? logo, String name, Color brandColor, String note, {bool disabled = false}) {
    final c = context.appColors;
    final selected = _selectedPaymentMethod == method;
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: GestureDetector(
        onTap: disabled || _isProcessing ? null : () => setState(() => _selectedPaymentMethod = method),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: selected ? brandColor : c.line, width: selected ? 2 : 1),
            boxShadow: selected ? [BoxShadow(color: brandColor.withValues(alpha: 0.13), blurRadius: 0, spreadRadius: 4)] : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: logo != null
                    ? Image.asset(logo, width: 34, height: 34, fit: BoxFit.contain)
                    : Icon(PhosphorIconsRegular.creditCard, color: brandColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: c.ink)),
                    Text(note, style: TextStyle(fontSize: 11.5, color: c.ink3)),
                  ],
                ),
              ),
              if (selected)
                Icon(PhosphorIconsFill.checkCircle, size: 26, color: brandColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: c.line, width: 1)),
      child: Column(
        children: [
          _priceRow('Sous-total', '${_totalAmount.toStringAsFixed(0)} FCFA'),
          const SizedBox(height: 10),
          _priceRow('Frais de service', '0 FCFA'),
          const SizedBox(height: 10),
          _priceRow('Réduction', '0 FCFA'),
          Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Container(height: 1, color: c.line2)),
          _priceRow('Total', '${_totalAmount.toStringAsFixed(0)} FCFA', isTotal: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    final c = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, color: isTotal ? c.ink : c.ink2, fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: isTotal ? 24 : 14, fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400, color: c.ink)),
      ],
    );
  }

  Widget _buildCancellationInfo(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: c.line2, width: 1), borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.shieldCheck, color: c.acc, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Annulez jusqu\'à 48 heures avant l\'événement : remboursement intégral sur votre compte mobile money, sans pénalité.',
              style: TextStyle(fontSize: 12.5, color: c.ink2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    final c = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _agreedToTerms ? c.acc : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: _agreedToTerms ? c.acc : c.line2, width: 1.5),
            ),
            child: _agreedToTerms ? const Icon(PhosphorIconsBold.check, size: 15, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text('J\'accepte les conditions et confirme la volonté d\'achat du billet',
              style: TextStyle(fontSize: 13, color: c.ink2)),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(BuildContext context) {
    final c = context.appColors;
    final active = _canSubmit;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, AppSpacing.screen, 16),
      decoration: BoxDecoration(color: c.glass, border: Border(top: BorderSide(color: c.line, width: 1))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: active ? _processPayment : null,
            child: _isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Text(_selectedPaymentMethod == PaymentMethod.moov ? 'Connexion à Moov Money…' : 'Connexion à Airtel Money…'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (active) ...[
                        const Icon(PhosphorIconsRegular.lockSimple, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(active ? 'Payer ${_totalAmount.toStringAsFixed(0)} FCFA' : 'Complétez vos coordonnées et acceptez les conditions'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

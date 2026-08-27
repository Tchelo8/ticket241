import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/event_location_card.dart';
import 'package:myapp/widgets/event_cards.dart';
import 'package:myapp/widgets/quantity_selector.dart';
import 'package:myapp/widgets/section_header.dart';
import 'package:myapp/widgets/themed_network_image.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  EventDetailsScreenState createState() => EventDetailsScreenState();
}

class EventDetailsScreenState extends State<EventDetailsScreen> {
  late List<Map<String, dynamic>> _ticketData;
  double _totalPrice = 0.0;
  final ApiService _apiService = ApiService();

  bool _isDescriptionExpanded = false;
  bool _isGeneralInfoExpanded = false;
  bool _isFollowing = false;
  List<Event> _suggestedEvents = [];
  bool _isLoadingSuggestions = true;

  @override
  void initState() {
    super.initState();
    _initializeTickets();
    _fetchSuggestedEvents();
  }

  void _initializeTickets() {
    _ticketData = [
      {'name': 'Billet Standard', 'price': widget.event.minPrice, 'quantity': 1},
      {'name': 'Pass Carré VIP', 'price': widget.event.maxPrice, 'quantity': 0},
    ];
    _calculateTotal();
  }

  Future<void> _fetchSuggestedEvents() async {
    final response = await _apiService.getEvents();
    if (mounted && response.success && response.data != null) {
      setState(() {
        _suggestedEvents = response.data!.where((e) => e.id != widget.event.id).take(5).toList();
        _isLoadingSuggestions = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  void _updateTicketQuantity(int index, int newQty) {
    setState(() {
      if (newQty >= 0) {
        _ticketData[index]['quantity'] = newQty;
        _calculateTotal();
      }
    });
  }

  void _calculateTotal() {
    double total = 0;
    for (var ticket in _ticketData) {
      total += ticket['quantity'] * (ticket['price'] as double);
    }
    _totalPrice = total;
  }

  String _formatDate(DateTime? date, {String format = 'dd MMMM yyyy, HH:mm'}) {
    if (date == null) return 'N/A';
    return DateFormat(format, 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(context),
                Transform.translate(
                  offset: const Offset(0, -52),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleBlock(context),
                      _buildOrganizerBand(context),
                      const SizedBox(height: 20),
                      _buildInfoCards(context),
                      const SizedBox(height: 24),
                      _buildAboutSection(context),
                      const SizedBox(height: 24),
                      _buildGeneralInfoSection(context),
                      const SizedBox(height: 24),
                      EventLocationCard(venueName: widget.event.venueName, venueAddress: widget.event.venueAddress),
                      const SizedBox(height: 24),
                      _buildTicketSelectionSection(context),
                      const SizedBox(height: 20),
                      _buildCancellationBlock(context),
                      const SizedBox(height: 24),
                      _buildSuggestionsSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    final c = context.appColors;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.event);

    return SizedBox(
      height: 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ThemedNetworkImage(url: widget.event.coverImageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.bg.withValues(alpha: 0), c.bg],
                stops: const [0.55, 1],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _floatingButton(icon: PhosphorIconsRegular.arrowLeft, onTap: () => context.pop()),
                Row(
                  children: [
                    _floatingButton(
                      icon: isFavorite ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                      iconColor: isFavorite ? const Color(0xFFFF90B1) : Colors.white,
                      onTap: () => favoritesProvider.toggleFavorite(widget.event),
                    ),
                    const SizedBox(width: 10),
                    _floatingButton(icon: PhosphorIconsRegular.shareNetwork, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingButton({required PhosphorIconData icon, required VoidCallback onTap, Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(color: Color(0x70141312), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  Widget _buildTitleBlock(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: c.acc, borderRadius: BorderRadius.circular(3)),
                child: Text(widget.event.categoryDisplayName.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), border: Border.all(color: c.line2)),
                child: Text(
                  widget.event.minAge > 0 ? '${widget.event.minAge}+ ANS' : 'TOUT PUBLIC',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.ink2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.event.name, style: Theme.of(context).textTheme.headlineLarge),
        ],
      ),
    );
  }

  Widget _buildOrganizerBand(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: 16),
      child: Container(
        decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: c.line, width: 1))),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: c.accs,
              child: Icon(PhosphorIconsRegular.buildings, color: c.acc, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.event.organizerName ?? 'Organisateur', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink)),
                  Text('Organisateur', style: TextStyle(fontSize: 12, color: c.ink3)),
                ],
              ),
            ),
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () => setState(() => _isFollowing = !_isFollowing),
                child: Text(_isFollowing ? 'Suivi' : 'Suivre'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          Expanded(child: _infoCard(context, PhosphorIconsRegular.calendar, 'Date', _formatDate(widget.event.startDate, format: 'dd MMM yyyy'))),
          const SizedBox(width: 12),
          Expanded(child: _infoCard(context, PhosphorIconsRegular.mapPin, 'Lieu', widget.event.venueName)),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, PhosphorIconData icon, String label, String value) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.card, border: Border.all(color: c.line, width: 1), borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: c.acc),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: c.ink3)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: c.ink)),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final c = context.appColors;
    final String description = widget.event.fullDescription ?? 'Aucune description disponible.';
    final bool isLong = description.length > 190;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            _isDescriptionExpanded || !isLong ? description : '${description.substring(0, 190)}…',
            style: TextStyle(fontSize: 15, height: 1.6, color: c.ink2),
          ),
          if (isLong)
            TextButton(
              onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
              child: Text(_isDescriptionExpanded ? 'Voir moins' : 'Lire la suite'),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection(BuildContext context) {
    final c = context.appColors;
    final availableSeats = widget.event.availableSeats;
    final almostFull = availableSeats < 120;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informations générales', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          _infoRow(context, PhosphorIconsRegular.calendar, 'DATE', _formatDate(widget.event.startDate, format: 'EEEE dd MMMM yyyy')),
          _infoRow(context, PhosphorIconsRegular.clock, 'HEURE', _formatDate(widget.event.startDate, format: 'HH:mm')),
          _infoRow(context, PhosphorIconsRegular.mapPin, 'LIEU', '${widget.event.venueName}, ${widget.event.cityName}'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoRow(context, PhosphorIconsRegular.usersThree, 'PLACES RESTANTES', '$availableSeats sur ${widget.event.totalSeats}'),
              ),
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: almostFull ? const Color(0xFFFFEEF4) : c.accs,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  almostFull ? 'BIENTÔT COMPLET' : 'DISPONIBLE',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: almostFull ? const Color(0xFFD6006C) : c.acc),
                ),
              ),
            ],
          ),
          if (_isGeneralInfoExpanded) ...[
            _infoRow(context, PhosphorIconsRegular.doorOpen, 'OUVERTURE DES PORTES', _formatDate(widget.event.doorsOpenTime, format: 'HH:mm')),
            _infoRow(context, PhosphorIconsRegular.mapTrifold, 'ADRESSE', widget.event.venueAddress),
            _infoRow(context, PhosphorIconsRegular.arrowCounterClockwise, 'REMBOURSEMENT',
                widget.event.allowRefund ? 'Jusqu\'à ${widget.event.refundDeadlineDays} jours avant l\'événement' : 'Non remboursable'),
            _infoRow(context, PhosphorIconsRegular.identificationBadge, 'ÂGE MINIMUM',
                widget.event.minAge > 0 ? '${widget.event.minAge} ans' : 'Tout public'),
            _infoRow(context, PhosphorIconsRegular.buildings, 'ORGANISATEUR', widget.event.organizerName ?? 'N/A'),
          ],
          GestureDetector(
            onTap: () => setState(() => _isGeneralInfoExpanded = !_isGeneralInfoExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_isGeneralInfoExpanded ? 'Voir moins' : 'Voir plus',
                      style: TextStyle(color: c.acc, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isGeneralInfoExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(PhosphorIconsRegular.caretDown, size: 16, color: c.acc),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, PhosphorIconData icon, String label, String value) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: c.acc),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, letterSpacing: 1, color: c.ink3)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: c.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelectionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Billets', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (var i = 0; i < _ticketData.length; i++) ...[
            _buildTicketRow(context, i),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketRow(BuildContext context, int index) {
    final c = context.appColors;
    final ticket = _ticketData[index];
    final qty = ticket['quantity'] as int;
    final selected = qty > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: selected ? c.acc : c.line, width: selected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket['name'] as String, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: c.ink)),
                const SizedBox(height: 4),
                Text('${(ticket['price'] as double).toStringAsFixed(0)} FCFA',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: c.ink)),
              ],
            ),
          ),
          QuantitySelector(value: qty, onChanged: (v) => _updateTicketQuantity(index, v)),
        ],
      ),
    );
  }

  Widget _buildCancellationBlock(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: c.line2, width: 1),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsRegular.shieldCheck, size: 22, color: c.acc),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Annulation gratuite jusqu\'à 48 h avant l\'événement.', style: TextStyle(fontSize: 13, color: c.ink2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    if (_isLoadingSuggestions) return const SizedBox.shrink();
    if (_suggestedEvents.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: SectionHeader(title: 'Vous aimerez aussi'),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            itemCount: _suggestedEvents.length,
            itemBuilder: (context, index) {
              final event = _suggestedEvents[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: EventWeekCard(
                  imageUrl: event.coverImageUrl,
                  title: event.name,
                  venue: event.venueName,
                  date: event.startDate,
                  price: event.minPrice,
                  isFavorite: context.watch<FavoritesProvider>().isFavorite(event),
                  onFavoriteToggle: () => context.read<FavoritesProvider>().toggleFavorite(event),
                  onTap: () => context.push('/details', extra: event),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final c = context.appColors;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 14, AppSpacing.screen, 14),
        decoration: BoxDecoration(
          color: c.glass,
          border: Border(top: BorderSide(color: c.line, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL', style: TextStyle(fontSize: 10, letterSpacing: 1, color: c.ink3)),
                  Text('${_totalPrice.toStringAsFixed(0)} FCFA',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: c.ink)),
                ],
              ),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _totalPrice > 0 ? () => _goToCheckout(context) : null,
                  child: Text(_totalPrice > 0 ? 'Continuer' : 'Choisir un billet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToCheckout(BuildContext context) {
    final tickets = _ticketData
        .where((ticket) => (ticket['quantity'] as int) > 0)
        .map((ticket) => EventTicket(
              eventName: ticket['name'] as String,
              ticketCount: ticket['quantity'] as int,
              price: ticket['price'] as double,
              imagePath: widget.event.coverImageUrl,
              location: widget.event.venueName,
              date: _formatDate(widget.event.startDate, format: 'dd MMMM yyyy'),
              time: _formatDate(widget.event.startDate, format: 'HH:mm'),
              status: 'Payé',
              daysLeft: widget.event.startDate.difference(DateTime.now()).inDays,
              isUpcoming: !widget.event.isPastEvent,
            ))
        .toList();

    if (tickets.isNotEmpty) {
      context.push('/checkout', extra: {'event': widget.event, 'tickets': tickets});
    }
  }
}

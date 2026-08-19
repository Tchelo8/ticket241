import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/widgets/event_location_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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

  // State for dynamic UI
  bool _isDescriptionExpanded = false;
  bool _isGeneralInfoExpanded = false;
  List<Event> _suggestedEvents = [];
  bool _isLoadingSuggestions = true;

  @override
  void initState() {
    super.initState();
    _initializeTickets();
    _fetchSuggestedEvents();
  }

  void _initializeTickets() {
    double minPrice = widget.event.minPrice;
    double maxPrice = widget.event.maxPrice;
    if (maxPrice <= minPrice) maxPrice = minPrice * 2;

    _ticketData = [
      {'name': 'Ticket Standard', 'price': minPrice, 'quantity': 1},
      {'name': 'Pass VIP', 'price': maxPrice, 'quantity': 0},
    ];
    _calculateTotal();
  }

  Future<void> _fetchSuggestedEvents() async {
    final response = await _apiService.getEvents();
    if (mounted && response.success && response.data != null) {
      setState(() {
        // Exclude the current event from suggestions and take a few
        _suggestedEvents = response.data!.where((e) => e.id != widget.event.id).take(5).toList();
        _isLoadingSuggestions = false;
      });
    } else if (mounted) {
        setState(() {
            _isLoadingSuggestions = false;
        });
    }
  }

  void _updateTicketQuantity(int index, int change) {
    setState(() {
      if (_ticketData[index]['quantity'] + change >= 0) {
        _ticketData[index]['quantity'] += change;
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
    const primaryColor = Color(0xFF1E90FF);
    const textColor = Colors.black87;
    const secondaryTextColor = Colors.grey;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(context, widget.event),
                _buildEventInfo(textColor),
                _buildAboutSection(textColor, primaryColor),
                _buildGeneralInfoSection(textColor, secondaryTextColor, primaryColor),
                _buildTicketSelectionSection(primaryColor, textColor),
                EventLocationCard(venueAddress: widget.event.venueAddress),
                _buildSuggestionsSection(textColor, secondaryTextColor, primaryColor),
                const SizedBox(height: 100), // Bottom padding for action bar
              ],
            ),
          ),
          _buildBottomActionBar(context, primaryColor, textColor),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, Event event) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(event);

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: event.coverImageUrl,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/enb.jpg', // Fallback image
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Gradient overlay for text readability
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
        // Top action buttons
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () => favoritesProvider.toggleFavorite(event),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Event title and date
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(event.startDate),
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 25,
            child: const Icon(Icons.business, color: Color(0xFF1E90FF)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.organizerName ?? 'Organisateur inconnu',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Organisateur',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Color textColor, Color primaryColor) {
    final String description = widget.event.fullDescription ?? "Aucune description disponible.";
    final bool isLongDescription = description.length > 350;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            _isDescriptionExpanded || !isLongDescription
                ? description
                : '${description.substring(0, 350)}...',
            style: TextStyle(color: textColor.withOpacity(0.7), height: 1.5),
          ),
          if (isLongDescription)
            TextButton(
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded ? 'Voir moins' : 'Lire la suite',
                style: TextStyle(color: primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection(Color textColor, Color secondaryTextColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informations générales', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.calendar_today, 'Date', _formatDate(widget.event.startDate, format: 'EEEE dd MMMM yyyy'), secondaryTextColor, textColor),
          _buildInfoRow(Icons.access_time, 'Heure', _formatDate(widget.event.startDate, format: 'HH:mm'), secondaryTextColor, textColor),
          _buildInfoRow(Icons.location_on, 'Lieu', '${widget.event.venueName}, ${widget.event.cityName}', secondaryTextColor, textColor),
          _buildInfoRow(Icons.event_seat, 'Places restantes', widget.event.availableSeats.toString(), secondaryTextColor, textColor),
          if (_isGeneralInfoExpanded)
            Column(
              children: [
                _buildInfoRow(Icons.sensor_door, 'Ouverture des portes', _formatDate(widget.event.doorsOpenTime, format: 'HH:mm'), secondaryTextColor, textColor),
                 _buildInfoRow(Icons.location_city, 'Adresse', widget.event.venueAddress, secondaryTextColor, textColor),
                 _buildInfoRow(Icons.policy, 'Remboursement', 'Jusqu\'à ${widget.event.refundDeadlineDays} jours avant', secondaryTextColor, textColor),
              ],
            ),
          
          TextButton(
            onPressed: () {
              setState(() {
                _isGeneralInfoExpanded = !_isGeneralInfoExpanded;
              });
            },
            child: Text(
              _isGeneralInfoExpanded ? 'Voir moins' : 'Voir plus',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(label, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: iconColor, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTicketSelectionSection(Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _ticketData.length,
        itemBuilder: (context, index) {
          final ticket = _ticketData[index];
          return _buildTicketRow(
            title: ticket['name'],
            price: (ticket['price'] as double).toStringAsFixed(0),
            quantity: ticket['quantity'],
            onIncrement: () => _updateTicketQuantity(index, 1),
            onDecrement: () => _updateTicketQuantity(index, -1),
            isSelected: ticket['quantity'] > 0,
            primaryColor: primaryColor,
            textColor: textColor,
          );
        },
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed, required Color iconColor}) {
    return Material(
      color: Colors.grey[200],
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: iconColor, size: 18),
        ),
      ),
    );
  }

  Widget _buildTicketRow({
    required String title,
    required String price,
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    bool isSelected = false,
    required Color primaryColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!, width: 1.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('$price FCFA', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('1 pers', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          Row(
            children: [
              _buildQuantityButton(icon: Icons.remove, onPressed: onDecrement, iconColor: textColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(quantity.toString(), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildQuantityButton(icon: Icons.add, onPressed: onIncrement, iconColor: textColor),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(Color textColor, Color secondaryTextColor, Color primaryColor) {
    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_suggestedEvents.isEmpty) {
      return const SizedBox.shrink(); // Do not show section if no suggestions
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Vous aimerez aussi', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: _suggestedEvents.length,
              itemBuilder: (context, index) {
                final event = _suggestedEvents[index];
                return _buildSuggestionCard(context, event, textColor, secondaryTextColor, primaryColor);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, Event event, Color textColor, Color secondaryTextColor, Color primaryColor) {

    return GestureDetector(
      onTap: () => context.push('/details', extra: event),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: event.coverImageUrl,
                    height: 150,
                    width: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/enb.jpg', // Fallback image
                      height: 150,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(event.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: secondaryTextColor, size: 14),
                const SizedBox(width: 5),
                Expanded(child: Text(event.venueName, style: TextStyle(color: secondaryTextColor, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, Color primaryColor, Color textColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10)],
            border: Border(top: BorderSide(color: Colors.grey[200]!))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text('${_totalPrice.toStringAsFixed(0)} FCFA', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              onPressed: _totalPrice > 0
                  ? () {
                      final tickets = _ticketData
                          .where((ticket) => ticket['quantity'] > 0)
                          .map((ticket) => EventTicket(
                                eventName: ticket['name'],
                                ticketCount: ticket['quantity'],
                                price: ticket['price'],
                                // These fields might need to be sourced from the main event object
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
                        context.push('/checkout', extra: {
                          'event': widget.event,
                          'tickets': tickets,
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text('Acheter', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

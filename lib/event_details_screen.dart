import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  EventDetailsScreenState createState() => EventDetailsScreenState();
}

class EventDetailsScreenState extends State<EventDetailsScreen> {
  late List<Map<String, dynamic>> _ticketData;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // Dynamically generate placeholder ticket types based on event prices
    _ticketData = [
      {'name': 'Ticket Standard', 'price': widget.event.minPrice, 'quantity': 1},
      if (widget.event.maxPrice > widget.event.minPrice)
        {'name': 'Pass VIP', 'price': widget.event.maxPrice, 'quantity': 0},
    ];
    _calculateTotal();
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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'fr_FR').format(date);
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
                _buildGeneralInfoSection(textColor, secondaryTextColor),
                _buildTicketSelectionSection(primaryColor, textColor),
                _buildLocationSection(textColor, secondaryTextColor),
                const SizedBox(height: 100),
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
        Image.network(
          event.coverImageUrl,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 50),
          ),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withAlpha((255 * 0.7).round())],
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withAlpha((255 * 0.5).round()),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withAlpha((255 * 0.5).round()),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        favoritesProvider.toggleFavorite(event);
                        if (!isFavorite) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ajouté aux favoris'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.black.withAlpha((255 * 0.5).round()),
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
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(event.startDate),
                style: TextStyle(color: Colors.white.withAlpha((255 * 0.9).round())),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.venueName,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.event.cityName}, ${widget.event.cityCountry}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Color textColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            'Rejoignez-nous pour ${widget.event.name} à ${widget.event.venueName}. Profitez d\'une expérience exceptionnelle dans la catégorie ${widget.event.category}. Places disponibles : ${widget.event.availableSeats}.',
            style: TextStyle(color: textColor.withAlpha((255 * 0.7).round()), height: 1.5),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Lire la suite', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection(Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informations générales', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.calendar_today, 'Date: ${DateFormat('EEEE dd MMMM', 'fr_FR').format(widget.event.startDate)}', secondaryTextColor, textColor),
          _buildInfoRow(Icons.access_time, 'Heure: ${DateFormat('HH:mm').format(widget.event.startDate)}', secondaryTextColor, textColor),
          _buildInfoRow(Icons.location_on, 'Lieu: ${widget.event.venueName}, ${widget.event.cityName}', secondaryTextColor, textColor),
          _buildInfoRow(Icons.event_seat, 'Places restantes: ${widget.event.availableSeats}', secondaryTextColor, textColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 15))),
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

  Widget _buildLocationSection(Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Localisation', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('${widget.event.venueName}, ${widget.event.cityName}', style: TextStyle(color: secondaryTextColor)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/images/map.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
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
          border: Border(top: BorderSide(color: Colors.grey[200]!))
        ),
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
              onPressed: _totalPrice > 0 ? () {
                context.push('/checkout');
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Acheter', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
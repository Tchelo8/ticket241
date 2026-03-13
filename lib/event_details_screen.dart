import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/ticket_model.dart';
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

  // Dummy data for suggested events
  final List<Event> _suggestedEvents = [
    Event(
        id: 101,
        slug: 'suggested-1',
        name: 'Concert sous les pyramides',
        coverImageUrl: 'assets/images/enb.jpg',
        venueName: 'Gizeh, Caire',
        startDate: DateTime(2025, 4, 10),
        minPrice: 5000,
        maxPrice: 15000,
        category: 'Concert',
        cityId: 1,
        cityName: 'Le Caire',
        cityCountry: 'Égypte',
        availableSeats: 50,
        soldSeats: 10,
        viewCount: 120,
        isFeatured: true,
        isPromoted: false,
        isSaleOpen: true,
        isPastEvent: false,
        isSoldOut: false),
    Event(
        id: 102,
        slug: 'suggested-2',
        name: 'Festival de Jazz de Mumbai',
        coverImageUrl: 'assets/images/jazz.png',
        venueName: 'Santorin, Grèce',
        startDate: DateTime(2025, 5, 25),
        minPrice: 4000,
        maxPrice: 12000,
        category: 'Festival',
        cityId: 2,
        cityName: 'Santorin',
        cityCountry: 'Grèce',
        availableSeats: 30,
        soldSeats: 5,
        viewCount: 85,
        isFeatured: false,
        isPromoted: true,
        isSaleOpen: true,
        isPastEvent: false,
        isSoldOut: false),
  ];

  @override
  void initState() {
    super.initState();
    // Dynamically generate placeholder ticket types based on event prices
    double minPrice = widget.event.minPrice;
    double maxPrice = widget.event.maxPrice;

    if (maxPrice <= minPrice) {
      maxPrice = minPrice * 2;
    }

    _ticketData = [
      {'name': 'Ticket Standard', 'price': minPrice, 'quantity': 1},
      {'name': 'Pass VIP', 'price': maxPrice, 'quantity': 0},
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
                _buildSuggestionsSection(textColor, secondaryTextColor, primaryColor),
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

    Widget imageWidget;
    if (event.coverImageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        event.coverImageUrl,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.network(
        event.coverImageUrl,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/enb.jpg',
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Stack(
      children: [
        imageWidget,
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
    const defaultDescription =
        "Le festival de musique est un événement de renommée mondiale qui a lieu chaque année dans la ville animée de Libreville. C'est une destination incontournable pour les amateurs de musique du monde entier, attirant des dizaines de milliers de participants venus vivre son atmosphère électrisante.";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            'Rejoignez-nous pour ${widget.event.name} à ${widget.event.venueName}. Profitez d\'une expérience exceptionnelle dans la catégorie ${widget.event.category}. Places disponibles : ${widget.event.availableSeats}.\n\n$defaultDescription',
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

  Widget _buildSuggestionsSection(Color textColor, Color secondaryTextColor, Color primaryColor) {
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
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(event);

    Widget imageWidget;
    if (event.coverImageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        event.coverImageUrl,
        height: 150,
        width: 200,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.network(
        event.coverImageUrl,
        height: 150,
        width: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/enb.jpg',
          height: 150,
          width: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageWidget,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
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
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withAlpha((255 * 0.5).round()),
                    radius: 15,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('À partir de ${event.minPrice.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(event.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on, color: secondaryTextColor, size: 14),
              const SizedBox(width: 5),
              Text(event.venueName, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
            ],
          )
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
                                // Remplissez les autres champs de EventTicket selon vos besoins
                                imagePath: '',
                                location: '',
                                date: '',
                                time: '',
                                status: '',
                                daysLeft: 0,
                                isUpcoming: true,
                              ))
                          .toList();

                      context.push('/checkout', extra: {
                        'event': widget.event,
                        'tickets': tickets,
                      });
                    }
                  : null,
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


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => ExplorerScreenState();
}

class ExplorerScreenState extends State<ExplorerScreen> {
    static final List<Event> _allEvents = [
    Event(name: 'Concert Live Acoustique', imagePath: 'assets/images/enb.jpg', location: 'Entre Nous Bar, Angondjé', date: '29 Mars', price: 5000.0),
    Event(name: 'Festival International de Sibang', imagePath: 'assets/images/sibang.jpg', location: 'Jardin Botanique, Libreville', date: '15 Avril', price: 10000.0),
    Event(name: 'Concert Oiseau Rare', imagePath: 'assets/images/oiseau.jpg', location: 'Casino Croisette, LBV', date: '14 Fév', price: 15000.0),
    Event(name: 'Entre Nous Bar', imagePath: 'assets/images/enb.jpg', location: 'Angondjé', date: 'Tous les vendredis', price: 5000.0),
    Event(name: 'Libreville Jazz Festival', imagePath: 'assets/images/jazz.png', location: 'Institut Français', date: '10 Jan', price: 20000.0),
    Event(name: 'CMS vs US Bitam', imagePath: 'assets/images/sibang.jpg', location: 'Stade de l\'amitié', date: '05 Mai', price: 1000.0),
    Event(name: 'Concert L\'oiseau rare', imagePath: 'assets/images/oiseau.jpg', location: 'Casino Croisette', date: '14 Fév', price: 15000.0),
  ];

  List<Event> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _filteredEvents = _allEvents;
  }

  void _filterEvents(String query) {
    final filtered = _allEvents.where((event) {
      final eventName = event.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return eventName.contains(searchLower);
    }).toList();

    setState(() {
      _filteredEvents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Explorer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildEventsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: _filterEvents,
      decoration: InputDecoration(
        hintText: 'Rechercher...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEventsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(context, event: event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, {required Event event}) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(event);

    return GestureDetector(
      onTap: () {
        context.push('/details');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((255 * 0.15).round()),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    event.imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
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
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255 * 0.9).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                     maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E90FF).withAlpha((255 * 0.1).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${event.price.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: Color(0xFF1E90FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

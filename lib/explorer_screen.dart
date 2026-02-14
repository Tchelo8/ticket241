
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
    Event(name: 'Concert Live Acoustique', imagePath: 'assets/images/enb.jpg', location: 'Entre Nous Bar, Angondjé', date: '29 Mars', price: 5000.0, category: 'Concert'),
    Event(name: 'Festival International de Sibang', imagePath: 'assets/images/sibang.jpg', location: 'Jardin Botanique, Libreville', date: '15 Avril', price: 10000.0, category: 'Festival'),
    Event(name: 'Concert Oiseau Rare', imagePath: 'assets/images/oiseau.jpg', location: 'Casino Croisette, LBV', date: '14 Fév', price: 15000.0, category: 'Concert'),
    Event(name: 'Entre Nous Bar', imagePath: 'assets/images/enb.jpg', location: 'Angondjé', date: 'Tous les vendredis', price: 5000.0, category: 'Soirée'),
    Event(name: 'Libreville Jazz Festival', imagePath: 'assets/images/jazz.png', location: 'Institut Français', date: '10 Jan', price: 20000.0, category: 'Festival'),
    Event(name: 'CMS vs US Bitam', imagePath: 'assets/images/sibang.jpg', location: 'Stade de l\'amitié', date: '05 Mai', price: 1000.0, category: 'Sport'),
    Event(name: 'Concert L\'oiseau rare', imagePath: 'assets/images/oiseau.jpg', location: 'Casino Croisette', date: '14 Fév', price: 15000.0, category: 'Concert'),
  ];

  final List<Map<String, String>> _categories = [
    {'name': 'Concert', 'image': 'assets/images/jazz.png'},
    {'name': 'Sport', 'image': 'assets/images/sibang.jpg'},
    {'name': 'Festival', 'image': 'assets/images/enb.jpg'},
    {'name': 'Soirée', 'image': 'assets/images/oiseau.jpg'},
    {'name': 'Théâtre', 'image': 'assets/images/party.png'},
  ];

  List<Event> _filteredEvents = [];
  String _selectedCategory = 'Concert';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final categoryMatch = event.category == _selectedCategory;
        final queryMatch = _searchQuery.isEmpty ||
            event.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return categoryMatch && queryMatch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
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
            _buildCategoryList(),
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
      onChanged: _onSearchChanged,
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

  Widget _buildCategoryList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category['name']!, category['image']!);
        },
      ),
    );
  }

  Widget _buildCategoryCard(String name, String image) {
    final isSelected = _selectedCategory == name;
    return GestureDetector(
      onTap: () => _onCategorySelected(name),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E90FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E90FF) : Colors.grey[300]!,
            width: 1.5,
          ),
           boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E90FF).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/api_service.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => ExplorerScreenState();
}

class ExplorerScreenState extends State<ExplorerScreen> {
  final ApiService _apiService = ApiService();
  List<Event> _allEvents = [];
  List<String> _categories = [];
  bool _isLoadingEvents = true;
  bool _isLoadingCategories = true;

  // Associe un nom de catégorie à une image locale pour garder une belle interface
  final Map<String, String> _categoryImages = {
    'CONCERT': 'assets/images/jazz.png',
    'SPORT': 'assets/images/sibang.jpg',
    'FESTIVAL': 'assets/images/enb.jpg',
    'SOIRÉE': 'assets/images/oiseau.jpg',
    'THÉÂTRE': 'assets/images/party.png',
    // On peut ajouter d'autres catégories ici au besoin
  };
  final String _defaultCategoryImage = 'assets/images/ticket.png'; // Image par défaut

  List<Event> _filteredEvents = [];
  String? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Récupère les événements et les catégories en parallèle pour plus de performance
  Future<void> _fetchData() async {
    // On lance les deux requêtes en même temps
    final eventsFuture = _apiService.getEvents();
    final categoriesFuture = _apiService.getCategories();

    // On attend les résultats
    final results = await Future.wait([eventsFuture, categoriesFuture]);

    final eventsResponse = results[0] as ApiResponse<List<Event>>;
    final categoriesResponse = results[1] as ApiResponse<List<String>>;

    if (mounted) {
      setState(() {
        // Traitement des événements
        if (eventsResponse.success && eventsResponse.data != null) {
          _allEvents = eventsResponse.data!;
        }
        _isLoadingEvents = false;

        // Traitement des catégories
        if (categoriesResponse.success && categoriesResponse.data != null) {
          _categories = categoriesResponse.data!;
          if (_categories.isNotEmpty) {
            // On sélectionne la première catégorie par défaut
            _selectedCategory = _categories.first;
          }
        }
        _isLoadingCategories = false;
        
        // On applique les filtres une fois que tout est chargé
        _applyFilters();
      });
    }
  }


  void _applyFilters() {
    if (_isLoadingEvents || _selectedCategory == null) return;

    setState(() {
      _filteredEvents = _allEvents.where((event) {
        // Le filtre par catégorie est maintenant sensible à la casse et gère le cas null
        final categoryMatch = event.category.toUpperCase() == _selectedCategory!.toUpperCase();
        
        // Le filtre par recherche reste inchangé
        final queryMatch = _searchQuery.isEmpty ||
            event.name.toLowerCase().contains(_searchQuery.toLowerCase());
            
        return categoryMatch && queryMatch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _isLoadingEvents || _isLoadingCategories;

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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEventsGrid(),
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
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_categories.isEmpty) {
      return const Center(child: Text("Aucune catégorie trouvée"));
    }
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final categoryName = _categories[index];
          // On récupère l'image associée ou l'image par défaut
          final categoryImage = _categoryImages[categoryName.toUpperCase()] ?? _defaultCategoryImage;
          return _buildCategoryCard(categoryName, categoryImage);
        },
      ),
    );
  }

  Widget _buildCategoryCard(String name, String imagePath) {
    final isSelected = _selectedCategory?.toUpperCase() == name.toUpperCase();
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
                    color: const Color(0xFF1E90FF).withAlpha(100),
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
                imagePath, // Utilise le chemin d'image dynamique
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                // Gestion d'erreur si une image n'est pas trouvée
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  _defaultCategoryImage,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsGrid() {
    if (_filteredEvents.isEmpty) {
      return const Center(child: Text("Aucun événement trouvé pour cette catégorie"));
    }
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
    final isPast = DateTime.now().isAfter(event.startDate);

    return GestureDetector(
      onTap: isPast ? null : () => context.push('/details', extra: event),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(50),
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
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    event.coverImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                if (isPast)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Passé',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isPast)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        favoritesProvider.toggleFavorite(event);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
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
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey[600] : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.venueName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isPast ? Colors.grey[300] : const Color(0xFF1E90FF).withAlpha(30)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${event.minPrice.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          color: isPast ? Colors.grey[700] : const Color(0xFF1E90FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
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

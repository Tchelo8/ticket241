import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:myapp/models/category_model.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/services/api_service.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => ExplorerScreenState();
}

class ExplorerScreenState extends State<ExplorerScreen> {
  final ApiService _apiService = ApiService();
  List<Event> _allEvents = [];
  List<Category> _categories = [];
  bool _isLoadingEvents = true;
  bool _isLoadingCategories = true;
  final String _selectedCity = 'Libreville';

  List<Event> _filteredEvents = [];
  String? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({String? city}) async {
    setState(() {
      _isLoadingEvents = true;
      _isLoadingCategories = true;
    });

    try {
      final responses = await Future.wait([
        _apiService.getEvents(city: city ?? _selectedCity),
        _apiService.getCategories(),
      ]);

      final eventsResponse = responses[0] as ApiResponse<List<Event>>;
      final categoriesResponse = responses[1] as ApiResponse<List<Category>>;

      if (!mounted) return;

      setState(() {
        _allEvents = (eventsResponse.success && eventsResponse.data != null) ? eventsResponse.data! : [];
        if (!eventsResponse.success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(eventsResponse.message ?? 'Le chargement des événements a échoué.')),
          );
        }

        _categories = (categoriesResponse.success && categoriesResponse.data != null) ? categoriesResponse.data! : [];
        if (_categories.isNotEmpty && _selectedCategory == null) {
          _selectedCategory = _categories.first.name;
        }
        if (!categoriesResponse.success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(categoriesResponse.message ?? 'Le chargement des catégories a échoué.')),
          );
        }

        _isLoadingEvents = false;
        _isLoadingCategories = false;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEvents = false;
          _isLoadingCategories = false;
          _allEvents = [];
          _categories = [];
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue: ${e.toString()}')),
        );
      }
    }
  }

  void _applyFilters() {
    if (_isLoadingEvents) return;

    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final categoryMatch = _selectedCategory == null ||
            event.category.toUpperCase() == _selectedCategory!.toUpperCase();
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
                  : _filteredEvents.isEmpty
                      ? const Center(
                          child: Text("Aucun résultat pour cette sélection."))
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
        prefixIcon: const Icon(Icons.search, color: Color.fromRGBO(158, 158, 158, 1)),
        filled: true,
        fillColor: const Color.fromRGBO(238, 238, 238, 1),
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
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final isSelected =
        _selectedCategory?.toUpperCase() == category.name.toUpperCase();

    const String fallbackImage = 'assets/images/logoblanc.png';

    Widget imageWidget;
    if (category.iconUrl != null && category.iconUrl!.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: category.iconUrl!,
        height: 40,
        width: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: const Color.fromRGBO(224, 224, 224, 1),
          highlightColor: const Color.fromRGBO(245, 245, 245, 1),
          child: Container(
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          fallbackImage,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ),
      );
    } else {
      imageWidget = Image.asset(
        fallbackImage,
        height: 40,
        width: 40,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: () => _onCategorySelected(category.name),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E90FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E90FF) : const Color.fromRGBO(224, 224, 224, 1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color.fromRGBO(30, 144, 255, 0.4),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageWidget,
            ),
            const SizedBox(height: 8),
            Text(
              category.displayName,
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
            const BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 4),
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
                  child: CachedNetworkImage(
                    imageUrl: event.coverImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: const Color.fromRGBO(224, 224, 224, 1),
                      highlightColor: const Color.fromRGBO(245, 245, 245, 1),
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: const Color.fromRGBO(224, 224, 224, 1),
                      child: const Icon(Icons.broken_image, color: Color.fromRGBO(158, 158, 158, 1)),
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
                          color: const Color.fromRGBO(0, 0, 0, 0.3),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 82, 82, 0.8),
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
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.9),
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
                        color: isPast ? const Color.fromRGBO(117, 117, 117, 1) : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.venueName,
                    style: const TextStyle(color: Color.fromRGBO(189, 189, 189, 1), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isPast ? const Color.fromRGBO(224, 224, 224, 1) : const Color.fromRGBO(30, 144, 255, 0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${event.minPrice.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          color: isPast ? const Color.fromRGBO(97, 97, 97, 1) : const Color(0xFF1E90FF),
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

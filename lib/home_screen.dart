import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/event_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/city_selection_popup.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCity = 'Libreville';
  final ApiService _apiService = ApiService();
  List<Event> _events = [];
  bool _isLoading = true;

  // Dummy data
  static final List<Event> _upcomingEvents = [
    Event(
        id: 0,
        slug: 'upcoming-1',
        name: 'Concert Live Acoustique',
        coverImageUrl: 'assets/images/enb.jpg',
        venueName: 'Entre Nous Bar, Angondjé',
        startDate: DateTime(2023, 3, 29), // Date passée pour tester
        minPrice: 5000.0,
        category: 'Concert',
        cityId: 1,
        cityName: 'Libreville',
        cityCountry: 'Gabon',
        soldSeats: 0,
        availableSeats: 100,
        maxPrice: 5000.0,
        isFeatured: false,
        isPromoted: false,
        viewCount: 0,
        isSaleOpen: true,
        isPastEvent: false,
        isSoldOut: false),
    Event(
        id: 0,
        slug: 'upcoming-2',
        name: 'Festival International de Sibang',
        coverImageUrl: 'assets/images/sibang.jpg',
        venueName: 'Jardin Botanique, Libreville',
        startDate: DateTime(2025, 4, 15),
        minPrice: 10000.0,
        category: 'Festival',
        cityId: 1,
        cityName: 'Libreville',
        cityCountry: 'Gabon',
        soldSeats: 0,
        availableSeats: 100,
        maxPrice: 10000.0,
        isFeatured: false,
        isPromoted: false,
        viewCount: 0,
        isSaleOpen: true,
        isPastEvent: false,
        isSoldOut: false),
    Event(
        id: 0,
        slug: 'upcoming-3',
        name: 'Concert Oiseau Rare',
        coverImageUrl: 'assets/images/oiseau.jpg',
        venueName: 'Casino Croisette, LBV',
        startDate: DateTime(2025, 2, 14),
        minPrice: 15000.0,
        category: 'Concert',
        cityId: 1,
        cityName: 'Libreville',
        cityCountry: 'Gabon',
        soldSeats: 0,
        availableSeats: 100,
        maxPrice: 15000.0,
        isFeatured: false,
        isPromoted: false,
        viewCount: 0,
        isSaleOpen: true,
        isPastEvent: false,
        isSoldOut: false),
  ];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    final response = await _apiService.getEvents();
    if (response.success && response.data != null) {
      setState(() {
        _events = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Erreur lors du chargement des événements')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM, yyyy', 'fr_FR').format(date);
  }

  String _formatDateUpcoming(DateTime date) {
    return DateFormat('dd MMM', 'fr_FR').format(date);
  }

  void _showCitySelection(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return const CitySelectionPopup();
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCity = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchEvents,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    _buildHeader(context),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Événements à venir"),
                    _buildUpcomingEventsList(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Populaire actuellement", showSeeAll: true),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildPopularEventsList(context, events: _events),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showCitySelection(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trouver des événements près de',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _selectedCity,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.expand_more, color: Colors.black87),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(50),
                    spreadRadius: 1,
                    blurRadius: 5,
                  )
                ]),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black),
              onPressed: () {
                context.push('/notifications');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        readOnly: true,
        onTap: () {
          widget.onNavigate(1);
        },
        decoration: InputDecoration(
          hintText: 'Rechercher des événements...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 8.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: () => widget.onNavigate(1),
              child: const Text(
                'Voir tout',
                style: TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsList() {
    return SizedBox(
      height: 120,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = _upcomingEvents[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildUpcomingEventCard(context, event: event),
                ),
              ),
            );
          },
          padding: const EdgeInsets.only(left: 24, top: 12),
        ),
      ),
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context, {required Event event}) {
    final formattedDate = _formatDateUpcoming(event.startDate);
    final dateParts = formattedDate.split(' ');
    final day = dateParts.isNotEmpty ? dateParts[0] : '';
    final month = dateParts.length > 1 ? dateParts[1] : '';
    final isPast = DateTime.now().isAfter(event.startDate);

    return GestureDetector(
      onTap: isPast ? null : () => context.push('/details', extra: event),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(40),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]),
        child: Opacity(
          opacity: isPast ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        event.coverImageUrl,
                        width: 80, 
                        height: 96, 
                        fit: BoxFit.cover,
                      ),
                    ),
                    if(!isPast)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(50),
                            ),
                          ),
                        ),
                      ),
                    if(!isPast)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E90FF))),
                          Text(month.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E90FF))),
                        ]),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: isPast ? Colors.grey[700] : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venueName,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                       const SizedBox(height: 8),
                      if (isPast)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Événement Passé',
                            style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularEventsList(BuildContext context, {required List<Event> events}) {
    return SizedBox(
      height: 250,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildPopularEventCard(context, event: event),
                ),
              ),
            );
          },
          padding: const EdgeInsets.only(left: 24, top: 12),
        ),
      ),
    );
  }

  Widget _buildPopularEventCard(BuildContext context, {required Event event}) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(event);
    final isPast = DateTime.now().isAfter(event.startDate);

    return GestureDetector(
      onTap: isPast ? null : () => context.push('/details', extra: event),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(40),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                         if (!favoritesProvider.isFavorite(event)) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ajouté aux favoris avec succès'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
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
              child: Opacity(
                opacity: isPast ? 0.6 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM, yyyy', 'fr_FR').format(event.startDate),
                      style: TextStyle(fontSize: 12, color: isPast? Colors.grey[700] : Color(0xFF1E90FF), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 17, 
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey[700] : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 80,
                              child: Text(event.venueName, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPast ? Colors.grey[300] : Color(0xFF1E90FF).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${event.minPrice.toStringAsFixed(0)} FCFA', style: TextStyle(color: isPast ? Colors.grey[700] : Color(0xFF1E90FF), fontWeight: FontWeight.bold, fontSize: 11)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

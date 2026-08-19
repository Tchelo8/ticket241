import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/city_selection_popup.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCity = 'Libreville';
  final ApiService _apiService = ApiService();
  List<Event> _allEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'fr_FR';
    _fetchEvents();
  }

  Future<void> _fetchEvents({String? city}) async {
    setState(() {
      _isLoading = true;
    });
    final response = await _apiService.getEvents(city: city ?? _selectedCity);
    if (mounted) {
      setState(() {
        _allEvents = (response.success && response.data != null) ? response.data! : [];
        if (!response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Erreur lors du chargement des événements')),
          );
        }
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM, yyyy').format(date);
  }

  String _formatDateUpcoming(DateTime date) {
    return DateFormat('dd MMM').format(date);
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
            return CitySelectionPopup(currentCity: _selectedCity); // Passe la ville actuelle
          },
        );
      },
    );

    if (result != null && result != _selectedCity) {
      setState(() {
        _selectedCity = result;
        _fetchEvents(city: _selectedCity); // On recharge les événements pour la nouvelle ville
      });
    }
  }

  List<Event> _getUpcomingEvents() {
    final now = DateTime.now();
    final upcoming = _allEvents.where((e) => e.startDate.isAfter(now)).toList();
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming;
  }

  List<Event> _getPopularEvents() {
    final now = DateTime.now();
    final popular = _allEvents.where((e) => e.isFeatured && e.startDate.isAfter(now)).toList();
    if (popular.isEmpty) {
        final sortedByViews = _allEvents.where((e) => e.startDate.isAfter(now)).toList();
        sortedByViews.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        popular.addAll(sortedByViews.take(5));
    }
    return popular;
  }

  List<Event> _getSportEvents() {
    final now = DateTime.now();
    return _allEvents.where((e) => e.category.toUpperCase() == 'SPORT' && e.startDate.isAfter(now)).toList();
  }

  List<Event> _getCultureEvents() {
    final now = DateTime.now();
    const cultureCategories = {'CONCERT', 'THÉÂTRE', 'FESTIVAL'};
    return _allEvents.where((e) => cultureCategories.contains(e.category.toUpperCase()) && e.startDate.isAfter(now)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = _getUpcomingEvents();
    final popularEvents = _getPopularEvents();
    final sportEvents = _getSportEvents();
    final cultureEvents = _getCultureEvents();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchEvents(), // Le refresh recharge pour la ville actuelle
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allEvents.isEmpty
                ? const Center(child: Text("Aucun événement trouvé pour cette ville."))
                : SingleChildScrollView(
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

                          if(upcomingEvents.isNotEmpty)
                            ...[_buildSectionHeader("Événements à venir"),
                            _buildUpcomingEventsList(upcomingEvents)],

                          if(popularEvents.isNotEmpty)
                            ...[const SizedBox(height: 24),
                            _buildSectionHeader("Populaire actuellement", showSeeAll: true),
                            _buildPopularEventsList(context, events: popularEvents)],
                          
                          if(sportEvents.isNotEmpty)
                            ...[const SizedBox(height: 24),
                            _buildSectionHeader("Sport", showSeeAll: true),
                            _buildPopularEventsList(context, events: sportEvents)],

                          if(cultureEvents.isNotEmpty)
                            ...[const SizedBox(height: 24),
                            _buildSectionHeader("Culture", showSeeAll: true),
                            _buildPopularEventsList(context, events: cultureEvents)],

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
                    color: const Color.fromRGBO(158, 158, 158, 0.2),
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
          widget.onNavigate(1); // Naviguer vers l'onglet Explorer
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

  Widget _buildUpcomingEventsList(List<Event> events) {
    return SizedBox(
      height: 120,
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

    return GestureDetector(
      onTap: () => context.push('/details', extra: event),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(158, 158, 158, 0.16),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: event.coverImageUrl,
                      width: 80,
                      height: 96,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                          width: 80, height: 96, color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey)),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.88),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
            ],
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
                color: const Color.fromRGBO(158, 158, 158, 0.16),
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
                  child: CachedNetworkImage(
                    imageUrl: event.coverImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
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
                          color: const Color.fromRGBO(0, 0, 0, 0.3),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          const SnackBar(
                            content: Text('Favoris mis à jour'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.9),
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
                        _formatDate(event.startDate),
                        style: TextStyle(fontSize: 12, color: isPast? Colors.grey[700] : const Color(0xFF1E90FF), fontWeight: FontWeight.w600)),
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
                            color: isPast ? Colors.grey[300] : const Color.fromRGBO(30, 144, 255, 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${event.minPrice.toStringAsFixed(0)} FCFA', style: TextStyle(color: isPast ? Colors.grey[700] : const Color(0xFF1E90FF), fontWeight: FontWeight.bold, fontSize: 11)),
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

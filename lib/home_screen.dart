import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/city_selection_popup.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/press_rule_header.dart';
import 'package:myapp/widgets/section_header.dart';
import 'package:myapp/widgets/event_cards.dart';
import 'package:myapp/widgets/interpolated_page_indicator.dart';
import 'package:myapp/widgets/themed_network_image.dart';

const Map<String, String> _cityRegions = {
  'Libreville': 'Estuaire',
  'Port-Gentil': 'Ogooué-Maritime',
  'Franceville': 'Haut-Ogooué',
  'Oyem': 'Woleu-Ntem',
  'Lambaréné': 'Moyen-Ogooué',
  'Moanda': 'Haut-Ogooué',
  'Tchibanga': 'Nyanga',
};

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
  final PageController _heroController = PageController(viewportFraction: 0.89);

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'fr_FR';
    _fetchEvents();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
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

  void _showCitySelection(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.4,
          maxChildSize: 0.78,
          expand: false,
          builder: (context, scrollController) {
            return CitySelectionPopup(currentCity: _selectedCity);
          },
        );
      },
    );

    if (result != null && result != _selectedCity) {
      setState(() {
        _selectedCity = result;
        _fetchEvents(city: _selectedCity);
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

  List<Event> _getTrendingEvents() {
    final now = DateTime.now();
    final trending = _allEvents.where((e) => e.startDate.isAfter(now)).toList();
    trending.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return trending.take(4).toList();
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

  void _toggleFavorite(BuildContext context, Event event) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    favoritesProvider.toggleFavorite(event);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favoris mis à jour'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final upcomingEvents = _getUpcomingEvents();
    final popularEvents = _getPopularEvents();
    final trendingEvents = _getTrendingEvents();
    final sportEvents = _getSportEvents();
    final cultureEvents = _getCultureEvents();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: c.acc,
          onRefresh: () => _fetchEvents(),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allEvents.isEmpty
                  ? Center(child: Text('Aucun événement trouvé pour cette ville.', style: TextStyle(color: c.ink2)))
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: AnimationLimiter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) =>
                                SlideAnimation(verticalOffset: 30.0, child: FadeInAnimation(child: widget)),
                            children: [
                              _buildHeader(context),
                              PressRuleHeader(
                                left: DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now()),
                                right: '${_cityRegions[_selectedCity] ?? _selectedCity} · ${_allEvents.length} events',
                              ),
                              const SizedBox(height: 14),
                              _buildSearchBar(),
                              const SizedBox(height: 20),
                              if (popularEvents.isNotEmpty) ...[
                                SectionHeader(title: 'À l\'affiche'),
                                _buildPosterCarousel(context, popularEvents),
                                const SizedBox(height: 8),
                                Center(
                                  child: InterpolatedPageIndicator(controller: _heroController, count: popularEvents.length),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (trendingEvents.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SectionHeader(title: 'Tendances actuelles', trailingLabel: '↗ vues', trailingColor: const Color(0xFFD6006C)),
                                      for (var i = 0; i < trendingEvents.length; i++)
                                        EventTrendingRow(
                                          rank: i + 1,
                                          imageUrl: trendingEvents[i].coverImageUrl,
                                          title: trendingEvents[i].name,
                                          metricLabel: '${trendingEvents[i].viewCount} vues',
                                          date: trendingEvents[i].startDate,
                                          price: trendingEvents[i].minPrice,
                                          onTap: () => context.push('/details', extra: trendingEvents[i]),
                                        ),
                                    ],
                                  ),
                                ),
                              if (upcomingEvents.isNotEmpty)
                                _buildWeekSection(context, 'Cette semaine', null, upcomingEvents),
                              if (cultureEvents.isNotEmpty)
                                _buildWeekSection(context, 'Concerts', () => widget.onNavigate(1), cultureEvents),
                              if (sportEvents.isNotEmpty)
                                _buildWeekSection(context, 'Sport', () => widget.onNavigate(1), sportEvents),
                              if (upcomingEvents.isNotEmpty) _buildCalendarSection(context, upcomingEvents),
                              _buildOrganizerBlock(context),
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
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, AppSpacing.screen, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showCitySelection(context),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: c.line, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIconsRegular.mapPin, size: 18, color: c.acc),
                  const SizedBox(width: 6),
                  Text(
                    _selectedCity,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.ink),
                  ),
                  const SizedBox(width: 4),
                  Icon(PhosphorIconsRegular.caretDown, size: 14, color: c.ink2),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: c.card, shape: BoxShape.circle, border: Border.all(color: c.line, width: 1)),
                  child: Icon(PhosphorIconsRegular.bell, size: 19, color: c.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: GestureDetector(
        onTap: () => widget.onNavigate(1),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: c.line2, width: 1),
          ),
          child: Row(
            children: [
              Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: c.ink3),
              const SizedBox(width: 10),
              Text('Concert, match, festival…', style: TextStyle(fontSize: 15, color: c.ink3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterCarousel(BuildContext context, List<Event> events) {
    return SizedBox(
      height: 340,
      child: PageView.builder(
        controller: _heroController,
        padEnds: false,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final isNew = index == 0;
          final isAlmostFull = event.availableSeats > 0 && event.availableSeats < (event.totalSeats * 0.15);
          return Padding(
            padding: const EdgeInsets.only(left: AppSpacing.screen, right: 6),
            child: EventPosterCard(
              imageUrl: event.coverImageUrl,
              category: event.categoryDisplayName,
              title: event.name,
              venue: event.venueName,
              date: event.startDate,
              price: event.minPrice,
              interestedCount: event.favoriteCount,
              badgeLabel: isAlmostFull ? 'Presque complet' : (isNew ? 'Nouveau' : null),
              badgeIsWarning: isAlmostFull,
              isFavorite: context.watch<FavoritesProvider>().isFavorite(event),
              onFavoriteToggle: () => _toggleFavorite(context, event),
              onTap: () => context.push('/details', extra: event),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekSection(BuildContext context, String title, VoidCallback? onSeeAll, List<Event> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: SectionHeader(title: title, trailingLabel: onSeeAll != null ? 'Tout voir' : null, onTrailingTap: onSeeAll),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: EventWeekCard(
                  imageUrl: event.coverImageUrl,
                  title: event.name,
                  venue: event.venueName,
                  date: event.startDate,
                  price: event.minPrice,
                  isFavorite: context.watch<FavoritesProvider>().isFavorite(event),
                  onFavoriteToggle: () => _toggleFavorite(context, event),
                  onTap: () => context.push('/details', extra: event),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection(BuildContext context, List<Event> events) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Le calendrier'),
          for (final event in events.take(6))
            GestureDetector(
              onTap: () => context.push('/details', extra: event),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line, width: 1))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Column(
                        children: [
                          Text(DateFormat('d').format(event.startDate),
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: c.ink)),
                          Text(DateFormat('MMM', 'fr_FR').format(event.startDate).toUpperCase(),
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: c.ink3)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 42, color: c.line, margin: const EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(DateFormat('HH:mm').format(event.startDate), style: TextStyle(fontSize: 12.5, color: c.ink2)),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      child: SizedBox(width: 58, height: 58, child: ThemedNetworkImage(url: event.coverImageUrl)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrganizerBlock(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, AppSpacing.screen, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surf,
          border: Border.all(color: c.line2, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text('Vous organisez un événement ?', style: Theme.of(context).textTheme.titleSmall),
            ),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Créer un événement')),
          ],
        ),
      ),
    );
  }
}

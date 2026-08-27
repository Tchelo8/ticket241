import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/models/category_model.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/app_bottom_sheet.dart';
import 'package:myapp/widgets/event_cards.dart';
import 'package:myapp/widgets/filter_sheet.dart';
import 'package:myapp/widgets/pill_chip.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => ExplorerScreenState();
}

class ExplorerScreenState extends State<ExplorerScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Event> _allEvents = [];
  List<Category> _categories = [];
  bool _isLoadingEvents = true;
  bool _isLoadingCategories = true;
  final String _selectedCity = 'Libreville';

  List<Event> _filteredEvents = [];
  ExplorerFilters _filters = const ExplorerFilters();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      _filteredEvents = filterEvents(_allEvents, searchQuery: _searchQuery, filters: _filters);
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _filters = _filters.copyWith(category: () => category);
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await AppBottomSheet.show<ExplorerFilters>(
      context: context,
      kicker: 'Affiner',
      title: 'Filtres',
      child: FilterSheetContent(
        allEvents: _allEvents,
        searchQuery: _searchQuery,
        categories: _categories,
        initialFilters: _filters,
      ),
    );
    if (result != null) {
      setState(() {
        _filters = result;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isLoading = _isLoadingEvents || _isLoadingCategories;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(context),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEvents.isEmpty
                      ? _buildNoResults(context)
                      : _buildEventsGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    final c = context.appColors;
    return Container(
      color: c.bg,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, AppSpacing.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explorer', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: c.line2, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: c.ink3),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            border: InputBorder.none,
                            isDense: true,
                            filled: false,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          child: Icon(PhosphorIconsRegular.x, size: 16, color: c.ink3),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _openFilterSheet,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _filters.activeCount > 0 ? c.accs : c.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: _filters.activeCount > 0 ? c.acc : c.line2, width: 1),
                      ),
                      child: Icon(PhosphorIconsRegular.slidersHorizontal, size: 19,
                          color: _filters.activeCount > 0 ? c.acc : c.ink),
                    ),
                    if (_filters.activeCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFD6006C), shape: BoxShape.circle),
                          child: Text('${_filters.activeCount}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingCategories)
            const SizedBox(height: 38)
          else
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  PillChip(
                    label: 'Tous',
                    icon: PhosphorIconsRegular.squaresFour,
                    selected: _filters.category == null,
                    onTap: () => _onCategorySelected(null),
                  ),
                  const SizedBox(width: 8),
                  for (final cat in _categories) ...[
                    PillChip(
                      label: cat.displayName,
                      selected: _filters.category?.toUpperCase() == cat.name.toUpperCase(),
                      onTap: () => _onCategorySelected(cat.name),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_filteredEvents.length} événements · $_selectedCity', style: TextStyle(fontSize: 12.5, color: c.ink3)),
              GestureDetector(
                onTap: _openFilterSheet,
                child: Text(_sortLabel(_filters.sort),
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.acc)),
              ),
            ],
          ),
          if (_filters.activeCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_filters.category != null)
                      _activePill(_filters.category!, () => _onCategorySelected(null)),
                    if (_filters.when != ExplorerWhen.all)
                      _activePill(_whenLabel(_filters.when), () => setState(() {
                            _filters = _filters.copyWith(when: ExplorerWhen.all);
                            _applyFilters();
                          })),
                    if (_filters.priceMax < 20000)
                      _activePill('≤ ${_filters.priceMax} FCFA', () => setState(() {
                            _filters = _filters.copyWith(priceMax: 20000);
                            _applyFilters();
                          })),
                    if (_filters.refundableOnly)
                      _activePill('Annulation gratuite', () => setState(() {
                            _filters = _filters.copyWith(refundableOnly: false);
                            _applyFilters();
                          })),
                    GestureDetector(
                      onTap: () => setState(() {
                        _filters = const ExplorerFilters();
                        _applyFilters();
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('Tout effacer', style: TextStyle(fontSize: 12.5, color: c.ink3, decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _activePill(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PillChip(label: label, style: PillChipStyle.activeFilter, onRemove: onRemove),
    );
  }

  String _sortLabel(ExplorerSort sort) {
    switch (sort) {
      case ExplorerSort.dateAsc:
        return 'Date · les plus proches';
      case ExplorerSort.priceAsc:
        return 'Prix croissant';
      case ExplorerSort.popularity:
        return 'Popularité';
    }
  }

  String _whenLabel(ExplorerWhen when) {
    switch (when) {
      case ExplorerWhen.all:
        return 'Tous';
      case ExplorerWhen.thisMonth:
        return 'Ce mois-ci';
      case ExplorerWhen.nextMonth:
        return 'Le mois prochain';
      case ExplorerWhen.later:
        return 'Plus tard';
    }
  }

  Widget _buildNoResults(BuildContext context) {
    final c = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.magnifyingGlass, size: 56, color: c.ink3),
            const SizedBox(height: 16),
            Text('Aucun événement ne correspond', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Essayez d\'élargir le budget ou de retirer un filtre.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: c.ink2)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => setState(() {
                _filters = const ExplorerFilters();
                _searchController.clear();
                _searchQuery = '';
                _applyFilters();
              }),
              child: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsGrid(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 4, AppSpacing.screen, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.cardGapMin,
        mainAxisSpacing: AppSpacing.cardGapMin,
        childAspectRatio: 0.66,
      ),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        final isPast = DateTime.now().isAfter(event.startDate);
        return EventGridCard(
          imageUrl: event.coverImageUrl,
          title: event.name,
          venue: event.venueName,
          date: event.startDate,
          price: event.minPrice,
          isPast: isPast,
          isFavorite: favoritesProvider.isFavorite(event),
          onFavoriteToggle: () => favoritesProvider.toggleFavorite(event),
          onTap: () => context.push('/details', extra: event),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/category_model.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import 'pill_chip.dart';
import 'toggle_switch.dart';

enum ExplorerWhen { all, thisMonth, nextMonth, later }

enum ExplorerSort { dateAsc, priceAsc, popularity }

/// État des filtres de la feuille "Affiner" — le prototype les nomme
/// budget/quand/catégorie/tri/annulation (README, "État").
class ExplorerFilters {
  final int priceMax;
  final ExplorerWhen when;
  final String? category;
  final ExplorerSort sort;
  final bool refundableOnly;

  const ExplorerFilters({
    this.priceMax = 20000,
    this.when = ExplorerWhen.all,
    this.category,
    this.sort = ExplorerSort.dateAsc,
    this.refundableOnly = false,
  });

  int get activeCount =>
      (priceMax < 20000 ? 1 : 0) +
      (when != ExplorerWhen.all ? 1 : 0) +
      (category != null ? 1 : 0) +
      (refundableOnly ? 1 : 0);

  ExplorerFilters copyWith({
    int? priceMax,
    ExplorerWhen? when,
    String? Function()? category,
    ExplorerSort? sort,
    bool? refundableOnly,
  }) {
    return ExplorerFilters(
      priceMax: priceMax ?? this.priceMax,
      when: when ?? this.when,
      category: category != null ? category() : this.category,
      sort: sort ?? this.sort,
      refundableOnly: refundableOnly ?? this.refundableOnly,
    );
  }
}

/// Applique recherche + filtres à une liste d'événements, utilisé à la fois
/// par ExplorerScreen (résultat affiché) et par la feuille de filtres
/// (aperçu "Voir N événements").
List<Event> filterEvents(
  List<Event> events, {
  required String searchQuery,
  required ExplorerFilters filters,
}) {
  final now = DateTime.now();
  final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
  final startOfMonthAfterNext = DateTime(now.year, now.month + 2, 1);

  var results = events.where((e) {
    final categoryMatch = filters.category == null || e.category.toUpperCase() == filters.category!.toUpperCase();
    final queryMatch = searchQuery.isEmpty || e.name.toLowerCase().contains(searchQuery.toLowerCase());
    final priceMatch = e.minPrice <= filters.priceMax;
    final refundMatch = !filters.refundableOnly || e.allowRefund;
    bool whenMatch;
    switch (filters.when) {
      case ExplorerWhen.all:
        whenMatch = true;
        break;
      case ExplorerWhen.thisMonth:
        whenMatch = e.startDate.isBefore(startOfNextMonth);
        break;
      case ExplorerWhen.nextMonth:
        whenMatch = !e.startDate.isBefore(startOfNextMonth) && e.startDate.isBefore(startOfMonthAfterNext);
        break;
      case ExplorerWhen.later:
        whenMatch = !e.startDate.isBefore(startOfMonthAfterNext);
        break;
    }
    return categoryMatch && queryMatch && priceMatch && refundMatch && whenMatch;
  }).toList();

  switch (filters.sort) {
    case ExplorerSort.dateAsc:
      results.sort((a, b) => a.startDate.compareTo(b.startDate));
      break;
    case ExplorerSort.priceAsc:
      results.sort((a, b) => a.minPrice.compareTo(b.minPrice));
      break;
    case ExplorerSort.popularity:
      results.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      break;
  }
  return results;
}

/// Contenu de la feuille "Affiner" (README écran 8).
class FilterSheetContent extends StatefulWidget {
  final List<Event> allEvents;
  final String searchQuery;
  final List<Category> categories;
  final ExplorerFilters initialFilters;

  const FilterSheetContent({
    super.key,
    required this.allEvents,
    required this.searchQuery,
    required this.categories,
    required this.initialFilters,
  });

  @override
  State<FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<FilterSheetContent> {
  late ExplorerFilters _filters = widget.initialFilters;

  int get _resultCount => filterEvents(widget.allEvents, searchQuery: widget.searchQuery, filters: _filters).length;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, 'Budget maximum'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_filters.priceMax} FCFA',
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: c.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text('$_resultCount événements', style: TextStyle(fontSize: 13, color: c.ink3)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: c.acc,
            inactiveTrackColor: c.line2,
            thumbColor: c.acc,
            overlayColor: c.accs,
          ),
          child: Slider(
            value: _filters.priceMax.toDouble(),
            min: 2000,
            max: 20000,
            divisions: 18,
            onChanged: (v) => setState(() => _filters = _filters.copyWith(priceMax: v.round())),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('2 000 FCFA', style: TextStyle(fontSize: 11.5, color: c.ink3)),
            Text('20 000 FCFA', style: TextStyle(fontSize: 11.5, color: c.ink3)),
          ],
        ),
        const SizedBox(height: 20),
        _label(context, 'Quand'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _whenPill('Tous', ExplorerWhen.all),
            _whenPill('Ce mois-ci', ExplorerWhen.thisMonth),
            _whenPill('Le mois prochain', ExplorerWhen.nextMonth),
            _whenPill('Plus tard', ExplorerWhen.later),
          ],
        ),
        const SizedBox(height: 20),
        _label(context, 'Catégorie'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PillChip(
              label: 'Tous',
              selected: _filters.category == null,
              onTap: () => setState(() => _filters = _filters.copyWith(category: () => null)),
            ),
            for (final cat in widget.categories)
              PillChip(
                label: cat.displayName,
                selected: _filters.category?.toUpperCase() == cat.name.toUpperCase(),
                onTap: () => setState(() => _filters = _filters.copyWith(category: () => cat.name)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _label(context, 'Trier par'),
        _sortOption(context, 'Date · les plus proches', ExplorerSort.dateAsc),
        _sortOption(context, 'Prix croissant', ExplorerSort.priceAsc),
        _sortOption(context, 'Popularité', ExplorerSort.popularity),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Annulation gratuite', style: Theme.of(context).textTheme.titleSmall),
            ToggleSwitch(
              value: _filters.refundableOnly,
              onChanged: (v) => setState(() => _filters = _filters.copyWith(refundableOnly: v)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _filters = const ExplorerFilters()),
                child: const Text('Réinitialiser'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_filters),
                child: Text(_resultCount == 0 ? 'Aucun résultat' : 'Voir $_resultCount événements'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String text) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: c.acc),
      ),
    );
  }

  Widget _whenPill(String label, ExplorerWhen value) {
    return PillChip(
      label: label,
      selected: _filters.when == value,
      onTap: () => setState(() => _filters = _filters.copyWith(when: value)),
    );
  }

  Widget _sortOption(BuildContext context, String label, ExplorerSort value) {
    final c = context.appColors;
    final selected = _filters.sort == value;
    return GestureDetector(
      onTap: () => setState(() => _filters = _filters.copyWith(sort: value)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
              size: 20,
              color: selected ? c.acc : c.line2,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? c.acc : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

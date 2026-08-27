import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:myapp/models/event_model.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/empty_state_template.dart';
import 'package:myapp/widgets/themed_network_image.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final favoriteEvents = favoritesProvider.favorites;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 12),
              child: Text('Favoris', style: Theme.of(context).textTheme.headlineMedium),
            ),
            Expanded(
              child: favoriteEvents.isEmpty
                  ? Center(
                      child: EmptyStateTemplate(
                        lottieAsset: 'assets/animations/nofav.json',
                        titleLine1: 'Rien de gardé',
                        titleLine2: 'pour l\'instant.',
                        body: 'Ajoutez des événements à vos favoris pour les retrouver ici.',
                        primaryLabel: 'Explorer les événements',
                        primaryIcon: PhosphorIconsRegular.compass,
                        onPrimary: () => context.go('/app'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 24),
                      itemCount: favoriteEvents.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _FavoriteCard(event: favoriteEvents[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Event event;
  const _FavoriteCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(event);

    return GestureDetector(
      onTap: () => context.push('/details', extra: event),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: c.line, width: 1),
          boxShadow: context.tokens.shadows.sh,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ThemedNetworkImage(url: event.coverImageUrl),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => favoritesProvider.toggleFavorite(event),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: Color(0x70100F0E), shape: BoxShape.circle),
                          child: Icon(
                            isFavorite ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                            color: isFavorite ? const Color(0xFFD6006C) : Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMM yyyy', 'fr_FR').format(event.startDate).toUpperCase(),
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: c.acc),
                  ),
                  const SizedBox(height: 4),
                  Text(event.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, color: c.ink)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(PhosphorIconsRegular.mapPin, size: 14, color: c.ink3),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text('${event.venueName}, ${event.cityName}',
                                  style: TextStyle(fontSize: 12, color: c.ink2), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      Text('${event.minPrice.toStringAsFixed(0)} FCFA',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

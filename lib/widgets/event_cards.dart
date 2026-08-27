import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import 'themed_network_image.dart';

String _formatPrice(num price) {
  final formatted = NumberFormat.decimalPattern('fr_FR').format(price);
  return '$formatted FCFA';
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final double size;

  const _FavoriteButton({required this.isFavorite, required this.onTap, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Color(0x70100F0E), shape: BoxShape.circle),
        child: Icon(
          isFavorite ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
          size: size * 0.5,
          color: isFavorite ? const Color(0xFFD6006C) : Colors.white,
        ),
      ),
    );
  }
}

/// Carte affiche du carrousel "À l'affiche" — 349px de large.
class EventPosterCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String venue;
  final DateTime date;
  final num price;
  final int interestedCount;
  final String? badgeLabel;
  final bool badgeIsWarning;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const EventPosterCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.venue,
    required this.date,
    required this.price,
    this.interestedCount = 0,
    this.badgeLabel,
    this.badgeIsWarning = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 349,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.poster),
              child: SizedBox(
                height: 236,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ThemedNetworkImage(url: imageUrl),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [const Color(0xDC0C0B0A), const Color(0xDC0C0B0A).withValues(alpha: 0)],
                          stops: const [0, 0.7],
                        ),
                      ),
                    ),
                    if (badgeLabel != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeIsWarning ? const Color(0xFFD6006C) : c.acc,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            badgeLabel!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('d').format(date),
                              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Color(0xFF201E1D), height: 1),
                            ),
                            Text(
                              DateFormat('MMM', 'fr_FR').format(date).toUpperCase(),
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: c.acc),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: c.accd),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w600, height: 1.08, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(venue, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 22,
                  child: Stack(
                    children: List.generate(3, (i) {
                      return Positioned(
                        left: i * 12.0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: c.accs,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.card, width: 1.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('$interestedCount intéressés', style: TextStyle(fontSize: 12, color: c.ink3)),
                ),
                Text(
                  'dès ${_formatPrice(price)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de rangée horizontale (Cette semaine, Concerts, Sport) — 214px.
class EventWeekCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String venue;
  final DateTime date;
  final num price;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const EventWeekCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.venue,
    required this.date,
    required this.price,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 214,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: SizedBox(
                height: 132,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ThemedNetworkImage(url: imageUrl),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteToggle),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('E d MMM', 'fr_FR').format(date).toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: c.acc),
            ),
            const SizedBox(height: 2),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(venue, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: c.ink2)),
            const SizedBox(height: 4),
            Text(_formatPrice(price), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink)),
          ],
        ),
      ),
    );
  }
}

/// Carte de grille Explorer — 2 colonnes.
class EventGridCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String venue;
  final DateTime date;
  final num price;
  final bool isFavorite;
  final bool isPast;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const EventGridCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.venue,
    required this.date,
    required this.price,
    this.isFavorite = false,
    this.isPast = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: isPast ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: SizedBox(
              height: 118,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ThemedNetworkImage(url: imageUrl),
                  if (isPast)
                    Positioned.fill(
                      child: Container(color: const Color(0x800C0B0A)),
                    ),
                  if (isPast)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFD6006C), borderRadius: BorderRadius.circular(3)),
                        child: const Text('PASSÉ',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  if (!isPast)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteToggle, size: 28),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('d MMM', 'fr_FR').format(date).toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c.acc),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 35,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(venue, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: c.ink2)),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(height: 1, color: c.line),
          ),
          const SizedBox(height: 6),
          Text(_formatPrice(price), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink)),
        ],
      ),
    );
  }
}

/// Ligne de classement "Tendances actuelles".
class EventTrendingRow extends StatelessWidget {
  final int rank;
  final String imageUrl;
  final String title;
  final String trendPercent;
  final DateTime date;
  final num price;
  final VoidCallback? onTap;

  const EventTrendingRow({
    super.key,
    required this.rank,
    required this.imageUrl,
    required this.title,
    required this.trendPercent,
    required this.date,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line, width: 1))),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text('$rank', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: c.ink3)),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.control),
              child: SizedBox(width: 52, height: 52, child: ThemedNetworkImage(url: imageUrl)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(trendPercent,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD6006C))),
                      const SizedBox(width: 6),
                      Text(DateFormat('d MMM', 'fr_FR').format(date), style: TextStyle(fontSize: 12, color: c.ink3)),
                    ],
                  ),
                ],
              ),
            ),
            Text(_formatPrice(price), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink)),
          ],
        ),
      ),
    );
  }
}

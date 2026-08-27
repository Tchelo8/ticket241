import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../theme/themed_image.dart';

/// "Le lieu" (README, Détail d'un événement) : carte 132px avec une épingle
/// magenta au centre, puis le nom, l'adresse et le bouton "Y aller".
class EventLocationCard extends StatelessWidget {
  final String venueName;
  final String venueAddress;

  const EventLocationCard({super.key, required this.venueName, required this.venueAddress});

  Future<void> _openDirections() async {
    final uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': venueAddress});
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Le lieu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: SizedBox(
              height: 132,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  ThemedImage(child: Image.asset('assets/images/map.jpg', fit: BoxFit.cover)),
                  Icon(PhosphorIconsFill.mapPin, size: 34, color: const Color(0xFFD6006C)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(venueName, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: c.ink)),
          const SizedBox(height: 2),
          Text(venueAddress, style: TextStyle(fontSize: 13, color: c.ink2)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _openDirections,
              icon: Icon(PhosphorIconsRegular.navigationArrow, size: 18, color: c.acc),
              label: Text('Y aller', style: TextStyle(color: c.acc)),
            ),
          ),
        ],
      ),
    );
  }
}

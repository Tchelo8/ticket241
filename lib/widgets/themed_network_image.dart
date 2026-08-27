import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';
import '../theme/themed_image.dart';

/// Image réseau avec le filtre du thème courant (Encre/N&B), un shimmer
/// pendant le chargement et une image locale de repli en cas d'erreur.
class ThemedNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final String fallbackAsset;

  const ThemedNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/images/enb.jpg',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return ThemedImage(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, _) => Shimmer.fromColors(
          baseColor: c.surf,
          highlightColor: c.card,
          child: Container(color: c.surf),
        ),
        errorWidget: (context, _, __) => Image.asset(fallbackAsset, fit: fit),
      ),
    );
  }
}

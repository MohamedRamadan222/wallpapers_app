import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';
import '../detail/wallpaper_detail_screen.dart';

/// Masonry card from the Home/Saved grids: pure photo, no chrome.
/// Titles live on the detail screen. Offline or failed loads degrade to a
/// neutral gradient, mirroring the prototype's `.img-fallback`.
class WallpaperCard extends StatelessWidget {
  const WallpaperCard({super.key, required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showWallpaperDetail(context, wallpaper),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: wallpaper.tall ? 3 / 4.4 : 3 / 4,
          child: Image.network(
            wallpaper.thumbUrl,
            fit: BoxFit.cover,
            semanticLabel: '${wallpaper.title} wallpaper',
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const ColoredBox(color: AppColors.surface2);
            },
            errorBuilder: (_, _, _) {
              return const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.cardFallback),
              );
            },
          ),
        ),
      ),
    );
  }
}

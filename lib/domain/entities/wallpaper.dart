import 'package:equatable/equatable.dart';

/// Browseable wallpaper categories. Each maps to a Pexels search term.
enum WallpaperCategory {
  nature,
  abstract,
  minimal,
  amoled,
  gradient,
  architecture,
}

extension WallpaperCategoryX on WallpaperCategory {
  String get label => switch (this) {
    WallpaperCategory.nature => 'Nature',
    WallpaperCategory.abstract => 'Abstract',
    WallpaperCategory.minimal => 'Minimal',
    WallpaperCategory.amoled => 'AMOLED',
    WallpaperCategory.gradient => 'Gradient',
    WallpaperCategory.architecture => 'Architecture',
  };

  /// Search term sent to Pexels for this category.
  String get query => switch (this) {
    WallpaperCategory.nature => 'nature',
    WallpaperCategory.abstract => 'abstract',
    WallpaperCategory.minimal => 'minimalist',
    WallpaperCategory.amoled => 'dark black',
    WallpaperCategory.gradient => 'gradient',
    WallpaperCategory.architecture => 'architecture',
  };
}

/// A wallpaper photo served by Pexels.
class Wallpaper extends Equatable {
  const Wallpaper({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.tall,
    required this.thumbUrl,
    required this.fullUrl,
    required this.actionUrl,
    required this.width,
    required this.height,
  });

  final String id;
  final String title;
  final String author;
  final WallpaperCategory category;
  final bool tall;
  final String thumbUrl;
  final String fullUrl;
  final String actionUrl;
  final int width;
  final int height;

  /// Real photo facts for the detail meta row (replaces prototype filler).
  String get metaLine => '$width × $height';

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    category,
    tall,
    thumbUrl,
    fullUrl,
    actionUrl,
    width,
    height,
  ];
}

/// One page of browse results. `hasMore` follows the API's `next_page`.
class WallpaperPage extends Equatable {
  const WallpaperPage({required this.items, required this.hasMore});

  final List<Wallpaper> items;
  final bool hasMore;

  @override
  List<Object?> get props => [items, hasMore];
}

/// A row on the Categories screen. Count and thumb come from live search.
class CategoryInfo extends Equatable {
  const CategoryInfo({
    required this.category,
    required this.wallpaperCount,
    required this.thumbUrl,
  });

  final WallpaperCategory category;
  final int wallpaperCount;
  final String thumbUrl;

  String get name => category.label;
  String get countLabel => '$wallpaperCount wallpapers';

  @override
  List<Object?> get props => [category, wallpaperCount, thumbUrl];
}

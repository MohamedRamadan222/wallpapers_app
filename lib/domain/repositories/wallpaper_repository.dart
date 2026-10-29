import '../entities/wallpaper.dart';

/// Single source of wallpaper data for the app. Reads live from Pexels;
/// swapping in another backend keeps every caller unchanged.
abstract interface class WallpaperRepository {
  Future<WallpaperPage> getCurated({int page = 1});
  Future<WallpaperPage> searchWallpapers({
    String query = '',
    WallpaperCategory? category,
    int page = 1,
  });
  Future<List<CategoryInfo>> getCategories();
  Future<List<Wallpaper>> getFavorites();
  Future<List<Wallpaper>> toggleFavorite(Wallpaper wallpaper);
}

import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/pexels_remote_data_source.dart';
import '../stores/favorites_store.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  const WallpaperRepositoryImpl({
    required this.remote,
    required this.favorites,
  });

  final PexelsRemoteDataSource remote;
  final FavoritesStore favorites;

  @override
  Future<WallpaperPage> getCurated({int page = 1}) async {
    final result = await remote.curated(page: page);
    return WallpaperPage(items: result.photos, hasMore: result.hasMore);
  }

  @override
  Future<WallpaperPage> searchWallpapers({
    String query = '',
    WallpaperCategory? category,
    int page = 1,
  }) async {
    final terms = [
      if (category != null) category.query,
      query.trim(),
    ].where((term) => term.isNotEmpty).join(' ');
    if (terms.isEmpty) return getCurated(page: page);
    final result = await remote.search(terms, page: page);
    return WallpaperPage(items: result.photos, hasMore: result.hasMore);
  }

  @override
  Future<List<CategoryInfo>> getCategories() async {
    final rows = await Future.wait(
      WallpaperCategory.values.map((category) async {
        final result = await remote.search(category.query, perPage: 1);
        return CategoryInfo(
          category: category,
          wallpaperCount: result.total,
          thumbUrl: result.photos.isEmpty ? '' : result.photos.first.thumbUrl,
        );
      }),
    );
    return rows;
  }

  @override
  Future<List<Wallpaper>> getFavorites() async => favorites.all();

  @override
  Future<List<Wallpaper>> toggleFavorite(Wallpaper wallpaper) async {
    return favorites.toggle(wallpaper);
  }
}

import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';

class GetWallpapers {
  const GetWallpapers(this._repository);
  final WallpaperRepository _repository;

  Future<WallpaperPage> call({int page = 1}) {
    return _repository.getCurated(page: page);
  }
}

class SearchWallpapers {
  const SearchWallpapers(this._repository);
  final WallpaperRepository _repository;

  Future<WallpaperPage> call({
    String query = '',
    WallpaperCategory? category,
    int page = 1,
  }) {
    return _repository.searchWallpapers(
      query: query,
      category: category,
      page: page,
    );
  }
}

class GetCategories {
  const GetCategories(this._repository);
  final WallpaperRepository _repository;

  Future<List<CategoryInfo>> call() => _repository.getCategories();
}

class GetFavorites {
  const GetFavorites(this._repository);
  final WallpaperRepository _repository;

  Future<List<Wallpaper>> call() => _repository.getFavorites();
}

class ToggleFavorite {
  const ToggleFavorite(this._repository);
  final WallpaperRepository _repository;

  /// Toggles the saved state of [wallpaper] and returns updated favorites.
  Future<List<Wallpaper>> call(Wallpaper wallpaper) {
    return _repository.toggleFavorite(wallpaper);
  }
}

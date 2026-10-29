import '../../domain/entities/wallpaper.dart';

/// In-memory saved set, keyed by photo id. Favorites hold full [Wallpaper]
/// values so the Saved tab works without refetching the catalog.
class FavoritesStore {
  final Map<String, Wallpaper> _items = {};

  List<Wallpaper> all() => _items.values.toList();

  List<Wallpaper> toggle(Wallpaper wallpaper) {
    if (_items.remove(wallpaper.id) == null) _items[wallpaper.id] = wallpaper;
    return all();
  }
}

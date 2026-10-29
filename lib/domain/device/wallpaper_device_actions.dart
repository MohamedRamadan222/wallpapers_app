/// Where a wallpaper should be applied on Android.
/// iOS exposes no wallpaper API; [both] and [lock] degrade gracefully there.
enum WallpaperTarget { home, lock, both }

/// Native device actions. Android implements set + save; iOS implements
/// save only (the OS reserves wallpaper changes to the user in Settings).
abstract interface class WallpaperDeviceActions {
  Future<void> setWallpaper({
    required String imageUrl,
    required String title,
    required WallpaperTarget target,
  });

  Future<void> saveToGallery({required String imageUrl, required String title});
}

import '../../domain/device/wallpaper_device_actions.dart';
import '../../domain/entities/wallpaper.dart';

class SetWallpaper {
  const SetWallpaper(this._actions);

  final WallpaperDeviceActions _actions;

  Future<void> call(
    Wallpaper wallpaper, {
    WallpaperTarget target = WallpaperTarget.both,
  }) {
    return _actions.setWallpaper(
      imageUrl: wallpaper.actionUrl,
      title: wallpaper.title,
      target: target,
    );
  }
}

class SaveToGallery {
  const SaveToGallery(this._actions);

  final WallpaperDeviceActions _actions;

  Future<void> call(Wallpaper wallpaper) {
    return _actions.saveToGallery(
      imageUrl: wallpaper.actionUrl,
      title: wallpaper.title,
    );
  }
}
